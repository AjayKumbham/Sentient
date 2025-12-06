from .base import BaseSTT
from .elevenlabs import ElevenLabsSTT
from main.config import STT_PROVIDER

# Conditionally import Deepgram only if needed
try:
    from .deepgram import DeepgramSTT
except ImportError:
    DeepgramSTT = None

if STT_PROVIDER == "FASTER_WHISPER":
    from .faster_whisper import FasterWhisperSTT
else:
    FasterWhisperSTT = None