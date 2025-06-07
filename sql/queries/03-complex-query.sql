-- --------------------------------------------------------------------
-- Query 3: ALBUM COHESION AND DURATION ANALYSIS WITH ADVANCED METRICS
-- --------------------------------------------------------------------
-- Objective: Evaluates albums on structure (song count, duration), popularity (plays, listeners),
--            and cohesion (song duration consistency).
-- Techniques:
--   - CTE `album_metrics`: Calculates per-album metrics (song count, total/avg/stddev/min/max duration).
--   - Joins: Combines albums, artists, songs.
--   - Correlated Subqueries (in CTE): Gathers album-specific play counts, unique listeners,
--     and recent plays from `playback_history`.
--   - Aggregations: COUNT, SUM, AVG, STDDEV, MIN, MAX.
--   - Window Functions: DENSE_RANK for overall and per-year popularity ranking.
--   - CASE Statement: Classifies album cohesion based on song duration standard deviation.
--   - Filtering: Includes albums with >= 2 songs and > 0 total plays.
-- Result: Lists albums with details on content, duration, popularity, song duration consistency,
--         and popularity ranks (overall and by release year). Ordered by popularity.
-- --------------------------------------------------------------------
WITH album_metrics AS (
    SELECT
        al.album_id,
        al.title AS album_title,
        ar.name AS artist_name,
        ar.country,
        al.release_year,
        al.album_type,
        COUNT(s.song_id) AS total_songs,
        SUM(s.duration) AS total_duration_seconds,
        AVG(s.duration) AS avg_song_duration,
        COALESCE(STDDEV(s.duration), 0) AS duration_stddev, -- COALESCE for cases with <2 songs if HAVING was <2
        MIN(s.duration) AS shortest_song,
        MAX(s.duration) AS longest_song,
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph
         JOIN vibesia_schema.songs s2 ON ph.song_id = s2.song_id
         WHERE s2.album_id = al.album_id) AS total_album_plays,
        (SELECT COUNT(DISTINCT ph.user_id)
         FROM vibesia_schema.playback_history ph
         JOIN vibesia_schema.songs s3 ON ph.song_id = s3.song_id
         WHERE s3.album_id = al.album_id) AS unique_listeners,
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph
         JOIN vibesia_schema.songs s4 ON ph.song_id = s4.song_id
         WHERE s4.album_id = al.album_id
           AND ph.playback_date >= CURRENT_DATE - INTERVAL '6 months') AS recent_plays
    FROM vibesia_schema.albums al
    JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
    JOIN vibesia_schema.songs s ON al.album_id = s.album_id
    GROUP BY al.album_id, al.title, ar.name, ar.country, al.release_year, al.album_type
    HAVING COUNT(s.song_id) >= 2 -- MODIFIED: Considers albums with at least 2 songs (to match sample data)
                                 -- Adjust to >= 3 or other value for production data if desired.
)
SELECT
    album_title,
    artist_name,
    country,
    release_year,
    album_type,
    total_songs,
    ROUND(total_duration_seconds / 60.0, 2) AS total_duration_minutes,
    ROUND(avg_song_duration / 60.0, 2) AS avg_song_minutes,
    ROUND(duration_stddev / 60.0, 2) AS duration_consistency_minutes,
    total_album_plays,
    unique_listeners,
    recent_plays,
    ROUND(total_album_plays::DECIMAL / NULLIF(total_songs, 0), 2) AS plays_per_song,
    CASE
        WHEN total_album_plays > 0 THEN ROUND(recent_plays::DECIMAL / total_album_plays * 100, 2)
        ELSE 0 -- Avoid division by zero if total_album_plays is 0 (though filtered out by WHERE)
    END AS recent_popularity_pct,
    CASE
        WHEN duration_stddev < 30 THEN 'Very Cohesive'       -- Less than 30 seconds std dev
        WHEN duration_stddev < 60 THEN 'Cohesive'          -- Less than 1 minute std dev
        WHEN duration_stddev < 120 THEN 'Moderately Varied' -- Less than 2 minutes std dev
        ELSE 'Very Varied'
    END AS cohesion_level,
    DENSE_RANK() OVER (ORDER BY total_album_plays DESC, unique_listeners DESC) AS popularity_rank, -- Added unique_listeners as tie-breaker
    DENSE_RANK() OVER (PARTITION BY release_year ORDER BY total_album_plays DESC, unique_listeners DESC) AS year_rank -- Added unique_listeners as tie-breaker
FROM album_metrics
WHERE total_album_plays > 0 -- Filters out albums with no recorded plays
ORDER BY popularity_rank, year_rank; -- Order by the calculated ranks