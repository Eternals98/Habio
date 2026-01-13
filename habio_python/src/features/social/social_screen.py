import flet as ft
from src.features.social.social_controller import SocialController

import flet as ft
from src.features.social.social_controller import SocialController

def SocialScreen(page: ft.Page):
    friends_column = ft.Column(spacing=10)
    gifts_column = ft.Column(spacing=10)

    def load_friends():
        friends = SocialController.get_friends()
        friends_column.controls = [build_friend_card(f) for f in friends]
        page.update()

    def load_gifts():
        gifts = SocialController.get_received_gifts()
        gifts_column.controls = [build_gift_card(g) for g in gifts]
        page.update()

    def build_friend_card(user):
        return ft.Container(
            content=ft.Row(
                controls=[
                    ft.Icon(ft.icons.PERSON, color=ft.Colors.CYAN),
                    ft.Column([
                        ft.Text(user.username, weight="bold"),
                        ft.Text(f"Lvl: {user.level} | Pet: {user.pet_name}", size=12, color="grey")
                    ]),
                    ft.IconButton(ft.icons.CARD_GIFTCARD, tooltip="Send Gift", 
                                  on_click=lambda _: open_gift_dialog(user))
                ],
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def open_gift_dialog(user):
        from src.models.inventory import InventoryItem, ShopItem
        from src.features.auth.auth_controller import AuthController

        current_user = AuthController.get_current_user()
        if not current_user:
            return

        # Get user's inventory
        inventory = (InventoryItem
                     .select(InventoryItem, ShopItem)
                     .join(ShopItem)
                     .where(InventoryItem.user == current_user, InventoryItem.quantity > 0))

        if not inventory:
            page.snack_bar = ft.SnackBar(ft.Text("No items to gift!"))
            page.snack_bar.open = True
            page.update()
            return

        def send_gift(item_id):
            success, msg = SocialController.send_gift(user.id, item_id)
            page.snack_bar = ft.SnackBar(ft.Text(msg))
            page.snack_bar.open = True
            dlg.open = False
            page.update()

        # Create list of items
        item_buttons = []
        for inv_item in inventory:
            item = inv_item.item
            item_buttons.append(
                ft.ElevatedButton(
                    f"{item.name} (x{inv_item.quantity})",
                    on_click=lambda e, iid=inv_item.id: send_gift(iid)
                )
            )

        dlg = ft.AlertDialog(
            title=ft.Text(f"Send Gift to {user.username}"),
            content=ft.Column(item_buttons, height=300, scroll=ft.ScrollMode.AUTO),
            actions=[ft.TextButton("Cancel", on_click=lambda _: setattr(dlg, 'open', False) or page.update())]
        )
        page.dialog = dlg
        dlg.open = True
        page.update()

    def add_friend_dialog(e):
        def add(e):
            if username_field.value:
                success, msg = SocialController.add_friend(username_field.value)
                page.snack_bar = ft.SnackBar(ft.Text(msg))
                page.snack_bar.open = True
                if success:
                    dlg.open = False
                    load_friends()
                page.update()

        username_field = ft.TextField(label="Friend's Username")
        dlg = ft.AlertDialog(
            title=ft.Text("Add Friend"),
            content=username_field,
            actions=[ft.TextButton("Add", on_click=add)]
        )
        page.dialog = dlg
        dlg.open = True
        page.update()

    def build_gift_card(gift):
        def claim(e):
            success, msg = SocialController.claim_gift(gift.id)
            page.snack_bar = ft.SnackBar(ft.Text(msg))
            page.snack_bar.open = True
            if success:
                load_gifts()
            page.update()

        return ft.Container(
            content=ft.Row(
                controls=[
                    ft.Icon(ft.icons.CARD_GIFTCARD, color=ft.Colors.PINK),
                    ft.Column([
                        ft.Text(f"Gift from {gift.sender.username}", weight="bold"),
                        ft.Text(gift.item.name, size=12, color="grey"),
                        ft.Text(gift.message or "No message", size=10, color="grey")
                    ]),
                    ft.ElevatedButton("Claim", on_click=claim)
                ],
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    load_friends()
    load_gifts()
    return ft.Container(
        content=ft.Column([
            ft.Text("Friends", size=24, weight="bold"),
            ft.ElevatedButton("Add Friend", on_click=add_friend_dialog),
            ft.Divider(),
            friends_column,
            ft.Divider(),
            ft.Text("Received Gifts", size=20, weight="bold"),
            gifts_column
        ]),
        padding=20,
        expand=True
    )

    def build_gift_card(self, gift):
        def claim(e):
            success, msg = SocialController.claim_gift(gift.id)
            self.page.snack_bar = ft.SnackBar(ft.Text(msg))
            self.page.snack_bar.open = True
            if success:
                self.load_gifts()
            self.page.update()

        return ft.Container(
            content=ft.Row(
                controls=[
                    ft.Icon(ft.icons.CARD_GIFTCARD, color=ft.colors.PINK),
                    ft.Column([
                        ft.Text(f"Gift from {gift.sender.username}", weight="bold"),
                        ft.Text(gift.item.name, size=12, color="grey"),
                        ft.Text(gift.message or "No message", size=10, color="grey")
                    ]),
                    ft.ElevatedButton("Claim", on_click=claim)
                ],
            ),
            padding=10,
            bgcolor=ft.colors.SURFACE_VARIANT,
            border_radius=10
        )

    def open_gift_dialog(self, user):
        from src.models.inventory import InventoryItem, ShopItem
        from src.features.auth.auth_controller import AuthController

        current_user = AuthController.get_current_user()
        if not current_user:
            return

        # Get user's inventory
        inventory = (InventoryItem
                     .select(InventoryItem, ShopItem)
                     .join(ShopItem)
                     .where(InventoryItem.user == current_user, InventoryItem.quantity > 0))

        if not inventory:
            self.page.snack_bar = ft.SnackBar(ft.Text("No items to gift!"))
            self.page.snack_bar.open = True
            self.page.update()
            return

        def send_gift(item_id):
            success, msg = SocialController.send_gift(user.id, item_id)
            self.page.snack_bar = ft.SnackBar(ft.Text(msg))
            self.page.snack_bar.open = True
            dlg.open = False
            self.page.update()

        # Create list of items
        item_buttons = []
        for inv_item in inventory:
            item = inv_item.item
            item_buttons.append(
                ft.ElevatedButton(
                    f"{item.name} (x{inv_item.quantity})",
                    on_click=lambda e, iid=inv_item.id: send_gift(iid)
                )
            )

        dlg = ft.AlertDialog(
            title=ft.Text(f"Send Gift to {user.username}"),
            content=ft.Column(item_buttons, height=300, scroll=ft.ScrollMode.AUTO),
            actions=[ft.TextButton("Cancel", on_click=lambda _: setattr(dlg, 'open', False) or self.page.update())]
        )
        self.page.dialog = dlg
        dlg.open = True
        self.page.update()

    def add_friend_dialog(self, e):
        def add(e):
            if username_field.value:
                success, msg = SocialController.add_friend(username_field.value)
                self.page.snack_bar = ft.SnackBar(ft.Text(msg))
                self.page.snack_bar.open = True
                if success:
                    dlg.open = False
                    self.load_friends()
                self.page.update()

        username_field = ft.TextField(label="Friend's Username")
        dlg = ft.AlertDialog(
            title=ft.Text("Add Friend"),
            content=username_field,
            actions=[ft.TextButton("Add", on_click=add)]
        )
        self.page.dialog = dlg
        dlg.open = True
        self.page.update()

    def build(self):
        self.load_friends()
        self.load_gifts()
        return ft.Container(
            content=ft.Column([
                ft.Text("Friends", size=24, weight="bold"),
                ft.ElevatedButton("Add Friend", on_click=self.add_friend_dialog),
                ft.Divider(),
                self.friends_column,
                ft.Divider(),
                ft.Text("Received Gifts", size=20, weight="bold"),
                self.gifts_column
            ]),
            padding=20,
            expand=True
        )
