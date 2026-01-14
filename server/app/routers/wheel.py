from fastapi import APIRouter, Depends, HTTPException
from typing import List
from pydantic import BaseModel
import random

from app.auth import get_current_user
from app.models import WheelPrize, ShopItem, InventoryItem
from app.db import init_db

router = APIRouter()


class WheelPrizeOut(BaseModel):
    id: int
    name: str
    prize_type: str
    value: int
    icon_path: str | None = None


@router.get("/", response_model=List[WheelPrizeOut])
async def list_prizes():
    init_db()
    prizes = WheelPrize.select()
    return [
        {"id": p.id, "name": p.name, "prize_type": p.prize_type, "value": p.value, "icon_path": p.icon_path}
        for p in prizes
    ]


class SpinResult(BaseModel):
    ok: bool
    message: str
    prize: dict


@router.post("/spin", response_model=SpinResult)
async def spin(current_user=Depends(get_current_user)):
    init_db()
    prizes = list(WheelPrize.select())
    if not prizes:
        raise HTTPException(status_code=404, detail="No wheel prizes available")

    # Build weighted list
    choices = []
    for p in prizes:
        choices.extend([p] * max(1, p.weight))

    win = random.choice(choices)

    # Apply prize
    if win.prize_type == "coins":
        current_user.coins += win.value
        current_user.save()
        return {"ok": True, "message": f"You won {win.value} coins!", "prize": {"name": win.name, "prize_type": win.prize_type, "value": win.value}}
    elif win.prize_type == "item":
        try:
            item = ShopItem.get_by_id(win.value)
            inv, created = InventoryItem.get_or_create(user=current_user, item=item, defaults={"quantity": 0})
            inv.quantity += 1
            inv.save()
            return {"ok": True, "message": f"You won {item.name}!", "prize": {"name": item.name, "prize_type": "item", "value": item.id}}
        except ShopItem.DoesNotExist:
            raise HTTPException(status_code=500, detail="Prize item not found")
    else:
        raise HTTPException(status_code=500, detail="Unknown prize type")
