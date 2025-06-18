# 🧩 DML — Data Manipulation Layer

This directory contains the **Data Manipulation Language (DML)** layer of the `MusicApp - Vibesia` project. It includes the core SQL components responsible for inserting, modifying, analyzing, and managing the data in the `vibesia_schema` database.

Each subdirectory is modular and focuses on a distinct purpose, such as data loading, audit logic, backend support functions, and stored procedures for user interaction.

> 📁 Every subfolder has its own dedicated `README.md` for detailed usage and structure.

---

## 📁 Directory Structure

```
dml/
├── audit/                # Audit logging and tracking system
├── data/                 # Base data insertion scripts
├── functions/            # SQL functions for backend and analytics
├── procedures-stored/    # Stored procedures for dynamic operations
└── README.md            # You are here
```

---

## 📂 Folder Overview

### 📂 `audit/`
> **Purpose**: Implements the auditing logic for tracking changes in system tables.

**Key Features:**
- Complete change tracking for all database operations
- Data lineage and security monitoring
- Example queries for audit data exploration
- Automatic logging of INSERT, UPDATE, DELETE operations

**Contains:**
- `audit-examples.sql` - Sample queries for audit analysis
- `README.md` - Comprehensive audit system documentation

➡️ See [`dml/audit/README.md`](./audit/README.md)

---

### 📂 `data/`
> **Purpose**: Loads the base data used in the MusicApp ecosystem.

**Key Features:**
- Sequential data loading with proper dependencies
- Comprehensive test dataset for development
- Realistic music industry data samples
- Referential integrity maintenance

**Script Sequence:**
1. `01-genres.sql` - Music genres foundation
2. `02-artists.sql` - Artist profiles and metadata
3. `03-albums.sql` - Album information linked to artists
4. `04-music.sql` - Individual songs and tracks
5. `05-song-genres.sql` - Song-genre relationships
6. `06-users.sql` - Application user accounts
7. `07-devices.sql` - User device information
8. `08-user-device.sql` - User-device associations
9. `09-playlists.sql` - User-created playlists
10. `10-playlist-song.sql` - Playlist compositions
11. `11-reproductions.sql` - Playback history data

➡️ See [`dml/data/README.md`](./data/README.md)

---

### 📂 `functions/`
> **Purpose**: Contains SQL functions used in application logic and reporting.

**Key Features:**
- Backend API support functions
- Analytics and reporting utilities
- User behavior analysis tools
- Performance-optimized queries

**Function Categories:**
- **Audit Functions**: `audit-function.sql`
- **Playlist Management**: `create-playlist.sql`
- **User Analytics**: `get-most-active-user.sql`
- **Content Analytics**: `get-top-song.sql`
- **Network Utilities**: `get-client_ip.sql`
- **Backend Helpers**: `helper-backend-functions.sql`

➡️ See [`dml/functions/README.md`](./functions/README.md)

---

### 📂 `procedures-stored/`
> **Purpose**: Implements stored procedures for playlist management and dynamic operations.

**Key Features:**
- Transactional playlist operations
- Error handling and validation
- Modular backend integration
- User interaction support

**Available Procedures:**
- `sp_add_song_to_playlist.sql` - Add songs to playlists
- `sp_remove_song_from_playlist.sql` - Remove songs from playlists
- `sp_delete_playlist.sql` - Complete playlist deletion
- `sp_update_playlist.sql` - Playlist metadata updates

➡️ See [`dml/procedures-stored/README.md`](./procedures-stored/README.md)

---

## 🔗 Quick Access Navigation

### 📊 **By Functionality**

| Functionality | Location | Files |
|---------------|----------|-------|
| **Data Loading** | `data/` | `01-genres.sql` to `11-reproductions.sql` |
| **Audit Tracking** | `audit/` | `audit-examples.sql` |
| **User Analytics** | `functions/` | `get-most-active-user.sql`, `get-client_ip.sql` |
| **Content Analytics** | `functions/` | `get-top-song.sql`, `helper-backend-functions.sql` |
| **Playlist Management** | `procedures-stored/` | All `sp_*.sql` files |
| **Backend Support** | `functions/` | `helper-backend-functions.sql` |

### 🎯 **By Use Case**

