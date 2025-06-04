-- --------------------------------------------------------------------
-- Query 5: USER LOYALTY ANALYSIS WITH CORRELATED SUBQUERIES
-- --------------------------------------------------------------------
-- Objective: Evaluate user loyalty by analyzing their historical and recent activity,
-- listening consistency, artist diversity, and engagement with playlists.
-- Techniques:
--   - Correlated scalar subqueries to obtain various activity metrics per user.
--   - Temporal analysis: active months, days since last play, recent playlist activity.
--   - Retention metrics: calculation of `avg_plays_per_active_month`.
--   - CASE to segment users into loyalty categories.
-- Result: A loyalty profile for each user, including their playback history,
-- consistency, recent activity, and an assigned loyalty segment.
-- --------------------------------------------------------------------
SELECT
    u.user_id,
    u.username,
    u.registration_date,
    -- Basic activity metrics
    (SELECT COUNT(*)
     FROM vibesia_schema.playback_history ph1
     WHERE ph1.user_id = u.user_id) AS lifetime_plays, -- Total historical plays

    -- Temporal consistency analysis (last 6 months by month)
    (SELECT COUNT(DISTINCT DATE_TRUNC('month', ph2.playback_date))
     FROM vibesia_schema.playback_history ph2
     WHERE ph2.user_id = u.user_id
       AND ph2.playback_date >= CURRENT_DATE - INTERVAL '6 months') AS active_months_last_6, -- Active months in the last 6 months

    -- Average plays per active month
    (SELECT ROUND(COUNT(*)::DECIMAL / NULLIF(COUNT(DISTINCT DATE_TRUNC('month', ph3.playback_date)), 0), 2)
     FROM vibesia_schema.playback_history ph3
     WHERE ph3.user_id = u.user_id
       AND ph3.playback_date >= CURRENT_DATE - INTERVAL '1 year') AS avg_plays_per_active_month, -- Average plays per active month in the last year

    -- Days since last playback
    (SELECT EXTRACT(DAYS FROM CURRENT_DATE - MAX(ph4.playback_date))
     FROM vibesia_schema.playback_history ph4
     WHERE ph4.user_id = u.user_id) AS days_since_last_play, -- Days since last playback

    -- Artist diversity analysis
    (SELECT COUNT(DISTINCT ar.artist_id)
     FROM vibesia_schema.playback_history ph5
     JOIN vibesia_schema.songs s ON ph5.song_id = s.song_id
     JOIN vibesia_schema.albums al ON s.album_id = al.album_id
     JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
     WHERE ph5.user_id = u.user_id) AS unique_artists_played, -- Unique artists listened to

    -- Song completion rate
    (SELECT ROUND(AVG(CASE WHEN ph6.completed THEN 1.0 ELSE 0.0 END) * 100, 2)
     FROM vibesia_schema.playback_history ph6
     WHERE ph6.user_id = u.user_id) AS completion_rate_pct, -- Song completion rate in percentage

    -- Playlist activity as an engagement indicator
    (SELECT COUNT(*)
     FROM vibesia_schema.playlists p
     WHERE p.user_id = u.user_id
       AND p.creation_date >= CURRENT_DATE - INTERVAL '3 months') AS recent_playlists_created, -- Playlists created in the last 3 months

    -- Loyalty classification based on multiple factors
    CASE
        WHEN (SELECT COUNT(*) FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id AND ph.playback_date >= CURRENT_DATE - INTERVAL '7 days') > 0
         AND (SELECT COUNT(DISTINCT DATE_TRUNC('month', ph.playback_date)) FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id AND ph.playback_date >= CURRENT_DATE - INTERVAL '6 months') >= 4
        THEN 'Highly Loyal'
        WHEN (SELECT COUNT(*) FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id AND ph.playback_date >= CURRENT_DATE - INTERVAL '30 days') > 0
         AND (SELECT COUNT(DISTINCT DATE_TRUNC('month', ph.playback_date)) FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id AND ph.playback_date >= CURRENT_DATE - INTERVAL '6 months') >= 2
        THEN 'Moderately Loyal'
        WHEN (SELECT COUNT(*) FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id AND ph.playback_date >= CURRENT_DATE - INTERVAL '90 days') > 0
        THEN 'Occasional'
        ELSE 'Inactive'
    END AS loyalty_segment -- User loyalty segment

FROM vibesia_schema.users u
WHERE u.is_active = TRUE
  AND u.registration_date <= CURRENT_DATE - INTERVAL '1 month' -- Users registered at least 1 month ago
  AND EXISTS (SELECT 1 FROM vibesia_schema.playback_history ph WHERE ph.user_id = u.user_id) -- With playback history
ORDER BY lifetime_plays DESC, active_months_last_6 DESC;