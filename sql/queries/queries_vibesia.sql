-- Retrieves songs that have a duration longer than the average duration of songs in their respective albums
-- Useful for identifying standout tracks that are longer than typical songs in the album
SELECT s.song_id, s.title, s.duration
FROM vibesia_schema.songs s
WHERE s.duration > (
    SELECT AVG(s2.duration)
    FROM vibesia_schema.songs s2
    WHERE s2.album_id = s.album_id
);

-- Finds users who have more song plays than the global average number of plays per user
-- Helps identify the most active listeners on the platform
SELECT u.user_id, u.username
FROM vibesia_schema.users u
WHERE (
    SELECT COUNT(*)
    FROM vibesia_schema.playback_history ph
    WHERE ph.user_id = u.user_id
) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM vibesia_schema.playback_history
        GROUP BY user_id
    ) AS sub
);

-- Identifies users who have created more playlists than the average user
-- Useful for finding power users who actively curate content
SELECT u.user_id, u.username
FROM vibesia_schema.users u
WHERE (
    SELECT COUNT(*)
    FROM vibesia_schema.playlists p
    WHERE p.user_id = u.user_id
) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM vibesia_schema.playlists
        GROUP BY user_id
    ) AS sub
);

-- Counts the number of playlists created by each user
-- Provides a basic overview of user engagement with playlist creation
SELECT u.user_id, u.username, COUNT(p.playlist_id) AS total_playlists
FROM vibesia_schema.users u
JOIN vibesia_schema.playlists p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(p.playlist_id) >= 1;

-- Lists all device types that have been used by at least one user
-- Helps understand the device ecosystem of the platform
SELECT d.device_id, d.device_type
FROM vibesia_schema.devices d
JOIN vibesia_schema.user_device ud ON d.device_id = ud.device_id;

-- Returns albums that actually contain songs (filtering out empty albums)
-- Ensures we're only working with meaningful album data
SELECT DISTINCT a.album_id, a.title
FROM vibesia_schema.albums a
JOIN vibesia_schema.songs s ON a.album_id = s.album_id;

-- Provides playback statistics broken down by month and year
-- Essential for understanding usage patterns and seasonal trends
SELECT 
    EXTRACT(YEAR FROM ph.playback_date) AS year,
    EXTRACT(MONTH FROM ph.playback_date) AS month,
    COUNT(*) AS total_plays
FROM vibesia_schema.playback_history ph
GROUP BY year, month
ORDER BY year, month;

-- Calculates the average duration of songs for each album
-- Helps analyze the typical length of tracks in different albums
SELECT a.title AS album_title, AVG(s.duration) AS avg_duration
FROM vibesia_schema.songs s
JOIN vibesia_schema.albums a ON s.album_id = a.album_id
GROUP BY a.title;


