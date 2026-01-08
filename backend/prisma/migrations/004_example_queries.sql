-- =====================================================
-- CONSULTAS DE EJEMPLO OPTIMIZADAS
-- Ejemplos de uso de la base de datos optimizada
-- =====================================================

-- =====================================================
-- 1. CONSULTAS DE BÚSQUEDA
-- =====================================================

-- Buscar candidatos por nombre (usando índice trigram)
SELECT id, first_name, last_name, email, phone
FROM candidate
WHERE (first_name || ' ' || last_name) ILIKE '%john%'
ORDER BY last_name, first_name
LIMIT 20;

-- Buscar posiciones por título (usando índice trigram)
SELECT p.id, p.title, p.location, c.name as company_name, p.salary_min, p.salary_max
FROM position p
INNER JOIN company c ON p.company_id = c.id
WHERE p.title ILIKE '%developer%'
  AND p.is_visible = true
  AND p.status = 'open'
ORDER BY p.created_at DESC;

-- =====================================================
-- 2. DASHBOARD DE RECLUTAMIENTO
-- =====================================================

-- Vista general de posiciones activas (usando vista materializada)
SELECT 
    position_id,
    title,
    company_name,
    total_applications,
    pending_applications,
    in_interview,
    accepted_applications,
    rejected_applications,
    last_application_date
FROM mv_position_stats
WHERE status = 'open' AND is_visible = true
ORDER BY total_applications DESC
LIMIT 20;

-- Top candidatos por rendimiento
SELECT 
    candidate_id,
    first_name || ' ' || last_name as full_name,
    email,
    total_applications,
    total_interviews,
    ROUND(average_score::numeric, 2) as avg_score,
    accepted_count,
    rejected_count
FROM mv_candidate_performance
WHERE total_applications > 0
ORDER BY average_score DESC NULLS LAST, total_interviews DESC
LIMIT 50;

-- Carga de trabajo de entrevistadores
SELECT 
    employee_id,
    name,
    company_name,
    total_interviews_conducted,
    interviews_last_30_days,
    upcoming_interviews,
    ROUND(average_score_given::numeric, 2) as avg_score_given
FROM mv_employee_workload
ORDER BY upcoming_interviews DESC, interviews_last_30_days DESC;

-- =====================================================
-- 3. PIPELINE DE RECLUTAMIENTO
-- =====================================================

-- Ver pipeline completo de una posición
SELECT 
    candidate_name,
    application_status,
    application_date,
    interviews_completed,
    last_interview_date,
    ROUND(average_interview_score::numeric, 2) as avg_score,
    completed_steps
FROM mv_recruitment_pipeline
WHERE position_id = 1  -- Reemplazar con ID real
ORDER BY 
    CASE application_status
        WHEN 'accepted' THEN 1
        WHEN 'interview' THEN 2
        WHEN 'under_review' THEN 3
        WHEN 'submitted' THEN 4
        WHEN 'rejected' THEN 5
        WHEN 'withdrawn' THEN 6
    END,
    application_date DESC;

-- Candidatos en etapa de entrevista
SELECT 
    a.id as application_id,
    c.first_name || ' ' || c.last_name as candidate_name,
    c.email,
    p.title as position_title,
    COUNT(i.id) as interviews_completed,
    MAX(i.interview_date) as last_interview,
    AVG(i.score) as average_score
FROM application a
INNER JOIN candidate c ON a.candidate_id = c.id
INNER JOIN position p ON a.position_id = p.id
LEFT JOIN interview i ON a.id = i.application_id
WHERE a.status = 'interview'
GROUP BY a.id, c.first_name, c.last_name, c.email, p.title
ORDER BY last_interview DESC;

-- =====================================================
-- 4. ANÁLISIS DE RENDIMIENTO
-- =====================================================

