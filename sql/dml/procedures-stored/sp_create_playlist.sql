--##################################################
--#              CREATE_PLAYLIST PROCEDURE         #
--##################################################

CREATE OR REPLACE PROCEDURE vibesia_schema.sp_create_playlist(
    OUT p_playlist_id INTEGER,      -- Output: ID of the newly created playlist (if successful)
    OUT p_success BOOLEAN,          -- Output: TRUE if successful, FALSE otherwise
    OUT p_message TEXT,             -- Output: Status message or error description
    p_user_id INTEGER,              -- Input: ID of the user creating the playlist
    p_name VARCHAR(100),            -- Input: Name for the new playlist
    p_description TEXT DEFAULT NULL, -- Input: (Optional) Description for the playlist
    p_status VARCHAR(20) DEFAULT 'private' -- Input: (Optional) Status of the playlist ('public' or 'private'), defaults to 'private'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_exists BOOLEAN;          -- Variable to check if the user exists
    v_name_exists BOOLEAN;          -- Variable to check if a playlist with the same name already exists for the user
BEGIN
    -- Initialize output parameters
    p_playlist_id := NULL;
    p_success := FALSE;
    p_message := '';

    -- Input validations
    IF p_user_id IS NULL THEN
        p_message := 'User ID is required.'; -- Message translated
        RETURN;
    END IF;

    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        p_message := 'Playlist name is required.'; -- Message translated
        RETURN;
    END IF;

    IF p_status NOT IN ('public', 'private') THEN
        p_message := 'Status must be ''public'' or ''private''.'; -- Message translated
        RETURN;
    END IF;

    -- Verify user exists
    SELECT EXISTS(SELECT 1 FROM vibesia_schema.users WHERE user_id = p_user_id)
    INTO v_user_exists;

    IF NOT v_user_exists THEN
        p_message := 'The specified user does not exist.'; -- Message translated
        RETURN;
    END IF;

    -- Check for duplicate playlist name for the same user
    SELECT EXISTS(
        SELECT 1 FROM vibesia_schema.playlists
        WHERE user_id = p_user_id AND name = p_name
    ) INTO v_name_exists;

    IF v_name_exists THEN
        p_message := 'You already have a playlist with that name.'; -- Message translated
        RETURN;
    END IF;

    -- Create the playlist
    INSERT INTO vibesia_schema.playlists (
        user_id, name, description, status, creation_date
    ) VALUES (
        p_user_id, p_name, p_description, p_status, CURRENT_TIMESTAMP
    ) RETURNING playlist_id INTO p_playlist_id; -- Get the ID of the newly inserted playlist

    p_success := TRUE;
    p_message := 'Playlist created successfully.'; -- Message translated

EXCEPTION
    WHEN OTHERS THEN
        p_success := FALSE;
        p_message := 'Error creating playlist: ' || SQLERRM;
END;
$$;



-- Example usage:
-- to create a playlist with a valid user ID and name
DO $$
DECLARE
    v_playlist_id INTEGER;
    v_success BOOLEAN;
    v_message TEXT;
BEGIN
    CALL vibesia_schema.sp_create_playlist(
        p_user_id     => 4,
        p_name        => 'My Newest Mix',
        p_success     => v_success,
        p_message     => v_message,
        p_playlist_id => v_playlist_id
    );
    RAISE NOTICE 'Scenario 1 - NULL User ID: Success: %, Playlist ID: %, Message: %', v_success, v_playlist_id, v_message;
END $$;

-- verify that the playlist is created successfully and the ID is returned
-- select * from vibesia_schema.playlists where user_id = 4;