from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import List
from app.auth import get_current_user
from app.models import ShopItem, InventoryItem
from app.db import init_db

router = APIRouter()


class BuyRequest(BaseModel):
    item_id: int


class ShopItemOut(BaseModel):
    id: int
    name: str
    description: str
    price: int
    icon_path: str


@router.get("/", response_model=List[ShopItemOut])
async def list_items():
    init_db()
    items = ShopItem.select()
    return [
        {"id": i.id, "name": i.name, "description": i.description, "price": i.price, "icon_path": i.icon_path}
        for i in items
    ]


@router.post("/buy")
async def buy_item(req: BuyRequest, current_user=Depends(get_current_user)):
    init_db()
    try:
        item = ShopItem.get_by_id(req.item_id)
    except ShopItem.DoesNotExist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    if current_user.coins < item.price:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough coins")
    current_user.coins -= item.price
    current_user.save()
    inv, created = InventoryItem.get_or_create(user=current_user, item=item, defaults={"quantity": 0})
    inv.quantity += 1
    inv.save()
    return {"ok": True, "message": f"Bought {item.name}"}


@router.get("/inventory")
async def list_inventory(current_user=Depends(get_current_user)):
    init_db()
    items = InventoryItem.select().where(InventoryItem.user == current_user)
    return [
        {"item_id": it.item.id, "name": it.item.name, "quantity": it.quantity, "is_equipped": it.is_equipped}
        for it in items
    ]
