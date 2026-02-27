from time import time

from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel

import boto3
import joblib

cloudwatch = boto3.client("cloudwatch", region_name="us-east-1")

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
    start = time.time()
    # 1. Extrai os valores do Pydantic
    input_data = [list(dados.model_dump().values())]
    
    # 2. Faz a predição
    prediction_raw = model.predict(input_data)[0]
    
    # 3. CONVERSÃO ESSENCIAL: transforma numpy.int64 em int comum do Python
    # Se o seu modelo for de regressão (números quebrados), use float(prediction_raw)
    prediction_final = int(prediction_raw) 

    latency = (time.time() - start) * 1000

    cloudwatch.put_metric_data(
        Namespace="MusicGenrePrediction",
        MetricData=[
            {
                "MetricName": "PredictionMade",
                "Dimensions": [
                    {
                        "Name": "PredictedClass",
                        "Value": str(prediction_final)
                    }
                ],
                "Value": 1,
                "Unit": "Count"
            },
            {
                "MetricName": "PredictionLatency",
                "Value": latency,
                "Unit": "Milliseconds",
            }
        ]
    )

    return {
        "features": dados.model_dump(), 
        "prediction": prediction_final
    }
# O "handler" que a AWS vai buscar é este objeto 'handler'
handler = Mangum(app)