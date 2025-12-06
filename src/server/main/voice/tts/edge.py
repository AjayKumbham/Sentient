import edge_tts
import asyncio
import tempfile
import os
import numpy as np
from pydub import AudioSegment
from .base import BaseTTS, TTSOptionsBase
import logging

logger = logging.getLogger(__name__)

class EdgeTTS(BaseTTS):
    async def stream_tts(self, text, language="en", options=None):
        logger.info(f"EdgeTTS synthesizing: {text[:50]}...")
        # Default voice. Can be parametrized later.
        voice = "en-US-ChristopherNeural"
        
        communicator = edge_tts.Communicate(text, voice)
        
        # Use a temporary file to handle the MP3 decoding via pydub+ffmpeg
        # This is robust and simple.
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tf:
            temp_filename = tf.name
        
        try:
            await communicator.save(temp_filename)
            
            # Load with pydub (requires ffmpeg in PATH)
            audio = AudioSegment.from_mp3(temp_filename)
            
            # Convert to float32 numpy array
            samples = np.array(audio.get_array_of_samples())
            
            if audio.sample_width == 2:
                samples = samples.astype(np.float32) / 32768.0
            elif audio.sample_width == 4:
                samples = samples.astype(np.float32) / 2147483648.0
            else:
                 samples = samples.astype(np.float32) / (2**(8*audio.sample_width-1))

            # Handle channels
            if audio.channels > 1:
                 # fastrtc often expects mono or specific shape. 
                 # Let's average to mono if complex, or keep if supported.
                 # Usually pure 1D array is safest for WebRTC mono.
                 samples = samples.reshape((-1, audio.channels))
                 samples = samples.mean(axis=1) # Convert to mono
            
            yield (audio.frame_rate, samples)
            
        except Exception as e:
            logger.error(f"EdgeTTS failed: {e}", exc_info=True)
        finally:
            if os.path.exists(temp_filename):
                os.remove(temp_filename)
