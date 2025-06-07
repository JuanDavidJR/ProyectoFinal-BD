-- --------------------------------------------------------------------
-- Query 10: PREDICTIVE USER CHURN ANALYSIS
-- --------------------------------------------------------------------
-- Objective: Identify users at risk of churn by analyzing recent behavior, activity trends, and engagement.
-- Techniques: CTEs, Correlated Subqueries, Temporal Analysis (activity in last 7, 30, 60, 90 days),
--             CASE for risk scores and segmentation, Window Functions (DENSE_RANK).
-- Result: Report per user: activity segment, churn risk score, activity trend, key metrics,
--         recommended action, user segment for targeted strategies, ordered by intervention priority.
-- --------------------------------------------------------------------
WITH user_behavior_metrics AS (
    SELECT
        u.user_id,
        u.username,
        u.registration_date,
        u.email,
        (CURRENT_DATE - u.registration_date) AS days_since_registration, -- User tenure (Corrected)

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph1
         WHERE ph1.user_id = u.user_id
           AND ph1.playback_date >= CURRENT_DATE - INTERVAL '7 days') AS plays_last_7_days,

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph2
         WHERE ph2.user_id = u.user_id
           AND ph2.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS plays_last_30_days,

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph3
         WHERE ph3.user_id = u.user_id
           AND ph3.playback_date >= CURRENT_DATE - INTERVAL '90 days') AS plays_last_90_days,

        COALESCE((SELECT EXTRACT(DAY FROM (CURRENT_TIMESTAMP - MAX(ph4.playback_date))) -- Use CURRENT_TIMESTAMP for interval with timestamp
                  FROM vibesia_schema.playback_history ph4
                  WHERE ph4.user_id = u.user_id), 9999) AS days_since_last_play, -- Corrected & COALESCE for users with no plays

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph5
         WHERE ph5.user_id = u.user_id
           AND ph5.playback_date >= CURRENT_DATE - INTERVAL '60 days'
           AND ph5.playback_date < CURRENT_DATE - INTERVAL '30 days') AS plays_30_60_days_ago,

        COALESCE((SELECT AVG(CASE WHEN ph6.completed THEN 1.0 ELSE 0.0 END)
                 FROM vibesia_schema.playback_history ph6
                 WHERE ph6.user_id = u.user_id
                   AND ph6.playback_date >= CURRENT_DATE - INTERVAL '90 days'), 0) AS completion_rate_last_90_days, -- COALESCE for no recent plays

        (SELECT COUNT(DISTINCT ph7.song_id)
         FROM vibesia_schema.playback_history ph7
         WHERE ph7.user_id = u.user_id
           AND ph7.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS unique_songs_last_30_days,

        (SELECT COUNT(*)
         FROM vibesia_schema.playlists p1
         WHERE p1.user_id = u.user_id
           AND p1.creation_date >= CURRENT_DATE - INTERVAL '60 days') AS playlists_created_last_60_days,

        (SELECT MAX(ps.date_added)
         FROM vibesia_schema.playlists p2
         JOIN vibesia_schema.playlist_songs ps ON p2.playlist_id = ps.playlist_id
         WHERE p2.user_id = u.user_id) AS last_playlist_activity,

        (SELECT COUNT(DISTINCT d.device_id)
         FROM vibesia_schema.playback_history ph8
         JOIN vibesia_schema.devices d ON ph8.device_id = d.device_id
         WHERE ph8.user_id = u.user_id
           AND ph8.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS devices_used_last_30_days,

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph9
         WHERE ph9.user_id = u.user_id
           AND ph9.rating IS NOT NULL
           AND ph9.playback_date >= CURRENT_DATE - INTERVAL '30 days') AS ratings_given_last_30_days,

        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph10
         WHERE ph10.user_id = u.user_id) AS total_lifetime_plays
    FROM vibesia_schema.users u
    WHERE u.is_active = TRUE
      AND u.registration_date <= CURRENT_DATE - INTERVAL '30 days' -- Consider users registered at least 30 days ago
),
churn_analysis AS (
    SELECT
        ubm.*,
        CASE
            WHEN plays_30_60_days_ago > 0 -- Avoid division by zero if no activity in prior period
            THEN ROUND(((plays_last_30_days - plays_30_60_days_ago)::DECIMAL / plays_30_60_days_ago * 100), 2)
            WHEN plays_last_30_days > 0 AND plays_30_60_days_ago = 0 THEN 100.00 -- Infinite growth, represented as 100% or some large number
            ELSE 0.00 -- No activity in either period or only in prior
        END AS activity_trend_pct,

        CASE
            WHEN days_since_last_play > 60 THEN 100
            WHEN days_since_last_play > 30 THEN 80
            WHEN days_since_last_play > 14 THEN 60
            WHEN plays_last_7_days = 0 AND plays_last_30_days < 5 AND days_since_registration > 30 THEN 70 -- Added tenure check for new users
            WHEN plays_last_30_days < plays_30_60_days_ago * 0.5 AND plays_30_60_days_ago > 0 THEN 50 -- Added check for plays_30_60_days_ago > 0
            WHEN COALESCE(completion_rate_last_90_days, 0) < 0.3 AND plays_last_90_days > 0 THEN 40 -- Check plays_last_90_days to ensure it's relevant
            ELSE 20
        END AS churn_risk_score,

        CASE
            WHEN plays_last_7_days > 10 THEN 'Very Active'
            WHEN plays_last_7_days > 3 THEN 'Active'
            WHEN plays_last_30_days > 0 THEN 'Moderately Active'
            WHEN plays_last_90_days > 0 AND days_since_last_play > 7 THEN 'At Risk' -- More specific "At Risk"
            ELSE 'Inactive'
        END AS activity_segment
    FROM user_behavior_metrics ubm
)
SELECT
    ca.username,
    ca.registration_date,
    ca.days_since_registration,
    ca.activity_segment,
    ca.plays_last_7_days,
    ca.plays_last_30_days,
    ca.plays_last_90_days,
    CASE WHEN ca.days_since_last_play = 9999 THEN NULL ELSE ca.days_since_last_play END AS days_since_last_play, -- Show NULL if never played
    ca.activity_trend_pct,
    ca.churn_risk_score,
    ROUND(COALESCE(ca.completion_rate_last_90_days,0) * 100, 2) AS completion_rate_pct,
    ca.unique_songs_last_30_days,
    ca.playlists_created_last_60_days,
    ca.devices_used_last_30_days,
    ca.ratings_given_last_30_days,
    ca.total_lifetime_plays,
    CASE
        WHEN ca.churn_risk_score >= 80 THEN 'Urgent Reactivation Campaign'
        WHEN ca.churn_risk_score >= 60 THEN 'Retention Program Offer'
        WHEN ca.churn_risk_score >= 40 THEN 'Personalized Engagement/Survey'
        WHEN ca.activity_segment = 'Very Active' THEN 'VIP/Loyalty Acknowledgment'
        ELSE 'Monitor/Regular Updates'
    END AS recommended_action,
    CASE
        WHEN ca.total_lifetime_plays > 500 AND ca.churn_risk_score >= 60 THEN 'High-Value At Risk' -- Adjusted threshold
        WHEN ca.days_since_registration < 90 AND ca.plays_last_30_days = 0 AND ca.total_lifetime_plays > 0 THEN 'Lost New Engaged User' -- Was engaged then lost
        WHEN ca.days_since_registration < 60 AND ca.total_lifetime_plays = 0 THEN 'Never Engaged New User'
        WHEN ca.playlists_created_last_60_days > 0 AND ca.plays_last_7_days = 0 AND ca.plays_last_30_days > 0 THEN 'Curator Lapsing' -- Was active recently
        WHEN COALESCE(ca.completion_rate_last_90_days,1) < 0.5 AND ca.plays_last_30_days > 10 THEN 'Frequent Skimmer' -- Adjusted threshold
        ELSE 'Standard'
    END AS user_segment,
    DENSE_RANK() OVER (ORDER BY ca.churn_risk_score DESC, ca.days_since_last_play DESC NULLS LAST) AS priority_rank
FROM churn_analysis ca
WHERE ca.total_lifetime_plays >= 0 -- Consider all users who meet the CTE criteria (e.g. registered > 30 days)
  -- AND ca.churn_risk_score >= 20 -- Optional: to only see users with some level of risk or specific segments
ORDER BY priority_rank, ca.churn_risk_score DESC, ca.days_since_last_play DESC NULLS LAST, ca.total_lifetime_plays DESC;