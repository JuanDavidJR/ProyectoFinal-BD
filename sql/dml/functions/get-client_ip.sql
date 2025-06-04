-- Auxiliary function to obtain the client's IP (optional)
CREATE OR REPLACE FUNCTION vibesia_schema.get_client_ip()
RETURNS INET AS $$
BEGIN
    RETURN inet_client_addr();
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;


-- SELECT vibesia_schema.get_client_ip();
SELECT vibesia_schema.get_client_ip() as client_ip;