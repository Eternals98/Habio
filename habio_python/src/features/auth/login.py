import flet as ft
from src.features.auth.auth_controller import AuthController

def LoginScreen(page: ft.Page):
    username_field = ft.TextField(label="Username", width=300)
    password_field = ft.TextField(label="Password", password=True, can_reveal_password=True, width=300)
    error_text = ft.Text(color=ft.Colors.RED)

    def login(e):
        success, message = AuthController.login(username_field.value, password_field.value)
        if success:
            page.go("/dashboard")
        else:
            error_text.value = message
            page.update()

    return ft.Container(
        content=ft.Column(
            alignment=ft.MainAxisAlignment.CENTER,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            controls=[
                ft.Text("Login Screen", size=40, color=ft.Colors.BLACK),
                ft.Text("Welcome Back", size=32, weight="bold"),
                ft.Text("Login to continue your journey", size=16, color=ft.Colors.GREY),
                ft.Container(height=20),
                username_field,
                password_field,
                error_text,
                ft.Container(height=10),
                ft.ElevatedButton("Login", on_click=login, width=300),
                ft.TextButton("Don't have an account? Sign Up", on_click=lambda _: page.go("/register"))
            ]
        ),
        bgcolor=ft.Colors.LIGHT_BLUE,
        expand=True
    )
