from src.models.user import User, Friend
from src.features.auth.auth_controller import AuthController
from src.features.habits.habit_controller import HabitController # Not needed directly but good context
from src.models.inventory import InventoryItem, Gift, ShopItem

class SocialController:
    @staticmethod
    def add_friend(friend_username):
        current_user = AuthController.get_current_user()
        if not current_user:
            return False, "Not logged in"
        
        if current_user.username == friend_username:
            return False, "Cannot add yourself"

        try:
            friend_user = User.get(User.username == friend_username)
            
            # Check if already friends
            if (Friend.select().where(Friend.user == current_user, Friend.friend == friend_user).exists()):
                 return False, "Already friends"

            Friend.create(user=current_user, friend=friend_user)
            # Bi-directional? For now, let's make it one-way follow or auto-add back. 
            # Let's do 1-way for simplicity or just create both records.
            Friend.create(user=friend_user, friend=current_user)
            
            return True, f"Added {friend_user.username} as friend!"
        except User.DoesNotExist:
            return False, "User not found"
        except Exception as e:
            return False, str(e)

    @staticmethod
    def get_friends():
        current_user = AuthController.get_current_user()
        if not current_user:
            return []
        
        # Join to get User data
        friends = (User
                   .select()
                   .join(Friend, on=(Friend.friend == User.id))
                   .where(Friend.user == current_user))
        return list(friends)

    @staticmethod
    def send_gift(friend_id, inventory_item_id):
        current_user = AuthController.get_current_user()
        if not current_user: return False, "Not logged in"

        try:
            # Check if user owns item
            inv_item = InventoryItem.get_by_id(inventory_item_id)
            if inv_item.user != current_user or inv_item.quantity < 1:
                return False, "You don't own this item"

            friend = User.get_by_id(friend_id)
            item = inv_item.item

            # Remove (decrement) from sender
            if inv_item.quantity > 1:
                inv_item.quantity -= 1
                inv_item.save()
            else:
                inv_item.delete_instance()

            # Create Gift record
            Gift.create(
                sender=current_user,
                receiver=friend,
                item=item,
                message="Here is a gift!"
            )
            return True, f"Sent {item.name} to {friend.username}!"

        except Exception as e:
            return False, str(e)

    @staticmethod
    def get_received_gifts():
        current_user = AuthController.get_current_user()
        if not current_user:
            return []

        gifts = (Gift
                 .select(Gift, ShopItem, User)
                 .join(ShopItem)
                 .switch(Gift)
                 .join(User, on=(Gift.sender == User.id))
                 .where(Gift.receiver == current_user, Gift.is_claimed == False))
        return list(gifts)

    @staticmethod
    def claim_gift(gift_id):
        current_user = AuthController.get_current_user()
        if not current_user: return False, "Not logged in"

        try:
            gift = Gift.get_by_id(gift_id)
            if gift.receiver != current_user:
                return False, "Not your gift"

            if gift.is_claimed:
                return False, "Already claimed"

            # Add to inventory
            inv_item, created = InventoryItem.get_or_create(
                user=current_user,
                item=gift.item,
                defaults={'quantity': 0}
            )
            inv_item.quantity += 1
            inv_item.save()

            # Mark as claimed
            gift.is_claimed = True
            gift.save()

            return True, f"Claimed {gift.item.name}!"
        except Exception as e:
            return False, str(e)
