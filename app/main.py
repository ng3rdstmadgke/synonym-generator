from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware


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

@app.get("/api/healthcheck")
async def healthcheck():
    message = "healty"
    return {"message": message}
