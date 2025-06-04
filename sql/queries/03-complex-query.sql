-- --------------------------------------------------------------------
-- Query 3: ALBUM COHESION AND DURATION ANALYSIS WITH ADVANCED METRICS
-- --------------------------------------------------------------------
-- Objective: Evaluate albums in terms of their structure (number of songs, duration),
-- popularity (plays, unique listeners), and cohesion (variability in song duration).
-- Techniques:
--   - CTE `album_metrics` to calculate metrics per album.
--   - Multiple Joins to combine data from albums, artists, and songs.
--   - Aggregations: COUNT, SUM, AVG, STDDEV, MIN, MAX.
--   - Correlated scalar subqueries to get total plays, unique listeners, and recent plays per album.
--   - Window functions: DENSE_RANK() to rank albums by general popularity and by release year.
--   - CASE to categorize the album's cohesion level.
-- Result: A list of albums with details about their content, duration, popularity,
-- song duration consistency, and popularity rankings.
-- --------------------------------------------------------------------
WITH album_metrics AS (
    SELECT
        al.album_id,
        al.title AS album_title,
        ar.name AS artist_name,
        ar.country,
        al.release_year,
        al.album_type,
        COUNT(s.song_id) AS total_songs,             -- Total songs in the album
        SUM(s.duration) AS total_duration_seconds,   -- Total album duration in seconds
        AVG(s.duration) AS avg_song_duration,        -- Average song duration
        STDDEV(s.duration) AS duration_stddev,       -- Standard deviation of song duration (cohesion)
        MIN(s.duration) AS shortest_song,            -- Duration of the shortest song
        MAX(s.duration) AS longest_song,             -- Duration of the longest song
        -- Popularity metrics
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph
         JOIN vibesia_schema.songs s2 ON ph.song_id = s2.song_id
         WHERE s2.album_id = al.album_id) AS total_album_plays, -- Total plays of songs from the album
        (SELECT COUNT(DISTINCT ph.user_id)
         FROM vibesia_schema.playback_history ph
         JOIN vibesia_schema.songs s3 ON ph.song_id = s3.song_id
         WHERE s3.album_id = al.album_id) AS unique_listeners, -- Unique listeners of the album
        -- Temporal popularity analysis
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph
         JOIN vibesia_schema.songs s4 ON ph.song_id = s4.song_id
         WHERE s4.album_id = al.album_id
           AND ph.playback_date >= CURRENT_DATE - INTERVAL '6 months') AS recent_plays -- Plays in the last 6 months
    FROM vibesia_schema.albums al
    JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
    JOIN vibesia_schema.songs s ON al.album_id = s.album_id
    GROUP BY al.album_id, al.title, ar.name, ar.country, al.release_year, al.album_type
    HAVING COUNT(s.song_id) >= 3 -- Considers only albums with at least 3 songs
)
SELECT
    album_title,
    artist_name,
    country,
    release_year,
    album_type,
    total_songs,
    ROUND(total_duration_seconds / 60.0, 2) AS total_duration_minutes, -- Total duration in minutes
    ROUND(avg_song_duration / 60.0, 2) AS avg_song_minutes,           -- Average song duration in minutes
    ROUND(duration_stddev / 60.0, 2) AS duration_consistency_minutes, -- Duration consistency in minutes
    total_album_plays,
    unique_listeners,
    recent_plays,
    ROUND(total_album_plays::DECIMAL / NULLIF(total_songs, 0), 2) AS plays_per_song, -- Average plays per song
    ROUND(recent_plays::DECIMAL / NULLIF(total_album_plays, 0) * 100, 2) AS recent_popularity_pct, -- Percentage of recent popularity
    -- Cohesion classification based on standard deviation
    CASE
        WHEN duration_stddev < 30 THEN 'Very Cohesive'
        WHEN duration_stddev < 60 THEN 'Cohesive'
        WHEN duration_stddev < 120 THEN 'Moderately Varied'
        ELSE 'Very Varied'
    END AS cohesion_level, -- Album cohesion level
    DENSE_RANK() OVER (ORDER BY total_album_plays DESC) AS popularity_rank, -- General popularity rank
    DENSE_RANK() OVER (PARTITION BY release_year ORDER BY total_album_plays DESC) AS year_rank -- Popularity rank within its release year
FROM album_metrics
WHERE total_album_plays > 0 -- Filters albums with no plays
ORDER BY total_album_plays DESC, unique_listeners DESC;