from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
import os

app = FastAPI(title="Tabanah Galaxy Backend", version="0.1.0")

@app.get("/health")
def health():
    return {"status": "ok", "service": "tabanah-backend", "version": "0.1.0"}

# Example protected stub
class EVMRequest(BaseModel):
    pv: float
    ev: float
    ac: float

@app.post("/evm/compute")
def compute_evm(req: EVMRequest):
    # Simple EVM metrics
    if req.ac == 0 or req.pv == 0:
        raise HTTPException(status_code=400, detail="AC and PV must be > 0")

    cpi = req.ev / req.ac
    spi = req.ev / req.pv
    cv = req.ev - req.ac
    sv = req.ev - req.pv

    return {
        "CPI": round(cpi, 4),
        "SPI": round(spi, 4),
        "CV": round(cv, 2),
        "SV": round(sv, 2)
    }
