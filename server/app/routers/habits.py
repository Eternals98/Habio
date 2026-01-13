from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel
from typing import List
from app.auth import get_current_user
from app.models import Habit, User, Room
from app.db import init_db

router = APIRouter()


class HabitCreate(BaseModel):
    name: str
    description: str | None = None
    difficulty: int = 1
    xp_reward: int = 10
    coin_reward: int = 5
    room_id: int | None = None


class HabitOut(BaseModel):
    id: int
    name: str
    description: str | None = None
    streak: int
    is_completed_today: bool


@router.get("/", response_model=List[HabitOut])
async def list_habits(current_user: User = Depends(get_current_user)):
    init_db()
    habits = Habit.select().where(Habit.user == current_user)
    return [
        {
            "id": h.id,
            "name": h.name,
            "description": h.description,
            "streak": h.streak,
            "is_completed_today": h.is_completed_today,
        }
        for h in habits
    ]


@router.post("/", response_model=HabitOut)
async def create_habit(h: HabitCreate, current_user: User = Depends(get_current_user)):
    init_db()
    room = None
    if h.room_id:
        try:
            room = Room.get_by_id(h.room_id)
        except Room.DoesNotExist:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Room not found")
    habit = Habit.create(
        user=current_user,
        room=room,
        name=h.name,
        description=h.description,
        difficulty=h.difficulty,
        xp_reward=h.xp_reward,
        coin_reward=h.coin_reward,
    )
    return {
        "id": habit.id,
        "name": habit.name,
        "description": habit.description,
        "streak": habit.streak,
        "is_completed_today": habit.is_completed_today,
    }


@router.put("/{habit_id}/complete", response_model=HabitOut)
async def complete_habit(habit_id: int, current_user: User = Depends(get_current_user)):
    init_db()
    try:
        habit = Habit.get(Habit.id == habit_id, Habit.user == current_user)
    except Habit.DoesNotExist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Habit not found")
    # apply completion: reward user
    if not habit.is_completed_today:
        habit.is_completed_today = True
        habit.streak += 1
        habit.last_completed_date = habit.last_completed_date
        habit.save()
        current_user.xp += habit.xp_reward
        current_user.coins += habit.coin_reward
        current_user.save()
    return {
        "id": habit.id,
        "name": habit.name,
        "description": habit.description,
        "streak": habit.streak,
        "is_completed_today": habit.is_completed_today,
    }


@router.delete("/{habit_id}")
async def delete_habit(habit_id: int, current_user: User = Depends(get_current_user)):
    init_db()
    try:
        habit = Habit.get(Habit.id == habit_id, Habit.user == current_user)
        habit.delete_instance()
        return {"ok": True}
    except Habit.DoesNotExist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Habit not found")
