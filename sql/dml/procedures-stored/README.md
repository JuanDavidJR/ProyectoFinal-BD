
# 📘 Stored Procedure Documentation – Vibesia 🎵

This document contains the detailed description of stored procedures implemented in the `vibesia_schema` schema for the **MusicApp - Vibesia** application.

---

### 🧩 Procedure: `vibesia_schema.sp_add_song_to_playlist`

**🎯 Purpose:**  
Adds a song to a specific user's playlist, validating permissions, data existence, and controlling position in the list.

**🔁 Parameters:**  
- Input:
  - `p_playlist_id`: Playlist ID.
  - `p_song_id`: Song ID to add.
  - `p_user_id`: ID of the user performing the action.
  - `p_position` *(optional)*: Desired position in the list.
- Output:
  - `p_success`: `TRUE` if successful.
  - `p_message`: Status or error message.

**🔧 Implementation Details:**  
- Verifies that the playlist and song exist, and that the user is the owner.
- Prevents duplicates in the same playlist.
- Automatically calculates position if not provided.
- Shifts songs if inserted in the middle.

**📌 Usage Example:**

```sql
CALL vibesia_schema.sp_add_song_to_playlist(
    p_playlist_id => 10,
    p_song_id     => 10,
    p_user_id     => 9,
    p_success     => v_success,
    p_message     => v_message
);
```

---

### 🧩 Procedure: `vibesia_schema.sp_delete_playlist`

**🎯 Purpose:**  
Deletes a playlist from the database, including its associated songs, validating user permissions.

**🔁 Parameters:**  
- Input:
  - `p_playlist_id`: ID of the playlist to delete.
  - `p_user_id`: ID of the user performing the action.
- Output:
  - `p_success`: `TRUE` if successful.
  - `p_message`: Status or error message.
  - `p_songs_removed`: Number of removed songs.

**🔧 Implementation Details:**  
- Validates existence and ownership of the playlist.
- Uses `ON DELETE CASCADE` to remove associated songs.
- Tracks number of songs deleted.

**📌 Usage Example:**

```sql
CALL vibesia_schema.sp_delete_playlist(
    p_playlist_id => 10,
    p_user_id     => 1,
    p_success     => v_success,
    p_message     => v_message,
    p_songs_removed => v_songs_removed
);
```

---

### 🧩 Procedure: `vibesia_schema.sp_remove_song_from_playlist`

**🎯 Purpose:**  
Removes a song from a playlist and adjusts positions of the remaining songs.

**🔁 Parameters:**  
- Input:
  - `p_playlist_id`: Playlist ID.
  - `p_song_id`: Song ID to remove.
  - `p_user_id`: ID of the user performing the action.
- Output:
  - `p_success`: `TRUE` if successful.
  - `p_message`: Status or error message.

**🔧 Implementation Details:**  
- Verifies permissions and data existence.
- Removes the song and reorders remaining songs to preserve order.

**📌 Usage Example:**

```sql
CALL vibesia_schema.sp_remove_song_from_playlist(
    p_playlist_id => 5,
    p_song_id     => 42,
    p_user_id     => 2,
    p_success     => v_success,
    p_message     => v_message
);
```

---

### 🧩 Procedure: `vibesia_schema.sp_update_playlist`

**🎯 Purpose:**  
Updates attributes (name, description, status) of an existing playlist.

**🔁 Parameters:**  
- Input:
  - `p_playlist_id`: Playlist ID to update.
  - `p_user_id`: User ID performing the update.
  - `p_new_name`, `p_new_description`, `p_new_status`: New values (optional).
- Output:
  - `p_success`: `TRUE` if successful.
  - `p_message`: Status or error message.

**🔧 Implementation Details:**  
- Validates that the playlist exists and is owned by the user.
- Rejects empty or duplicate names.
- Accepts only `public` or `private` as valid status.

**📌 Usage Example:**

```sql
CALL vibesia_schema.sp_update_playlist(
    p_playlist_id     => 12,
    p_user_id         => 3,
    p_new_name        => 'My Updated Playlist',
    p_new_description => 'Updated with new songs',
    p_new_status      => 'public',
    p_success         => v_success,
    p_message         => v_message
);
```

---

**📌 Final Notes:**  
All procedures use `EXCEPTION` handling to capture errors and return user-friendly messages. This facilitates backend integration and improves the user experience.
