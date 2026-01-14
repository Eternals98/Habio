import flet as ft
import random
from threading import Timer
from src.features.wheel.wheel_repository import list_prizes, spin
from src.features.auth.auth_controller import AuthController
from src.core.theme import section_title, card_container, primary_button, show_snack, press_effect


def WheelScreen(page: ft.Page):
    prizes_col = ft.Column(scroll=ft.ScrollMode.AUTO)
    result_text = ft.Text("")
    spin_button = primary_button("Spin")

    def load_prizes():
        try:
            prizes = list_prizes()
            controls = []
            for p in prizes:
                icon = None
                ip = p.get('icon_path')
                if ip:
                    try:
                        icon = ft.Image(src=ip, width=36, height=36)
                    except Exception:
                        icon = ft.Icon(ft.icons.STAR)
                else:
                    icon = ft.Icon(ft.icons.STAR)

                controls.append(card_container(ft.Row([icon, ft.Column([ft.Text(p.get('name')), ft.Text(f"({p.get('prize_type')})", size=10)])], alignment=ft.MainAxisAlignment.SPACE_BETWEEN)))

            prizes_col.controls = controls
            page.update()
            return
        except Exception:
            prizes_col.controls = [ft.Text("Unable to load prizes")]
            page.update()

    def show_result(result):
        show_snack(page, result.get('message') if isinstance(result, dict) else str(result))

    def do_spin(e):
        # Press feedback
        press_effect(spin_button, page, temp_label="...", duration=2.2)

        try:
            pool = list_prizes()
            names = [p['name'] for p in pool] if pool else ["5 coins","10 coins","25 coins","50 coins"]
        except Exception:
            names = ["5 coins","10 coins","25 coins","50 coins"]

        # Call spin endpoint first (server applies prize), then animate a slow deceleration that lands on the prize
        try:
            res = spin()
        except Exception as ex:
            show_result(str(ex))
            return

        # determine target index
        prize_name = None
        if isinstance(res, dict):
            prize = res.get('prize') or {}
            prize_name = prize.get('name') or res.get('message')
        if not prize_name:
            prize_name = ""

        try:
            target_idx = names.index(prize_name)
        except ValueError:
            # prize not in the visible list; pick a random target for animation
            target_idx = random.randrange(len(names))

        # decelerating animation
        total_steps = random.randint(40, 80)
        current = random.randrange(len(names))
        state = {'step': 0, 'pos': current}

        def step():
            state['pos'] = (state['pos'] + 1) % len(names)
            state['step'] += 1
            prizes_col.controls = [ft.Text(names[state['pos']], size=18, weight='bold')]
            page.update()
            progress = state['step'] / total_steps
            # quadratic easing for smooth slow-down
            delay = 0.02 + (0.45 * (progress ** 2))
            if state['step'] < total_steps:
                Timer(delay, step).start()
            else:
                # slowly advance to exact target if needed
                if state['pos'] != target_idx:
                    def slow_to_target():
                        state['pos'] = (state['pos'] + 1) % len(names)
                        prizes_col.controls = [ft.Text(names[state['pos']], size=18, weight='bold')]
                        page.update()
                        if state['pos'] != target_idx:
                            Timer(0.22, slow_to_target).start()
                        else:
                            show_result(res)
                    Timer(0.22, slow_to_target).start()
                else:
                    show_result(res)

        step()

    spin_button.on_click = do_spin

    load_prizes()
    return ft.Container(
        content=ft.Column([
            section_title('Wheel'),
            card_container(prizes_col, padding=8),
            ft.Container(height=10),
            ft.Row([spin_button], alignment=ft.MainAxisAlignment.CENTER),
        ], expand=True),
        padding=20,
        expand=True
    )