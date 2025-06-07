-- --------------------------------------------------------------------
-- Query 1: COMPLETE ANALYSIS OF MUSICAL TRENDS BY SEASON
-- --------------------------------------------------------------------
-- Objective: Identifies seasonal trends for genres, artists, and albums over years, calculating
--            popularity (plays, listeners), ratings, and growth.
-- Techniques:
--   - CTE `seasonal_stats`: Pre-aggregates playback data by genre, artist, album, season, and year.
--   - Joins: Connects playback_history with songs, albums, artists, song_genres, genres, users.
--   - Aggregations: COUNT(*) for total plays, AVG() for rating, COUNT(DISTINCT) for unique listeners.
--   - Date/Time: EXTRACT(MONTH/YEAR), CASE for season, INTERVAL for date range.
--   - Window Functions: RANK() for seasonal popularity, LAG() for year-over-year comparison of plays.
--   - Filtering: CTE filters for last 2 years, completed plays with ratings. Final select filters by min play volume.
-- Result: Lists seasonal musical items (genre/artist/album) with play counts, avg rating, unique listeners,
--         seasonal rank, previous year's plays, and growth percentage. Ordered by season and total plays.
-- --------------------------------------------------------------------
WITH seasonal_stats AS (
    SELECT
        g.name AS genre_name,                 -- Genre name
        ar.name AS artist_name,               -- Artist name
        al.title AS album_title,              -- Album title
        CASE
            WHEN EXTRACT(MONTH FROM ph.playback_date) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM ph.playback_date) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM ph.playback_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Autumn'
        END AS season,                        -- Season of the year
        -- For Winter, year might span. e.g. Dec 2022, Jan 2023, Feb 2023.
        -- To group Winter Dec-Jan-Feb as one season "Winter YYYY" (e.g. Winter 2023 for Dec 2022-Feb 2023)
        -- a more complex year calculation might be needed. The current one uses the actual year of the playback_date.
        -- For simplicity, we use EXTRACT(YEAR...). If Dec is part of next year's winter, adjust year logic:
        -- (CASE WHEN EXTRACT(MONTH FROM ph.playback_date) = 12 THEN EXTRACT(YEAR FROM ph.playback_date) + 1 ELSE EXTRACT(YEAR FROM ph.playback_date) END) AS season_year,
        EXTRACT(YEAR FROM ph.playback_date) AS year, -- Year of playback
        COUNT(*) AS total_plays,              -- Total plays
        AVG(ph.rating) AS avg_rating,         -- Average rating
        COUNT(DISTINCT ph.user_id) AS unique_listeners -- Unique listeners
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.songs s ON ph.song_id = s.song_id
    JOIN vibesia_schema.albums al ON s.album_id = al.album_id
    JOIN vibesia_schema.artists ar ON al.artist_id = ar.artist_id
    JOIN vibesia_schema.song_genres sg ON s.song_id = sg.song_id
    JOIN vibesia_schema.genres g ON sg.genre_id = g.genre_id
    JOIN vibesia_schema.users u ON ph.user_id = u.user_id -- user_id from 'u' is used in COUNT(DISTINCT u.user_id)
    WHERE ph.playback_date >= (CURRENT_DATE - INTERVAL '2 years') -- Considers data from the last 2 full years up to today
        AND ph.completed = TRUE                     -- Only completed playbacks
        AND ph.rating IS NOT NULL                   -- Only playbacks with ratings
    GROUP BY g.name, ar.name, al.title, season, year
)
SELECT
    season,
    year, -- Added year to the final output for clarity, as LAG is by year
    genre_name,
    artist_name,
    album_title,
    total_plays,
    ROUND(avg_rating::numeric, 2) AS avg_rating, -- Explicitly cast to numeric for rounding
    unique_listeners,
    RANK() OVER (PARTITION BY season, year ORDER BY total_plays DESC) as season_rank_in_year, -- Rank by season and year based on plays
    LAG(total_plays, 1, 0) OVER (PARTITION BY genre_name, artist_name, album_title, season ORDER BY year) as previous_year_plays_same_season_album, -- Plays from the previous year for the same genre/artist/album/season
    COALESCE(ROUND(
        ((total_plays - LAG(total_plays, 1, 0) OVER (PARTITION BY genre_name, artist_name, album_title, season ORDER BY year)) * 100.0 /
         NULLIF(LAG(total_plays, 1, 0) OVER (PARTITION BY genre_name, artist_name, album_title, season ORDER BY year), 0)), 2
    ),0) AS growth_percentage_same_season_album -- Year-over-year growth for the same album in the same season
FROM seasonal_stats
WHERE total_plays > 5 -- Adjusted filter: Show items with more than 5 plays. (Adjust as needed for your data volume, e.g., > 50)
ORDER BY year DESC, season, total_plays DESC;