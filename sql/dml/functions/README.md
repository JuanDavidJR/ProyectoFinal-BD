
### Function: vibesia_schema.get_client_ip()

**✪ Purpose:**This auxiliary function is used to retrieve the client's IP address that initiates a session or query in the database. It is useful for auditing, logging, or security purposes.

**✪ Returns:**`INET` – The client's IP address as `INET` type. If it cannot be retrieved (e.g., in a client-less session), it returns `NULL`.

**✪ Implementation Details:**

- Internally uses PostgreSQL's built-in function `inet_client_addr()` to get the IP.
- Wrapped in a `BEGIN ... EXCEPTION` block to safely return `NULL` in case of error.

**✪ Function Definition:**

```sql
CREATE OR REPLACE FUNCTION vibesia_schema.get_client_ip()
RETURNS INET AS $$
BEGIN
    RETURN inet_client_addr();
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;
```

**✪ Usage Example:**

```sql
SELECT vibesia_schema.get_client_ip() AS client_ip;
```

**✪ Notes:**

- The function is marked as `STABLE`, which means it returns the same result within a session.
- The returned value may vary depending on whether the connection is local, proxied, or behind a load balancer.

---

### Function: vibesia_schema.get_most_active_user()

**✪ Purpose:**Retrieves the most active users on the platform, meaning those with the highest number of completed playbacks.

**✪ Returns:**A table with the following fields:

- `user_id` – User ID
- `username` – Username
- `total_reproductions` – Total number of completed playbacks

**✪ Implementation Details:**

- Filters only completed playbacks (`completed = TRUE`)
- Includes only active users (`is_active = TRUE`)
- Returns a maximum of 5 results, ordered by number of playbacks

**✪ Function Definition:**

```sql
CREATE OR REPLACE FUNCTION vibesia_schema.get_most_active_user()
RETURNS TABLE (
    user_id INTEGER,
    username VARCHAR,
    total_reproductions BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM vibesia_schema.playback_history ph
        JOIN vibesia_schema.users u ON u.user_id = ph.user_id
        WHERE ph.completed = TRUE AND u.is_active = TRUE
    ) THEN
        RAISE NOTICE 'No active users with completed playbacks found';
        RETURN;
    END IF;

    RETURN QUERY
    SELECT u.user_id, u.username, COUNT(*) AS total_reproductions
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.users u ON u.user_id = ph.user_id
    WHERE ph.completed = TRUE      
      AND u.is_active = TRUE       
    GROUP BY u.user_id, u.username
    ORDER BY total_reproductions DESC
    LIMIT 5;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error retrieving most active user: %', SQLERRM;
END;
$$;
```

**✪ Usage Example:**

```sql
SELECT * FROM vibesia_schema.get_most_active_user();
```

**✪ Notes:**

- Includes error handling with `EXCEPTION` to prevent silent failures.
- Recommended for generating user engagement reports.

---

### Function: vibesia_schema.get_top_song()

**✪ Purpose:**Returns the most played songs on the platform.

**✪ Returns:**A table with:

- `song_id` – Song ID
- `title` – Title
- `total_reproductions` – Total number of times it was played (completed)

**✪ Implementation Details:**

- Considers only playbacks marked as `completed = TRUE`
- Groups by song and sorts in descending order
- Returns a maximum of 5 songs

**✪ Function Definition:**

```sql
CREATE OR REPLACE FUNCTION vibesia_schema.get_top_song()
RETURNS TABLE (
    song_id INTEGER,
    title VARCHAR,
    total_reproductions BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM vibesia_schema.playback_history
        WHERE completed = TRUE
    ) THEN
        RAISE NOTICE 'No completed playbacks found in the system';
        RETURN;
    END IF;

    RETURN QUERY
    SELECT s.song_id, s.title, COUNT(*) AS total_reproductions
    FROM vibesia_schema.playback_history ph
    JOIN vibesia_schema.songs s ON s.song_id = ph.song_id
    WHERE ph.completed = TRUE  
    GROUP BY s.song_id, s.title
    ORDER BY total_reproductions DESC
    LIMIT 5;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error retrieving top song: %', SQLERRM;
END;
$$;
```

**✪ Usage Example:**

```sql
SELECT * FROM vibesia_schema.get_top_song();
```

**✪ Notes:**

- Very useful for building music dashboards
- Can be extended to use filters by date or genre
