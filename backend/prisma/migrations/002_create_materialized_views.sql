-- =====================================================
-- VISTAS MATERIALIZADAS PARA OPTIMIZACIÓN DE CONSULTAS
-- =====================================================

-- Vista materializada: Estadísticas de posiciones
CREATE MATERIALIZED VIEW mv_position_stats AS
SELECT 
    p.id AS position_id,
    p.title,
    p.company_id,
    c.name AS company_name,
    p.status,
    p.is_visible,
    COUNT(DISTINCT a.id) AS total_applications,
    COUNT(DISTINCT CASE WHEN a.status = 'submitted' THEN a.id END) AS pending_applications,
    COUNT(DISTINCT CASE WHEN a.status = 'interview' THEN a.id END) AS in_interview,
    COUNT(DISTINCT CASE WHEN a.status = 'accepted' THEN a.id END) AS accepted_applications,
    COUNT(DISTINCT CASE WHEN a.status = 'rejected' THEN a.id END) AS rejected_applications,
    MAX(a.application_date) AS last_application_date,
    p.created_at,
    p.application_deadline
FROM position p
LEFT JOIN company c ON p.company_id = c.id
LEFT JOIN application a ON p.id = a.position_id
GROUP BY p.id, p.title, p.company_id, c.name, p.status, p.is_visible, p.created_at, p.application_deadline;

CREATE UNIQUE INDEX idx_mv_position_stats_id ON mv_position_stats (position_id);
CREATE INDEX idx_mv_position_stats_company ON mv_position_stats (company_id);
CREATE INDEX idx_mv_position_stats_status ON mv_position_stats (status);

-- Vista materializada: Rendimiento de candidatos
CREATE MATERIALIZED VIEW mv_candidate_performance AS
SELECT 
    c.id AS candidate_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(DISTINCT a.id) AS total_applications,
    COUNT(DISTINCT i.id) AS total_interviews,
    AVG(i.score) AS average_score,
    MAX(i.score) AS max_score,
    COUNT(DISTINCT CASE WHEN a.status = 'accepted' THEN a.id END) AS accepted_count,
    COUNT(DISTINCT CASE WHEN a.status = 'rejected' THEN a.id END) AS rejected_count,
    COUNT(DISTINCT ed.id) AS education_count,
    COUNT(DISTINCT we.id) AS work_experience_count,
    MAX(a.application_date) AS last_application_date
FROM candidate c
LEFT JOIN application a ON c.id = a.candidate_id
LEFT JOIN interview i ON a.id = i.application_id
LEFT JOIN education ed ON c.id = ed.candidate_id
LEFT JOIN work_experience we ON c.id = we.candidate_id
GROUP BY c.id, c.first_name, c.last_name, c.email;

CREATE UNIQUE INDEX idx_mv_candidate_performance_id ON mv_candidate_performance (candidate_id);
CREATE INDEX idx_mv_candidate_performance_score ON mv_candidate_performance (average_score DESC NULLS LAST);

-- Vista materializada: Carga de trabajo de empleados
CREATE MATERIALIZED VIEW mv_employee_workload AS
SELECT 
    e.id AS employee_id,
    e.name,
    e.email,
    e.company_id,
    c.name AS company_name,
    COUNT(DISTINCT i.id) AS total_interviews_conducted,
    COUNT(DISTINCT CASE 
        WHEN i.interview_date >= CURRENT_DATE - INTERVAL '30 days' 
        THEN i.id 
    END) AS interviews_last_30_days,
    COUNT(DISTINCT CASE 
        WHEN i.interview_date >= CURRENT_DATE 
        THEN i.id 
    END) AS upcoming_interviews,
    AVG(i.score) AS average_score_given,
    MAX(i.interview_date) AS last_interview_date
FROM employee e
LEFT JOIN company c ON e.company_id = c.id
LEFT JOIN interview i ON e.id = i.employee_id
WHERE e.is_active = true
GROUP BY e.id, e.name, e.email, e.company_id, c.name;

CREATE UNIQUE INDEX idx_mv_employee_workload_id ON mv_employee_workload (employee_id);
CREATE INDEX idx_mv_employee_workload_company ON mv_employee_workload (company_id);

-- Vista materializada: Pipeline de reclutamiento
CREATE MATERIALIZED VIEW mv_recruitment_pipeline AS
SELECT 
    p.id AS position_id,
    p.title AS position_title,
    p.company_id,
    c.name AS company_name,
    a.id AS application_id,
    a.candidate_id,
    cand.first_name || ' ' || cand.last_name AS candidate_name,
    a.status AS application_status,
    a.application_date,
    COUNT(i.id) AS interviews_completed,
    MAX(i.interview_date) AS last_interview_date,
    AVG(i.score) AS average_interview_score,
    array_agg(ist.name ORDER BY ist.order_index) AS completed_steps
FROM position p
INNER JOIN company c ON p.company_id = c.id
INNER JOIN application a ON p.id = a.position_id
INNER JOIN candidate cand ON a.candidate_id = cand.id
LEFT JOIN interview i ON a.id = i.application_id
LEFT JOIN interview_step ist ON i.interview_step_id = ist.id
GROUP BY p.id, p.title, p.company_id, c.name, a.id, a.candidate_id, 
         cand.first_name, cand.last_name, a.status, a.application_date;

