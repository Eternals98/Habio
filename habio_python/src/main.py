import flet as ft
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from src.core.database import initialize_database
from src.features.auth.login import LoginScreen
from src.features.auth.register import RegisterScreen

def main(page: ft.Page):
    print("App started")
    # Initialize Database
    initialize_database()

    # Page Configuration — cozy & modern
    page.title = "Habio"
    page.padding = 0
    from src.core.theme import BG
    page.bgcolor = BG

    # Basic Routing
    from src.features.dashboard.dashboard import DashboardScreen
    from src.features.social.social_screen import SocialScreen

    def route_change(route):
        print("Route change:", page.route)
        page.controls.clear()

        if page.route == "/":
            page.go("/login")
            return

        if page.route == "/login":
            page.add(LoginScreen(page))
        elif page.route == "/register":
            page.add(RegisterScreen(page))
        elif page.route == "/dashboard":
            dashboard = DashboardScreen(page)
            page.add(dashboard)
        elif page.route == "/social":
            social = SocialScreen(page)
            page.add(social)
        elif page.route == "/store":
            from src.features.store.store_screen import StoreScreen
            store = StoreScreen(page)
            page.add(store)
        elif page.route == "/inventory":
            from src.features.store.inventory_screen import InventoryScreen
            inventory = InventoryScreen(page)
            page.add(inventory)
        elif page.route == "/room":
            from src.features.room.room_screen import RoomScreen
            room = RoomScreen(page)
            page.add(room)
        elif page.route == "/wheel":
            from src.features.wheel.wheel_screen import WheelScreen
            wheel = WheelScreen(page)
            page.add(wheel)
        elif page.route == "/pet":
            from src.features.pet.pet_screen import PetScreen
            pet = PetScreen(page)
            page.add(pet)
            from src.features.room.room_screen import RoomScreen
            room = RoomScreen(page)
            page.add(room)

        page.update()



    page.on_route_change = route_change
    page.route = "/login"
    route_change(None)

if __name__ == "__main__":
    ft.run(main)
