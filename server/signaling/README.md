# FastAPI Signaling Server

Phase 4 will implement authenticated WebRTC room signaling here. The minimal
health endpoint keeps deployment/tooling decisions isolated from Phase 1.

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
