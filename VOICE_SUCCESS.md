# Voice Chat Setup: Success! 🎤✅

Your local voice chat environment is fully configured and operational.

## Configuration Summary
- **Ears (STT):** `FASTER_WHISPER` (Local, High Quality)
- **Brain (LLM):** `GEMINI` (Cloud via API, Model: `gemini-2.5-flash`)
- **Mouth (TTS):** `ORPHEUS` (Local, Neural TTS, Buffered)

## How to Run
1. **Start the Server:**
   ```powershell
   cd src/server
   $env:ENVIRONMENT = "selfhost"
   uvicorn main.app:app --reload
   ```
2. **Start the Client:**
   ```powershell
   cd src/client
   npm run dev
   ```

## Troubleshooting
- If you hear stuttering, the TTS buffer is working, but your CPU might be overloaded.
- If you get "404 Model Not Found", check `GEMINI_API_KEY` in `.env.selfhost`.
- If you see "MCP Connection Failed", you can ignore it for simple chat, or run `start_all_services.ps1` to enable advanced tools (requires Docker/Postgres).

## Recent Fixes Applied
1. **Unlocked "Pro" Voice Mode** for self-hosted users.
2. **Fixed Concurrency Crash** in server audio processing.
3. **Added Gemini Support** to the voice backend (custom code in `utils.py`).
4. **Fixed TTS Stuttering** by implementing audio buffering in `orpheus.py`.
5. **Updated Setup Scripts** (`enable_free_voice.ps1`) to support Gemini configuration out-of-the-box.

Enjoy Sentient! 🤖
