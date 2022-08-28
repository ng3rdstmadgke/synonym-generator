from typing import List

from pydantic import BaseModel
from gensim.models import KeyedVectors
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from settings import get_env, logging_error_exception

env = get_env()
model = KeyedVectors.load_word2vec_format(env.model_file, binary=True)

# NOTE: dev環境ではAPI documentを表示
app = FastAPI(
    redoc_url="/api/redoc",
    docs_url="/api/docs",
    openapi_url="/api/docs/openapi.json"
)
    
    
# CORS: https://fastapi.tiangolo.com/tutorial/cors/
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
    
class InvocationsRequestSchema(BaseModel):
    keyword: str
class InvocationsResponseSchema(BaseModel):
    synonyms: List[str]
    
    
@app.get("/ping")
async def ping():
    return {"message": "pong"}
    
@app.post("/invocations", response_model=InvocationsResponseSchema)
async def invocations(request_schema: InvocationsRequestSchema):
    try:
        text = request_schema.keyword.strip()
        synonyms = [i[0] for i in model.most_similar(positive=text, topn=20)]
    except Exception as e:
        logging_error_exception(e)
        synonyms = []
    return {"synonyms": synonyms}