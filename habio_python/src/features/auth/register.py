import flet as ft
from src.features.auth.auth_controller import AuthController

def RegisterScreen(page: ft.Page):
    username_field = ft.TextField(label="Username", width=300)
    email_field = ft.TextField(label="Email", width=300)
    password_field = ft.TextField(label="Password", password=True, can_reveal_password=True, width=300)
    error_text = ft.Text(color=ft.Colors.RED)

    def register(e):
        success, message = AuthController.register(
            username_field.value,
            email_field.value,
            password_field.value
        )
        if success:
            page.snack_bar = ft.SnackBar(ft.Text("Registration successful! Please login."))
            page.snack_bar.open = True
            page.go("/login")
        else:
            error_text.value = message
            page.update()

    return ft.Container(
        content=ft.Column(
            alignment=ft.MainAxisAlignment.CENTER,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            controls=[
                ft.Text("Create Account", size=32, weight="bold"),
                ft.Text("Join Habio today", size=16, color=ft.Colors.GREY),
                ft.Container(height=20),
                username_field,
                email_field,
                password_field,
                error_text,
                ft.Container(height=10),
                ft.ElevatedButton("Sign Up", on_click=register, width=300),
                ft.TextButton("Already have an account? Login", on_click=lambda _: page.go("/login"))
            ]
        ),
        bgcolor=ft.Colors.LIGHT_BLUE,
        expand=True
    )