CREATE INDEX idx_mv_recruitment_pipeline_position ON mv_recruitment_pipeline (position_id);
CREATE INDEX idx_mv_recruitment_pipeline_company ON mv_recruitment_pipeline (company_id);
CREATE INDEX idx_mv_recruitment_pipeline_candidate ON mv_recruitment_pipeline (candidate_id);
CREATE INDEX idx_mv_recruitment_pipeline_status ON mv_recruitment_pipeline (application_status);

-- =====================================================
-- FUNCIONES PARA REFRESCAR VISTAS MATERIALIZADAS
-- =====================================================

-- Función para refrescar todas las vistas materializadas
CREATE OR REPLACE FUNCTION refresh_all_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_position_stats;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_candidate_performance;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_employee_workload;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_recruitment_pipeline;
END;
$$ LANGUAGE plpgsql;

-- Función para refrescar vistas relacionadas con posiciones
CREATE OR REPLACE FUNCTION refresh_position_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_position_stats;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_recruitment_pipeline;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VISTAS NORMALES (NO MATERIALIZADAS) PARA CONSULTAS COMUNES
-- =====================================================

-- Vista: Aplicaciones con información completa
CREATE OR REPLACE VIEW v_application_details AS
SELECT 
    a.id AS application_id,
    a.application_date,
    a.status,
    a.notes,
    c.id AS candidate_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    p.id AS position_id,
    p.title AS position_title,
    p.location,
    p.employment_type,
    comp.id AS company_id,
    comp.name AS company_name,
    COUNT(i.id) AS interview_count,
    MAX(i.interview_date) AS last_interview_date,
    AVG(i.score) AS average_score
FROM application a
INNER JOIN candidate c ON a.candidate_id = c.id
INNER JOIN position p ON a.position_id = p.id
INNER JOIN company comp ON p.company_id = comp.id
LEFT JOIN interview i ON a.id = i.application_id
GROUP BY a.id, a.application_date, a.status, a.notes,
         c.id, c.first_name, c.last_name, c.email, c.phone,
         p.id, p.title, p.location, p.employment_type,
         comp.id, comp.name;

-- Vista: Candidatos con perfil completo
CREATE OR REPLACE VIEW v_candidate_profile AS
SELECT 
    c.id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.address,
    json_agg(DISTINCT jsonb_build_object(
        'id', e.id,
        'institution', e.institution,
        'title', e.title,
        'startDate', e.start_date,
        'endDate', e.end_date
    )) FILTER (WHERE e.id IS NOT NULL) AS education,
    json_agg(DISTINCT jsonb_build_object(
        'id', w.id,
        'company', w.company,
        'position', w.position,
        'description', w.description,
        'startDate', w.start_date,
        'endDate', w.end_date
    )) FILTER (WHERE w.id IS NOT NULL) AS work_experience,
    json_agg(DISTINCT jsonb_build_object(
        'id', r.id,
        'filePath', r.file_path,
        'fileType', r.file_type,
        'uploadDate', r.upload_date
    )) FILTER (WHERE r.id IS NOT NULL) AS resumes
FROM candidate c
LEFT JOIN education e ON c.id = e.candidate_id
LEFT JOIN work_experience w ON c.id = w.candidate_id
LEFT JOIN resume r ON c.id = r.candidate_id
GROUP BY c.id, c.first_name, c.last_name, c.email, c.phone, c.address;

-- Vista: Posiciones activas con detalles
CREATE OR REPLACE VIEW v_active_positions AS
SELECT 
    p.id,
    p.title,
    p.description,
    p.location,
    p.salary_min,
    p.salary_max,
    p.employment_type,
    p.benefits,
    p.application_deadline,
    p.requirements,
    p.responsibilities,
    c.id AS company_id,
    c.name AS company_name,
    if_flow.description AS interview_flow_description,
    COUNT(DISTINCT a.id) AS application_count,
    p.created_at
FROM position p
INNER JOIN company c ON p.company_id = c.id
LEFT JOIN interview_flow if_flow ON p.interview_flow_id = if_flow.id
LEFT JOIN application a ON p.id = a.position_id
WHERE p.is_visible = true 
  AND p.status = 'open'
  AND (p.application_deadline IS NULL OR p.application_deadline >= CURRENT_DATE)
GROUP BY p.id, p.title, p.description, p.location, p.salary_min, p.salary_max,
         p.employment_type, p.benefits, p.application_deadline, p.requirements,
         p.responsibilities, c.id, c.name, if_flow.description, p.created_at;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON MATERIALIZED VIEW mv_position_stats IS 'Estadísticas agregadas por posición para dashboards';
COMMENT ON MATERIALIZED VIEW mv_candidate_performance IS 'Métricas de rendimiento de candidatos';
COMMENT ON MATERIALIZED VIEW mv_employee_workload IS 'Carga de trabajo de empleados entrevistadores';
COMMENT ON MATERIALIZED VIEW mv_recruitment_pipeline IS 'Vista del pipeline completo de reclutamiento';
COMMENT ON VIEW v_application_details IS 'Detalles completos de aplicaciones con información relacionada';
COMMENT ON VIEW v_candidate_profile IS 'Perfil completo del candidato con historial';
COMMENT ON VIEW v_active_positions IS 'Posiciones activas y visibles con métricas';
