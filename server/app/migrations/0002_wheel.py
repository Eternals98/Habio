from app.models import WheelPrize, ShopItem


def apply(db):
    # Create the table
    db.create_tables([WheelPrize])

    # Seed a few prizes (coins and items)
    # Ensure some shop items exist first
    try:
        # Item-based prize: use first shop item if available
        first_item = ShopItem.select().limit(1).first()
        if first_item:
            WheelPrize.create(name=f"Lucky {first_item.name}", prize_type="item", value=first_item.id, item=first_item, icon_path=first_item.icon_path, weight=10)
    except Exception:
        pass

    # Coin prizes
    for amt, w in [(50, 5), (25, 10), (10, 30)]:
        WheelPrize.create(name=f"{amt} coins", prize_type="coins", value=amt, weight=w)

    # Small consolation prize
    WheelPrize.create(name="5 coins", prize_type="coins", value=5, weight=50)
