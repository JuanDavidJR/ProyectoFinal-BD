-- ##################################################
-- #             CREATE_PLAYLIST FUNCTION           #
-- ##################################################

-- Function: vibesia_schema.sp_create_playlist
-- Description: Creates a new playlist for a given user if all input validations pass.
--              It checks for required fields, validates user existence,
--              avoids duplicate playlist names per user, and returns
--              the new playlist ID along with a success status and message.

CREATE OR REPLACE FUNCTION vibesia_schema.sp_create_playlist(
    p_user_id INTEGER,                   -- Input: ID of the user creating the playlist
    p_name VARCHAR(100),                 -- Input: Name for the new playlist
    p_description TEXT DEFAULT NULL,     -- Input: (Optional) Description for the playlist
    p_status VARCHAR(20) DEFAULT 'private' -- Input: (Optional) Status: 'public' or 'private'
)
RETURNS TABLE(                            -- Output columns: result of the operation
    p_playlist_id INTEGER,               -- ID of the newly created playlist
    p_success BOOLEAN,                   -- Operation success flag
    p_message TEXT                       -- Message explaining the result
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_exists BOOLEAN;               -- Flag to check if the user exists
    v_name_exists BOOLEAN;               -- Flag to check for duplicate playlist name
    v_new_playlist_id INTEGER;           -- Local variable to store the new playlist ID
BEGIN
    -- Validate user ID is provided
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT NULL::INTEGER, FALSE, 'User ID is required.';
        RETURN;
    END IF;

    -- Validate playlist name is not null or empty
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        RETURN QUERY SELECT NULL::INTEGER, FALSE, 'Playlist name is required.';
        RETURN;
    END IF;

    -- Validate status value
    IF p_status NOT IN ('public', 'private') THEN
        RETURN QUERY SELECT NULL::INTEGER, FALSE, 'Status must be ''public'' or ''private''.';
        RETURN;
    END IF;

    -- Check if the user exists in the system
    SELECT EXISTS(
        SELECT 1 FROM vibesia_schema.users u WHERE u.user_id = p_user_id
    ) INTO v_user_exists;

    IF NOT v_user_exists THEN
        RETURN QUERY SELECT NULL::INTEGER, FALSE, 'The specified user does not exist.';
        RETURN;
    END IF;

    -- Check if a playlist with the same name already exists for the user
    SELECT EXISTS(
        SELECT 1 FROM vibesia_schema.playlists pl
        WHERE pl.user_id = p_user_id AND pl.name = p_name
    ) INTO v_name_exists;

    IF v_name_exists THEN
        RETURN QUERY SELECT NULL::INTEGER, FALSE, 'You already have a playlist with that name.';
        RETURN;
    END IF;

    -- Insert the new playlist into the database
    INSERT INTO vibesia_schema.playlists (
        user_id, name, description, status, creation_date
    ) VALUES (
        p_user_id, p_name, p_description, p_status, CURRENT_TIMESTAMP
    )
    RETURNING playlists.playlist_id INTO v_new_playlist_id; -- Capture the new playlist ID

    -- Return success result
    RETURN QUERY SELECT v_new_playlist_id, TRUE, 'Playlist created successfully.';

EXCEPTION
    WHEN OTHERS THEN
        -- Handle unexpected errors by returning the error message
        RETURN QUERY SELECT NULL::INTEGER, FALSE, 'Error creating playlist: ' || SQLERRM;
END;
$$;

-- Example usage:
-- SELECT * FROM vibesia_schema.sp_create_playlist(1, 'My Playlist', 'Chill vibes', 'private');
