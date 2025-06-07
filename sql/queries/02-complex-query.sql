-- ====================================================================
-- COMPLEX QUERIES FOR VIBESIA DATABASE
-- Demonstrating: Correlated Subqueries, Advanced Aggregations,
-- Date/Time Operations, and Complex Filtering
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 2: INFLUENTIAL USERS WITH TEMPORAL BEHAVIOR ANALYSIS
-- --------------------------------------------------------------------
-- Objective: Identify the most active and influential users on the platform by analyzing their
--            playback history, playlist creation, listening diversity, and recent activity.
--            This query helps understand user engagement and pinpoint power users.
--
-- Techniques:
--   - Correlated Scalar Subqueries: Used extensively to calculate specific metrics for each user.
--   - Multiple Joins (Implicit in Subqueries): To access related data.
--   - Complex Aggregations: COUNT(*), COUNT(DISTINCT), AVG.
--   - Date/Time Operations: (CURRENT_DATE - u.registration_date), INTERVAL, DATE_TRUNC.
--   - Filtering:
--       - `u.is_active = TRUE`: Selects only users marked as active.
--       - `EXISTS (...)`: Ensures the user has playback history.
--       - Influence Filter: Compares a user's total plays against a multiple (e.g., 1.0 times)
--         of the average total plays across all users.
--
-- Result: A list of influential users with detailed statistics.
-- --------------------------------------------------------------------
SELECT
    u.user_id,
    u.username,
    u.email,
    (CURRENT_DATE - u.registration_date) AS days_since_registration,
    (SELECT COUNT(*) FROM vibesia_schema.playback_history ph1 WHERE ph1.user_id = u.user_id) AS total_plays,
    (SELECT COUNT(DISTINCT ph2.song_id) FROM vibesia_schema.playback_history ph2 WHERE ph2.user_id = u.user_id) AS unique_songs_played,
    (SELECT COUNT(*) FROM vibesia_schema.playlists p WHERE p.user_id = u.user_id) AS playlists_created,
    COALESCE((SELECT AVG(song_count.cnt)
     FROM (SELECT COUNT(ps.song_id) as cnt
           FROM vibesia_schema.playlists p
           LEFT JOIN vibesia_schema.playlist_songs ps ON ps.playlist_id = p.playlist_id
           WHERE p.user_id = u.user_id
           GROUP BY p.playlist_id) AS song_count), 0) AS avg_songs_per_playlist,
    (SELECT COUNT(*)
     FROM vibesia_schema.playback_history ph3
     WHERE ph3.user_id = u.user_id
       AND ph3.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS plays_last_30_days,
    (SELECT COUNT(DISTINCT DATE_TRUNC('day', ph4.playback_date))
     FROM vibesia_schema.playback_history ph4
     WHERE ph4.user_id = u.user_id
       AND ph4.playback_date >= CURRENT_DATE - INTERVAL '90 days') AS active_days_last_90,
    (SELECT ROUND(AVG(ph5.rating)::numeric, 2)
     FROM vibesia_schema.playback_history ph5
     WHERE ph5.user_id = u.user_id AND ph5.rating IS NOT NULL) AS avg_rating_given,
    (SELECT COUNT(DISTINCT g.genre_id)
     FROM vibesia_schema.playback_history ph6
     JOIN vibesia_schema.songs s ON ph6.song_id = s.song_id
     JOIN vibesia_schema.song_genres sg ON s.song_id = sg.song_id
     JOIN vibesia_schema.genres g ON sg.genre_id = g.genre_id
     WHERE ph6.user_id = u.user_id) AS genres_diversity
FROM vibesia_schema.users u
WHERE u.is_active = TRUE
  AND EXISTS (SELECT 1 FROM vibesia_schema.playback_history ph_exists WHERE ph_exists.user_id = u.user_id)
  AND (SELECT COUNT(*) FROM vibesia_schema.playback_history ph_total_plays WHERE ph_total_plays.user_id = u.user_id) >
      COALESCE((SELECT AVG(user_plays.cnt) * 1.0 -- MODIFIED: Multiplier reduced from 1.5 to 1.0
                FROM (SELECT COUNT(*) as cnt FROM vibesia_schema.playback_history GROUP BY user_id) AS user_plays), 0)
ORDER BY total_plays DESC, genres_diversity DESC;