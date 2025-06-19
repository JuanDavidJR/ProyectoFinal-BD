-- ====================================================================
-- SQL SCRIPT FOR DATABASE SCHEMA MIGRATIONS
-- Schema: vibesia_schema
-- ====================================================================
-- This script applies several modifications to the database tables
-- to add new features, constraints, and data fields.
-- ====================================================================


-- 1. Add popularity column to artists table
-- This adds an integer column to the 'artists' table to store a popularity score.
-- A CHECK constraint ensures the value is always between 0 and 100.
ALTER TABLE vibesia_schema.artists 
ADD COLUMN popularity INTEGER DEFAULT 0 CHECK (popularity >= 0 AND popularity <= 100);


-- 2. Add explicit_content column to songs table
-- This adds a boolean flag to the 'songs' table to identify tracks with explicit content.
-- It defaults to 'false' for new entries.
ALTER TABLE vibesia_schema.songs
ADD COLUMN explicit_content BOOLEAN DEFAULT false;


-- 3. Create unique constraint on playlists table
-- This adds a unique constraint on the combination of 'name' and 'user_id' in the 'playlists' table.
-- This prevents a single user from creating multiple playlists with the exact same name.
ALTER TABLE vibesia_schema.playlists
ADD CONSTRAINT uk_playlist_user_name UNIQUE (name, user_id);


-- 4. Add last_reproduction_date field to user_device table
-- This adds a timestamp column to the 'user_device' table.
-- It can be used to track the last time a song was played on a specific user's device.
ALTER TABLE vibesia_schema.user_device
ADD COLUMN last_reproduction_date TIMESTAMP;


-- 5. Add CHECK constraint to albums table for valid release year
-- This adds a CHECK constraint to the 'albums' table to ensure data integrity.
-- It validates that the 'release_year' is between 1900 and the current year.
ALTER TABLE vibesia_schema.albums 
ADD CONSTRAINT chk_release_year_valid
CHECK (release_year >= 1900 AND release_year <= EXTRACT(YEAR FROM CURRENT_DATE));


-- 6. Modify the user's password hash column
-- This alters the existing 'hashed_password' column in the 'users' table to set a default value.
-- Note: This is generally not recommended for production but can be useful for data migration.
ALTER TABLE vibesia_schema.users 
ALTER COLUMN hashed_password SET DEFAULT 'temp_hash';


-- 7. Add a column to mark whether the user is active or not
-- This adds a boolean 'is_active' flag to the 'users' table.
-- It defaults to TRUE and can be used for soft-deleting or deactivating user accounts.
ALTER TABLE vibesia_schema.users
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;


-- 8. Enable cascade delete for playlist songs
-- This modifies the foreign key on 'playlist_songs' that references 'playlists'.
-- It ensures that when a playlist is deleted, all its corresponding song entries are also automatically deleted.
-- This is crucial for maintaining data integrity.
ALTER TABLE vibesia_schema.playlist_songs
DROP CONSTRAINT IF EXISTS playlist_songs_playlist_id_fkey; -- Drop if exists to avoid errors on re-run

ALTER TABLE vibesia_schema.playlist_songs
ADD CONSTRAINT playlist_songs_playlist_id_fkey
FOREIGN KEY (playlist_id) REFERENCES vibesia_schema.playlists(playlist_id)
ON DELETE CASCADE;


-- 9. Enable cascade delete for user playlists
-- This modifies the foreign key on 'playlists' that references 'users'.
-- It ensures that when a user is deleted, all their playlists are also automatically deleted.
-- This fixes the foreign key violation error that occurred during user deletion.
ALTER TABLE vibesia_schema.playlists
DROP CONSTRAINT IF EXISTS playlists_user_id_fkey; -- Drop if exists to avoid errors on re-run

ALTER TABLE vibesia_schema.playlists
ADD CONSTRAINT playlists_user_id_fkey
FOREIGN KEY (user_id) REFERENCES vibesia_schema.users(user_id)
ON DELETE CASCADE;


