-- --------------------------------------------------------------------
-- Query 10: PREDICTIVE USER CHURN ANALYSIS
-- --------------------------------------------------------------------
-- Objective: Identify users at risk of leaving the platform (churn) by analyzing
-- their recent behavior, activity trends, and engagement metrics.
-- Techniques:
--   - Two CTEs: `user_behavior_metrics` to calculate a wide range of metrics per user
--             and `churn_analysis` to calculate risk scores and segmentation.
--   - Extensive correlated scalar subqueries to obtain activity, engagement, and diversity metrics.
--   - Complex temporal analysis: comparison of activity in different periods (last 7, 30, 60, 90 days).
--   - CASE to calculate `activity_trend_pct`, `churn_risk_score`, `activity_segment`,
--          `recommended_action`, and `user_segment`.
--   - Window functions: DENSE_RANK() to prioritize users based on risk.
-- Result: A detailed report per user with their activity segment, churn risk score,
-- activity trend, key behavior metrics, recommended action, and a user segment
-- for targeted strategies. Users are ordered by intervention priority.
-- --------------------------------------------------------------------
WITH user_behavior_metrics AS (
    SELECT
        u.user_id,
        u.username,
        u.registration_date,
        u.email,
        EXTRACT(DAYS FROM CURRENT_DATE - u.registration_date) AS days_since_registration, -- User tenure

        -- Recent activity metrics
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph1
         WHERE ph1.user_id = u.user_id
           AND ph1.playback_date >= CURRENT_DATE - INTERVAL '7 days') AS plays_last_7_days, -- Plays in the last 7 days

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph2
         WHERE ph2.user_id = u.user_id
           AND ph2.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS plays_last_30_days, -- Plays in the last 30 days

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph3
         WHERE ph3.user_id = u.user_id
           AND ph3.playback_date >= CURRENT_DATE - INTERVAL '90 days') AS plays_last_90_days, -- Plays in the last 90 days

        -- Days since last activity
        (SELECT EXTRACT(DAYS FROM CURRENT_DATE - MAX(ph4.playback_date))
         FROM vibesia_schema.playback_history ph4
         WHERE ph4.user_id = u.user_id) AS days_since_last_play, -- Days since last playback

        -- Activity trend (period comparison)
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph5
         WHERE ph5.user_id = u.user_id
           AND ph5.playback_date >= CURRENT_DATE - INTERVAL '60 days'
           AND ph5.playback_date < CURRENT_DATE - INTERVAL '30 days') AS plays_30_60_days_ago, -- Plays between 30 and 60 days ago

        -- Engagement metrics
        (SELECT AVG(CASE WHEN ph6.completed THEN 1.0 ELSE 0.0 END)
         FROM vibesia_schema.playback_history ph6
         WHERE ph6.user_id = u.user_id
           AND ph6.playback_date >= CURRENT_DATE - INTERVAL '90 days') AS completion_rate_last_90_days, -- Completion rate in the last 90 days

        (SELECT COUNT(DISTINCT ph7.song_id)
         FROM vibesia_schema.playback_history ph7
         WHERE ph7.user_id = u.user_id
           AND ph7.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS unique_songs_last_30_days, -- Unique songs listened to in the last 30 days

        -- Playlist activity
        (SELECT COUNT(*)
         FROM vibesia_schema.playlists p1
         WHERE p1.user_id = u.user_id
           AND p1.creation_date >= CURRENT_DATE - INTERVAL '60 days') AS playlists_created_last_60_days, -- Playlists created in the last 60 days

        (SELECT MAX(ps.date_added)
         FROM vibesia_schema.playlists p2
         JOIN vibesia_schema.playlist_songs ps ON p2.playlist_id = ps.playlist_id
         WHERE p2.user_id = u.user_id) AS last_playlist_activity, -- Date of last playlist activity (song addition)

        -- Consumption diversity
        (SELECT COUNT(DISTINCT d.device_id)
         FROM vibesia_schema.playback_history ph8
         JOIN vibesia_schema.devices d ON ph8.device_id = d.device_id
         WHERE ph8.user_id = u.user_id
           AND ph8.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS devices_used_last_30_days, -- Devices used in the last 30 days

        -- Rating pattern
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph9
         WHERE ph9.user_id = u.user_id
           AND ph9.rating IS NOT NULL
           AND ph9.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS ratings_given_last_30_days, -- Ratings given in the last 30 days

        -- Total historical activity for context
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph10
         WHERE ph10.user_id = u.user_id) AS total_lifetime_plays -- Total historical plays
    FROM vibesia_schema.users u
    WHERE u.is_active = TRUE
        AND u.registration_date <= CURRENT_DATE - INTERVAL '30 days'  -- At least 30 days old
),
churn_analysis AS (
    SELECT *,
        -- Activity trend calculation
        CASE
            WHEN plays_last_30_days > 0 AND plays_30_60_days_ago > 0
            THEN ROUND(((plays_last_30_days - plays_30_60_days_ago)::DECIMAL / plays_30_60_days_ago * 100), 2)
            ELSE NULL
        END AS activity_trend_pct, -- Activity trend (last 30d vs 30-60d ago)

        -- Churn risk score (simplified, heuristic)
        CASE
            WHEN days_since_last_play > 60 THEN 100 -- Very high risk
            WHEN days_since_last_play > 30 THEN 80  -- High risk
            WHEN days_since_last_play > 14 THEN 60  -- Moderate-high risk
            WHEN plays_last_7_days = 0 AND plays_last_30_days < 5 THEN 70 -- Concerning recent inactivity
            WHEN plays_last_30_days < plays_30_60_days_ago * 0.5 THEN 50 -- Significant drop in activity
            WHEN completion_rate_last_90_days < 0.3 THEN 40 -- Low engagement
            ELSE 20 -- Low risk
        END AS churn_risk_score, -- Churn risk score

        -- User classification
        CASE
            WHEN plays_last_7_days > 10 THEN 'Very Active'
            WHEN plays_last_7_days > 3 THEN 'Active'
            WHEN plays_last_30_days > 0 THEN 'Moderately Active'
            WHEN plays_last_90_days > 0 THEN 'At Risk'
            ELSE 'Inactive'
        END AS activity_segment -- User activity segment
    FROM user_behavior_metrics
)
SELECT
    username,
    registration_date,
    days_since_registration,
    activity_segment,
    plays_last_7_days,
    plays_last_30_days,
    plays_last_90_days,
    days_since_last_play,
    activity_trend_pct,
    churn_risk_score,
    ROUND(completion_rate_last_90_days * 100, 2) AS completion_rate_pct,
    unique_songs_last_30_days,
    playlists_created_last_60_days,
    devices_used_last_30_days,
    ratings_given_last_30_days,
    total_lifetime_plays,

    -- Action recommendations based on profile
    CASE
        WHEN churn_risk_score >= 80 THEN 'Urgent Reactivation Campaign'
        WHEN churn_risk_score >= 60 THEN 'Retention Program'
        WHEN churn_risk_score >= 40 THEN 'Personalized Engagement'
        WHEN activity_segment = 'Very Active' THEN 'Loyalty Program'
        ELSE 'Regular Maintenance'
    END AS recommended_action, -- Recommended action

    -- Segmentation for targeted strategies
    CASE
        WHEN total_lifetime_plays > 1000 AND churn_risk_score > 50 THEN 'VIP At Risk'
        WHEN days_since_registration < 90 AND plays_last_30_days = 0 THEN 'Lost New User'
        WHEN playlists_created_last_60_days > 0 AND plays_last_7_days = 0 THEN 'Inactive Curator'
        WHEN completion_rate_last_90_days < 0.5 AND plays_last_30_days > 20 THEN 'Shallow Listener'
        ELSE 'Standard User'
    END AS user_segment, -- User segment for marketing

    DENSE_RANK() OVER (ORDER BY churn_risk_score DESC, days_since_last_play DESC) AS priority_rank -- Priority rank for intervention

