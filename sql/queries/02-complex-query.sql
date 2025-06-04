-- --------------------------------------------------------------------
-- Query 2: INFLUENTIAL USERS WITH TEMPORAL BEHAVIOR ANALYSIS
-- --------------------------------------------------------------------
-- Objective: Identify the most active and influential users on the platform by analyzing their
-- playback history, playlist creation, listening diversity, and recent activity.
-- Techniques:
--   - Correlated scalar subqueries to calculate specific metrics per user.
--   - Multiple Joins (implicit in subqueries) to access data from playlists, songs, etc.
--   - Complex aggregations: COUNT, COUNT(DISTINCT), AVG.
--   - Date operations: DATE_PART, CURRENT_DATE - INTERVAL.
--   - Filtering to select active users who exceed an activity threshold (1.5 times the average).
-- Result: A list of influential users with detailed statistics about their behavior,
-- tenure, playback activity, playlist management, and taste diversity.
-- --------------------------------------------------------------------
SELECT
    u.user_id,
    u.username,
    u.email,
    DATE_PART('days', CURRENT_DATE - u.registration_date) AS days_since_registration, -- Days since registration
    -- Playback statistics
    (SELECT COUNT(*) FROM vibesia_schema.playback_history ph1 WHERE ph1.user_id = u.user_id) AS total_plays, -- Total plays by the user
    (SELECT COUNT(DISTINCT ph2.song_id) FROM vibesia_schema.playback_history ph2 WHERE ph2.user_id = u.user_id) AS unique_songs_played, -- Unique songs played
    -- Playlist analysis
    (SELECT COUNT(*) FROM vibesia_schema.playlists p WHERE p.user_id = u.user_id) AS playlists_created, -- Playlists created by the user
    (SELECT AVG(song_count.cnt)
     FROM (SELECT COUNT(*) as cnt
           FROM vibesia_schema.playlist_songs ps
           JOIN vibesia_schema.playlists p ON ps.playlist_id = p.playlist_id
           WHERE p.user_id = u.user_id
           GROUP BY p.playlist_id) AS song_count) AS avg_songs_per_playlist, -- Average songs per playlist for the user
    -- Advanced temporal analysis
    (SELECT COUNT(*)
     FROM vibesia_schema.playback_history ph3
     WHERE ph3.user_id = u.user_id
       AND ph3.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS plays_last_30_days, -- Plays in the last 30 days
    (SELECT COUNT(DISTINCT DATE_TRUNC('day', ph4.playback_date))
     FROM vibesia_schema.playback_history ph4
     WHERE ph4.user_id = u.user_id
       AND ph4.playback_date >= CURRENT_DATE - INTERVAL '90 days') AS active_days_last_90, -- Active days in the last 90 days
    -- Average rating and rating behavior
    (SELECT ROUND(AVG(ph5.rating), 2)
     FROM vibesia_schema.playback_history ph5
     WHERE ph5.user_id = u.user_id AND ph5.rating IS NOT NULL) AS avg_rating_given, -- Average rating given by the user
    -- Diversity of genres listened to
    (SELECT COUNT(DISTINCT g.genre_id)
     FROM vibesia_schema.playback_history ph6
     JOIN vibesia_schema.songs s ON ph6.song_id = s.song_id
     JOIN vibesia_schema.song_genres sg ON s.song_id = sg.song_id
     JOIN vibesia_schema.genres g ON sg.genre_id = g.genre_id
     WHERE ph6.user_id = u.user_id) AS genres_diversity -- Number of unique genres listened to
FROM vibesia_schema.users u
WHERE u.is_active = TRUE -- Only active users
  AND EXISTS (SELECT 1 FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id) -- Ensures the user has playback history
  AND (SELECT COUNT(*) FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id) >
      (SELECT AVG(user_plays.cnt) * 1.5 -- Filters users whose activity exceeds 1.5 times the general average
       FROM (SELECT COUNT(*) as cnt FROM vibesia_schema.playback_history GROUP BY user_id) AS user_plays)
ORDER BY total_plays DESC, genres_diversity DESC;