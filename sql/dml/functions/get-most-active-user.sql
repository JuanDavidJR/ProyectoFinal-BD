-- Function to get the most active user based on playback history
-- This function retrieves the user with the highest number of song reproductions
CREATE OR REPLACE FUNCTION vibesia_schema.get_most_active_user()
RETURNS TABLE (
    user_id INTEGER,
    username VARCHAR,
    total_reproductions BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM vibesia_schema.playback_history ph
        JOIN vibesia_schema.users u ON u.user_id = ph.user_id
        WHERE ph.completed = TRUE AND u.is_active = TRUE
    ) THEN
        RAISE NOTICE 'No hay usuarios activos con reproducciones completadas';
        RETURN;
    END IF;

    RETURN QUERY
    SELECT u.user_id, u.username, COUNT(*) AS total_reproductions
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.users u ON u.user_id = ph.user_id
    WHERE ph.completed = TRUE      
      AND u.is_active = TRUE       
    GROUP BY u.user_id, u.username
    ORDER BY total_reproductions DESC
    LIMIT 5;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener el usuario más activo: %', SQLERRM;
END;
$$;



-- To get the most active user in the platform
SELECT * FROM vibesia_schema.get_most_active_user();