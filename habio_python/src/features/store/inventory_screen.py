import flet as ft
from src.models.inventory import InventoryItem, ShopItem
from src.features.auth.auth_controller import AuthController

def InventoryScreen(page: ft.Page):
    items_column = ft.Column(scroll=ft.ScrollMode.AUTO)

    def load_inventory():
        user = AuthController.get_current_user()
        if not user:
            return

        items = (InventoryItem
                 .select(InventoryItem, ShopItem)
                 .join(ShopItem)
                 .where(InventoryItem.user == user))

        items_column.controls = [build_item_card(item) for item in items]
        page.update()

    def build_item_card(inv_item):
        item = inv_item.item
        return ft.Container(
            content=ft.Row(
                controls=[
                    ft.Text(item.icon_path, size=30),
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