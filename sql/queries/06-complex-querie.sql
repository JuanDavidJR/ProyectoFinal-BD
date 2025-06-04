-- --------------------------------------------------------------------
-- Query 6: ARTIST PERFORMANCE ANALYSIS WITH ADVANCED TEMPORAL METRICS
-- --------------------------------------------------------------------
-- Objective: Evaluate artist performance, considering their catalog, popularity (total and recent),
-- average rating, growth in plays, and device reach.
-- Techniques:
--   - Two CTEs: `artist_performance` to aggregate base metrics and `artist_trends` to calculate trends and rankings.
--   - Multiple Joins (artists, albums, songs, history).
--   - Aggregations: COUNT(DISTINCT), COUNT, AVG.
--   - Subquery in JOIN to calculate average plays per album.
--   - Window functions: DENSE_RANK() for popularity and country rankings.
--   - Temporal analysis: Comparison of plays in the last 12 months vs. the previous 12 months.
--   - CASE to calculate growth percentage and classify the trend.
-- Result: A detailed report of each artist's performance, including catalog metrics,
-- popularity, engagement, growth, rankings, and efficiency.
-- --------------------------------------------------------------------
WITH artist_performance AS (
    SELECT
        ar.artist_id,
        ar.name AS artist_name,
        ar.country,
        ar.formation_year,
        ar.artist_type,
        -- Current metrics
        COUNT(DISTINCT al.album_id) AS total_albums,     -- Total albums by the artist
        COUNT(DISTINCT s.song_id) AS total_songs,        -- Total songs by the artist
        COUNT(DISTINCT ph.user_id) AS unique_listeners,  -- Unique listeners of the artist
        COUNT(ph.playback_id) AS total_plays,            -- Total plays of the artist's songs
        AVG(ph.rating) AS avg_rating,                    -- Average rating of their songs
        -- Temporal metrics (last 12 months vs. previous)
        COUNT(CASE WHEN ph.playback_date >= CURRENT_DATE - INTERVAL '12 months' THEN ph.playback_id END) AS plays_last_12_months, -- Plays in the last 12 months
        COUNT(CASE WHEN ph.playback_date < CURRENT_DATE - INTERVAL '12 months'
                   AND ph.playback_date >= CURRENT_DATE - INTERVAL '24 months' THEN ph.playback_id END) AS plays_12_24_months_ago, -- Plays between 12 and 24 months ago
        -- Diversity of devices where played
        COUNT(DISTINCT ph.device_id) AS device_diversity, -- Number of different device types where the artist was heard
        -- Engagement analysis per album
        AVG(album_plays.plays_per_album) AS avg_plays_per_album -- Average plays per album for the artist
    FROM vibesia_schema.artists ar
    JOIN vibesia_schema.albums al ON ar.artist_id = al.artist_id
    JOIN vibesia_schema.songs s ON al.album_id = s.album_id
    LEFT JOIN vibesia_schema.playback_history ph ON s.song_id = ph.song_id
    LEFT JOIN ( -- Subquery to get plays per album
        SELECT al2.album_id, COUNT(ph2.playback_id) as plays_per_album
        FROM vibesia_schema.albums al2
        JOIN vibesia_schema.songs s2 ON al2.album_id = s2.album_id
        LEFT JOIN vibesia_schema.playback_history ph2 ON s2.song_id = ph2.song_id
        GROUP BY al2.album_id
    ) album_plays ON al.album_id = album_plays.album_id
    GROUP BY ar.artist_id, ar.name, ar.country, ar.formation_year, ar.artist_type
    HAVING COUNT(ph.playback_id) > 0 -- Considers only artists with at least one play
),
artist_trends AS (
    SELECT *,
        -- Growth trend calculation
        CASE
            WHEN plays_12_24_months_ago > 0
            THEN ROUND(((plays_last_12_months - plays_12_24_months_ago)::DECIMAL / plays_12_24_months_ago * 100), 2)
            ELSE NULL
        END AS growth_percentage, -- Play growth percentage (last 12m vs 12-24m ago)
        -- Rankings
        DENSE_RANK() OVER (ORDER BY total_plays DESC) AS popularity_rank, -- General popularity rank
        DENSE_RANK() OVER (ORDER BY plays_last_12_months DESC) AS recent_popularity_rank, -- Recent popularity rank
        DENSE_RANK() OVER (PARTITION BY country ORDER BY total_plays DESC) AS country_rank -- Popularity rank within their country
    FROM artist_performance
)
SELECT
    artist_name,
    country,
    artist_type,
    CURRENT_DATE - MAKE_DATE(formation_year, 1, 1) AS years_active, -- Years artist has been active (approximate)
    total_albums,
    total_songs,
    total_plays,
    unique_listeners,
    ROUND(avg_rating, 2) AS avg_rating,
    plays_last_12_months,
    growth_percentage,
    device_diversity,
    ROUND(avg_plays_per_album, 2) AS avg_plays_per_album,
    popularity_rank,
    recent_popularity_rank,
    country_rank,
    -- Trend classification
    CASE
        WHEN growth_percentage > 50 THEN 'Rising'
        WHEN growth_percentage > 0 THEN 'Growing'
        WHEN growth_percentage > -25 THEN 'Stable'
        ELSE 'Declining'
    END AS trend_status, -- Artist's trend status
    -- Efficiency (plays per song)
    ROUND(total_plays::DECIMAL / NULLIF(total_songs, 0), 2) AS efficiency_plays_per_song -- Efficiency: plays per song
FROM artist_trends
WHERE total_plays >= 100 -- Filters artists with a minimum number of plays
ORDER BY popularity_rank, recent_popularity_rank;