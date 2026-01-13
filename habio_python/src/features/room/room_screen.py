import flet as ft
from src.models.room import Room
from src.features.auth.auth_controller import AuthController

def RoomScreen(page: ft.Page):
    rooms_column = ft.Column(scroll=ft.ScrollMode.AUTO)

    def load_rooms():
        user = AuthController.get_current_user()
        if not user:
            return

        rooms = Room.select().where(Room.user == user)
        rooms_column.controls = [build_room_card(room) for room in rooms]
        page.update()

    def build_room_card(room):
        return ft.Container(
            content=ft.Column([
                ft.Text(room.name, size=18, weight="bold"),
                ft.Text(f"Habits: {len(room.habits)}", size=14),
            ]),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def create_room(e):
        def close_dlg(e):
            dlg.open = False
            page.update()

        def save_room(e):
            if name_field.value:
                user = AuthController.get_current_user()
                if user:
                    Room.create(user=user, name=name_field.value)
                    load_rooms()
                close_dlg(e)

        name_field = ft.TextField(label="Room Name")
        dlg = ft.AlertDialog(
            title=ft.Text("New Room"),
            content=name_field,
            actions=[
                ft.TextButton("Cancel", on_click=close_dlg),
                ft.TextButton("Create", on_click=save_room),
            ],
        )
        page.dialog = dlg
        dlg.open = True
        page.update()

    load_rooms()
    return ft.Container(
        content=ft.Column([
            ft.Text("My Rooms", size=24, weight="bold"),
            ft.ElevatedButton("Create New Room", on_click=create_room),
            ft.Container(height=10),
            rooms_column
        ]),
        padding=20,
        expand=True
    )