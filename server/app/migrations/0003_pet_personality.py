from app.models import User


def apply(db):
    # add column if not exists - Peewee / sqlite simple approach: create table migration
    try:
        # For sqlite this will work; for Postgres this will add the column
        db.execute_sql('ALTER TABLE "user" ADD COLUMN pet_personality varchar DEFAULT "alegre"')
    except Exception:
        pass

    # Seed existing users with random personalities if not set
    import random
    choices = ['alegre', 'tierno', 'triste', 'enojon', 'timido', 'energetico']
    for u in User.select():
        if not getattr(u, 'pet_personality', None):
            u.pet_personality = random.choice(choices)
            u.save()