# Habio Server (FastAPI)

Este servicio proporciona la API para la app Habio.

Requisitos

- Docker & Docker Compose

Iniciar localmente (dev)

1. Copia `server/.env.example` a `server/.env` y ajusta variables si lo deseas.
2. Levantar stack:
   docker-compose up --build

La API estará en http://localhost:8000

Adminer (UI de DB) estará disponible en http://localhost:8080 — usuario y contraseña según `server/.env.example`.

Inicializar DB manualmente:
docker-compose run api python -c "from app.db import init_db; init_db()"

Tests:

- Instala dependencias y ejecuta pytest localmente, o ejecuta desde dentro del contenedor.

Despliegue en VPS

- Copia `docker-compose.yml` y `server/.env.example` (renombra a `.env`), ajusta secretos y variables, y ejecuta `docker-compose up -d`.
- Configura un reverse proxy (nginx) para TLS y proxy a `localhost:8000`.
