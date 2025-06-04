--##################################################
--#            AUDIT TRIGGER FUNCTION              #
--##################################################

-- Function: vibesia_schema.audit_function
-- Purpose: Generic trigger function to log INSERT, UPDATE, and DELETE operations
--          across multiple system tables into the audit_log table.
-- Description:
--     - Converts OLD and NEW rows into JSONB for flexible logging.
--     - Extracts the first identifier column ending in '_id' to track the primary record affected.
--     - Uses PostgreSQL built-in context variables (e.g., TG_OP, TG_TABLE_NAME, current_user).
--     - Captures client IP using a helper function.
--     - Can be attached as a trigger to multiple tables for unified audit tracking.
-- Note:
--     - This function must be triggered AFTER DML operations.
--     - It assumes that at least one column in the table ends with '_id' to identify the record.
CREATE OR REPLACE FUNCTION vibesia_schema.audit_function()
RETURNS TRIGGER AS $$
DECLARE
    record_id INTEGER;
    old_data JSONB;
    new_data JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
        SELECT value::INTEGER INTO record_id
        FROM jsonb_each_text(to_jsonb(OLD))
        WHERE key ~ '_id$'
        LIMIT 1;
    ELSIF (TG_OP = 'UPDATE') THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
        SELECT value::INTEGER INTO record_id
        FROM jsonb_each_text(to_jsonb(NEW))
        WHERE key ~ '_id$'
        LIMIT 1;
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
        SELECT value::INTEGER INTO record_id
        FROM jsonb_each_text(to_jsonb(NEW))
        WHERE key ~ '_id$'
        LIMIT 1;
    END IF;

    INSERT INTO vibesia_schema.audit_log (
        user_name,
        action_type,
        table_name,
        record_id,
        old_values,
        new_values,
        connection_ip
    ) VALUES (
        current_user,                    
        TG_OP,                           
        TG_TABLE_NAME,                   
        record_id,                       
        old_data,                        
        new_data,                        
        vibesia_schema.get_client_ip()   
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;