FROM churn_analysis
WHERE total_lifetime_plays > 0 -- Only users with some historical activity
ORDER BY churn_risk_score DESC, days_since_last_play DESC, total_lifetime_plays DESC;



-- ====================================================================
-- SUMMARY OF CAPABILITIES DEMONSTRATED:
-- ====================================================================
-- ✅ MULTIPLE JOINS: All queries use multiple JOINs (3-6 tables per query)
-- ✅ CORRELATED SUBQUERIES: Extensive use in queries 2, 5, 7, 8, 10 with external references
-- ✅ ADVANCED AGGREGATIONS: COUNT, AVG, SUM, STDDEV, window functions (RANK, DENSE_RANK, LAG)
-- ✅ DATE/TIME OPERATIONS: EXTRACT, DATE_TRUNC, INTERVAL, complex temporal comparisons
-- ✅ PREDICTIVE ANALYSIS (BASIC): Trend metrics, risk scoring, segmentation for churn
-- ✅ WINDOW FUNCTIONS: ROW_NUMBER, RANK, DENSE_RANK, LAG, partitioning
-- ✅ COMPLEX CTEs: Extensive use of WITH to structure complex queries
-- ✅ STATISTICAL ANALYSIS: Standard deviation, conditional averages, comparisons
-- ====================================================================