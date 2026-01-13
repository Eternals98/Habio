import flet as ft
from src.models.room import Room
from src.features.auth.auth_controller import AuthController
from src.features.room.room_repository import list_rooms, create_room as api_create_room
import flet as ft


def RoomScreen(page: ft.Page):
    rooms_column = ft.Column(scroll=ft.ScrollMode.AUTO)

    def build_room_card_from_dict(room_dict):
        return ft.Container(
            content=ft.Column([
                ft.Text(room_dict.get("name"), size=18, weight="bold"),
                ft.Text(f"Habits: {room_dict.get('habits_count', '?')}", size=14),
            ]),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def build_room_card(room):
        # room may be a model or a dict from API
        if isinstance(room, dict):
            return build_room_card_from_dict(room)
        return ft.Container(
            content=ft.Column([
                ft.Text(room.name, size=18, weight="bold"),
                ft.Text(f"Habits: {len(room.habits)}", size=14),
            ]),
            padding=10,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def load_rooms():
        user = AuthController.get_current_user()
        if not user:
            return
        # Try server
        try:
            rooms = list_rooms()
            rooms_column.controls = [build_room_card(r) for r in rooms]
            page.update()
            return
        except Exception:
            pass

        # Fallback to local DB
        rooms = Room.select().where(Room.user == user)
        rooms_column.controls = [build_room_card(room) for room in rooms]
        page.update()

    def create_room(e):
        def close_dlg(e):
            dlg.open = False
            page.update()

        def save_room(e):
            if name_field.value:
                user = AuthController.get_current_user()
                if not user:
                    close_dlg(e)
                    return
                # Try server
                try:
                    api_create_room(name_field.value)
                    load_rooms()
                except Exception:
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