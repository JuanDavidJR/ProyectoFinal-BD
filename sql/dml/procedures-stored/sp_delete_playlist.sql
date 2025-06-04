--##################################################
--#             DELETE_PLAYLIST PROCEDURE          #
--##################################################

CREATE OR REPLACE PROCEDURE vibesia_schema.sp_delete_playlist(
    OUT p_success BOOLEAN,          -- Output: TRUE if successful, FALSE otherwise
    OUT p_message TEXT,             -- Output: Status message or error description
    OUT p_songs_removed INTEGER,    -- Output: Number of songs that were in the playlist (and thus removed from playlist_songs)
    p_playlist_id INTEGER,          -- Input: ID of the playlist to be deleted
    p_user_id INTEGER               -- Input: ID of the user attempting to delete the playlist (for permission check)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_playlist_exists BOOLEAN;      -- Variable to check if the playlist exists
    v_user_owns_playlist BOOLEAN;   -- Variable to check if the user owns the playlist
    v_playlist_name VARCHAR(100);   -- Variable to store playlist name (currently not used in output message but fetched)
BEGIN
    -- Initialize output parameters
    p_success := FALSE;
    p_message := '';
    p_songs_removed := 0;

    -- Input validations
    IF p_playlist_id IS NULL THEN
        p_message := 'Playlist ID is required.'; -- Message translated
        RETURN;
    END IF;

    IF p_user_id IS NULL THEN
        p_message := 'User ID is required.'; -- Message translated
        RETURN;
    END IF;

    -- Verify playlist exists and get ownership status
    SELECT
        EXISTS(SELECT 1 FROM vibesia_schema.playlists WHERE playlist_id = p_playlist_id),
        EXISTS(SELECT 1 FROM vibesia_schema.playlists
              WHERE playlist_id = p_playlist_id AND user_id = p_user_id),
        COALESCE((SELECT name FROM vibesia_schema.playlists WHERE playlist_id = p_playlist_id), '') -- Fetch name, default to empty if not found
    INTO v_playlist_exists, v_user_owns_playlist, v_playlist_name;

    IF NOT v_playlist_exists THEN
        p_message := 'The specified playlist does not exist.'; -- Message translated
        RETURN;
    END IF;

    IF NOT v_user_owns_playlist THEN
        p_message := 'You do not have permission to delete this playlist.'; -- Message translated
        RETURN;
    END IF;

    -- Count songs in playlist before deletion from playlist_songs
    SELECT COUNT(*) INTO p_songs_removed
    FROM vibesia_schema.playlist_songs
    WHERE playlist_id = p_playlist_id;

    -- Delete the playlist from the playlists table.
    -- IMPORTANT: This relies on ON DELETE CASCADE on the foreign key
    -- from playlist_songs.playlist_id to playlists.playlist_id.
    -- If ON DELETE CASCADE is not set, this DELETE will fail if there are
    -- songs in playlist_songs referencing this playlist.
    -- If no CASCADE, you MUST delete from playlist_songs first:
    -- DELETE FROM vibesia_schema.playlist_songs WHERE playlist_id = p_playlist_id;
    DELETE FROM vibesia_schema.playlists
    WHERE playlist_id = p_playlist_id;

    p_success := TRUE;
    p_message := 'Playlist deleted successfully.'; -- Message translated
    -- p_songs_removed already holds the count of songs that were associated with the playlist.

EXCEPTION
    WHEN OTHERS THEN
        p_success := FALSE;
        p_message := 'Error deleting playlist: ' || SQLERRM;
        p_songs_removed := 0; -- Reset on error
END;
$$;


-- Example usage:
-- 
DO $$
DECLARE
    v_success BOOLEAN;
    v_message TEXT;
    v_songs_removed INTEGER;
BEGIN
    CALL vibesia_schema.sp_delete_playlist(
        p_playlist_id => 10,
        p_user_id     => 1,
        p_success     => v_success,
        p_message     => v_message,
        p_songs_removed => v_songs_removed
    );
    RAISE NOTICE 'Scenario 1 - NULL Playlist ID: Success: %, Songs Removed: %, Message: %', v_success, v_songs_removed, v_message;
END $$;
-- Expected: v_success = FALSE, v_songs_removed = 0, v_message = 'Playlist ID is required.'
--verify with a valid playlist ID and user ID
--select * from vibesia_schema.playlists where playlist_id = 10;
