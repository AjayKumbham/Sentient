import logging
from typing import AsyncGenerator, Optional, Union, Tuple
import numpy as np
from .base import BaseTTS, TTSOptionsBase
from main.config import AZURE_SPEECH_KEY, AZURE_SPEECH_REGION

try:
    import azure.cognitiveservices.speech as speechsdk
    AZURE_AVAILABLE = True
except ImportError:
    AZURE_AVAILABLE = False
    speechsdk = None

logger = logging.getLogger(__name__)

class AzureTTS(BaseTTS):
    """
    Microsoft Azure Text-to-Speech implementation (English only).
    Uses high-quality neural voice synthesis.
    """
    def __init__(self):
        if not AZURE_AVAILABLE:
            raise ImportError("Azure Speech SDK not installed. Install: pip install azure-cognitiveservices-speech")
        if not AZURE_SPEECH_KEY:
            raise ValueError("AZURE_SPEECH_KEY is required for AzureTTS.")
        if not AZURE_SPEECH_REGION:
            raise ValueError("AZURE_SPEECH_REGION is required for AzureTTS.")
        
        try:
            # Create speech config
            self.speech_config = speechsdk.SpeechConfig(
                subscription=AZURE_SPEECH_KEY,
                region=AZURE_SPEECH_REGION
            )
            
            # Use high-quality English neural voice (JennyNeural - natural female)
            # Alternative: "en-US-GuyNeural" for male voice
            self.speech_config.speech_synthesis_voice_name = "en-US-JennyNeural"
            
            # Set output format to 16kHz PCM for voice applications
            self.speech_config.set_speech_synthesis_output_format(
                speechsdk.SpeechSynthesisOutputFormat.Raw16Khz16BitMonoPcm
            )
            
            logger.info(f"AzureTTS initialized successfully for region: {AZURE_SPEECH_REGION}")
        except Exception as e:
            logger.error(f"Failed to initialize Azure TTS config: {e}", exc_info=True)
            raise

    async def stream_tts(
        self, 
        text: str, 
        language: Optional[str] = "en", 
        options: TTSOptionsBase = None
    ) -> AsyncGenerator[Union[bytes, Tuple[int, np.ndarray]], None]:
        """
        Synthesize English speech from text using Azure Neural TTS.
        
        Args:
            text: Text to synthesize
            language: Ignored (English only)
            options: Ignored
            
        Yields:
            Tuple of (sample_rate, audio_array) - audio_array is float32 numpy array
        """
        logger.info(f"Synthesizing: '{text[:100]}...'")
        
        try:
            # Create synthesizer with null output (we handle the audio data)
            synthesizer = speechsdk.SpeechSynthesizer(
                speech_config=self.speech_config,
                audio_config=None
            )
            
            # Perform synthesis
            result = synthesizer.speak_text_async(text).get()
            
            # Process result
            if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
                audio_data = result.audio_data
                
                if audio_data and len(audio_data) > 0:
                    # Convert 16-bit PCM to float32 numpy array
                    audio_array = np.frombuffer(audio_data, dtype=np.int16)
                    audio_float = audio_array.astype(np.float32) / 32768.0
                    
                    # Sample rate is 16kHz
                    sample_rate = 16000
                    
                    logger.info(f"✓ Synthesized {len(audio_float)} samples at {sample_rate}Hz")
                    yield (sample_rate, audio_float)
                else:
                    logger.warning("No audio data generated")
            
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation = result.cancellation_details
                logger.error(f"Synthesis canceled: {cancellation.reason}")
                if cancellation.reason == speechsdk.CancellationReason.Error:
                    logger.error(f"Error: {cancellation.error_details}")
            
            else:
                logger.warning(f"Unexpected result: {result.reason}")
        
        except Exception as e:
            logger.error(f"Exception during synthesis: {e}", exc_info=True)
