import time
import datetime
from datetime import timezone
START_TIME = time.time()

import os
import platform
import logging
logging.basicConfig(level=logging.INFO)
import socket

logger = logging.getLogger(__name__)

if platform.system() == 'Windows':
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        local_ip = s.getsockname()[0]
    except Exception:
        local_ip = '127.0.0.1'
    finally:
        s.close()

    logger.info(f"Detected local IP: {local_ip}")

    os.environ['WEBRTC_IP'] = local_ip

from contextlib import asynccontextmanager
import logging
from bson import ObjectId
from typing import Optional
import httpx

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import ENCODERS_BY_TYPE

from main.config import (
    APP_SERVER_PORT, AZURE_SPEECH_KEY, AZURE_SPEECH_REGION
)
from main.dependencies import mongo_manager
from main.auth.routes import router as auth_router
from main.chat.routes import router as chat_router
from main.notifications.routes import router as notifications_router
from main.integrations.routes import router as integrations_router
from main.misc.routes import router as misc_router
from main.tasks.routes import router as agents_router
from main.settings.routes import router as settings_router
from main.testing.routes import router as testing_router
from main.memories.db import close_db_pool as close_memories_pg_pool
from main.memories.routes import router as memories_router
from mcp_hub.memory.utils import initialize_embedding_model
from main.files.routes import router as files_router
from main.voice.routes import router as voice_router, stream as voice_stream
from main.voice.stt.base import BaseSTT
from main.voice.stt.azure import AzureSTT
from main.voice.tts.base import BaseTTS
from main.voice.tts.azure import AzureTTS

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__) 

# Add a custom encoder for ObjectId to FastAPI's internal dictionary
ENCODERS_BY_TYPE[ObjectId] = str

http_client: httpx.AsyncClient = httpx.AsyncClient()
stt_model_instance: Optional[BaseSTT] = None
tts_model_instance: Optional[BaseTTS] = None

def initialize_stt():
    """Initialize Azure Speech-to-Text"""
    global stt_model_instance
    logger.info("Initializing Azure Speech-to-Text...")
    
    if not AZURE_SPEECH_KEY or not AZURE_SPEECH_REGION:
        logger.error("AZURE_SPEECH_KEY and AZURE_SPEECH_REGION are required.")
        logger.error("Please configure Azure Speech credentials in your .env file.")
        return
    
    try:
        stt_model_instance = AzureSTT()
        logger.info("✓ Azure STT initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Azure STT: {e}", exc_info=True)

def initialize_tts():
    """Initialize Azure Text-to-Speech"""
    global tts_model_instance
    logger.info("Initializing Azure Text-to-Speech...")
    
    if not AZURE_SPEECH_KEY or not AZURE_SPEECH_REGION:
        logger.error("AZURE_SPEECH_KEY and AZURE_SPEECH_REGION are required.")
        logger.error("Please configure Azure Speech credentials in your .env file.")
        return
    
    try:
        tts_model_instance = AzureTTS()
        logger.info("✓ Azure TTS initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Azure TTS: {e}", exc_info=True)

@asynccontextmanager
async def lifespan(app_instance: FastAPI):
    logger.info("App startup...")
    await mongo_manager.initialize_db()
    initialize_stt()
    initialize_tts()
    initialize_embedding_model()
    logger.info("App startup complete.")
    yield 
    logger.info("App shutdown sequence initiated...")
    if mongo_manager and mongo_manager.client:
        mongo_manager.client.close()
    await close_memories_pg_pool()
    logger.info("App shutdown complete.")

app = FastAPI(title="Sentient Main Server", version="2.2.0", docs_url="/docs", redoc_url="/redoc", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # More permissive for development
    allow_credentials=True, 
    allow_methods=["*"], 
    allow_headers=["*"]
)

# FIX: Mount the FastRTC stream with a /voice prefix
voice_stream.mount(app, "/voice")

app.include_router(auth_router)
app.include_router(chat_router)
app.include_router(notifications_router)
app.include_router(integrations_router)
app.include_router(misc_router)
app.include_router(agents_router)
app.include_router(settings_router)
app.include_router(testing_router)
app.include_router(memories_router)
app.include_router(voice_router)
app.include_router(files_router)

@app.get("/", tags=["General"])
async def root():
    return {"message": "Sentient Main Server Operational (Qwen Agent Integrated)."}

@app.get("/health", tags=["General"])
async def health():
    return {
        "status": "healthy",
        "timestamp": datetime.datetime.now(timezone.utc).isoformat(),
        "services": {
            "database": "connected" if mongo_manager.client else "disconnected",
            "stt": "loaded" if stt_model_instance else "not_loaded",
            "tts": "loaded" if tts_model_instance else "not_loaded",
            "llm": "qwen_agent_on_demand"
        }
    }

END_TIME = time.time()
logger.info(f"Main Server app.py loaded in {END_TIME - START_TIME:.2f} seconds.")

if __name__ == "__main__":
    import uvicorn
    log_config = uvicorn.config.LOGGING_CONFIG.copy()
    log_config["formatters"]["access"]["fmt"] = '%(asctime)s %(levelname)s %(client_addr)s - "[MAIN_SERVER_ACCESS] %(request_line)s" %(status_code)s'
    log_config["formatters"]["default"]["fmt"] = '%(asctime)s %(levelname)s [%(name)s] [MAIN_SERVER_DEFAULT] %(message)s'
    uvicorn.run("main.app:app", host="127.0.0.1", port=APP_SERVER_PORT, lifespan="on", reload=False, workers=1, log_config=log_config)