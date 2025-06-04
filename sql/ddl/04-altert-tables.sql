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

-- 6. Add a column to store the user's password hash
ALTER TABLE vibesia_schema.users 
ALTER COLUMN hashed_password SET DEFAULT 'temp_hash';

-- 7. Add a column to mark whether the user is active or not
ALTER TABLE vibesia_schema.users
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;