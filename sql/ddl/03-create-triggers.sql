--##################################################
--#            TRIGGER TABLES                      #
--##################################################

-- Trigger: users
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.users
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: playlists
CREATE TRIGGER audit_playlists
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.playlists
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Albums
CREATE TRIGGER audit_albums
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.albums
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Artists 
CREATE TRIGGER audit_artists
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.artists
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Devices
CREATE TRIGGER audit_devices
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.devices
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Genres
CREATE TRIGGER audit_genres
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.genres
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Playback_history
CREATE TRIGGER audit_playback_history
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.playback_history
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Playlist_songs
CREATE TRIGGER audit_playlist_songs
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.playlist_songs
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Songs
CREATE TRIGGER audit_songs
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.songs
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

--Trigger: Song_genres 
CREATE TRIGGER audit_song_genres
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.song_genres
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: User_device
CREATE TRIGGER audit_user_device
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.user_device
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();