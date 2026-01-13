import flet as ft
from src.models.inventory import InventoryItem, ShopItem
from src.features.auth.auth_controller import AuthController
from src.features.store.store_repository import list_inventory
import os


def _maybe_image_control(path_or_emoji):
    if isinstance(path_or_emoji, str) and any(path_or_emoji.lower().endswith(ext) for ext in ('.png', '.jpg', '.jpeg', '.svg')):
        candidate = os.path.join('assets', 'images', path_or_emoji)
        try:
            return ft.Image(src=candidate, width=48, height=48)
        except Exception:
            return ft.Text(path_or_emoji, size=30)
    return ft.Text(path_or_emoji, size=30)


def InventoryScreen(page: ft.Page):
    items_column = ft.Column(scroll=ft.ScrollMode.AUTO)

    def load_inventory():
        user = AuthController.get_current_user()
        if not user:
            return

        # Try server
        try:
            items = list_inventory()
            items_column.controls = [build_item_card_dict(it) for it in items]
            page.update()
            return
        except Exception:
            pass

        items = (InventoryItem
                 .select(InventoryItem, ShopItem)
                 .join(ShopItem)
                 .where(InventoryItem.user == user))

        items_column.controls = [build_item_card(item) for item in items]
        page.update()

    def build_item_card_dict(it):
        return ft.Container(
            content=ft.Row(
                controls=[
                    _maybe_image_control(it.get('icon_path')),
                    ft.Column([
                        ft.Text(it.get('name'), weight="bold"),
                        ft.Text(f"Quantity: {it.get('quantity')}"),
                        ft.Text(it.get('description', ''), size=12),
                    ], expand=True),
                ]
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def build_item_card(inv_item):
        item = inv_item.item
        return ft.Container(
            content=ft.Row(
                controls=[
                    _maybe_image_control(item.icon_path),
                    ft.Column([
                        ft.Text(item.name, weight="bold"),
                        ft.Text(f"Quantity: {inv_item.quantity}"),
                        ft.Text(item.description, size=12),
                    ], expand=True),
                ]
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    load_inventory()
    return ft.Container(
        content=ft.Column([
            ft.Text("My Inventory", size=24, weight="bold"),
            ft.Container(height=10),
            items_column
        ]),
        padding=20,
        expand=True
    )