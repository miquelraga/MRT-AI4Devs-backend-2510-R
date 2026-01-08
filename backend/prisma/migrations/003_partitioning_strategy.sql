-- =====================================================
-- ESTRATEGIA DE PARTICIONAMIENTO PARA ESCALABILIDAD
-- Se implementa particionamiento por rango en tablas de alto volumen
-- =====================================================

-- =====================================================
-- PARTICIONAMIENTO DE TABLA APPLICATION
-- Particionada por año de aplicación
-- =====================================================

-- 1. Crear nueva tabla particionada
CREATE TABLE application_partitioned (
    id SERIAL,
    position_id INTEGER NOT NULL,
    candidate_id INTEGER NOT NULL,
    application_date DATE DEFAULT CURRENT_DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'submitted' NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT application_partitioned_status_valid CHECK (status IN ('submitted', 'under_review', 'interview', 'rejected', 'accepted', 'withdrawn')),
    PRIMARY KEY (id, application_date)
) PARTITION BY RANGE (application_date);

-- 2. Crear particiones por año (2024-2027)
CREATE TABLE application_2024 PARTITION OF application_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE application_2025 PARTITION OF application_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE application_2026 PARTITION OF application_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE application_2027 PARTITION OF application_partitioned
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');

-- Partición por defecto para fechas futuras
CREATE TABLE application_default PARTITION OF application_partitioned DEFAULT;

-- 3. Crear índices en tabla particionada
CREATE INDEX idx_application_part_position_id ON application_partitioned (position_id);
CREATE INDEX idx_application_part_candidate_id ON application_partitioned (candidate_id);
CREATE INDEX idx_application_part_status ON application_partitioned (status);
CREATE INDEX idx_application_part_date ON application_partitioned (application_date DESC);
CREATE INDEX idx_application_part_position_status ON application_partitioned (position_id, status);

-- 4. Añadir foreign keys (se aplican a todas las particiones)
ALTER TABLE application_partitioned 
    ADD CONSTRAINT fk_application_part_position 
    FOREIGN KEY (position_id) REFERENCES position(id) ON DELETE CASCADE;

ALTER TABLE application_partitioned 
    ADD CONSTRAINT fk_application_part_candidate 
    FOREIGN KEY (candidate_id) REFERENCES candidate(id) ON DELETE CASCADE;

-- 5. Añadir trigger para updated_at
CREATE TRIGGER update_application_partitioned_updated_at 
    BEFORE UPDATE ON application_partitioned
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- PARTICIONAMIENTO DE TABLA INTERVIEW
-- Particionada por fecha de entrevista
-- =====================================================

-- 1. Crear nueva tabla particionada
CREATE TABLE interview_partitioned (
    id SERIAL,
    application_id INTEGER NOT NULL,
    interview_step_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    interview_date TIMESTAMP WITH TIME ZONE NOT NULL,
    result VARCHAR(50),
    score INTEGER CHECK (score >= 0 AND score <= 100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT interview_partitioned_result_valid CHECK (result IN ('pending', 'passed', 'failed', 'cancelled')),
    PRIMARY KEY (id, interview_date)
) PARTITION BY RANGE (interview_date);

-- 2. Crear particiones trimestrales (más granularidad para entrevistas)
-- Q1 2025
CREATE TABLE interview_2025_q1 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

-- Q2 2025
CREATE TABLE interview_2025_q2 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

-- Q3 2025
CREATE TABLE interview_2025_q3 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

-- Q4 2025
CREATE TABLE interview_2025_q4 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Q1 2026
CREATE TABLE interview_2026_q1 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

-- Q2 2026
CREATE TABLE interview_2026_q2 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');

-- Q3 2026
CREATE TABLE interview_2026_q3 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');

-- Q4 2026
CREATE TABLE interview_2026_q4 PARTITION OF interview_partitioned
    FOR VALUES FROM ('2026-10-01') TO ('2027-01-01');

-- Partición por defecto
CREATE TABLE interview_default PARTITION OF interview_partitioned DEFAULT;

-- 3. Crear índices
CREATE INDEX idx_interview_part_application_id ON interview_partitioned (application_id);
CREATE INDEX idx_interview_part_step_id ON interview_partitioned (interview_step_id);
CREATE INDEX idx_interview_part_employee_id ON interview_partitioned (employee_id);
CREATE INDEX idx_interview_part_date ON interview_partitioned (interview_date DESC);
CREATE INDEX idx_interview_part_result ON interview_partitioned (result);
CREATE INDEX idx_interview_part_employee_date ON interview_partitioned (employee_id, interview_date DESC);

-- 4. Añadir foreign keys
ALTER TABLE interview_partitioned 
    ADD CONSTRAINT fk_interview_part_application 
    FOREIGN KEY (application_id) REFERENCES application(id) ON DELETE CASCADE;

ALTER TABLE interview_partitioned 
    ADD CONSTRAINT fk_interview_part_step 
    FOREIGN KEY (interview_step_id) REFERENCES interview_step(id) ON DELETE RESTRICT;

ALTER TABLE interview_partitioned 
    ADD CONSTRAINT fk_interview_part_employee 
    FOREIGN KEY (employee_id) REFERENCES employee(id) ON DELETE RESTRICT;

-- 5. Añadir trigger
CREATE TRIGGER update_interview_partitioned_updated_at 
    BEFORE UPDATE ON interview_partitioned
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNCIÓN PARA CREAR AUTOMÁTICAMENTE NUEVAS PARTICIONES
-- =====================================================

CREATE OR REPLACE FUNCTION create_application_partition(target_year INTEGER)
RETURNS void AS $$
DECLARE
    partition_name TEXT;
    start_date DATE;
    end_date DATE;
BEGIN
    partition_name := 'application_' || target_year::TEXT;
    start_date := (target_year || '-01-01')::DATE;
    end_date := ((target_year + 1) || '-01-01')::DATE;
    
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF application_partitioned FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );
    
    RAISE NOTICE 'Created partition: %', partition_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_interview_partition(target_year INTEGER, target_quarter INTEGER)
