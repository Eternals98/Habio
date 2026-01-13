from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import List
from app.auth import get_current_user
from app.models import Room
from app.db import init_db

router = APIRouter()


class RoomCreate(BaseModel):
    name: str


class RoomOut(BaseModel):
    id: int
    name: str


@router.get("/", response_model=List[RoomOut])
async def list_rooms(current_user=Depends(get_current_user)):
    init_db()
    rooms = Room.select().where(Room.user == current_user)
    return [{"id": r.id, "name": r.name} for r in rooms]


@router.post("/", response_model=RoomOut)
async def create_room(req: RoomCreate, current_user=Depends(get_current_user)):
    init_db()
    room = Room.create(user=current_user, name=req.name)
    return {"id": room.id, "name": room.name}
