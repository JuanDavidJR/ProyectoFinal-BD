--##################################################
--#              ADD_SONG_TO_PLAYLIST PROCEDURE    #
--##################################################

CREATE OR REPLACE PROCEDURE vibesia_schema.sp_add_song_to_playlist(
    OUT p_success BOOLEAN,    -- Output: TRUE if successful, FALSE otherwise
    OUT p_message TEXT,       -- Output: Status message or error description
    p_playlist_id INTEGER,    -- Input: ID of the playlist to add the song to
    p_song_id INTEGER,        -- Input: ID of the song to be added
    p_user_id INTEGER,        -- Input: ID of the user performing the action (for permission checks)
    p_position INTEGER DEFAULT NULL -- Input: Desired position of the song in the playlist (optional, appends if NULL)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_position INTEGER; -- Stores the current maximum position in the playlist
BEGIN
    -- Basic input validation
    IF p_playlist_id IS NULL OR p_song_id IS NULL OR p_user_id IS NULL THEN
        p_success := FALSE;
        p_message := 'Playlist ID, Song ID, and User ID are required.'; -- Message translated
        RETURN;
    END IF;

    -- Verify that playlist exists and belongs to the user
    IF NOT EXISTS (
        SELECT 1 FROM vibesia_schema.playlists
        WHERE playlist_id = p_playlist_id AND user_id = p_user_id
    ) THEN
        p_success := FALSE;
        p_message := 'Playlist does not exist or you do not have permissions.'; -- Message translated
        RETURN;
    END IF;

    -- Verify that song exists
    IF NOT EXISTS (
        SELECT 1 FROM vibesia_schema.songs
        WHERE song_id = p_song_id
    ) THEN
        p_success := FALSE;
        p_message := 'The specified song does not exist.'; -- Message translated
        RETURN;
    END IF;

    -- Verify that song is not already in the playlist
    IF EXISTS (
        SELECT 1 FROM vibesia_schema.playlist_songs
        WHERE playlist_id = p_playlist_id AND song_id = p_song_id
    ) THEN
        p_success := FALSE;
        p_message := 'The song is already in this playlist.'; -- Message translated
        RETURN;
    END IF;

    -- Determine the maximum position in the playlist
    SELECT COALESCE(MAX(position), 0) INTO v_max_position
    FROM vibesia_schema.playlist_songs
    WHERE playlist_id = p_playlist_id;

    -- If position is not specified, set it to the next available position (append)
    IF p_position IS NULL THEN
        p_position := v_max_position + 1;
    ELSIF p_position > v_max_position + 1 THEN -- If specified position is too high, append
        p_position := v_max_position + 1;
    ELSIF p_position <= 0 THEN -- If specified position is invalid (<=0), append
        p_position := v_max_position + 1;
    END IF;
    
    -- If inserting at a position that is less than or equal to the current max position,
    -- (or if p_position was adjusted to be v_max_position + 1 and there are existing songs)
    -- we need to shift subsequent songs.
    IF p_position <= v_max_position +1 AND v_max_position > 0 AND p_position <= v_max_position THEN
        UPDATE vibesia_schema.playlist_songs
        SET position = position + 1
        WHERE playlist_id = p_playlist_id AND position >= p_position;
    END IF;

    -- Insert the song into the playlist
    INSERT INTO vibesia_schema.playlist_songs (
        playlist_id, song_id, position, date_added
    ) VALUES (
        p_playlist_id, p_song_id, p_position, CURRENT_TIMESTAMP
    );

    p_success := TRUE;
    p_message := 'Song added to playlist successfully.'; -- Message translated
EXCEPTION
    WHEN OTHERS THEN
        p_success := FALSE;
        p_message := 'Error adding song to playlist: ' || SQLERRM;
END;
$$;



-- Example usage:
--Add a song to an empty playlist (appends as position 1):
DO $$
DECLARE
    v_success BOOLEAN;
    v_message TEXT;
BEGIN
    CALL vibesia_schema.sp_add_song_to_playlist(
        p_playlist_id => 10,
        p_song_id     => 10,
        p_user_id     => 9, -- Assuming user_id 9 has permission
        -- p_position is NULL, will append
        p_success     => v_success,
        p_message     => v_message
    );
    RAISE NOTICE 'Scenario 1 - Add song 10 (append): Success: %, Message: %', v_success, v_message;
END $$;


-- To verify:
-- SELECT * FROM vibesia_schema.playlist_songs WHERE playlist_id = 10 ORDER BY position;
-- Expected: Song 501 at position 1