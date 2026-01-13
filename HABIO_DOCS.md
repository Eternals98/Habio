# Habio — Estado actual del proyecto

Resumen breve

- Cliente: `habio_python` (Flet). UI básica funcional; autenticación y flujos principales integrados con API.
- Servidor: `server` (FastAPI + Peewee). Autenticación JWT (bcrypt), endpoints para auth/habits/rooms/shop/inventory.
- DB: Postgres en Docker (production) / SQLite fallback (local). Adminer incluido para gestión rápida.
- Docker: `docker-compose.yml` levanta `db` (Postgres), `api` (FastAPI) y `adminer` (UI DB).

Cómo ejecutar (desarrollo local)

1. Configura el entorno:

   - Copia el .env de ejemplo y ajústalo para tu entorno:

     cp server/.env.example server/.env

   - **IMPORTANTE**: Cambia `SECRET_KEY` por un valor fuerte en `server/.env` antes de desplegar.

2. Levantar servicios (recomendado - Docker):

   - Para un arranque limpio (reconstruye imágenes con dependencias actualizadas):

     docker-compose down
     docker-compose up -d --build

   - URLs útiles:
     - API: http://localhost:8000
     - OpenAPI / Swagger: http://localhost:8000/docs
     - Adminer (interfaz DB): http://localhost:8080

3. Credenciales de Adminer / Postgres (valores por defecto en `docker-compose.yml` / `server/.env.example`):

   - Driver: PostgreSQL
   - Server: `db` (o `localhost` si conectas al puerto 5432 desde el host)
   - Port: 5432
   - Username: `postgres` (POSTGRES_USER)
   - Password: `postgres` (POSTGRES_PASSWORD)
   - Database: `habio` (POSTGRES_DB)

   - Ejemplo en Adminer: Selecciona `PostgreSQL`, pon `db` como servidor y las credenciales anteriores.

4. Inicializar la DB / seed (si es necesario):

   docker-compose run --rm api python -c "from app.db import init_db; init_db()"

5. Tests (ahora incluidos en la imagen):

   - **Hemos añadido `pytest` y `pytest-asyncio` a `server/requirements.txt`.**
   - Después de editar `requirements.txt`, reconstruye la imagen con `docker-compose up -d --build` para que `pytest` esté disponible dentro del contenedor.
   - Ejecutar tests en el contenedor:

     docker-compose run --rm api pytest -q

   - Alternativa local: `pytest -q` (si tienes las dependencias y un entorno adecuado).

6. Nota operativa y cambios recientes:

   - Se corrigió un problema con Pydantic (`BaseSettings` en v2.12): `server/app/config.py` ahora intenta importar `BaseSettings` desde `pydantic` y, si falla, usa `pydantic-settings` (compatibilidad hacia atrás).
   - El Dockerfile fue actualizado para instalar dependencias de compilación y drivers de Postgres; ahora instalamos `psycopg` y `psycopg2-binary` para soportar conexiones Postgres desde Peewee.
   - Si prefieres desarrollo sin Postgres, ajusta `DATABASE_URL` a `sqlite:///./habio.db` y el app usará SQLite como fallback.
   - Migrations: actualmente usamos `db.create_tables(...)` en `app.db` para crear tablas; recomendar implementar `peewee_migrate` para migraciones en producción.

7. Resumen rápido de endpoints y comportamiento

   - POST /auth/register, POST /auth/login, GET /auth/me
   - CRUD/complete para `/habits` (POST/GET/PUT/DELETE)
   - `/rooms` (GET/POST)
   - `/shop` (GET, POST /shop/buy, GET /shop/inventory)

Si quieres, puedo añadir un apartado con ejemplos `curl` o un script `make test` para automatizar las pruebas y la reconstrucción de la imagen.

API — endpoints principales

- POST /auth/register {username, email, password} -> {access_token}
- POST /auth/login {username, password} -> {access_token}
- GET /auth/me -> {id, username, email}

