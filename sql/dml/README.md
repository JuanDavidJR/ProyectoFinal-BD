# 🗄 PostgreSQL Functions for Vibesia

> 📘 Enterprise-grade library of PostgreSQL stored procedures and functions for audit logging, user management, and analytics in the Vibesia platform.

---

## 📚 Índice

* [🚀 Introducción](#-introducción)
* [🎯 Objetivos](#-objetivos)
* [✨ Características](#-características)
* [🏗 Requisitos](#-requisitos)
* [⚙ Instalación](#-instalación)
* [🧠 Uso](#-uso)
* [🧪 Pruebas y Desarrollo](#-pruebas-y-desarrollo)
* [🛡 Mejores Prácticas](#-mejores-prácticas)
* [🤝 Contribuciones](#-contribuciones)
* [📄 Licencia](#-licencia)
* [🙋 Soporte](#-soporte)

---

## 🚀 Introducción

Este repositorio contiene una biblioteca modular de funciones PostgreSQL diseñadas para integrarse con Vibesia, una plataforma de gestión musical. Está orientado a facilitar el desarrollo de aplicaciones robustas mediante un sistema avanzado de auditoría, gestión de usuarios y análisis en tiempo real.

---

## 🎯 Objetivos

* Brindar funciones reutilizables para facilitar la lógica del backend.
* Ofrecer herramientas de trazabilidad, seguridad y monitoreo de usuarios.
* Permitir estadísticas de comportamiento y reproducción de contenido.

---

## ✨ Características

### 🔍 Auditoría y Seguridad

* Registro de operaciones con contexto de aplicación.
* Variables de sesión para trazabilidad.
* Soporte de compatibilidad con sistemas existentes de auditoría.

### 👥 Gestión de Usuarios

* Creación de listas de reproducción con validación.
* Seguimiento de actividad por usuario.
* Control de acceso basado en roles.

### 📊 Analítica y Reportes

* Identificación de usuarios más activos.
* Canciones más reproducidas.
* Análisis del historial de reproducción.
* Estadísticas en tiempo real.

### 🛠 Utilidades para Desarrolladores

* Funciones auxiliares para integración backend.
* Gestión de contexto por sesión.
* Validación de errores.

---

## 🏗 Requisitos

### Tecnologías

* PostgreSQL 12 o superior

### Estructura Base

Asegúrate de tener las siguientes tablas (pueden variar según implementación):

```sql
-- Estructura requerida (simplificada)
-- audit_log, users, playlists, songs, playback_history
```

---

## ⚙ Instalación

### Paso a paso

```sql
-- 1. Crear esquema si no existe
CREATE SCHEMA IF NOT EXISTS vibesia_schema;

-- 2. Instalar funciones en orden
\i functions/get-client_ip.sql
\i functions/helper-backend-functions.sql
\i functions/audit-function.sql
\i functions/create-playlist.sql
\i functions/get-most-active-user.sql
\i functions/get-top-song.sql
```

---

## 🧠 Uso

### Crear Playlist

```sql
-- Establecer contexto de auditoría
SELECT vibesia_schema.set_audit_context(
  456, 'creator@music.com', 'user',
  'MusicApp/1.0', '/api/playlists', 'req-456'
);

-- Crear playlist
SELECT * FROM vibesia_schema.sp_create_playlist(
  456, 'Summer Hits 2024', 'Best songs for summer', 'public'
);

-- Limpiar contexto
SELECT vibesia_schema.clear_audit_context();
```

### Obtener Estadísticas

```sql
SELECT * FROM vibesia_schema.get_most_active_user();
SELECT * FROM vibesia_schema.get_top_song();
```

### Consulta Compuesta para Dashboard

```sql
WITH user_stats AS (
    SELECT * FROM vibesia_schema.get_most_active_user()
),
song_stats AS (
    SELECT * FROM vibesia_schema.get_top_song()
)
SELECT 
    'Most Active User' AS metric_type,
    username AS name,
    total_reproductions AS value
FROM user_stats
UNION ALL
SELECT 
    'Top Song',
    title,
    total_reproducciones
FROM song_stats;
```

---

## 🧪 Pruebas y Desarrollo

```sql
DO $$
BEGIN
    RAISE NOTICE 'IP: %', vibesia_schema.get_client_ip();
    PERFORM vibesia_schema.set_audit_context(999, 'test@test.com', 'test');
    RAISE NOTICE 'Contexto OK';
    PERFORM vibesia_schema.clear_audit_context();
    RAISE NOTICE 'Contexto limpiado';
END $$;
```

---

## 🛡 Mejores Prácticas

### Seguridad

* Validar parámetros de entrada.
* Usar variables de sesión para aplicaciones multiusuario.
* Implementar control de errores.

### Rendimiento

* Indexar columnas clave del log de auditoría.
* Usar particiones por fecha.
* Hacer uso de pool de conexiones.
* Medir tiempos de ejecución.

### Desarrollo

* Probar en entornos de staging.
* Documentar cambios en el esquema.
* Seguir convención de nombres y comentarios claros.

---

## 🤝 Contribuciones

¡Bienvenido a colaborar! Sigue estos pasos:

1. Haz un *fork* del repositorio.
2. Crea tu rama: `git checkout -b feature/NuevaFuncionalidad`
3. Asegúrate de *probar* tus cambios.
4. Haz commit: `git commit -m 'Agrega nueva funcionalidad X'`
5. Push a tu fork: `git push origin feature/NuevaFuncionalidad`
6. Abre un *Pull Request*.

> ✳ Revisa los estándares de calidad de código y comentarios en cada función.

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## 🙋 Soporte

* 🐛 *Bugs*: [Issues](../../issues)
* 💡 *Ideas y mejoras*: Usa [Discussions](../../discussions)
* 📧 *Contacto*: Puedes dejar tu mensaje en los issues o comentar en los archivos fuente.

---

It's almost over 🏁 by Ad-Astra Team