-- Tasa de conversión por posición
SELECT 
    p.id,
    p.title,
    c.name as company_name,
    COUNT(DISTINCT a.id) as total_applications,
    COUNT(DISTINCT CASE WHEN a.status = 'interview' THEN a.id END) as reached_interview,
    COUNT(DISTINCT CASE WHEN a.status = 'accepted' THEN a.id END) as accepted,
    ROUND(
        100.0 * COUNT(CASE WHEN a.status = 'accepted' THEN 1 END) / 
        NULLIF(COUNT(a.id), 0), 2
    ) as acceptance_rate
FROM position p
INNER JOIN company c ON p.company_id = c.id
LEFT JOIN application a ON p.id = a.position_id
GROUP BY p.id, p.title, c.name
HAVING COUNT(a.id) > 0
ORDER BY acceptance_rate DESC;

-- Tiempo promedio del proceso de reclutamiento
SELECT 
    p.id,
    p.title,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        COALESCE(
            (SELECT MAX(i.interview_date) 
             FROM interview i 
             WHERE i.application_id = a.id),
            a.updated_at
        ) - a.created_at
    )) / 86400)::numeric, 1) as avg_days_to_complete,
    COUNT(a.id) as total_applications
FROM position p
INNER JOIN application a ON p.id = a.position_id
WHERE a.status IN ('accepted', 'rejected')
GROUP BY p.id, p.title
HAVING COUNT(a.id) >= 5
ORDER BY avg_days_to_complete;

-- =====================================================
-- 5. CONSULTAS DE CANDIDATOS
-- =====================================================

-- Perfil completo de un candidato (usando vista)
SELECT *
FROM v_candidate_profile
WHERE id = 1;  -- Reemplazar con ID real

-- Historial de aplicaciones de un candidato
SELECT 
    a.id as application_id,
    p.title as position_title,
    comp.name as company_name,
    a.application_date,
    a.status,
    COUNT(i.id) as interviews_completed,
    AVG(i.score) as average_score,
    MAX(i.interview_date) as last_interview
FROM application a
INNER JOIN position p ON a.position_id = p.id
INNER JOIN company c ON a.candidate_id = c.id
INNER JOIN company comp ON p.company_id = comp.id
LEFT JOIN interview i ON a.id = i.application_id
WHERE a.candidate_id = 1  -- Reemplazar con ID real
GROUP BY a.id, p.title, comp.name, a.application_date, a.status
ORDER BY a.application_date DESC;

-- Candidatos con experiencia específica
SELECT DISTINCT
    c.id,
    c.first_name,
    c.last_name,
    c.email,
    we.position as last_position,
    we.company as last_company,
    EXTRACT(YEAR FROM AGE(COALESCE(we.end_date, CURRENT_DATE), we.start_date)) as years_experience
FROM candidate c
INNER JOIN work_experience we ON c.id = we.candidate_id
WHERE we.position ILIKE '%developer%'
  AND we.end_date IS NULL  -- Trabajo actual
ORDER BY years_experience DESC;

-- =====================================================
-- 6. CONSULTAS DE ENTREVISTAS
-- =====================================================

-- Próximas entrevistas programadas
SELECT 
    i.id,
    i.interview_date,
    c.first_name || ' ' || c.last_name as candidate_name,
    p.title as position_title,
    e.name as interviewer_name,
    ist.name as interview_step,
    it.name as interview_type
FROM interview i
INNER JOIN application a ON i.application_id = a.id
INNER JOIN candidate c ON a.candidate_id = c.id
INNER JOIN position p ON a.position_id = p.id
INNER JOIN employee e ON i.employee_id = e.id
INNER JOIN interview_step ist ON i.interview_step_id = ist.id
INNER JOIN interview_type it ON ist.interview_type_id = it.id
WHERE i.interview_date >= CURRENT_TIMESTAMP
  AND i.result IN ('pending', NULL)
ORDER BY i.interview_date;

-- Historial de entrevistas por empleado
SELECT 
    e.id,
    e.name,
    COUNT(i.id) as total_interviews,
    COUNT(CASE WHEN i.result = 'passed' THEN 1 END) as passed,
    COUNT(CASE WHEN i.result = 'failed' THEN 1 END) as failed,
    AVG(i.score) as average_score_given,
    MIN(i.interview_date) as first_interview,
    MAX(i.interview_date) as last_interview
