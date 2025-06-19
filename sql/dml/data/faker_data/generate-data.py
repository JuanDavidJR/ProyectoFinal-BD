import psycopg2
from faker import Faker
import random
import numpy as np
from datetime import datetime, timedelta
from tqdm import tqdm
from psycopg2.extras import execute_batch

# ==============================================================================
# 1. CONFIGURATION: Replace with your actual database credentials
# ==============================================================================
DB_CONFIG = {
    'dbname': 'musicdb',             # Matches created database
    'user': 'music_admin',           # Matches created user
    'password': 'music-password',    # Local password for user
    'host': 'localhost',             # Local PostgreSQL server
    'port': '5432'                   # Default PostgreSQL port
}
# ==============================================================================

# Number of playback records to generate
NUM_PLAYBACK_RECORDS = 50000

# ==============================================================================
# 2. CORE LOGIC
# ==============================================================================

def connect_db():
    """Establish connection to the PostgreSQL database."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Database connection established.")
        return conn
    except psycopg2.OperationalError as e:
        print(f"❌ Failed to connect to the database: {e}")
        return None

def fetch_existing_ids(cursor, table_name, column_name):
    """Retrieve all existing IDs from a given table and column."""
    cursor.execute(f"SELECT {column_name} FROM vibesia_schema.{table_name}")
    return [row[0] for row in cursor.fetchall()]

def generate_playback_history(conn):
    """Generate realistic playback history data with fan community and crossover logic."""
    cursor = conn.cursor()
    fake = Faker()

    print("📥 Fetching existing IDs from the database...")
    user_ids = fetch_existing_ids(cursor, 'users', 'user_id')
    song_ids = fetch_existing_ids(cursor, 'songs', 'song_id')
    device_ids = fetch_existing_ids(cursor, 'devices', 'device_id')

    print("🎼 Mapping songs to their artists...")
    cursor.execute("""
        SELECT s.song_id, a.artist_id 
        FROM vibesia_schema.songs s 
        JOIN vibesia_schema.albums al ON s.album_id = al.album_id 
        JOIN vibesia_schema.artists a ON al.artist_id = a.artist_id
    """)
    song_to_artist_map = {song: artist for song, artist in cursor.fetchall()}

    # Popularity weights: first 10 songs are more popular
    song_weights = [0.8 if i < 10 else 0.2 for i in range(len(song_ids))]
    song_weights = np.array(song_weights) / sum(song_weights)

    # Define community groups
    rock_fans = user_ids[:len(user_ids) // 2]
    pop_fans = user_ids[len(user_ids) // 2:]

    rock_artists = [1, 6, 8, 11]
    pop_artists = [2, 3, 5, 7]

    rock_songs = [s_id for s_id, a_id in song_to_artist_map.items() if a_id in rock_artists]
    pop_songs = [s_id for s_id, a_id in song_to_artist_map.items() if a_id in pop_artists]

    print(f"🎧 Generating {NUM_PLAYBACK_RECORDS} playback records with crossover logic...")
    
    records_to_insert = []
    crossover_chance = 0.15  # 15% chance of listening to a different genre

    for _ in tqdm(range(NUM_PLAYBACK_RECORDS), desc="Generating Playback History"):
        
        user_id = random.choice(user_ids)
        song_id = None
        is_rock_fan = user_id in rock_fans

        if is_rock_fan:
            # Rock fan usually listens to rock
            if random.random() > crossover_chance and rock_songs:
                song_id = random.choice(rock_songs)
            elif pop_songs:  # crossover
                song_id = random.choice(pop_songs)
        else:
            # Pop fan usually listens to pop
            if random.random() > crossover_chance and pop_songs:
                song_id = random.choice(pop_songs)
            elif rock_songs:  # crossover
                song_id = random.choice(rock_songs)

        # Add randomness with global popularity
        if song_id is None or random.random() < 0.1:
            song_id = int(np.random.choice(song_ids, p=song_weights))

        device_id = random.choice(device_ids)
        playback_date = fake.date_time_between(start_date='-2y', end_date='now')
        completed = random.choices([True, False], weights=[0.85, 0.15])[0]

        rating = None
        if completed and random.random() < 0.7:
            rating = random.randint(3, 5) if random.random() < 0.75 else random.randint(1, 2)

        records_to_insert.append((user_id, song_id, device_id, playback_date, completed, rating))

    print("📤 Inserting records into the database...")
    insert_query = """
    INSERT INTO vibesia_schema.playback_history 
    (user_id, song_id, device_id, playback_date, completed, rating) 
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (user_id, song_id, playback_date) DO NOTHING;
    """

    try:
        execute_batch(cursor, insert_query, records_to_insert)
        conn.commit()
        print(f"✅ {len(records_to_insert)} records successfully inserted.")
    except Exception as e:
        print(f"❌ Failed to insert records: {e}")
    finally:
        cursor.close()

def main():
    """Main function to run the script."""
    conn = connect_db()
    if conn:
        try:
            generate_playback_history(conn)
        except Exception as e:
            print(f"❌ An error occurred during generation: {e}")
        finally:
            conn.close()
            print("🔒 Database connection closed.")

if __name__ == '__main__':
    main()
