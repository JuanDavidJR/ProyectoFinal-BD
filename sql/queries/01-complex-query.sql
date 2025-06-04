-- ====================================================================
-- COMPLEX QUERIES FOR VIBESIA DATABASE
-- Demonstrating: Multiple Joins, Correlated Subqueries,
-- Advanced Aggregations, and Date/Time Operations
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: COMPLETE ANALYSIS OF MUSICAL TRENDS BY SEASON
-- --------------------------------------------------------------------
-- Objective: Identify trends of genres, artists, and albums across different seasons and years,
-- calculating metrics for popularity, rating, and growth.
-- Techniques:
--   - Common Table Expression (CTE) `seasonal_stats` to pre-aggregate data.
--   - Multiple Joins to connect playback history, songs, albums, artists, genres, and users.
--   - Advanced aggregations: COUNT(*), AVG(rating), COUNT(DISTINCT user_id).
--   - Date operations: EXTRACT(MONTH), EXTRACT(YEAR), CASE to determine the season, INTERVAL.
--   - Window functions: RANK() to rank by season, LAG() to compare with the previous year.
--   - Filtering by date (last 2 years), completed playbacks, and rated playbacks.
-- Result: A list of musical trends by season, showing total plays, average rating,
-- unique listeners, rank within the season, previous year's plays, and growth percentage.
-- --------------------------------------------------------------------
WITH seasonal_stats AS (
    SELECT
        g.name AS genre_name,                 -- Genre name
        ar.name AS artist_name,               -- Artist name
        al.title AS album_title,              -- Album title
        CASE
            WHEN EXTRACT(MONTH FROM ph.playback_date) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM ph.playback_date) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM ph.playback_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Autumn'
        END AS season,                        -- Season of the year
        EXTRACT(YEAR FROM ph.playback_date) AS year, -- Year of playback
        COUNT(*) AS total_plays,              -- Total plays
        AVG(ph.rating) AS avg_rating,         -- Average rating
        COUNT(DISTINCT ph.user_id) AS unique_listeners -- Unique listeners
    FROM vibesia_schema.playbook_history ph
    JOIN vibesia_schema.songs s ON ph.song_id = s.song_id
    JOIN vibesia_schema.albums al ON s.album_id = al.album_id
    JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
    JOIN vibesia_schema.song_genres sg ON s.song_id = sg.song_id
    JOIN vibesia_schema.genres g ON sg.genre_id = g.genre_id
    JOIN vibesia_schema.users u ON ph.user_id = u.user_id
    WHERE ph.playback_date >= CURRENT_DATE - INTERVAL '2 years' -- Considers data from the last 2 years
        AND ph.completed = TRUE                     -- Only completed playbacks
        AND ph.rating IS NOT NULL                   -- Only playbacks with ratings
    GROUP BY g.name, ar.name, al.title, season, year
)
SELECT
    season,
    genre_name,
    artist_name,
    album_title,
    total_plays,
    avg_rating,
    unique_listeners,
    RANK() OVER (PARTITION BY season ORDER BY total_plays DESC) as season_rank, -- Rank by season based on plays
    LAG(total_plays) OVER (PARTITION BY genre_name, artist_name ORDER BY year) as previous_year_plays, -- Plays from the previous year for the same genre/artist
    ROUND(
        ((total_plays - LAG(total_plays) OVER (PARTITION BY genre_name, artist_name ORDER BY year)) * 100.0 /
         NULLIF(LAG(total_plays) OVER (PARTITION BY genre_name, artist_name ORDER BY year), 0)), 2
    ) AS growth_percentage -- Year-over-year growth percentage
FROM seasonal_stats
WHERE total_plays > 50 -- Filters results with a minimum volume of plays
ORDER BY season, total_plays DESC;