FROM employee e
LEFT JOIN interview i ON e.id = i.employee_id
WHERE e.is_active = true
GROUP BY e.id, e.name
ORDER BY total_interviews DESC;

-- =====================================================
-- 7. REPORTES EJECUTIVOS
-- =====================================================

-- Resumen general del sistema
SELECT 
    (SELECT COUNT(*) FROM company) as total_companies,
    (SELECT COUNT(*) FROM employee WHERE is_active = true) as active_employees,
    (SELECT COUNT(*) FROM position WHERE status = 'open') as open_positions,
    (SELECT COUNT(*) FROM candidate) as total_candidates,
    (SELECT COUNT(*) FROM application WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as applications_last_30_days,
    (SELECT COUNT(*) FROM interview WHERE interview_date >= CURRENT_DATE - INTERVAL '30 days') as interviews_last_30_days,
    (SELECT COUNT(*) FROM application WHERE status = 'accepted' AND updated_at >= CURRENT_DATE - INTERVAL '30 days') as hires_last_30_days;

-- Top empresas por actividad de reclutamiento
SELECT 
    c.id,
    c.name,
    COUNT(DISTINCT p.id) as open_positions,
    COUNT(DISTINCT a.id) as total_applications,
    COUNT(DISTINCT i.id) as total_interviews,
    COUNT(DISTINCT CASE WHEN a.status = 'accepted' THEN a.id END) as successful_hires
FROM company c
LEFT JOIN position p ON c.id = p.company_id AND p.status = 'open'
LEFT JOIN application a ON p.id = a.position_id
LEFT JOIN interview i ON a.id = i.application_id
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT p.id) > 0
ORDER BY total_applications DESC;

-- Análisis de funel de conversión
WITH funnel AS (
    SELECT 
        COUNT(DISTINCT a.id) as total_applications,
        COUNT(DISTINCT CASE WHEN a.status IN ('under_review', 'interview', 'accepted') THEN a.id END) as reviewed,
        COUNT(DISTINCT CASE WHEN a.status IN ('interview', 'accepted') THEN a.id END) as interviewed,
        COUNT(DISTINCT CASE WHEN a.status = 'accepted' THEN a.id END) as accepted
    FROM application a
    WHERE a.created_at >= CURRENT_DATE - INTERVAL '90 days'
)
SELECT 
    total_applications,
    reviewed,
    interviewed,
    accepted,
    ROUND(100.0 * reviewed / NULLIF(total_applications, 0), 2) as pct_reviewed,
    ROUND(100.0 * interviewed / NULLIF(reviewed, 0), 2) as pct_interviewed,
    ROUND(100.0 * accepted / NULLIF(interviewed, 0), 2) as pct_accepted
FROM funnel;

-- =====================================================
-- 8. MANTENIMIENTO Y OPTIMIZACIÓN
-- =====================================================

-- Ver tamaño de tablas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Ver estadísticas de uso de índices
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Identificar queries lentas (requiere pg_stat_statements)
-- Primero habilitar: CREATE EXTENSION pg_stat_statements;
/*
SELECT 
    query,
    calls,
    ROUND(total_exec_time::numeric, 2) as total_time_ms,
    ROUND(mean_exec_time::numeric, 2) as avg_time_ms,
    ROUND(min_exec_time::numeric, 2) as min_time_ms,
    ROUND(max_exec_time::numeric, 2) as max_time_ms
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY mean_exec_time DESC
LIMIT 20;
*/

-- =====================================================
-- COMENTARIOS Y NOTAS
-- =====================================================

-- Estas consultas están optimizadas para usar los índices creados
-- Para mejor rendimiento:
-- 1. Refrescar vistas materializadas regularmente
-- 2. Ejecutar ANALYZE después de inserts/updates masivos
-- 3. Monitorear uso de índices con pg_stat_user_indexes
-- 4. Ajustar work_mem para queries complejas si es necesario
