-- ##################################################
-- #        REMOVE_SONG_FROM_PLAYLIST PROCEDURE     #
-- ##################################################

CREATE OR REPLACE PROCEDURE vibesia_schema.sp_remove_song_from_playlist(
    OUT p_success BOOLEAN,      -- Output: TRUE if successful, FALSE otherwise
    OUT p_message TEXT,         -- Output: Status message or error description
    p_playlist_id INTEGER,      -- Input: ID of the playlist to modify
    p_song_id INTEGER,          -- Input: ID of the song to be removed
    p_user_id INTEGER           -- Input: ID of the user performing the action (for permission checks)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_removed_position INTEGER; -- Variable to store the position of the song being removed
BEGIN
    -- 1. Basic input validation
    IF p_playlist_id IS NULL OR p_song_id IS NULL OR p_user_id IS NULL THEN
        p_success := FALSE;
        p_message := 'Playlist ID, Song ID, and User ID are required.';
        RETURN;
    END IF;

    -- 2. Verify that the playlist exists and that the user owns it.
    -- This is a critical security check to prevent unauthorized modifications.
    IF NOT EXISTS (
        SELECT 1 FROM vibesia_schema.playlists
        WHERE playlist_id = p_playlist_id AND user_id = p_user_id
    ) THEN
        p_success := FALSE;
        p_message := 'Playlist not found or you do not have permission to modify it.';
        RETURN;
    END IF;

    -- 3. Get the position of the song to be removed.
    -- This also implicitly confirms that the song is currently in the playlist.
    SELECT position INTO v_removed_position
    FROM vibesia_schema.playlist_songs
    WHERE playlist_id = p_playlist_id AND song_id = p_song_id;

    IF NOT FOUND THEN -- 'NOT FOUND' is true if the SELECT INTO query returned no rows
        p_success := FALSE;
        p_message := 'The specified song is not in this playlist.';
        RETURN;
    END IF;

    -- 4. Delete the target song from the playlist_songs table.
    DELETE FROM vibesia_schema.playlist_songs
    WHERE playlist_id = p_playlist_id AND song_id = p_song_id;

    -- 5. Update the positions of all subsequent songs in the playlist to fill the gap.
    -- This is crucial for maintaining the integrity of the playlist's order.
    -- For example, if a song at position 3 is removed, songs at positions 4, 5, 6...
    -- will be updated to positions 3, 4, 5...
    UPDATE vibesia_schema.playlist_songs
    SET position = position - 1
    WHERE playlist_id = p_playlist_id AND position > v_removed_position;

    -- 6. If all steps complete, set the success status.
    p_success := TRUE;
    p_message := 'Song removed from playlist successfully.';

EXCEPTION
    -- Catch any other unexpected database errors during the transaction.
    WHEN OTHERS THEN
        p_success := FALSE;
        p_message := 'An unexpected error occurred while removing the song: ' || SQLERRM;
END;
$$;