--##################################################
--#                DDL SCRIPT DOCUMENTATION                #
--##################################################
-- This script defines the database structure for a music management system called Vibesia
-- Includes tables for artists, albums, songs, genres, users, playlists, devices, and playback history, 
-- ensuring data integrity, normalization, and performance.
-- The system allows users to manage their music libraries, create playlists, track listening habits,
-- and rate content. It supports the core functionality of cataloging music by artists and albums,
-- organizing songs into playlists, and analyzing user preferences through playback history,
-- The script also includes an audit logging mechanism to track changes across critical tables.

--##################################################
--#              TABLE DEFINITIONS                  #
--##################################################

-- Table: vibesia_schema.artists
-- Brief: Stores information about music artists/bands
CREATE TABLE vibesia_schema.artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    formation_year INTEGER,
    biography TEXT,
    artist_type VARCHAR(30) NOT NULL CHECK (artist_type IN ('soloist', 'band', 'collective')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: vibesia_schema.genres
-- Brief: Catalog of music genres
CREATE TABLE vibesia_schema.genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Table: vibesia_schema.users
-- Brief: System users who can create playlists and have listening history
CREATE TABLE vibesia_schema.users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    preferences TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: vibesia_schema.playlists
-- Brief: User-created collections of songs
CREATE TABLE vibesia_schema.playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'private' CHECK (status IN ('public', 'private')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: vibesia_schema.albums
-- Brief: Music albums released by artists
CREATE TABLE vibesia_schema.albums (
    album_id SERIAL PRIMARY KEY,
    artist_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    release_year INTEGER,
    record_label VARCHAR(100),
    album_type VARCHAR(30) NOT NULL CHECK (album_type IN ('studio', 'live', 'compilation')),
    cover_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: vibesia_schema.devices
-- Brief: User devices for music playback
CREATE TABLE vibesia_schema.devices (
    device_id SERIAL PRIMARY KEY,
    device_type VARCHAR(30) NOT NULL CHECK (device_type IN ('mobile', 'computer', 'tablet', 'other')),
    operating_system VARCHAR(50)
);

-- Table: vibesia_schema.song_genres
-- Brief: Many-to-many relationship between songs and genres
CREATE TABLE vibesia_schema.song_genres (
    song_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (song_id, genre_id)
);

-- Table: vibesia_schema.playlist_songs
-- Brief: Many-to-many relationship between playlists and songs
CREATE TABLE vibesia_schema.playlist_songs (
    playlist_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    date_added TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id)
);

-- Table: vibesia_schema.playback_history
-- Brief: Record of song playbacks by users
CREATE TABLE vibesia_schema.playback_history (
    playback_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    device_id INTEGER NOT NULL,
    playback_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT playback_unique_user_song_time UNIQUE (user_id, song_id, playback_date)
);

-- Table: vibesia_schema.user_device
-- Brief: User device 
CREATE TABLE vibesia_schema.user_device (
    user_id INTEGER NOT NULL,
    device_id INTEGER NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_access TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, device_id)
);


-- Table: vibesia_schema.songs
-- Brief: Individual songs belonging to albums
CREATE TABLE vibesia_schema.songs (
    song_id SERIAL PRIMARY KEY,
    album_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    duration INTEGER NOT NULL,
    track_number INTEGER,
    composer VARCHAR(100),
    lyrics TEXT,
    audio_path VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--##################################################
--#            RELATIONSHIP DEFINITIONS            #
--##################################################

-- Relationships for albums
ALTER TABLE vibesia_schema.albums ADD CONSTRAINT fk_albums_artist 
    FOREIGN KEY (artist_id) REFERENCES vibesia_schema.artists (artist_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for songs
ALTER TABLE vibesia_schema.songs ADD CONSTRAINT fk_songs_album 
    FOREIGN KEY (album_id) REFERENCES vibesia_schema.albums (album_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for playlists
ALTER TABLE vibesia_schema.playlists ADD CONSTRAINT fk_playlists_user 
    FOREIGN KEY (user_id) REFERENCES vibesia_schema.users (user_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for song_genres
ALTER TABLE vibesia_schema.song_genres ADD CONSTRAINT fk_song_genres_song 
    FOREIGN KEY (song_id) REFERENCES vibesia_schema.songs (song_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE vibesia_schema.song_genres ADD CONSTRAINT fk_song_genres_genre 
    FOREIGN KEY (genre_id) REFERENCES vibesia_schema.genres (genre_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for playlist_songs
ALTER TABLE vibesia_schema.playlist_songs ADD CONSTRAINT fk_playlist_songs_playlist 
    FOREIGN KEY (playlist_id) REFERENCES vibesia_schema.playlists (playlist_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE vibesia_schema.playlist_songs ADD CONSTRAINT fk_playlist_songs_song 
    FOREIGN KEY (song_id) REFERENCES vibesia_schema.songs (song_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for playback_history
ALTER TABLE vibesia_schema.playback_history ADD CONSTRAINT fk_playback_history_user 
    FOREIGN KEY (user_id) REFERENCES vibesia_schema.users (user_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE vibesia_schema.playback_history ADD CONSTRAINT fk_playback_history_song 
    FOREIGN KEY (song_id) REFERENCES vibesia_schema.songs (song_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE vibesia_schema.playback_history ADD CONSTRAINT fk_playback_history_device 
    FOREIGN KEY (device_id) REFERENCES vibesia_schema.devices (device_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for user_device
ALTER TABLE vibesia_schema.user_device ADD CONSTRAINT fk_user_device_user 
    FOREIGN KEY (user_id) REFERENCES vibesia_schema.users(user_id) 
     ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE vibesia_schema.user_device  ADD CONSTRAINT fk_user_device_devices 
    FOREIGN KEY (device_id) REFERENCES vibesia_schema.devices(device_id)  
    ON UPDATE CASCADE ON DELETE CASCADE;

--##################################################
--#               ALTER TABLES                     #
--##################################################

-- 1. Add popularity column to artists table
ALTER TABLE vibesia_schema.artists 
ADD COLUMN popularity INTEGER DEFAULT 0 CHECK (popularity BETWEEN 1 AND 100);

-- 2. Add explicit_content column to songs table
ALTER TABLE vibesia_schema.songs
ADD COLUMN explicit_content BOOLEAN DEFAULT false;

-- 3. Create unique constraint on playlists table
ALTER TABLE vibesia_schema.playlists
ADD CONSTRAINT uk_playlist_user_name UNIQUE (name, user_id);

-- 4. Add last_reproduction_date field to user_device table     
ALTER TABLE vibesia_schema.user_device
ADD COLUMN last_reproduction_date TIMESTAMP;

-- 5. Add CHECK constraint to albums table for valid release year
ALTER TABLE vibesia_schema.albums 
ADD CONSTRAINT chk_release_year_valid
CHECK (release_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE));

-- 6. Add a column to store the user's password hash (CORRECTED)
ALTER TABLE vibesia_schema.users 
ADD COLUMN hashed_password VARCHAR(255) NOT NULL DEFAULT 'temp_hash';

-- 7. Add a column to mark whether the user is active or not
ALTER TABLE vibesia_schema.users
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- 8. Enable cascade delete for playlist songs
ALTER TABLE vibesia_schema.playlist_songs
DROP CONSTRAINT IF EXISTS playlist_songs_playlist_id_fkey; -- Drop if exists to avoid errors on re-run

ALTER TABLE vibesia_schema.playlist_songs
ADD CONSTRAINT playlist_songs_playlist_id_fkey
FOREIGN KEY (playlist_id) REFERENCES vibesia_schema.playlists(playlist_id)
ON DELETE CASCADE;

-- 9. Enable cascade delete for user playlists
ALTER TABLE vibesia_schema.playlists
DROP CONSTRAINT IF EXISTS playlists_user_id_fkey; -- Drop if exists to avoid errors on re-run

ALTER TABLE vibesia_schema.playlists
ADD CONSTRAINT playlists_user_id_fkey
FOREIGN KEY (user_id) REFERENCES vibesia_schema.users(user_id)
ON DELETE CASCADE;

--##################################################
--#                AUDIT TABLE                     #
--##################################################
-- Table: vibesia_schema.audit_log
-- Brief: Audit table to track all CRUD operations on system tables
CREATE TABLE vibesia_schema.audit_log (
    audit_id SERIAL PRIMARY KEY,
    db_user_name VARCHAR(100) NOT NULL DEFAULT SESSION_USER,
    app_user_id INTEGER,                           
    app_user_email VARCHAR(255),                     
    app_user_role VARCHAR(50),
    action_type VARCHAR(10) NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')), 
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    table_name VARCHAR(50) NOT NULL,                
    record_id INTEGER, 
    old_values JSONB,                               
    new_values JSONB, 
    connection_ip INET,               
    user_agent TEXT,                                 
    api_endpoint VARCHAR(255),      
    request_id VARCHAR(100),
    application_name VARCHAR(50) DEFAULT 'vibesia_app',
    environment VARCHAR(20) DEFAULT 'production'
);

CREATE INDEX idx_audit_log_app_user_id ON vibesia_schema.audit_log (app_user_id);
CREATE INDEX idx_audit_log_timestamp ON vibesia_schema.audit_log (timestamp);
CREATE INDEX idx_audit_log_table_name ON vibesia_schema.audit_log (table_name);
CREATE INDEX idx_audit_log_action_type ON vibesia_schema.audit_log (action_type);
CREATE INDEX idx_audit_log_record_id ON vibesia_schema.audit_log (table_name, record_id);

--##################################################
--#                CREATE INDEXES                  #
--##################################################

-- Indexes for improving search operations
CREATE INDEX idx_playlists_user_id ON vibesia_schema.playlists(user_id);
CREATE INDEX idx_playback_history_user_id ON vibesia_schema.playback_history(user_id);
CREATE INDEX idx_playback_history_song_id ON vibesia_schema.playback_history(song_id);
CREATE INDEX idx_playback_history_playback_date ON vibesia_schema.playback_history(playback_date);
CREATE INDEX idx_user_device_user_id ON vibesia_schema.user_device(user_id);
CREATE INDEX idx_user_device_device_id ON vibesia_schema.user_device(device_id);

--##################################################
--#            FUNCTIONAL INDEXES                  #
--##################################################
-- For efficient case-insensitive searches
CREATE INDEX idx_users_username_lower ON vibesia_schema.users (LOWER(username));
CREATE INDEX idx_users_email_lower ON vibesia_schema.users (LOWER(email));
CREATE INDEX idx_artists_name_search ON vibesia_schema.artists (LOWER(name));
CREATE INDEX idx_albums_title_search ON vibesia_schema.albums (LOWER(title));
CREATE INDEX idx_songs_title_search ON vibesia_schema.songs (LOWER(title));
CREATE INDEX idx_genres_name_lower ON vibesia_schema.genres (LOWER(name));
CREATE INDEX idx_playlists_name_lower ON vibesia_schema.playlists (LOWER(name));

--##################################################
--#         COMPOSITE INDEXES FOR ANALYTICS       #
--##################################################
-- Playback history analytical indexes
CREATE INDEX idx_playback_history_user_date ON vibesia_schema.playback_history (user_id, playback_date DESC);
CREATE INDEX idx_playback_history_song_date ON vibesia_schema.playback_history (song_id, playback_date DESC);
CREATE INDEX idx_playback_history_device_date ON vibesia_schema.playback_history (device_id, playback_date);
CREATE INDEX idx_playback_history_q1_filters ON vibesia_schema.playback_history (completed, rating, playback_date);
CREATE INDEX idx_q1_grouping_helper ON vibesia_schema.playback_history (song_id, user_id, playback_date);

-- Specialized indexes for performance
CREATE INDEX idx_users_only_active ON vibesia_schema.users (registration_date) WHERE is_active = TRUE;
CREATE INDEX idx_artists_country_name_perf ON vibesia_schema.artists (country, name);
CREATE INDEX idx_playlist_songs_playlist_date_added ON vibesia_schema.playlist_songs (playlist_id, date_added DESC);

--##################################################
--#            FOREIGN KEY INDEXES                 #
--##################################################
-- Additional FK indexes for join optimization
CREATE INDEX idx_songs_album_id_fk ON vibesia_schema.songs (album_id);
CREATE INDEX idx_albums_artist_id_fk ON vibesia_schema.albums (artist_id);

--##################################################
--#               END DOCUMENTATION                #
--##################################################