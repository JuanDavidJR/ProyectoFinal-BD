-- --------------------------------------------------------------------
-- Query 9: MUSICAL ECOSYSTEM ANALYSIS: COLLABORATIONS AND CONNECTIONS
-- --------------------------------------------------------------------
-- Objective: Identify connections between artists (based on shared listeners) and
-- between genres (based on users listening to both), to understand the musical ecosystem.
-- Techniques:
--   - Two CTEs: `artist_connections` to find connected artists and `genre_crossover` for genre overlaps.
--   - Multiple Joins (implicit self-join on `playback_history` for `artist_connections` and `genre_crossover`).
--   - Aggregations: COUNT(DISTINCT), AVG, COUNT.
--   - `UNION ALL` to combine results from both analyses.
--   - Window functions: DENSE_RANK() to rank connection strength.
--   - Filtering to ensure a minimum number of shared connections/listeners.
-- Result: A list of artist pairs and genre pairs with their connection strength,
-- associated average ratings, and temporal affinity.
-- --------------------------------------------------------------------
WITH artist_connections AS (
    -- Finds artists who share listeners
    SELECT
        ar1.artist_id AS artist1_id,
        ar1.name AS artist1_name,
        ar2.artist_id AS artist2_id,
        ar2.name AS artist2_name,
        COUNT(DISTINCT ph1.user_id) AS shared_listeners, -- Number of listeners who have heard both artists
        AVG(ph1.rating) AS avg_rating_artist1,           -- Average rating for artist 1 by these listeners
        AVG(ph2.rating) AS avg_rating_artist2,           -- Average rating for artist 2 by these listeners
        -- Temporal similarity (listened to in similar periods by the same user)
        COUNT(CASE WHEN ABS(EXTRACT(EPOCH FROM ph1.playback_date - ph2.playback_date)) <= 86400 THEN 1 END) AS same_day_plays -- Times both artists were heard by the same user on the same day
    FROM vibesia_schema.playback_history ph1
    JOIN vibesia_schema.songs s1 ON ph1.song_id = s1.song_id
    JOIN vibesia_schema.albums al1 ON s1.album_id = al1.album_id
    JOIN vibesia_schema.artists ar1 ON al1.artist_id = ar1.artist_id
    JOIN vibesia_schema.playback_history ph2 ON ph1.user_id = ph2.user_id -- Join by user to find co-listens
    JOIN vibesia_schema.songs s2 ON ph2.song_id = s2.song_id
    JOIN vibesia_schema.albums al2 ON s2.album_id = al2.album_id
    JOIN vibesia_schema.artists ar2 ON al2.artist_id = ar2.artist_id
    WHERE ar1.artist_id < ar2.artist_id  -- Avoid duplicates (ar1, ar2) and self-connections (ar1, ar1)
        AND ph1.playback_date >= CURRENT_DATE - INTERVAL '1 year'
        AND ph2.playback_date >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY ar1.artist_id, ar1.name, ar2.artist_id, ar2.name
    HAVING COUNT(DISTINCT ph1.user_id) >= 10 -- Minimum of 10 shared listeners
),
genre_crossover AS (
    -- Analyzes genre crossover by user
    SELECT
        g1.name AS genre1,
        g2.name AS genre2,
        COUNT(DISTINCT ph1.user_id) AS users_listening_both, -- Users who listen to both genres
        AVG(ph1.rating) AS avg_rating_genre1,                -- Average rating for genre 1 by these users
        AVG(ph2.rating) AS avg_rating_genre2,                -- Average rating for genre 2 by these users
        COUNT(*) AS total_crossover_plays                    -- Total plays where a user listened to both genres
    FROM vibesia_schema.playback_history ph1
    JOIN vibesia_schema.songs s1 ON ph1.song_id = s1.song_id
    JOIN vibesia_schema.song_genres sg1 ON s1.song_id = sg1.song_id
    JOIN vibesia_schema.genres g1 ON sg1.genre_id = g1.genre_id
    JOIN vibesia_schema.playback_history ph2 ON ph1.user_id = ph2.user_id -- Join by user
    JOIN vibesia_schema.songs s2 ON ph2.song_id = s2.song_id
    JOIN vibesia_schema.song_genres sg2 ON s2.song_id = sg2.song_id
    JOIN vibesia_schema.genres g2 ON sg2.genre_id = g2.genre_id
    WHERE g1.genre_id < g2.genre_id -- Avoid duplicates and self-connections
        AND ph1.playback_date >= CURRENT_DATE - INTERVAL '6 months'
        AND ph2.playback_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY g1.name, g2.name
    HAVING COUNT(DISTINCT ph1.user_id) >= 5 -- Minimum of 5 users listening to both genres
)
SELECT
    'Artist Connection' AS analysis_type, -- Type of analysis
    artist1_name AS entity1,
    artist2_name AS entity2,
    shared_listeners AS connection_strength, -- Strength of connection
    ROUND(avg_rating_artist1, 2) AS rating1,
    ROUND(avg_rating_artist2, 2) AS rating2,
    same_day_plays AS temporal_affinity,      -- Temporal affinity
    DENSE_RANK() OVER (ORDER BY shared_listeners DESC) AS connection_rank -- Connection rank
FROM artist_connections
WHERE shared_listeners >= 15 -- Additional strength filter

UNION ALL

SELECT
    'Genre Crossover' AS analysis_type,
    genre1 AS entity1,
    genre2 AS entity2,
    users_listening_both AS connection_strength,
    ROUND(avg_rating_genre1, 2) AS rating1,
    ROUND(avg_rating_genre2, 2) AS rating2,
    total_crossover_plays AS temporal_affinity,
    DENSE_RANK() OVER (ORDER BY users_listening_both DESC) AS connection_rank
FROM genre_crossover
WHERE users_listening_both >= 8 -- Additional strength filter

ORDER BY connection_strength DESC, analysis_type;