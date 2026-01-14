from fastapi import FastAPI
from app.routers import auth, habits, rooms, shop, wheel, pet, gifts
from app.db import init_db

app = FastAPI(title="Habio API")

# Ensure db is initialized on startup
@app.on_event("startup")
async def startup_event():
    init_db()

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(habits.router, prefix="/habits", tags=["habits"])
app.include_router(rooms.router, prefix="/rooms", tags=["rooms"])
app.include_router(shop.router, prefix="/shop", tags=["shop"])
app.include_router(wheel.router, prefix="/wheel", tags=["wheel"]) 
app.include_router(pet.router, prefix="/pet", tags=["pet"])
app.include_router(gifts.router, prefix="/gifts", tags=["gifts"])

@app.get("/")
async def root():
    return {"message": "Habio API"}
