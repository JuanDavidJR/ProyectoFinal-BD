-- --------------------------------------------------------------------
-- Query 7: PLAYLIST ANALYSIS AND CURATION PATTERNS
-- --------------------------------------------------------------------
-- Objective: Analyze playlists in terms of their content (number of songs, diversity of genres and artists),
-- duration, popularity of their songs, and update activity.
-- Techniques:
--   - CTE `playlist_analytics` to calculate metrics per playlist.
--   - Multiple Joins to connect playlists, users, and songs (implicit in subqueries).
--   - Correlated scalar subqueries to calculate diversity, duration, average song popularity, and recent additions.
--   - Aggregations: COUNT, SUM, AVG.
--   - Window functions: DENSE_RANK() to rank by popularity and diversity.
--   - CASE to classify activity level and curation quality.
-- Result: A detailed analysis of playlists, showing their composition, popularity,
-- update frequency, and quality rankings.
-- --------------------------------------------------------------------
WITH playlist_analytics AS (
    SELECT
        p.playlist_id,
        p.name AS playlist_name,
        u.username AS creator,
        p.creation_date,
        p.status,
        COUNT(ps.song_id) AS total_songs, -- Total songs in the playlist
        -- Genre diversity in the playlist
        (SELECT COUNT(DISTINCT g.genre_id)
         FROM vibesia_schema.playlist_songs ps2
         JOIN vibesia_schema.songs s ON ps2.song_id = s.song_id
         JOIN vibesia_schema.song_genres sg ON s.song_id = sg.song_id
         JOIN vibesia_schema.genres g ON sg.genre_id = g.genre_id
         WHERE ps2.playlist_id = p.playlist_id) AS genre_diversity, -- Number of unique genres in the playlist
        -- Artist diversity
        (SELECT COUNT(DISTINCT ar.artist_id)
         FROM vibesia_schema.playlist_songs ps3
         JOIN vibesia_schema.songs s2 ON ps3.song_id = s2.song_id
         JOIN vibesia_schema.albums al ON s2.album_id = al.album_id
         JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
         WHERE ps3.playlist_id = p.playlist_id) AS artist_diversity, -- Number of unique artists in the playlist
        -- Total duration of the playlist
        (SELECT SUM(s3.duration)
         FROM vibesia_schema.playlist_songs ps4
         JOIN vibesia_schema.songs s3 ON ps4.song_id = s3.song_id
         WHERE ps4.playlist_id = p.playlist_id) AS total_duration_seconds, -- Total playlist duration in seconds
        -- Popularity of songs in the playlist
        (SELECT AVG(song_popularity.play_count)
         FROM (SELECT COUNT(ph.playback_id) as play_count
               FROM vibesia_schema.playlist_songs ps5
               JOIN vibesia_schema.playback_history ph ON ps5.song_id = ph.song_id
               WHERE ps5.playlist_id = p.playlist_id
               GROUP BY ps5.song_id) AS song_popularity) AS avg_song_popularity, -- Average popularity of songs in the playlist (based on their total plays)
        -- Update frequency (recently added songs)
        (SELECT COUNT(*)
         FROM vibesia_schema.playlist_songs ps6
         WHERE ps6.playlist_id = p.playlist_id
           AND ps6.date_added >= CURRENT_DATE - INTERVAL '30 days') AS recent_additions -- Songs added in the last 30 days
    FROM vibesia_schema.playlists p
    JOIN vibesia_schema.users u ON p.user_id = u.user_id
    LEFT JOIN vibesia_schema.playlist_songs ps ON p.playlist_id = ps.playlist_id
    GROUP BY p.playlist_id, p.name, u.username, p.creation_date, p.status
    HAVING COUNT(ps.song_id) > 0 -- Considers only playlists with songs
)
SELECT
    playlist_name,
    creator,
    creation_date,
    status,
    total_songs,
    genre_diversity,
    artist_diversity,
    ROUND(total_duration_seconds / 3600.0, 2) AS total_hours, -- Total duration in hours
    ROUND(avg_song_popularity, 2) AS avg_song_popularity,
    recent_additions,
    -- Playlist quality metrics
    ROUND(genre_diversity::DECIMAL / NULLIF(total_songs, 0) * 100, 2) AS genre_diversity_pct, -- Genre diversity percentage
    ROUND(artist_diversity::DECIMAL / NULLIF(total_songs, 0) * 100, 2) AS artist_diversity_pct, -- Artist diversity percentage
    -- Activity classification
    CASE
        WHEN recent_additions > 5 THEN 'Very Active'
        WHEN recent_additions > 2 THEN 'Active'
        WHEN recent_additions > 0 THEN 'Moderately Active'
        ELSE 'Inactive'
    END AS activity_level, -- Playlist activity level
    -- Curation classification (based on diversity and popularity)
    CASE
        WHEN genre_diversity >= 5 AND avg_song_popularity > 100 THEN 'Excellent Curation'
        WHEN genre_diversity >= 3 AND avg_song_popularity > 50 THEN 'Good Curation'
        WHEN genre_diversity >= 2 THEN 'Basic Curation'
        ELSE 'Limited Curation'
    END AS curation_quality, -- Playlist curation quality
    DENSE_RANK() OVER (ORDER BY avg_song_popularity DESC) AS popularity_rank, -- Playlist popularity rank
    DENSE_RANK() OVER (ORDER BY genre_diversity DESC) AS diversity_rank -- Playlist diversity rank
FROM playlist_analytics
WHERE total_songs >= 5 -- Filters playlists with at least 5 songs
ORDER BY avg_song_popularity DESC, genre_diversity DESC;