- GET /habits/ -> list of habits
- POST /habits/ {name, description?, room_id?} -> Created habit
- PUT /habits/{id}/complete -> mark habit completed (rewards XP / coins)
- DELETE /habits/{id} -> delete habit

- GET /rooms/ -> list rooms
- POST /rooms/ {name} -> create room

- GET /shop/ -> list shop items
- POST /shop/buy {item_id} -> buy item
- GET /shop/inventory -> list user inventory

Cliente (Flet) — comportamiento

- Ubicación principal: `habio_python/src/`
- Cliente usa un `HttpClient` global (`habio_python/src/services/http_client.py`) con baseURL por defecto `http://localhost:8000` o `HABIO_API_URL`.
- JWT: el token se guarda en `.habio_session.json` en la raíz del proyecto (manejado por `src/core/session.py`).
- Modos:
  - Online: se usa la API para auth/habits/rooms/store.
  - Offline: hay lógica de fallback que usa la base local (SQLite) si la API falla, con sincronización minimal.

Archivos clave creados/actualizados

- Servidor (server/)

  - `server/app/main.py` (entrypoint, registra routers)
  - `server/app/config.py` (config por env)
  - `server/app/db.py` (conexión Peewee — detecta `DATABASE_URL`)
  - `server/app/models.py` (models: User, Habit, Room, ShopItem, InventoryItem, Gift)
  - `server/app/auth.py` (bcrypt + JWT helpers)
  - `server/app/routers/*.py` (auth.py, habits.py, rooms.py, shop.py)
  - `server/requirements.txt`, `server/Dockerfile`, `server/.env.example`
  - `docker-compose.yml` (db, api, adminer)
  - `server/tests/` (tests unit/integration básicos)

- Cliente (habio_python/)
  - `habio_python/src/services/http_client.py` (http wrapper + token support)
  - `habio_python/src/core/database.py` (usa `DATABASE_URL` si está definido)
  - `habio_python/src/core/session.py` (guardar token en archivo)
  - `habio_python/src/features/auth/*` (controller y repo adaptados al API)
  - `habio_python/src/features/habits/*`, `room/*`, `store/*` (repos y screens adaptados para API/fallback)
  - `habio_python/tests/test_integration_auth.py` (test cliente)

Assets

- Las imágenes usadas por Flutter están en `assets/images/` en la raíz del repo (original app). Se pueden copiar a `habio_python/assets/images/` si quieres empaquetarlas con la app Python.
- La UI actual muestra emojis para ítems por defecto; Store/Inventory intentan cargar imágenes si `icon_path` termina en `.png/.jpg/.svg`.

Cómo probar el flujo completo (recomendado)

1. Levanta con `docker-compose up --build`.
2. En otra terminal, ejecuta: `docker-compose run api pytest -q` para tests server.
3. Abre la app Flet localmente: `python habio_python/src/main.py` (requiere tener dependencias instaladas: `pip install -r habio_python/requirements.txt`) y prueba registro/login, crear rooms/habits, completar hábitos y comprar ítems.

Notas de seguridad y próximos pasos

- Cambiar `SECRET_KEY` por uno fuerte en `server/.env` antes de producción.
- Mejorar migraciones (usar `peewee_migrate` o un sistema de migraciones) y añadir backups automáticos de Postgres.
- Visual: crear `habio_python/assets/images/pets/` con variantes de mascotas (penguin, ducky, teddy) y añadir `habio_python/src/features/game/pet_visual.py` para mostrar la mascota en `Dashboard`.
- Tests: ampliar cobertura para flujos social/gifting y edge-cases.

Resumen de status

- Endpoints principales implementados y con tests unitarios básicos.
- Cliente adaptado para usar API con fallback local.
- Docker + Adminer listos.

Si quieres, el siguiente paso que puedo ejecutar ahora es:

- Ejecutar tests dentro del contenedor Docker (levantar `docker-compose up -d` y ejecutar `docker-compose run api pytest -q`), o
- Empezar con la mejora visual (mascota e imágenes) como siguiente iteración.

Dime cuál prefieres y lo hago.