| Use Case | Recommended Files | Purpose |
|----------|-------------------|---------|
| **Initial Setup** | `data/01-genres.sql` → `data/11-reproductions.sql` | Load base data |
| **API Development** | `functions/helper-backend-functions.sql` | Backend utilities |
| **User Management** | `procedures-stored/sp_*.sql` | User interactions |
| **Analytics & Reporting** | `functions/get-*.sql` | Data insights |
| **Compliance & Security** | `audit/audit-examples.sql` | Change tracking |

---

## 🛠️ System Requirements

### **Database Compatibility**
- **PostgreSQL:** Version 14 or higher
- **Schema:** `vibesia_schema` (must exist)
- **Dependencies:** DDL scripts must be executed first

### **Prerequisites**
```sql
-- Verify schema exists
SELECT schema_name FROM information_schema.schemata 
WHERE schema_name = 'vibesia_schema';

-- Check required tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'vibesia_schema';
```

### **Execution Order**
1. **DDL Layer**: `sql/ddl/` (tables, constraints, triggers)
2. **DML Functions**: `sql/dml/functions/` (support functions)
3. **DML Data**: `sql/dml/data/` (base data loading)
4. **DML Procedures**: `sql/dml/procedures-stored/` (stored procedures)
5. **Audit Setup**: `sql/dml/audit/` (audit examples and testing)

---

## 🔐 Security Considerations

### **Data Protection**
- Sensitive user data is handled through audit logging
- All functions include proper input validation
- Stored procedures implement transaction safety

### **Access Control**
```sql
-- Example role-based access
GRANT EXECUTE ON FUNCTION vibesia_schema.get_top_song() TO app_readonly;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA vibesia_schema TO app_readwrite;
```

### **Audit Trail**
- All data changes are automatically logged
- Audit functions track user actions and system changes
- Historical data preservation for compliance

---

## 🎓 Educational Context & Learning Outcomes

### **Database Skills Demonstrated**
- **Data Modeling**: Proper normalization and relationship management
- **Transaction Management**: ACID compliance and rollback strategies
- **Function Development**: Reusable SQL logic and optimization
- **Stored Procedures**: Dynamic operations and parameter handling
- **Audit Systems**: Change tracking and data lineage

### **Real-World Applications**
- **Music Streaming Platforms**: Spotify, Apple Music, YouTube Music
- **E-commerce**: Product catalogs and user behavior tracking
- **Social Media**: User engagement and content recommendation
- **Analytics Platforms**: Business intelligence and reporting systems

### **Technical Concepts**
- **Modular Architecture**: Separation of concerns and maintainability
- **Data Pipeline Design**: ETL processes and batch operations
- **API Backend Support**: Database-driven application development
- **Performance Engineering**: Query optimization and indexing strategies

---

## 🔧 Troubleshooting

### **Common Issues**

**Data Loading Failures:**
```sql
-- Check foreign key constraints
SELECT constraint_name, table_name 
FROM information_schema.table_constraints 
WHERE constraint_type = 'FOREIGN KEY' 
AND table_schema = 'vibesia_schema';
```

**Function Execution Errors:**
```sql
-- Verify function exists
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'vibesia_schema';
```

**Permission Issues:**
```sql
-- Check user privileges
SELECT grantee, privilege_type, table_name 
FROM information_schema.role_table_grants 
WHERE table_schema = 'vibesia_schema';
```

---

## 📚 Documentation References

### **Internal Documentation**
- **Database Schema**: `../ddl/README.md`
- **Complex Queries**: `../queries/README.md`
- **Pipeline Automation**: `../pipelines/README.md`
- **Project Overview**: `../../README.md`

---

## 📬 Support & Contact

### **Getting Help**
1. **First**: Check the specific subfolder README
2. **Issues**: Open GitHub issue with specific error details
3. **Questions**: Use GitHub discussions for general questions
4. **Contributions**: Follow the contributing guidelines above

---

## 📜 License & Usage

This project is developed for educational purposes as part of a university database systems course. All scripts and documentation are available under the MIT License for learning and academic use.

**Academic Citation:**
```
MusicApp Vibesia - DML Layer
GitHub: https://github.com/JuanDavidJR/ProyectoFinal-BD
```

---

**Engineered with 🎵 and 💻 by the Ad-Astra Team**