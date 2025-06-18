# 🗃️ SQL Scripts — MusicApp Vibesia

This directory contains all SQL assets used to define, manage, and query the database schema for the **MusicApp Vibesia** project. It is structured to separate DDL, DML, stored procedures, functions, pipelines, and complex queries for better maintainability and automation.

---

## 📁 Directory Structure

```
sql/
├── ddl/                  # Schema definition scripts
├── dml/                  # Data insertion, audit logic, stored procedures and functions
├── pipelines/            # Batch scripts for automated execution
├── queries/              # Complex SQL queries for reporting and analysis
└── README.md             # You are here
```

---

## 📐 `ddl/` — Data Definition Language

> Contains all scripts related to the creation and alteration of the database structure.

| File                        | Purpose |
|-----------------------------|---------|
| `01-create-database.sql`    | Creates the initial database instance. |
| `02-create-tables.sql`      | Defines all system tables. |
| `03-create-triggers.sql`    | Includes triggers for automatic audit logging. |
| `04-alter-tables.sql`       | Performs alterations such as constraints and foreign keys. |
| `.gitkeep`                  | Keeps folder tracked in Git when empty. |
| `README.md`                 | Additional context for DDL scripts. |

---

## 🧩 `dml/` — Data Manipulation, Functions, Procedures, Audit

> This folder is divided into four subfolders for clarity:

### 📦 `dml/data/`
Contains scripts to populate the system with base data.

| File                 | Description                     |
|----------------------|----------------------------------|
| `01-genres.sql`      | List of music genres             |
| `02-artists.sql`     | Initial artist records           |
| `03-albums.sql`      | Albums associated with artists   |
| `04-music.sql`       | Songs linked to albums           |
| `05-song-genres.sql` | Mapping songs to genres          |
| `06-users.sql`       | Application users                |
| `07-devices.sql`     | User devices                     |
| `08-user-device.sql` | Relationship: user ↔ device      |
| `09-playlists.sql`   | Playlist records                 |
| `10-playlist-song.sql` | Songs in playlists            |
| `11-reproductions.sql` | Song play history             |

---

### 🔐 `dml/audit/`
> Audit logging structure and test cases.

| File                   | Description                          |
|------------------------|--------------------------------------|
| `audit-examples.sql`   | Query examples for using `audit_log` |
| `README.md`            | Documentation of audit logging usage |

---

### 🧠 `dml/functions/`
> SQL functions used by backend and reporting systems.

| Function File               | Description                                  |
|-----------------------------|----------------------------------------------|
| `audit-function.sql`        | Automatically logs changes to audit table    |
| `create-playlist.sql`       | Creates playlists programmatically           |
| `get-client_ip.sql`         | Returns client IP address                    |
| `get-most-active-user.sql`  | Determines user with most plays              |
| `get-top-song.sql`          | Returns the most played song overall         |
| `helper-backend-functions.sql` | Misc. helper functions for API/backend |

---

### ⚙️ `dml/procedures-stored/`
> Stored procedures for user interactions in the app.

| Procedure File                 | Description                             |
|--------------------------------|-----------------------------------------|
| `sp_add_song_to_playlist.sql`  | Adds a song to a playlist               |
| `sp_remove_song_from_playlist.sql` | Removes a song from a playlist     |
| `sp_delete_playlist.sql`       | Deletes an entire playlist              |
| `sp_update_playlist.sql`       | Updates playlist metadata               |
| `README.md`                    | Overview of procedures                  |

---

## 🔄 `pipelines/` — Batch Execution

> Contains scripts for executing multiple SQL files in batch.

### 📂 `pipelines/create-database/`
Automates creation of the database from schema to triggers.

### 📂 `pipelines/insert-data/`
Sequential loading of base data and audit setup.

⚙️ Pipelines may use shell scripts or psql batch execution for automation.

---

## 📊 `queries/` — Complex SQL Queries

> Advanced analytical queries for the final delivery.

| File                      | Description                      |
|---------------------------|----------------------------------|
| `01-complex-query.sql` → `10-complex-query.sql` | Analytical queries showcasing system functionality |
| `queries_vibesia.sql`     | Consolidated query set           |
| `README.md`               | Query documentation and usage    |

---

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 17.0+
- psql command-line tool
- Git (for version control)

### Database Setup
1. **Create Database:**
   ```bash
   psql -U postgres -f ddl/01-create-database.sql
   ```

2. **Run Full Pipeline:**
   ```bash
   # Execute complete database setup
   ./pipelines/create-database/run-all.sh
   
   # Insert initial data
   ./pipelines/insert-data/run-all.sh
   ```

3. **Test Installation:**
   ```bash
   psql -U postgres -d vibesia_db -f queries/01-complex-query.sql
   ```

---

## 🧪 Development Notes

- All scripts are compatible with **PostgreSQL 17.0+**.
- SQL files are modular, organized by responsibility.
- Most DDL/DML scripts can be run independently or via batch pipelines.
- Audit functionality is triggered automatically on data changes.
- Read `sql/dml/audit/README.md` for full audit tracking system.

### Naming Conventions
- **DDL files:** Numbered sequentially (`01-`, `02-`, etc.)
- **DML data files:** Sequential loading order
- **Functions:** Descriptive names with hyphen separation
- **Stored procedures:** Prefixed with `sp_`

### Best Practices
- Always backup database before running DDL alterations
- Test functions and procedures in development environment first
- Use transactions for batch data operations
- Monitor audit logs for system changes

---

## 🎓 Educational Objective

This SQL architecture supports the academic goal of building a robust and observable PostgreSQL database system capable of:

- **Normalized Structure:** Proper relational design with foreign keys
- **Modular Organization:** Clear separation of concerns (DDL/DML/Functions)
- **Audit Logging:** Complete change tracking and accountability
- **Backend Integration:** Functions and procedures ready for API consumption
- **Analytics Ready:** Complex queries for insights and reporting
- **Scalable Design:** Pipeline automation for deployment and maintenance

---

## 🔧 Troubleshooting

### Common Issues

**Database Connection Errors:**
```bash
# Check PostgreSQL service status
sudo systemctl status postgresql

# Verify user permissions
psql -U postgres -c "\du"
```

**Script Execution Failures:**
```bash
# Run with verbose output
psql -U postgres -d vibesia_db -v ON_ERROR_STOP=1 -f yourscript.sql
```

**Audit Function Not Triggering:**
- Verify triggers are installed: `\dt` in psql
- Check function permissions and syntax
- Review `dml/audit/README.md` for debugging steps

---

## 📈 Performance Considerations

- **Indexing:** Primary keys and foreign keys are automatically indexed
- **Audit Impact:** Audit triggers add ~5-10% overhead to DML operations
- **Query Optimization:** Use `EXPLAIN ANALYZE` for complex queries
- **Connection Pooling:** Recommended for production deployments

---

## 📬 Contributions & Issues

This folder is maintained by the **MusicApp Vibesia** development team for a university project. 

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-sql-function`)
3. Test your SQL scripts thoroughly
4. Commit with descriptive messages
5. Submit a pull request

### Reporting Issues
Please open an issue in the [main repository](https://github.com/JuanDavidJR/ProyectoFinal-BD.git) with:
- SQL script filename
- PostgreSQL version
- Error message (if any)
- Expected vs. actual behavior

---

## 📝 License

This project is developed for educational purposes as part of a university database course. All code is available under the MIT License for learning and academic use.

---

**Made with ❤️ by the Vibesia Team**