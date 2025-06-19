# 🎵 Vibesia Playback History Generator

This Python script generates **realistic playback history records** for the `Vibesia MusicDB` PostgreSQL database. It creates smart data that respects foreign keys, simulates user behavior, and is optimized for efficient bulk insertion.

---

## 📌 Key Features

- ✅ Connects to a PostgreSQL database using configurable credentials  
- 🧠 Simulates realistic listening behavior (e.g., fan communities, popular songs, sessions)  
- 📈 Generates up to **50,000+ playback records** with controlled randomization  
- 🔁 Supports re-runnable logic using conflict handling on insertion  
- 🚀 Uses `psycopg2`, `Faker`, and `NumPy` for fast and reliable data generation  
- 🎯 Prepares your system for testing analytics, queries, and dashboards  

---

## 🛠️ Requirements  

Make sure you have the following installed:  

```bash  
pip install psycopg2 faker numpy tqdm  
```  

---  

## ⚙️ Database Configuration  

Before running the script, ensure your PostgreSQL database has been created using the following setup:  

```sql  
-- 1. Create user  
CREATE USER music_admin WITH PASSWORD 'YOUR-PASSWORD';  

-- 2. Create database  
CREATE DATABASE musicdb   
WITH ENCODING='UTF8'   
LC_COLLATE='es_CO.utf-8'   
LC_CTYPE='es_CO.utf-8'   
TEMPLATE=template0   
OWNER=music_admin;  

-- 3. Grant privileges  
GRANT ALL PRIVILEGES ON DATABASE musicdb TO music_admin;  

-- 4. Create schema  
CREATE SCHEMA IF NOT EXISTS vibesia_schema AUTHORIZATION music_admin;  

-- 5. Optional comments  
COMMENT ON DATABASE musicdb IS 'system database for music management';  
COMMENT ON SCHEMA vibesia_schema IS 'main schema for the musicdb database';  
```  

Update your Python script with the following credentials:  

```python  
DB_CONFIG = {  
    'dbname': 'musicdb',  
    'user': 'music_admin',  
    'password': 'YOUR-PASSWORD',  
    'host': 'localhost',  
    'port': '5432'  
}  
```  

---  

## 📂 Table Prerequisites  

The script assumes the existence of the following tables:  

* `vibesia_schema.users (user_id)`  
* `vibesia_schema.songs (song_id)`  
* `vibesia_schema.devices (device_id)`  
* `vibesia_schema.albums (album_id)`  
* `vibesia_schema.artists (artist_id)`  
* `vibesia_schema.playback_history` with at least the following columns:  

  * `user_id`, `song_id`, `device_id`, `playback_date`, `completed`, `rating`  

**Note**: The `playback_history` table should define a unique constraint or primary key across `(user_id, song_id, playback_date)` for the `ON CONFLICT DO NOTHING` clause to work.  

---  

## 🚀 How to Run  

1. Activate your Python environment (if any):  

   ```bash  
   source .venv/bin/activate  
   ```  

    install dependencies

   ```bash  
   pip install psycopg2-binary faker numpy tqdm 
   ```  

2. Run the script:  

   ```bash  
   python generate_playback_history.py  
   ```  

3. Output example:  

   ```  
   ✅ Database connection established.  
   📥 Fetching existing IDs from the database...  
   🎧 Generating 50000 playback records...  
   📤 Inserting records into the database...  
   ✅ 50000 records successfully inserted.  
   🔒 Database connection closed.  
   ```  

---  

## 🧪 Example Use Cases  

* Populate your development or staging environment  
* Test performance of analytics queries  
* Benchmark query plans for clustering or indexing  
* Simulate fan-based engagement behavior  

---  

## � Author  

Carlos Wilches  
📫 [LinkedIn](https://linkedin.com) *(replace with your profile)*  
🎓 Backend Developer & Data Engineer | PostgreSQL + Python Enthusiast  

---  

## 📄 License  

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.  

```  

---

⚠️ Warning: This script was tested on a Friday afternoon. It works. We don’t know *why*, but it works.
