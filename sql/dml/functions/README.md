# 🗄 PostgreSQL Functions for Vibesia

> 📘 Enterprise-grade library of PostgreSQL stored procedures and functions for audit logging, user management, and analytics in the Vibesia platform.

---

## 🚀 Introduction

This repository contains a modular library of PostgreSQL functions designed to integrate with Vibesia, a music management platform. It is oriented towards facilitating the development of robust applications through an advanced system of auditing, user management, and real-time analytics.

---

## 🎯 Objectives

* Provide reusable functions to facilitate backend logic.
* Offer tools for traceability, security, and user monitoring.
* Enable behavioral statistics and content playback tracking.

---

## ✨ Features

### 🔍 Auditing and Security

* Operation logging with application context.
* Session variables for traceability.
* Compatibility support with existing audit systems.

### 👥 User Management

* Playlist creation with validation.
* User activity tracking.
* Role-based access control.

### 📊 Analytics and Reports

* Most active user identification.
* Most played songs.
* Playback history analysis.
* Real-time statistics.

### 🛠 Developer Utilities

* Helper functions for backend integration.
* Session context management.
* Error validation.

---

## 🏗 Requirements

### Technologies

* PostgreSQL 12 or higher

### Base Structure

Make sure you have the following tables (may vary depending on implementation):

```sql
-- Required structure (simplified)
-- audit_log, users, playlists, songs, playback_history
```

---

## ⚙ Installation

### Step by step

```sql
-- 1. Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS vibesia_schema;

-- 2. Install functions in order
\i functions/get-client_ip.sql
\i functions/helper-backend-functions.sql
\i functions/audit-function.sql
\i functions/create-playlist.sql
\i functions/get-most-active-user.sql
\i functions/get-top-song.sql
```

---

## 🧠 Usage

### Create Playlist

```sql
-- Set audit context
SELECT vibesia_schema.set_audit_context(
  456, 'creator@music.com', 'user',
  'MusicApp/1.0', '/api/playlists', 'req-456'
);

-- Create playlist
SELECT * FROM vibesia_schema.sp_create_playlist(
  456, 'Summer Hits 2024', 'Best songs for summer', 'public'
);

-- Clear context
SELECT vibesia_schema.clear_audit_context();
```

### Get Statistics

```sql
SELECT * FROM vibesia_schema.get_most_active_user();
SELECT * FROM vibesia_schema.get_top_song();
```

### Composite Query for Dashboard

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

## 🧪 Testing and Development

```sql
DO $$
BEGIN
    RAISE NOTICE 'IP: %', vibesia_schema.get_client_ip();
    PERFORM vibesia_schema.set_audit_context(999, 'test@test.com', 'test');
    RAISE NOTICE 'Context OK';
    PERFORM vibesia_schema.clear_audit_context();
    RAISE NOTICE 'Context cleared';
END $$;
```

---

## 🛡 Best Practices

### Security

* Validate input parameters.
* Use session variables for multi-user applications.
* Implement error handling.

### Performance

* Index key columns in audit log.
* Use date-based partitioning.
* Make use of connection pooling.
* Measure execution times.

### Development

* Test in staging environments.
* Document schema changes.
* Follow naming conventions and clear comments.

---

## 🤝 Contributions

Welcome to collaborate! Follow these steps:

1. Fork the repository.
2. Create your branch: `git checkout -b feature/NewFeature`
3. Make sure to test your changes.
4. Commit: `git commit -m 'Add new feature X'`
5. Push to your fork: `git push origin feature/NewFeature`
6. Open a Pull Request.

> ✳ Review the code quality standards and comments in each function.

---

## 📄 License

This project is under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## 🙋 Support

* 🐛 Bugs: [Issues](../../issues)
* 💡 Ideas and improvements: Use [Discussions](../../discussions)
* 📧 Contact: You can leave your message in issues or comment on source files.

---

It's almost over 🏁 by Ad-Astra Team