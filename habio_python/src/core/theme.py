import flet as ft
import threading

# 🎨 Improved Habio Theme - Cozy & Inviting
PRIMARY = ft.Colors.BLUE_600
PRIMARY_LIGHT = ft.Colors.BLUE_400
ACCENT = ft.Colors.CYAN_400
ACCENT_WARM = ft.Colors.ORANGE_400
BG = ft.Colors.BLUE_50
SURFACE = ft.Colors.WHITE
CARD_BG = "#F5F7FF"  # Soft blue tint
TEXT_PRIMARY = ft.Colors.BLUE_900
TEXT_MUTED = ft.Colors.GREY_700
SUCCESS = ft.Colors.GREEN_400
ERROR = ft.Colors.RED_400
WARNING = ft.Colors.ORANGE_300

BUTTON_STYLE = {
    "width": 140,
    "height": 44,
}

BUTTON_STYLE_SMALL = {
    "width": 96,
    "height": 36,
}


def section_title(text: str):
    return ft.Text(text, size=24, weight="bold", color=TEXT_PRIMARY)


def section_subtitle(text: str):
    return ft.Text(text, size=12, color=TEXT_MUTED)


def card_container(content, padding=14):
    return ft.Container(
        content=content,
        padding=padding,
        bgcolor=CARD_BG,
        border_radius=12,
        shadow=ft.BoxShadow(
            spread_radius=0,
            blur_radius=4,
            color=ft.Colors.with_opacity(0.1, ft.Colors.BLACK),
            offset=ft.Offset(0, 2)
        )
    )


def primary_button(label: str, on_click=None, small: bool = False):
    style = BUTTON_STYLE_SMALL if small else BUTTON_STYLE
    return ft.ElevatedButton(
        label,
        on_click=on_click,
        style=ft.ButtonStyle(
            bgcolor={ft.ControlState.DEFAULT: PRIMARY},
            color={ft.ControlState.DEFAULT: SURFACE},
            shape=ft.RoundedRectangleBorder(radius=8),
        ),
        width=style.get("width"),
        height=style.get("height"),
    )


def show_snack(page: ft.Page, text: str, seconds: int = 2):
    snack = ft.SnackBar(
        ft.Text(text, color=SURFACE),
        bgcolor=PRIMARY,
        duration=int(seconds * 1000),
    )
    page.snack_bar = snack
    snack.open = True
    page.update()
    # Auto-close after delay
    try:
        t = threading.Timer(seconds, lambda: (setattr(snack, 'open', False), page.update()))
        t.daemon = True
        t.start()
    except Exception:
        pass


def press_effect(button: ft.ElevatedButton, page: ft.Page, temp_label: str="...", duration: float=0.14):
    if not button:
        return

    orig_disabled = button.disabled
    orig_content = button.content

    button.disabled = True
    button.content = ft.Text(temp_label)
    page.update()

    def _restore():
        button.disabled = orig_disabled
        button.content = orig_content
        try:
            page.update()
        except Exception:
            pass

    t = threading.Timer(duration, _restore)
    t.daemon = True
    t.start()

