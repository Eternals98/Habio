import flet as ft
from src.features.auth.auth_controller import AuthController
import os

def LoginScreen(page: ft.Page):
    # ---------- Inputs ----------
    username_field = ft.TextField(
        label="Username",
        width=320,
        border_radius=14,
        border_color=ft.Colors.BLUE_200,
        focused_border_color=ft.Colors.BLUE_500,
        filled=True,
        fill_color="#FFFFFF",
        content_padding=ft.Padding(14, 12, 14, 12),
    )

    password_field = ft.TextField(
        label="Password",
        password=True,
        can_reveal_password=True,
        width=320,
        border_radius=14,
        border_color=ft.Colors.BLUE_200,
        focused_border_color=ft.Colors.BLUE_500,
        filled=True,
        fill_color="#FFFFFF",
        content_padding=ft.Padding(14, 12, 14, 12),
    )

    error_text = ft.Text(color=ft.Colors.RED_400, size=12)

    login_button = ft.ElevatedButton(
        "Login",
        width=320,
        height=46,
        style=ft.ButtonStyle(
            bgcolor=ft.Colors.BLUE_600,
            color=ft.Colors.WHITE,
            elevation=1,
            shape=ft.RoundedRectangleBorder(radius=14),
        ),
    )

    def login(e):
        success, message = AuthController.login(username_field.value, password_field.value)
        if success:
            page.go("/dashboard")
        else:
            error_text.value = message
            login_button.scale = 0.97
            page.update()

            import threading
            def restore():
                login_button.scale = 1.0
                page.update()
            threading.Timer(0.12, restore).start()

    login_button.on_click = login

    # ---------- Helpers ----------
    def pet_image(filename, size, opacity=1.0):
        return ft.Image(
            src=f"assets/images/pets/{filename}",
            width=size,
            height=size,
            fit="contain",
            opacity=opacity,
        )

    # ---------- Background (gradient + soft blobs) ----------
    background = ft.Container(
        expand=True,
        gradient=ft.LinearGradient(
            begin=ft.Alignment.TOP_LEFT,
            end=ft.Alignment.BOTTOM_RIGHT,
            colors=["#EAF3FF", "#F6FBFF", "#EEF2FF"],
        ),
    )

    # Soft blobs (simple circles) - feel "cute"
    blob1 = ft.Container(
        width=240, height=240,
        border_radius=999,
        bgcolor=ft.Colors.with_opacity(0.12, ft.Colors.BLUE_400),
    )
    blob2 = ft.Container(
        width=180, height=180,
        border_radius=999,
        bgcolor=ft.Colors.with_opacity(0.10, ft.Colors.CYAN_400),
    )
    blob3 = ft.Container(
        width=260, height=260,
        border_radius=999,
        bgcolor=ft.Colors.with_opacity(0.10, ft.Colors.INDIGO_300),
    )

    # ---------- Card ----------
    title_row = ft.Row(
        [
            ft.Text("Habio", size=44, weight=ft.FontWeight.W_800, color=ft.Colors.BLUE_700),
        ],
        alignment=ft.MainAxisAlignment.CENTER,
    )

    form_card = ft.Container(
        width=420,
        padding=ft.Padding(28, 26, 28, 24),
        border_radius=26,
        bgcolor=ft.Colors.WHITE,
        shadow=ft.BoxShadow(
            blur_radius=22,
            spread_radius=0,
            color=ft.Colors.with_opacity(0.12, ft.Colors.BLACK),
            offset=ft.Offset(0, 10),
        ),
        content=ft.Column(
            [
                title_row,
                ft.Container(height=6),
                ft.Text(
                    "Welcome back 🐾",
                    size=22,
                    weight=ft.FontWeight.W_700,
                    color=ft.Colors.BLUE_GREY_900,
                    text_align=ft.TextAlign.CENTER,
                ),
                ft.Text(
                    "Alimenta tu mascota con consistencia.\nUn hábito = una mascota.",
                    size=13,
                    color=ft.Colors.BLUE_GREY_600,
                    text_align=ft.TextAlign.CENTER,
                ),
                ft.Container(height=18),

                username_field,
                ft.Container(height=12),
                password_field,

                ft.Container(height=10),
                error_text,
                ft.Container(height=14),

                login_button,

                ft.Container(height=12),
                ft.Row(
                    [
                        ft.TextButton(
                            "Sign Up",
                            on_click=lambda _: page.go("/register"),
                            style=ft.ButtonStyle(color=ft.Colors.BLUE_700),
                        ),
                        ft.TextButton(
                            "Forgot Password?",
                            on_click=lambda _: None,
                            style=ft.ButtonStyle(color=ft.Colors.BLUE_400),
                        ),
                    ],
                    alignment=ft.MainAxisAlignment.CENTER,
                    spacing=18,
                ),
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            spacing=0,
        ),
    )

    # ---------- Layout ----------
    return ft.Stack(
        [
            background,

            # Blobs behind everything
            ft.Container(content=blob1, left=-60, top=-60),
            ft.Container(content=blob2, right=-40, top=40),
            ft.Container(content=blob3, left=-90, bottom=-90),

            # Center card
            ft.Container(
                content=form_card,
                alignment=ft.Alignment.CENTER,
                expand=True,
            ),
        ],
        expand=True,
    )