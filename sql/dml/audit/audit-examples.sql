--##################################################
--#            AUDIT USAGE EXAMPLES               #
--##################################################

-- Example queries for audit analysis:

-- 1. Get all operations on a specific record
SELECT * FROM vibesia_schema.audit_log 
WHERE table_name = 'users' AND record_id = 1 
ORDER BY operation_timestamp DESC;

-- 2. Get all operations by a specific user
SELECT * FROM vibesia_schema.audit_log 
WHERE user_id = 1
ORDER BY operation_timestamp DESC;

-- 3. Get operations within a date range
SELECT * FROM vibesia_schema.audit_log 
WHERE operation_timestamp BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY operation_timestamp DESC;

-- 4. Get deleted records with their last known values
SELECT table_name, record_id, old_values, operation_timestamp
FROM vibesia_schema.audit_log 
WHERE operation = 'DELETE'
ORDER BY operation_timestamp DESC;

-- 5. Track changes to specific fields
SELECT table_name, record_id, 
       old_values->>'field_name' as old_value,
       new_values->>'field_name' as new_value,
       operation_timestamp
FROM vibesia_schema.audit_log 
WHERE operation = 'UPDATE' 
  AND (old_values->>'field_name' != new_values->>'field_name');