RETURNS void AS $$
DECLARE
    partition_name TEXT;
    start_date DATE;
    end_date DATE;
    start_month INTEGER;
BEGIN
    partition_name := 'interview_' || target_year::TEXT || '_q' || target_quarter::TEXT;
    start_month := (target_quarter - 1) * 3 + 1;
    start_date := (target_year || '-' || LPAD(start_month::TEXT, 2, '0') || '-01')::DATE;
    
    IF target_quarter = 4 THEN
        end_date := ((target_year + 1) || '-01-01')::DATE;
    ELSE
        end_date := (target_year || '-' || LPAD((start_month + 3)::TEXT, 2, '0') || '-01')::DATE;
    END IF;
    
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF interview_partitioned FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );
    
    RAISE NOTICE 'Created partition: %', partition_name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PROCEDIMIENTO PARA MANTENIMIENTO AUTOMÁTICO DE PARTICIONES
-- =====================================================

CREATE OR REPLACE FUNCTION maintain_partitions()
RETURNS void AS $$
DECLARE
    current_year INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    current_quarter INTEGER := EXTRACT(QUARTER FROM CURRENT_DATE);
BEGIN
    -- Crear particiones para el próximo año en applications
    PERFORM create_application_partition(current_year + 1);
    
    -- Crear particiones para los próximos 2 trimestres en interviews
    IF current_quarter <= 2 THEN
        PERFORM create_interview_partition(current_year, current_quarter + 2);
    ELSE
        PERFORM create_interview_partition(current_year + 1, current_quarter - 2);
    END IF;
    
    PERFORM create_interview_partition(current_year + 1, CASE WHEN current_quarter = 4 THEN 1 ELSE current_quarter + 1 END);
    
    RAISE NOTICE 'Partition maintenance completed';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON TABLE application_partitioned IS 'Tabla de aplicaciones particionada por año para mejor rendimiento';
COMMENT ON TABLE interview_partitioned IS 'Tabla de entrevistas particionada por trimestre para mejor rendimiento';
COMMENT ON FUNCTION create_application_partition IS 'Crea una nueva partición anual para applications';
COMMENT ON FUNCTION create_interview_partition IS 'Crea una nueva partición trimestral para interviews';
COMMENT ON FUNCTION maintain_partitions IS 'Mantenimiento automático de particiones futuras';

-- =====================================================
-- NOTA IMPORTANTE
-- =====================================================
-- Para migrar datos de las tablas originales a las particionadas:
-- 
-- 1. Insertar datos existentes:
--    INSERT INTO application_partitioned SELECT * FROM application;
--    INSERT INTO interview_partitioned SELECT * FROM interview;
--
-- 2. Verificar integridad de datos
--
-- 3. Renombrar tablas:
--    ALTER TABLE application RENAME TO application_old;
--    ALTER TABLE application_partitioned RENAME TO application;
--    
--    ALTER TABLE interview RENAME TO interview_old;
--    ALTER TABLE interview_partitioned RENAME TO interview;
--
-- 4. Actualizar vistas y aplicaciones que referencien estas tablas
--
-- 5. Después de verificar, eliminar tablas antiguas:
--    DROP TABLE application_old;
--    DROP TABLE interview_old;
-- =====================================================
