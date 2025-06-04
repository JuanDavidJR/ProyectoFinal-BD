-- --------------------------------------------------------------------
-- Query 8: RATING CORRELATION ANALYSIS WITH CONTEXTUAL FACTORS
-- --------------------------------------------------------------------
-- Objective: Explore how different contextual factors (time, day, device type,
-- song duration, artist familiarity, completion) correlate
-- with user-given ratings.
-- Techniques:
--   - CTE `rating_context` to gather playback data with its context.
--   - Multiple Joins to enrich playback data.
--   - Temporal operations: EXTRACT for hour, day, month.
--   - Correlated scalar subqueries to get user context at the time of playback.
--   - Conditional aggregations (AVG with CASE) to analyze ratings under different conditions.
--   - GROUP BY to analyze by hour, day, and device.
-- Result: Statistics showing how average rating varies by different contexts,
-- allowing inference of potential correlations.
-- --------------------------------------------------------------------
WITH rating_context AS (
    SELECT
        ph.playback_id,
        ph.rating,
        ph.completed,
        ph.playback_date,
        EXTRACT(HOUR FROM ph.playback_date) AS hour_of_day,     -- Hour of the day of playback
        EXTRACT(DOW FROM ph.playback_date) AS day_of_week,      -- Day of the week
        EXTRACT(MONTH FROM ph.playback_date) AS month,          -- Month
        s.duration,                                             -- Song duration
        s.track_number,                                         -- Track number in the album
        al.album_type,                                          -- Album type
        ar.country AS artist_country,                           -- Artist's country
        ar.formation_year,                                      -- Artist's formation year
        g.name AS genre,                                        -- Song genre
        d.device_type,                                          -- Device type
        d.operating_system,                                     -- Operating system
        u.registration_date,                                    -- User registration date
        EXTRACT(DAYS FROM ph.playback_date - u.registration_date) AS user_days_since_registration, -- User tenure at the time of playback
        -- User context at the time of playback
        (SELECT COUNT(*)
         FROM vibesia_schema.playback_history ph2
         WHERE ph2.user_id = ph.user_id
           AND ph2.playback_date < ph.playback_date
           AND ph2.playback_date >= ph.playback_date - INTERVAL '1 hour') AS songs_played_last_hour, -- Songs played by the user in the previous hour
        -- Previous experience with the artist
        (SELECT COUNT(DISTINCT s2.song_id)
         FROM vibesia_schema.playback_history ph3
         JOIN vibesia_schema.songs s2 ON ph3.song_id = s2.song_id
         JOIN vibesia_schema.albums al2 ON s2.album_id = al2.album_id
         WHERE ph3.user_id = ph.user_id
           AND al2.artist_id = al.artist_id
           AND ph3.playback_date < ph.playback_date) AS previous_artist_songs_heard -- Songs by the same artist previously heard by the user
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.songs s ON ph.song_id = s.song_id
    JOIN vibesia_schema.albums al ON s.album_id = al.album_id
    JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
    JOIN vibesia_schema.song_genres sg ON s.song_id = sg.song_id
    JOIN vibesia_schema.genres g ON sg.genre_id = g.genre_id
    JOIN vibesia_schema.users u ON ph.user_id = u.user_id
    JOIN vibesia_schema.devices d ON ph.device_id = d.device_id
    WHERE ph.rating IS NOT NULL                                 -- Only rated playbacks
        AND ph.playback_date >= CURRENT_DATE - INTERVAL '1 year' -- Data from the last year
)
SELECT
    -- Analysis by hour of the day
    hour_of_day,
    COUNT(*) AS total_ratings,                                 -- Total ratings in that hour
    ROUND(AVG(rating), 2) AS avg_rating_by_hour,               -- Average rating by hour
    STDDEV(rating) AS rating_stddev,                           -- Standard deviation of rating

    -- Analysis by day of the week (name is added here, but grouped by number)
    CASE day_of_week
        WHEN 0 THEN 'Sunday' WHEN 1 THEN 'Monday' WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday' WHEN 4 THEN 'Thursday' WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,

    -- Analysis by device type
    device_type,
    COUNT(CASE WHEN rating >= 4 THEN 1 END) AS high_ratings,    -- Number of high ratings
    COUNT(CASE WHEN rating <= 2 THEN 1 END) AS low_ratings,     -- Number of low ratings

    -- Correlation with song duration
    ROUND(AVG(CASE WHEN duration > 240 THEN rating ELSE NULL END), 2) AS avg_rating_long_songs, -- Avg rating for long songs (>4 min)
    ROUND(AVG(CASE WHEN duration <= 240 THEN rating ELSE NULL END), 2) AS avg_rating_short_songs, -- Avg rating for short songs (<=4 min)

    -- Impact of previous experience with the artist
    ROUND(AVG(CASE WHEN previous_artist_songs_heard > 5 THEN rating ELSE NULL END), 2) AS avg_rating_familiar_artist, -- Avg rating if artist is familiar
    ROUND(AVG(CASE WHEN previous_artist_songs_heard = 0 THEN rating ELSE NULL END), 2) AS avg_rating_new_artist, -- Avg rating if artist is new to the user

    -- Analysis by playback completion
    ROUND(AVG(CASE WHEN completed = TRUE THEN rating ELSE NULL END), 2) AS avg_rating_completed, -- Avg rating if song was completed
    ROUND(AVG(CASE WHEN completed = FALSE THEN rating ELSE NULL END), 2) AS avg_rating_skipped, -- Avg rating if song was skipped

    -- Correlation with recent activity
    ROUND(AVG(CASE WHEN songs_played_last_hour > 3 THEN rating ELSE NULL END), 2) AS avg_rating_binge_listening, -- Avg rating in binge listening sessions
    ROUND(AVG(CASE WHEN songs_played_last_hour <= 1 THEN rating ELSE NULL END), 2) AS avg_rating_casual_listening -- Avg rating in casual listening

FROM rating_context
GROUP BY hour_of_day, day_of_week, device_type -- Groups to analyze trends by these dimensions
HAVING COUNT(*) >= 20 -- Considers only groups with sufficient data
ORDER BY hour_of_day, day_of_week;