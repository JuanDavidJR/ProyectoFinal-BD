-- --------------------------------------------------------------------
-- Query 4: LISTENING PATTERNS BY DEVICE AND TIME OF DAY
-- --------------------------------------------------------------------
-- Objective: Analyze how listening patterns (volume, completion, song duration, ratings)
-- vary by device type, operating system, time of day, and day of the week.
-- Techniques:
--   - CTE `hourly_device_stats` to aggregate playback data by device, hour, and day.
--   - Multiple Joins: history, devices, songs, users.
--   - Date/Time operations: EXTRACT(HOUR), EXTRACT(DOW) to get hour and day of the week.
--   - Aggregations: COUNT, COUNT(DISTINCT), AVG, COUNT with CASE.
--   - Window functions: SUM() OVER to calculate usage percentages, ROW_NUMBER() to identify peaks.
--   - CASE to convert the day of the week number to its name.
-- Result: Detailed listening statistics segmented by device, OS, hour, and day,
-- including completion rates, average duration, percentage of high ratings, and peak usage rankings.
-- --------------------------------------------------------------------
WITH hourly_device_stats AS (
    SELECT
        d.device_type,                          -- Device type (e.g., Mobile, Desktop)
        d.operating_system,                     -- Operating system (e.g., iOS, Android, Windows)
        EXTRACT(HOUR FROM ph.playback_date) AS hour_of_day, -- Hour of the day (0-23)
        EXTRACT(DOW FROM ph.playback_date) AS day_of_week, -- Day of the week (0=Sunday, 6=Saturday)
        COUNT(*) AS total_plays,                -- Total plays
        COUNT(DISTINCT ph.user_id) AS unique_users, -- Unique users
        AVG(CASE WHEN ph.completed THEN 1.0 ELSE 0.0 END) AS completion_rate, -- Song completion rate
        AVG(s.duration) AS avg_song_duration,   -- Average duration of songs listened to
        COUNT(CASE WHEN ph.rating >= 4 THEN 1 END) AS high_ratings -- Number of high ratings (>=4)
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.devices d ON ph.device_id = d.device_id
    JOIN vibesia_schema.songs s ON ph.song_id = s.song_id
    JOIN vibesia_schema.users u ON ph.user_id = u.user_id
    WHERE ph.playback_date >= CURRENT_DATE - INTERVAL '6 months' -- Considers data from the last 6 months
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
    END AS day_name, -- Name of the day of the week
    total_plays,
    unique_users,
    ROUND(completion_rate * 100, 2) AS completion_percentage, -- Completion rate in percentage
    ROUND(avg_song_duration / 60.0, 2) AS avg_duration_minutes, -- Average duration in minutes
    high_ratings,
    ROUND(high_ratings::DECIMAL / NULLIF(total_plays, 0) * 100, 2) AS high_rating_percentage, -- Percentage of high ratings
    -- Peak usage analysis
    ROUND(total_plays::DECIMAL / SUM(total_plays) OVER (PARTITION BY device_type) * 100, 2) AS device_usage_pct, -- Device usage percentage in that hour/day relative to the device's total
    ROW_NUMBER() OVER (PARTITION BY device_type ORDER BY total_plays DESC) AS peak_rank_by_device -- Peak usage rank by device
FROM hourly_device_stats
WHERE total_plays >= 10 -- Filters combinations with low playback volume
ORDER BY device_type, total_plays DESC;