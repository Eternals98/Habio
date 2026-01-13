import flet as ft
from src.features.habits.habit_controller import HabitController
from src.features.auth.auth_controller import AuthController
from src.models.room import Room

def DashboardScreen(page: ft.Page):
    rooms_column = ft.Column(spacing=10, scroll=ft.ScrollMode.AUTO)
    user_stats = ft.Text("Loading...", color=ft.Colors.WHITE)

    def load_data():
        user = AuthController.get_current_user()
        if user:
            user_stats.value = f"Level: {user.level} | XP: {user.xp} | Coins: {user.coins}"
        else:
            page.go("/login")
            return

        rooms = Room.select().where(Room.user == user)
        rooms_column.controls = [build_room_card(room) for room in rooms]
        page.update()

    def build_room_card(room):
        habits_in_room = [build_habit_card(h) for h in room.habits]
        return ft.Container(
            content=ft.Column([
                ft.Text(room.name, size=20, weight="bold"),
                ft.ElevatedButton("Add Habit to this Room", on_click=lambda e: add_habit_to_room(room)),
                ft.Container(height=10),
                *habits_in_room
            ]),
            padding=15,
            bgcolor=ft.Colors.SURFACE_VARIANT,
            border_radius=10
        )

    def build_habit_card(habit):
        return ft.Container(
            content=ft.Row(
                controls=[
                    ft.Icon("check_circle" if habit.is_completed_today else "radio_button_unchecked", 
                            color=ft.Colors.GREEN if habit.is_completed_today else ft.Colors.WHITE),
                    ft.Text(habit.name, size=16, expand=True),
                    ft.Text(f"Streak: {habit.streak}"),
                    ft.IconButton(
                        icon="check",
                        on_click=lambda _, h=habit: mark_completed(h),
                        disabled=habit.is_completed_today
                    )
                ],
                alignment=ft.MainAxisAlignment.SPACE_BETWEEN
            ),
            padding=10,
            bgcolor=ft.Colors.SURFACE,
            border_radius=5
        )

    def mark_completed(habit):
        success, msg = HabitController.complete_habit(habit.id)
        if success:
            page.snack_bar = ft.SnackBar(ft.Text(msg))
            page.snack_bar.open = True
            load_data()
        
    def add_habit_to_room(room):
        add_habit_dialog(page, room)

    load_data()
    return ft.Container(
        content=ft.Column(
            controls=[
                ft.Container(
                    content=ft.Row(
                        [
                            ft.Text("Dashboard", size=24, weight="bold"),
                            user_stats
                        ],
                        alignment=ft.MainAxisAlignment.SPACE_BETWEEN
                    ),
                    padding=10,
                    bgcolor=ft.Colors.PRIMARY_CONTAINER
                ),
                ft.Container(height=20),
                ft.Text("My Rooms", size=20),
                ft.Container(
                    content=rooms_column,
                    expand=True
                ),
            ],
            expand=True
        ),
        padding=20,
        expand=True
    )

def add_habit_dialog(page, room):
    from src.features.habits.habit_controller import HabitController
    def close_dlg(e):
        dlg.open = False
        page.update()

    def save_habit(e):
        if name_field.value:
            HabitController.create_habit(name_field.value, room=room)
            close_dlg(e)
            # Reload
            page.go("/dashboard")

    name_field = ft.TextField(label="Habit Name")
    dlg = ft.AlertDialog(
        title=ft.Text(f"New Habit in {room.name}"),
        content=name_field,
        actions=[
            ft.TextButton("Cancel", on_click=close_dlg),
            ft.TextButton("Save", on_click=save_habit),
        ],
    )
    page.dialog = dlg
    dlg.open = True
    page.update()