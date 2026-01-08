-- =====================================================
-- Sistema de Gestión de Reclutamiento (ATS)
-- Diseño optimizado con DDD y normalización 3NF
-- PostgreSQL 14+
-- =====================================================

-- Activar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para búsquedas de texto optimizadas

-- =====================================================
-- DOMINIO: ORGANIZACIÓN
-- =====================================================

-- Tabla: COMPANY
-- Representa la organización que gestiona el reclutamiento
CREATE TABLE company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT company_name_not_empty CHECK (name <> '')
);

-- Tabla: EMPLOYEE
-- Empleados que participan en el proceso de reclutamiento
CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL REFERENCES company(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT employee_name_not_empty CHECK (name <> ''),
    CONSTRAINT employee_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- =====================================================
-- DOMINIO: FLUJO DE ENTREVISTAS (Optimizado)
-- =====================================================

-- Tabla: INTERVIEW_TYPE
-- Tipos de entrevista (técnica, RH, cultural, etc.)
CREATE TABLE interview_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT interview_type_name_not_empty CHECK (name <> '')
);

-- Tabla: INTERVIEW_FLOW
-- Define flujos de entrevista reutilizables por múltiples posiciones
CREATE TABLE interview_flow (
    id SERIAL PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT interview_flow_desc_not_empty CHECK (description <> '')
);

