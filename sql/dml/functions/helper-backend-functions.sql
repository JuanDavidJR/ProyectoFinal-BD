--##################################################
--#         HELPER FUNCTIONS FOR BACKEND           #
--##################################################

-- Función helper para establecer el contexto de auditoría desde el backend
-- Uso: SELECT vibesia_schema.set_audit_context(123, 'user@example.com', 'admin', 'Mozilla/5.0...', '/api/products', 'req-123');
CREATE OR REPLACE FUNCTION vibesia_schema.set_audit_context(
    p_app_user_id INTEGER DEFAULT NULL,
    p_app_user_email VARCHAR(255) DEFAULT NULL,
    p_app_user_role VARCHAR(50) DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_api_endpoint VARCHAR(255) DEFAULT NULL,
    p_request_id VARCHAR(100) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    -- Establecer variables de sesión para el contexto de auditoría
    IF p_app_user_id IS NOT NULL THEN
        PERFORM set_config('audit.app_user_id', p_app_user_id::TEXT, false);
    END IF;
    
    IF p_app_user_email IS NOT NULL THEN
        PERFORM set_config('audit.app_user_email', p_app_user_email, false);
    END IF;
    
    IF p_app_user_role IS NOT NULL THEN
        PERFORM set_config('audit.app_user_role', p_app_user_role, false);
    END IF;
    
    IF p_user_agent IS NOT NULL THEN
        PERFORM set_config('audit.user_agent', p_user_agent, false);
    END IF;
    
    IF p_api_endpoint IS NOT NULL THEN
        PERFORM set_config('audit.api_endpoint', p_api_endpoint, false);
    END IF;
    
    IF p_request_id IS NOT NULL THEN
        PERFORM set_config('audit.request_id', p_request_id, false);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Función helper para limpiar el contexto de auditoría
CREATE OR REPLACE FUNCTION vibesia_schema.clear_audit_context()
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('audit.app_user_id', '', false);
    PERFORM set_config('audit.app_user_email', '', false);
    PERFORM set_config('audit.app_user_role', '', false);
    PERFORM set_config('audit.user_agent', '', false);
    PERFORM set_config('audit.api_endpoint', '', false);
    PERFORM set_config('audit.request_id', '', false);
END;
$$ LANGUAGE plpgsql;