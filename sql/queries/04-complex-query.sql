-- --------------------------------------------------------------------
-- Query 4: LISTENING PATTERNS BY DEVICE AND TIME OF DAY
-- --------------------------------------------------------------------
-- Objective: Analyze how listening patterns vary by device type, OS, time of day, and day of the week.
-- Techniques: CTE, Joins, Date/Time EXTRACT, Aggregations (COUNT, AVG, CASE), Window Functions (SUM, ROW_NUMBER).
-- Result: Detailed listening statistics segmented by device, OS, hour, and day.
-- --------------------------------------------------------------------
WITH hourly_device_stats AS (
    SELECT
        d.device_type,
        d.operating_system,
        EXTRACT(HOUR FROM ph.playback_date) AS hour_of_day,
        EXTRACT(DOW FROM ph.playback_date) AS day_of_week, -- 0=Sunday, 6=Saturday
        COUNT(*) AS total_plays,
        COUNT(DISTINCT ph.user_id) AS unique_users,
        AVG(CASE WHEN ph.completed THEN 1.0 ELSE 0.0 END) AS completion_rate,
        AVG(s.duration) AS avg_song_duration,
        COUNT(CASE WHEN ph.rating >= 4 THEN 1 END) AS high_ratings
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.devices d ON ph.device_id = d.device_id
    JOIN vibesia_schema.songs s ON ph.song_id = s.song_id
    -- JOIN vibesia_schema.users u ON ph.user_id = u.user_id -- u is not used in this CTE, can be removed for minor optimization
    WHERE ph.playback_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY d.device_type, d.operating_system,
             EXTRACT(HOUR FROM ph.playback_date),
             EXTRACT(DOW FROM ph.playback_date)
)
SELECT
    device_type,
    operating_system,
    hour_of_day,
    CASE day_of_week
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    total_plays,
    unique_users,
    ROUND(completion_rate * 100, 2) AS completion_percentage,
    ROUND(avg_song_duration / 60.0, 2) AS avg_duration_minutes,
    high_ratings,
    CASE
        WHEN total_plays > 0 THEN ROUND(high_ratings::DECIMAL / total_plays * 100, 2)
        ELSE 0
    END AS high_rating_percentage, -- Avoid division by zero
    ROUND(total_plays::DECIMAL / NULLIF(SUM(total_plays) OVER (PARTITION BY device_type, operating_system), 0) * 100, 2) AS usage_pct_within_device_os, -- % of plays for this hour/day within the device/OS total
    ROW_NUMBER() OVER (PARTITION BY device_type, operating_system, day_of_week ORDER BY total_plays DESC) AS peak_hour_rank_on_day_for_device_os -- Ranks peak hours for a given device/OS on a specific day of the week
FROM hourly_device_stats
WHERE total_plays >= 2 -- MODIFIED: Filters combinations with at least 2 plays (Adjust from 10 for sample data)
ORDER BY device_type, operating_system, day_of_week, total_plays DESC;