-- Tabla: INTERVIEW_STEP
-- Pasos específicos dentro de un flujo de entrevista
CREATE TABLE interview_step (
    id SERIAL PRIMARY KEY,
    interview_flow_id INTEGER NOT NULL REFERENCES interview_flow(id) ON DELETE CASCADE,
    interview_type_id INTEGER NOT NULL REFERENCES interview_type(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT interview_step_name_not_empty CHECK (name <> ''),
    CONSTRAINT interview_step_order_positive CHECK (order_index > 0),
    CONSTRAINT unique_flow_order UNIQUE(interview_flow_id, order_index)
);

-- =====================================================
-- DOMINIO: POSICIONES (Normalizado - redundancias eliminadas)
-- =====================================================

-- Tabla: POSITION
-- Posiciones de trabajo disponibles
-- OPTIMIZACIÓN: Se eliminó 'job_description' redundante con 'description'
-- OPTIMIZACIÓN: Se eliminó 'company_description' (debe estar en tabla COMPANY)
CREATE TABLE position (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL REFERENCES company(id) ON DELETE CASCADE,
    interview_flow_id INTEGER REFERENCES interview_flow(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'draft' NOT NULL,
    is_visible BOOLEAN DEFAULT false NOT NULL,
    location VARCHAR(255),
    requirements TEXT,
    responsibilities TEXT,
    salary_min NUMERIC(12, 2) CHECK (salary_min >= 0),
    salary_max NUMERIC(12, 2) CHECK (salary_max >= salary_min),
    employment_type VARCHAR(50) NOT NULL DEFAULT 'full-time',
    benefits TEXT,
    application_deadline DATE,
    contact_info VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT position_title_not_empty CHECK (title <> ''),
    CONSTRAINT position_status_valid CHECK (status IN ('draft', 'open', 'closed', 'cancelled')),
    CONSTRAINT position_employment_type_valid CHECK (employment_type IN ('full-time', 'part-time', 'contract', 'internship', 'temporary'))
);

-- =====================================================
-- DOMINIO: CANDIDATOS
-- =====================================================

-- Tabla: CANDIDATE
-- Información de candidatos
CREATE TABLE candidate (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT candidate_first_name_not_empty CHECK (first_name <> ''),
    CONSTRAINT candidate_last_name_not_empty CHECK (last_name <> ''),
    CONSTRAINT candidate_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Tabla: EDUCATION
-- Historial educativo del candidato
CREATE TABLE education (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id) ON DELETE CASCADE,
    institution VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT education_institution_not_empty CHECK (institution <> ''),
    CONSTRAINT education_title_not_empty CHECK (title <> ''),
    CONSTRAINT education_date_order CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Tabla: WORK_EXPERIENCE
-- Experiencia laboral del candidato
CREATE TABLE work_experience (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id) ON DELETE CASCADE,
    company VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT work_experience_company_not_empty CHECK (company <> ''),
    CONSTRAINT work_experience_position_not_empty CHECK (position <> ''),
    CONSTRAINT work_experience_date_order CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Tabla: RESUME
-- CVs y documentos del candidato
CREATE TABLE resume (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT resume_file_path_not_empty CHECK (file_path <> ''),
    CONSTRAINT resume_file_type_valid CHECK (file_type IN ('pdf', 'doc', 'docx', 'txt'))
);

-- =====================================================
-- DOMINIO: APLICACIONES Y ENTREVISTAS
-- =====================================================

-- Tabla: APPLICATION
-- Aplicaciones de candidatos a posiciones
CREATE TABLE application (
    id SERIAL PRIMARY KEY,
    position_id INTEGER NOT NULL REFERENCES position(id) ON DELETE CASCADE,
    candidate_id INTEGER NOT NULL REFERENCES candidate(id) ON DELETE CASCADE,
    application_date DATE DEFAULT CURRENT_DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'submitted' NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT application_status_valid CHECK (status IN ('submitted', 'under_review', 'interview', 'rejected', 'accepted', 'withdrawn')),
    CONSTRAINT unique_candidate_position UNIQUE(candidate_id, position_id)
);

-- Tabla: INTERVIEW
-- Entrevistas realizadas dentro de una aplicación
CREATE TABLE interview (
    id SERIAL PRIMARY KEY,
    application_id INTEGER NOT NULL REFERENCES application(id) ON DELETE CASCADE,
    interview_step_id INTEGER NOT NULL REFERENCES interview_step(id) ON DELETE RESTRICT,
    employee_id INTEGER NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    interview_date TIMESTAMP WITH TIME ZONE NOT NULL,
    result VARCHAR(50),
    score INTEGER CHECK (score >= 0 AND score <= 100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT interview_result_valid CHECK (result IN ('pending', 'passed', 'failed', 'cancelled'))
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN DE RENDIMIENTO
-- =====================================================

-- COMPANY
CREATE INDEX idx_company_name ON company USING btree (name);

-- EMPLOYEE
CREATE INDEX idx_employee_company_id ON employee USING btree (company_id);
CREATE INDEX idx_employee_email ON employee USING btree (email);
CREATE INDEX idx_employee_is_active ON employee USING btree (is_active) WHERE is_active = true;
CREATE INDEX idx_employee_company_active ON employee USING btree (company_id, is_active);

-- INTERVIEW_TYPE
CREATE INDEX idx_interview_type_name ON interview_type USING btree (name);

-- INTERVIEW_FLOW
CREATE INDEX idx_interview_flow_active ON interview_flow USING btree (is_active) WHERE is_active = true;

-- INTERVIEW_STEP
CREATE INDEX idx_interview_step_flow_id ON interview_step USING btree (interview_flow_id);
CREATE INDEX idx_interview_step_type_id ON interview_step USING btree (interview_type_id);
CREATE INDEX idx_interview_step_flow_order ON interview_step USING btree (interview_flow_id, order_index);

-- POSITION
CREATE INDEX idx_position_company_id ON position USING btree (company_id);
CREATE INDEX idx_position_interview_flow_id ON position USING btree (interview_flow_id);
CREATE INDEX idx_position_status ON position USING btree (status);
CREATE INDEX idx_position_visible ON position USING btree (is_visible) WHERE is_visible = true;
CREATE INDEX idx_position_company_status ON position USING btree (company_id, status);
CREATE INDEX idx_position_deadline ON position USING btree (application_deadline) WHERE application_deadline IS NOT NULL;
CREATE INDEX idx_position_employment_type ON position USING btree (employment_type);
-- Índice para búsquedas de texto completo
CREATE INDEX idx_position_title_trgm ON position USING gin (title gin_trgm_ops);
CREATE INDEX idx_position_location ON position USING btree (location) WHERE location IS NOT NULL;

-- CANDIDATE
CREATE INDEX idx_candidate_email ON candidate USING btree (email);
CREATE INDEX idx_candidate_name ON candidate USING btree (last_name, first_name);
-- Índice para búsquedas de texto completo en nombre
CREATE INDEX idx_candidate_full_name_trgm ON candidate USING gin ((first_name || ' ' || last_name) gin_trgm_ops);
CREATE INDEX idx_candidate_created_at ON candidate USING btree (created_at DESC);

-- EDUCATION
CREATE INDEX idx_education_candidate_id ON education USING btree (candidate_id);
CREATE INDEX idx_education_dates ON education USING btree (start_date DESC, end_date DESC);

-- WORK_EXPERIENCE
CREATE INDEX idx_work_experience_candidate_id ON work_experience USING btree (candidate_id);
CREATE INDEX idx_work_experience_dates ON work_experience USING btree (start_date DESC, end_date DESC);

-- RESUME
CREATE INDEX idx_resume_candidate_id ON resume USING btree (candidate_id);
CREATE INDEX idx_resume_upload_date ON resume USING btree (upload_date DESC);

-- APPLICATION
CREATE INDEX idx_application_position_id ON application USING btree (position_id);
CREATE INDEX idx_application_candidate_id ON application USING btree (candidate_id);
CREATE INDEX idx_application_status ON application USING btree (status);
CREATE INDEX idx_application_date ON application USING btree (application_date DESC);
CREATE INDEX idx_application_position_status ON application USING btree (position_id, status);
CREATE INDEX idx_application_candidate_status ON application USING btree (candidate_id, status);

-- INTERVIEW
CREATE INDEX idx_interview_application_id ON interview USING btree (application_id);
CREATE INDEX idx_interview_step_id ON interview USING btree (interview_step_id);
CREATE INDEX idx_interview_employee_id ON interview USING btree (employee_id);
CREATE INDEX idx_interview_date ON interview USING btree (interview_date DESC);
CREATE INDEX idx_interview_result ON interview USING btree (result);
CREATE INDEX idx_interview_employee_date ON interview USING btree (employee_id, interview_date DESC);

-- =====================================================
-- TRIGGERS PARA ACTUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_company_updated_at BEFORE UPDATE ON company
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employee_updated_at BEFORE UPDATE ON employee
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_flow_updated_at BEFORE UPDATE ON interview_flow
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_position_updated_at BEFORE UPDATE ON position
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_candidate_updated_at BEFORE UPDATE ON candidate
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_application_updated_at BEFORE UPDATE ON application
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_updated_at BEFORE UPDATE ON interview
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- COMENTARIOS PARA DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE company IS 'Organizaciones que utilizan el sistema ATS';
COMMENT ON TABLE employee IS 'Empleados que participan en procesos de reclutamiento';
COMMENT ON TABLE interview_type IS 'Tipos de entrevistas (técnica, RH, cultural, etc.)';
COMMENT ON TABLE interview_flow IS 'Flujos de entrevista reutilizables';
COMMENT ON TABLE interview_step IS 'Pasos individuales dentro de un flujo de entrevista';
COMMENT ON TABLE position IS 'Posiciones de trabajo disponibles';
COMMENT ON TABLE candidate IS 'Candidatos que aplican a posiciones';
COMMENT ON TABLE education IS 'Historial educativo de candidatos';
COMMENT ON TABLE work_experience IS 'Experiencia laboral de candidatos';
COMMENT ON TABLE resume IS 'CVs y documentos de candidatos';
COMMENT ON TABLE application IS 'Aplicaciones de candidatos a posiciones específicas';
COMMENT ON TABLE interview IS 'Entrevistas realizadas dentro del proceso de aplicación';

-- =====================================================
-- DATOS SEMILLA (OPCIONAL)
-- =====================================================

-- Tipos de entrevista comunes
INSERT INTO interview_type (name, description) VALUES
    ('Screening Telefónico', 'Primera entrevista para validar información básica del candidato'),
    ('Técnica', 'Entrevista para evaluar habilidades técnicas específicas'),
    ('Recursos Humanos', 'Entrevista para evaluar fit cultural y beneficios'),
    ('Gerencial', 'Entrevista con gerentes o líderes de equipo'),
    ('Final', 'Entrevista final con stakeholders clave');

COMMENT ON DATABASE CURRENT_DATABASE() IS 'Sistema de Gestión de Reclutamiento (ATS) - Versión optimizada';
