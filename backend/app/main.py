from fastapi import FastAPI

app = FastAPI(title="NexSpend API", version="0.1.0")


@app.get("/health", tags=["system"])
async def health_check() -> dict[str, str]:
    """Liveness endpoint; product APIs start after the Day 1 foundation."""
    return {"status": "ok"}
