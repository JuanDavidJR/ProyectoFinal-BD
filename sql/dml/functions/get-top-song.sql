-- This function retrieves the most played song in the platform
-- and returns its ID, title, and total number of plays. 

CREATE OR REPLACE FUNCTION vibesia_schema.get_top_song()
RETURNS TABLE (
    song_id INTEGER,
    title VARCHAR,
    total_reproducciones BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM vibesia_schema.playback_history 
        WHERE completed = TRUE
    ) THEN
        RAISE NOTICE 'No hay reproducciones completadas en el sistema';
        RETURN;
    END IF;

    RETURN QUERY
    SELECT s.song_id, s.title, COUNT(*) AS total_reproducciones
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.songs s ON s.song_id = ph.song_id
    WHERE ph.completed = TRUE  
    GROUP BY s.song_id, s.title
    ORDER BY total_reproducciones DESC
    LIMIT 5;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener la canción más reproducida: %', SQLERRM;
END;
$$;


-- To get the top song in the platform
SELECT * FROM vibesia_schema.get_top_song();
