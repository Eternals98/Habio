# Habio - Gamified Habit Tracker (Python/Flet Version)

Habio es una aplicación de seguimiento de hábitos gamificada, migrada de Flutter a Python usando el framework Flet para desarrollo cross-platform (PC, móvil, web).

## 🎯 Características Principales

- **Seguimiento de Hábitos**: Crea y completa hábitos diarios con sistema de streaks y XP.
- **Rooms (Habitaciones)**: Organiza hábitos en habitaciones temáticas.
- **Gamificación**: Sistema de niveles, monedas y mascotas virtuales.
- **Red Social**: Agrega amigos, envía regalos y compite.
- **Tienda**: Compra items con monedas para personalizar tu experiencia.
- **Inventario**: Gestiona tus compras y regalos recibidos.

## 🛠️ Tecnologías Utilizadas

- **Lenguaje**: Python 3.12+
- **Framework UI**: Flet (para interfaces cross-platform)
- **Base de Datos**: SQLite con ORM Peewee
- **Empaquetado**: Flet Build (APK/IPA)
- **Gestión de Dependencias**: pip

## 📁 Arquitectura del Proyecto

```
habio_python/
├── src/
│   ├── core/
│   │   ├── database.py          # Configuración SQLite y modelos base
│   │   └── theme.py             # Tema visual (opcional)
│   ├── models/
│   │   ├── user.py              # Modelo Usuario y Amigos
│   │   ├── habit.py             # Modelo Hábitos
│   │   ├── room.py              # Modelo Rooms
│   │   └── inventory.py         # Modelos Tienda, Inventario, Regalos
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login.py         # Pantalla de login
│   │   │   ├── register.py      # Pantalla de registro
│   │   │   └── auth_controller.py # Lógica de autenticación
│   │   ├── dashboard/
│   │   │   └── dashboard.py     # Dashboard con rooms y hábitos
│   │   ├── social/
│   │   │   ├── social_screen.py # Pantalla de amigos y regalos
│   │   │   └── social_controller.py # Lógica social
│   │   ├── store/
│   │   │   ├── store_screen.py  # Pantalla de tienda
│   │   │   └── inventory_screen.py # Pantalla de inventario
│   │   └── room/
│   │       └── room_screen.py   # Pantalla de gestión de rooms
│   ├── features/habits/
│   │   └── habit_controller.py  # Lógica de hábitos
│   └── main.py                  # Punto de entrada de la app
├── requirements.txt             # Dependencias Python
├── pyproject.toml               # Configuración para Flet Build
└── README.md                    # Este archivo
```

### Patrón Arquitectónico
- **MVC Simplificado**: 
  - Models: Capa de datos (Peewee ORM)
  - Views: Pantallas Flet (funciones que retornan Containers)
  - Controllers: Lógica de negocio

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Python 3.12+
- pip

### Instalación
1. Clona o descarga el proyecto
2. Navega a `habio_python/`
3. Instala dependencias:
   ```bash
   pip install -r requirements.txt
   ```

### Ejecución en Desarrollo
```bash
python src/main.py
```
Esto abre la app en una ventana nativa.

## 📱 Construcción para Producción

### Para Android (APK)
1. Instala Flutter SDK y Android Studio
2. Instala Flet CLI:
   ```bash
   pip install flet[build]
   ```
3. Construye APK:
   ```bash
   flet build apk
   ```
4. El APK se genera en `build/flet/android/apk/`

### Para iOS (IPA)
1. En macOS con Xcode instalado
2. Construye IPA:
   ```bash
   flet build ipa
   ```

## 🎮 Funcionalidades Detalladas

### Autenticación
- **Registro**: Crea cuenta con username, email y password
- **Login**: Accede con username y password
- **Seguridad**: Passwords hasheadas con SHA256

### Rooms (Habitaciones)
- **Creación**: Crea rooms personalizadas para organizar hábitos
- **Room por Defecto**: Al registrar, se crea automáticamente "My Room"
- **Gestión**: Lista todas tus rooms en la pantalla de Rooms

### Hábitos
- **Creación**: Agrega hábitos dentro de rooms específicas
- **Completar**: Marca como completado diariamente para ganar XP y monedas
- **Streaks**: Sistema de rachas consecutivas
- **Gamificación**: 
  - XP: Experiencia para subir de nivel
  - Monedas: Para comprar en la tienda
  - Mascota: Evoluciona con tu progreso

### Sistema Social
- **Amigos**: Agrega usuarios por username
- **Regalos**: Envía items de tu inventario a amigos
- **Recepción**: Recibe regalos y reclámalos a tu inventario

### Tienda e Inventario
- **Tienda**: Compra alimentos, accesorios, decoraciones con monedas
- **Inventario**: Ve todos tus items comprados y regalados
- **Items**: Mascotas, alimentos, accesorios, decoraciones, fondos

## 🎯 Lógica de Gamificación

### Sistema de Niveles
- Cada hábito completado da XP (10 por defecto)
- Al acumular XP, subes de nivel
- Niveles desbloquean nuevas funcionalidades

### Economía
- Monedas ganadas al completar hábitos (5 por defecto)
- Gastar monedas en la tienda
- Items afectan la experiencia (ej: alimentos curan a la mascota)

### Mascotas
- Cada usuario tiene una mascota que evoluciona
- Alimentar con items de la tienda
- Salud baja si no completas hábitos

## 🔧 Desarrollo

### Agregar Nueva Funcionalidad
1. Define el modelo en `src/models/`
2. Crea controller en `src/features/[feature]/`
3. Implementa pantalla en `src/features/[feature]/[screen].py`
4. Integra en `main.py` routing

### Base de Datos
- Usa SQLite para desarrollo (fácil migración a otros DB)
- Modelos con Peewee ORM
- Migraciones automáticas con `db.create_tables()`

### Testing
Ejecuta el script de verificación:
```bash
python verify_logic.py
```
Prueba registro, login, hábitos y social.

## 📈 Roadmap

- [ ] Personalización de mascotas
- [ ] Decoración de rooms con items
- [ ] Modo oscuro completo
- [ ] Sincronización en la nube
- [ ] Notificaciones push
- [ ] Estadísticas avanzadas

## 🤝 Contribución

Para contribuir:
1. Fork el proyecto
2. Crea rama feature
3. Commit cambios
4. Push y crea Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

---

¡Disfruta usando Habio para mejorar tus hábitos diarios! 🎉