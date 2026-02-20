from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel

app = FastAPI()

class Numeros(BaseModel):
    num1: float
    num2: float

@app.get("/")
def read_root():
    return {"status": "Online", "mode": "FastAPI on Lambda"}

@app.post("/somar")
def somar(dados: Numeros):
    resultado = dados.num1 + dados.num2
    return {"resultado": resultado}

# O "handler" que a AWS vai buscar é este objeto 'handler'
handler = Mangum(app)