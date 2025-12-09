import logging
from typing import Tuple, Optional
from .base import BaseSTT
from main.config import AZURE_SPEECH_KEY, AZURE_SPEECH_REGION

try:
    import azure.cognitiveservices.speech as speechsdk
    AZURE_AVAILABLE = True
except ImportError:
    AZURE_AVAILABLE = False
    speechsdk = None

logger = logging.getLogger(__name__)

class AzureSTT(BaseSTT):
    """
    Microsoft Azure Speech-to-Text implementation (English only).
    Follows Azure best practices for real-time speech recognition.
    """
    def __init__(self):
        if not AZURE_AVAILABLE:
            raise ImportError("Azure Speech SDK not installed. Install: pip install azure-cognitiveservices-speech")
        if not AZURE_SPEECH_KEY:
            raise ValueError("AZURE_SPEECH_KEY is required for AzureSTT.")
        if not AZURE_SPEECH_REGION:
            raise ValueError("AZURE_SPEECH_REGION is required for AzureSTT.")
        
        try:
            # Create speech config
            self.speech_config = speechsdk.SpeechConfig(
                subscription=AZURE_SPEECH_KEY,
                region=AZURE_SPEECH_REGION
            )
            
            # Set to English (US) only
            self.speech_config.speech_recognition_language = "en-US"
            
            # Enable profanity masking
            self.speech_config.set_profanity(speechsdk.ProfanityOption.Masked)
            
            # Use detailed output format for better results
            self.speech_config.output_format = speechsdk.OutputFormat.Detailed
            
            logger.info(f"AzureSTT initialized successfully for region: {AZURE_SPEECH_REGION}")
        except Exception as e:
            logger.error(f"Failed to initialize Azure Speech config: {e}", exc_info=True)
            raise

    async def transcribe(self, audio_bytes: bytes, sample_rate: int) -> Tuple[str, Optional[str]]:
        """
        Transcribe English audio using Azure Speech Service.
        
        Args:
            audio_bytes: Raw PCM audio data (16-bit signed integer, mono)
            sample_rate: Sample rate in Hz
            
        Returns:
            Tuple of (transcription_text, "en-US")
        """
        logger.info(f"Transcribing {len(audio_bytes)} bytes at {sample_rate}Hz")
        
        try:
            # Create audio format (16-bit PCM, mono)
            audio_format = speechsdk.audio.AudioStreamFormat(
                samples_per_second=sample_rate,
                bits_per_sample=16,
                channels=1
            )
            
            # Create and populate push stream
            push_stream = speechsdk.audio.PushAudioInputStream(stream_format=audio_format)
            push_stream.write(audio_bytes)
            push_stream.close()
            
            # Create audio config
            audio_config = speechsdk.audio.AudioConfig(stream=push_stream)
            
            # Create recognizer
            speech_recognizer = speechsdk.SpeechRecognizer(
                speech_config=self.speech_config,
                audio_config=audio_config
            )
            
            # Perform recognition
            result = speech_recognizer.recognize_once()
            
            # Handle result
            if result.reason == speechsdk.ResultReason.RecognizedSpeech:
                transcript = result.text.strip()
                logger.info(f"✓ Transcribed: '{transcript[:100]}...'")
                return transcript, "en-US"
            
            elif result.reason == speechsdk.ResultReason.NoMatch:
                # Note: NoMatchDetails has a bug in some SDK versions, so we skip it
                logger.warning("No speech recognized")
                return "", None
            
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation = result.cancellation_details
                logger.error(f"Recognition canceled: {cancellation.reason}")
                if cancellation.reason == speechsdk.CancellationReason.Error:
                    logger.error(f"Error: {cancellation.error_details}")
                return "", None
            
            else:
                logger.warning(f"Unexpected result: {result.reason}")
                return "", None

        except Exception as e:
            logger.error(f"Exception during transcription: {e}", exc_info=True)
            return "", None
