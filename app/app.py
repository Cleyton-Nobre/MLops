from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel

import joblib

app = FastAPI()
model=joblib.load("model.pkl")

class features(BaseModel):
    popularity : float
    acousticness : float
    danceability : float
    duration_ms : float
    energy : float
    instrumentalness : float
    liveness : float
    loudness : float
    speechiness : float
    tempo : float
    valence : float

@app.get("/")
def read_root():
    return {"status": "Online", "mode": "FastAPI on Lambda"}

@app.post("/predict")
def predict(dados: features):
    
    pred = model.predict([list(dados.dict().values())])[0]
    return {"features": dados.dict(), "prediction": pred}

# O "handler" que a AWS vai buscar é este objeto 'handler'
handler = Mangum(app)