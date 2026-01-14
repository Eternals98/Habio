from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from app.auth import get_current_user
from app.db import init_db
from app.models import Gift, InventoryItem, User, ShopItem

router = APIRouter()


class SendGiftRequest(BaseModel):
    receiver_id: int
    inventory_id: int
    message: str | None = None


@router.post("/send")
async def send_gift(req: SendGiftRequest, current_user=Depends(get_current_user)):
    init_db()
    try:
        inv = InventoryItem.get_by_id(req.inventory_id)
        if inv.user.id != current_user.id or inv.quantity < 1:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You don't own this item")
        receiver = User.get_by_id(req.receiver_id)
        item = inv.item
        # Decrement or delete
        if inv.quantity > 1:
            inv.quantity -= 1
            inv.save()
        else:
            inv.delete_instance()
        Gift.create(sender=current_user, receiver=receiver, item=item, message=req.message)
        return {"ok": True, "message": f"Sent {item.name} to {receiver.username}"}
    except InventoryItem.DoesNotExist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Inventory item not found")
    except User.DoesNotExist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Receiver not found")
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/received")
async def list_received(current_user=Depends(get_current_user)):
    init_db()
    items = Gift.select().where(Gift.receiver == current_user, Gift.is_claimed == False)
    return [
        {"id": g.id, "sender_id": g.sender.id, "sender_username": g.sender.username, "item_id": g.item.id, "item_name": g.item.name, "message": g.message}
        for g in items
    ]


class ClaimRequest(BaseModel):
    gift_id: int


@router.post("/claim")
async def claim_gift(req: ClaimRequest, current_user=Depends(get_current_user)):
    init_db()
    try:
        g = Gift.get_by_id(req.gift_id)
        if g.receiver.id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your gift")
        if g.is_claimed:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Already claimed")
        # add to inventory
        inv, created = InventoryItem.get_or_create(user=current_user, item=g.item, defaults={"quantity": 0})
        inv.quantity += 1
        inv.save()
        g.is_claimed = True
        g.save()
        return {"ok": True, "message": f"Claimed {g.item.name}"}
    except Gift.DoesNotExist:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gift not found")
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))