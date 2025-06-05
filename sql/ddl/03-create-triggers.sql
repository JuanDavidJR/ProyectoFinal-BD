--##################################################
--#            TRIGGER TABLES                      #
--##################################################

-- Trigger: users
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.users
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Artists 
CREATE TRIGGER audit_artists
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.artists
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();

-- Trigger: Songs
CREATE TRIGGER audit_songs
AFTER INSERT OR UPDATE OR DELETE ON vibesia_schema.songs
FOR EACH ROW EXECUTE FUNCTION vibesia_schema.audit_function();