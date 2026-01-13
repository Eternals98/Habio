import flet as ft
from src.models.inventory import ShopItem, InventoryItem
from src.features.auth.auth_controller import AuthController

def StoreScreen(page: ft.Page):
    shop_items = ft.Column(scroll=ft.ScrollMode.AUTO)

    def load_shop_items():
        items = ShopItem.select()
        shop_items.controls = [build_shop_item_card(item) for item in items]
        page.update()

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
                    ft.Text(item.icon_path, size=30),
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