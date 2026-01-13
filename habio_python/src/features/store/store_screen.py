import flet as ft
from src.models.inventory import ShopItem, InventoryItem
from src.features.auth.auth_controller import AuthController
from src.features.store.store_repository import list_items, buy_item
from src.features.auth.auth_repository import me as api_me
import os

ASSETS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '..', '..', 'assets', 'images')

def _maybe_image_control(path_or_emoji):
    # If path looks like an image filename, try to load from assets
    if isinstance(path_or_emoji, str) and any(path_or_emoji.lower().endswith(ext) for ext in ('.png', '.jpg', '.jpeg', '.svg')):
        candidate = os.path.join('assets', 'images', path_or_emoji)
        try:
            return ft.Image(src=candidate, width=48, height=48)
        except Exception:
            return ft.Text(path_or_emoji, size=30)
    return ft.Text(path_or_emoji, size=30)


def StoreScreen(page: ft.Page):
    shop_items = ft.Column(scroll=ft.ScrollMode.AUTO)

    def load_shop_items():
        # Try server first
        try:
            items = list_items()
            shop_items.controls = [build_shop_item_card_dict(item) for item in items]
            page.update()
            return
        except Exception:
            pass

        # Fallback to local DB
        items = ShopItem.select()
        shop_items.controls = [build_shop_item_card(item) for item in items]
        page.update()

    def build_shop_item_card_dict(item):
        def buy(e):
            try:
                resp = buy_item(item['id'])
                page.snack_bar = ft.SnackBar(ft.Text(resp.get('message', 'Bought!')))
                page.snack_bar.open = True
                # Update UI coins
                try:
                    user_data = api_me()
                    # Update local coins if user exists
                except Exception:
                    pass
                load_shop_items()
            except Exception as ex:
                page.snack_bar = ft.SnackBar(ft.Text(str(ex)))
                page.snack_bar.open = True
                page.update()

        return ft.Container(
            content=ft.Row(
                controls=[
                    _maybe_image_control(item.get('icon_path')),
                    ft.Column([
                        ft.Text(item.get('name'), weight="bold"),
                        ft.Text(item.get('description', ''), size=12),
                        ft.Text(f"{item.get('price')} coins")
                    ], expand=True),
                    ft.ElevatedButton("Buy", on_click=buy)
                ]
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def build_shop_item_card(item):
        def buy(e):
            user = AuthController.get_current_user()
            if user and user.coins >= item.price:
                user.coins -= item.price
                user.save()
                # Add to inventory
                inv_item, created = InventoryItem.get_or_create(
                    user=user, item=item, defaults={'quantity': 0}
                )
                inv_item.quantity += 1
                inv_item.save()
                page.snack_bar = ft.SnackBar(ft.Text(f"Bought {item.name}!"))
                page.snack_bar.open = True
                load_shop_items()
            else:
                page.snack_bar = ft.SnackBar(ft.Text("Not enough coins!"))
                page.snack_bar.open = True
                page.update()

        return ft.Container(
            content=ft.Row(
                controls=[
                    _maybe_image_control(item.icon_path),
                    ft.Column([
                        ft.Text(item.name, weight="bold"),
                        ft.Text(item.description, size=12),
                        ft.Text(f"{item.price} coins")
                    ], expand=True),
                    ft.ElevatedButton("Buy", on_click=buy)
                ]
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    load_shop_items()
    user = AuthController.get_current_user()
    coins_text = f"Coins: {user.coins if user else 0}"
    return ft.Container(
        content=ft.Column([
            ft.Text("Shop", size=24, weight="bold"),
            ft.Text(coins_text, size=18, color=ft.Colors.YELLOW),
            ft.Divider(),
            shop_items
        ]),
        padding=20,
        expand=True
    )