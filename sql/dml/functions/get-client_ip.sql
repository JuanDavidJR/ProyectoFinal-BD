-- Function: vibesia_schema.get_client_ip()
-- Description: Returns the IP address of the client connected to the database.
-- It uses the built-in PostgreSQL function inet_client_addr().
-- If the IP cannot be retrieved, it safely returns NULL.
-- This function is useful for auditing or logging purposes.

CREATE OR REPLACE FUNCTION vibesia_schema.get_client_ip()
RETURNS INET AS $$
BEGIN
    -- Attempt to get the IP address of the client connection
    RETURN inet_client_addr();

EXCEPTION
    WHEN OTHERS THEN
        -- If an error occurs (e.g., not in a client context), return NULL
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- Example usage:
-- SELECT vibesia_schema.get_client_ip() AS client_ip;
