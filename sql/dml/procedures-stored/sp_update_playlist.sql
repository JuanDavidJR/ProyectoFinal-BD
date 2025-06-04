--##################################################
--#             UPDATE_PLAYLIST PROCEDURE          #
--##################################################

CREATE OR REPLACE PROCEDURE vibesia_schema.sp_update_playlist(
    OUT p_success BOOLEAN,          -- Output: TRUE if successful, FALSE otherwise
    OUT p_message TEXT,             -- Output: Status message or error description
    p_playlist_id INTEGER,          -- Input: ID of the playlist to be updated
    p_user_id INTEGER,              -- Input: ID of the user attempting to update (for permission check)
    p_new_name VARCHAR(100) DEFAULT NULL, -- Input: (Optional) New name for the playlist
    p_new_description TEXT DEFAULT NULL, -- Input: (Optional) New description for the playlist
    p_new_status VARCHAR(20) DEFAULT NULL -- Input: (Optional) New status ('public' or 'private')
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_name VARCHAR(100);    -- Stores the current name of the playlist for comparison
BEGIN
    -- Initialize output parameters (p_success and p_message will be set explicitly later)

    -- Basic input validation for required parameters
    IF p_playlist_id IS NULL OR p_user_id IS NULL THEN
        p_success := FALSE;
        p_message := 'Playlist ID and User ID are required.'; -- Message translated
        RETURN;
    END IF;

    -- Validate if playlist exists and belongs to the user, and fetch current name
    SELECT name INTO v_current_name
    FROM vibesia_schema.playlists
    WHERE playlist_id = p_playlist_id AND user_id = p_user_id;

    IF NOT FOUND THEN -- This checks if the SELECT INTO query found a row
        p_success := FALSE;
        p_message := 'Playlist does not exist or you do not have permissions.'; -- Message translated
        RETURN;
    END IF;

    -- Validate new name (if provided and different from current name)
    IF p_new_name IS NOT NULL AND TRIM(p_new_name) = '' THEN -- Check if new name is empty string
        p_success := FALSE;
        p_message := 'Playlist name cannot be empty.'; -- Message translated
        RETURN;
    END IF;

    IF p_new_name IS NOT NULL AND p_new_name != v_current_name THEN
        IF EXISTS (
            SELECT 1 FROM vibesia_schema.playlists
            WHERE user_id = p_user_id AND name = p_new_name AND playlist_id != p_playlist_id -- Exclude current playlist from check
        ) THEN
            p_success := FALSE;
            p_message := 'You already have another playlist with that name.'; -- Message translated
            RETURN;
        END IF;
    END IF;

    -- Validate new status (if provided)
    IF p_new_status IS NOT NULL AND p_new_status NOT IN ('public', 'private') THEN
        p_success := FALSE;
        p_message := 'Status must be ''public'' or ''private''.'; -- Message translated
        RETURN;
    END IF;

    -- Check if at least one updateable field is provided
    IF p_new_name IS NULL AND p_new_description IS NULL AND p_new_status IS NULL THEN
        p_success := FALSE;
        p_message := 'No new information provided to update the playlist.'; -- New message for no-op
        RETURN;
    END IF;
    
    -- Update playlist
    -- COALESCE is used to keep the current value if a new value is not provided (NULL)
    UPDATE vibesia_schema.playlists
    SET name = COALESCE(p_new_name, name),
        description = COALESCE(p_new_description, description),
        status = COALESCE(p_new_status, status),
        updated_at = CURRENT_TIMESTAMP -- Assuming you have an 'updated_at' column
    WHERE playlist_id = p_playlist_id;
    -- Note: If 'updated_at' column doesn't exist, remove that line from the SET clause.

    p_success := TRUE;
    p_message := 'Playlist updated successfully.'; -- Message translated
EXCEPTION
    WHEN OTHERS THEN
        p_success := FALSE;
        p_message := 'Error updating playlist: ' || SQLERRM;
END;
$$;



--example usage:
DO $$
DECLARE
    v_success BOOLEAN;
    v_message TEXT;
BEGIN
    CALL vibesia_schema.sp_update_playlist(
        p_playlist_id     => NULL,
        p_user_id         => 1,
        p_new_name        => 'Updated Name',
        p_success         => v_success,
        p_message         => v_message
    );
    RAISE NOTICE 'Scenario 1 - NULL Playlist ID: Success: %, Message: %', v_success, v_message;
END $$;
-- Expected: v_success = FALSE, v_message = 'Playlist ID and User ID are required.'