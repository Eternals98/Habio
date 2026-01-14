import flet as ft
from src.features.auth.auth_controller import AuthController
from src.features.pet.pet_repository import chat, list_personalities, set_personality
from threading import Timer
from src.core.theme import show_snack


def chat_bubble_row(container: ft.Container, sender: str = 'pet'):
    alignment = ft.MainAxisAlignment.START if sender == 'pet' else ft.MainAxisAlignment.END
    return ft.Row([container], alignment=alignment)


def PetScreen(page: ft.Page):
    chat_list = ft.Column(scroll=ft.ScrollMode.AUTO)
    inp = ft.TextField(expand=True, hint_text='Say something to your pet...')

    def send(e):
        user = AuthController.get_current_user()
        if not user:
            show_snack(page, 'Not logged in')
            return
        msg = inp.value
        if not msg:
            return
        # append user's message
        user_ct = ft.Container(ft.Text(msg), bgcolor=ft.Colors.PRIMARY_CONTAINER, padding=10, border_radius=8)
        chat_list.controls.append(chat_bubble_row(user_ct, sender='user'))
        page.update()
        try:
            resp = chat(msg)
            reply = resp.get('reply')
            # highlight pet reply, then fade; also do a quick fade-in (opacity)
            pet_ct = ft.Container(ft.Text(reply), bgcolor=ft.Colors.YELLOW_100, padding=10, border_radius=8)
            # start invisible for a quick fade-in
            pet_ct.opacity = 0.0
            chat_list.controls.append(chat_bubble_row(pet_ct, sender='pet'))
            page.update()

            def fade_in_then_out():
                try:
                    # fade in
                    pet_ct.opacity = 1.0
                    page.update()
                    # then normalize background after a short delay
                    def fade_bg():
                        try:
                            pet_ct.bgcolor = ft.Colors.SURFACE_VARIANT
                            page.update()
                        except Exception:
                            pass
                    Timer(1.4, fade_bg).start()
                except Exception:
                    pass

            Timer(0.06, fade_in_then_out).start()
        except Exception as e:
            pet_ct = ft.Container(ft.Text('Error: ' + str(e)), bgcolor=ft.Colors.SURFACE_VARIANT, padding=10, border_radius=8)
            chat_list.controls.append(chat_bubble_row(pet_ct, sender='pet'))
            page.update()
        inp.value = ''
        page.update()

    # Show personality
    user = AuthController.get_current_user()
    personality_val = getattr(user, 'pet_personality', 'alegre') if user else 'alegre'
    personality_text = ft.Text(f'Personality: {personality_val}', size=12)

    def open_personality_dialog(e):
        try:
            items = list_personalities()
        except Exception as ex:
            show_snack(page, f'Error loading personalities: {ex}')
            return

        def choose_personality(person):
            try:
                set_personality(person)
                # update local user
                if user:
                    user.pet_personality = person
                personality_text.value = f'Personality: {person}'
                show_snack(page, f'Personality set to {person}')
                page.dialog.open = False
                page.update()
            except Exception as ex:
                show_snack(page, f'Error setting personality: {ex}')

        dialog = ft.AlertDialog(
            title=ft.Text('Choose Personality'),
            content=ft.Column([ft.ElevatedButton(f"{it['name']} - {it.get('description','')}", on_click=lambda e, name=it['name']: choose_personality(name)) for it in items]),
            actions=[ft.TextButton('Close', on_click=lambda e: (setattr(page.dialog, 'open', False), page.update()))]
        )
        page.dialog = dialog
        page.dialog.open = True
        page.update()

    return ft.Container(
        content=ft.Column([
            ft.Row([ft.Text('Chat with your pet', size=24, weight='bold'), personality_text, ft.IconButton(icon='edit', on_click=open_personality_dialog)]),
            ft.Divider(),
            ft.Container(content=chat_list, expand=True),
            ft.Row([inp, ft.IconButton(icon='send', on_click=send)])
        ], expand=True),
        padding=20,
        expand=True
    )