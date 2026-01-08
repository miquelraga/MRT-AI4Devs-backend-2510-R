-- =====================================================
-- DATOS DE PRUEBA (SEED DATA)
-- Script para poblar la base de datos con datos de ejemplo
-- =====================================================

-- =====================================================
-- 1. COMPAÑÍAS
-- =====================================================

INSERT INTO company (name) VALUES
    ('TechCorp Solutions'),
    ('InnovateSoft Inc'),
    ('DataDrive Analytics'),
    ('CloudNine Systems'),
    ('AI Ventures Ltd');

-- =====================================================
-- 2. EMPLEADOS
-- =====================================================

INSERT INTO employee (company_id, name, email, role, is_active) VALUES
    -- TechCorp Solutions
    (1, 'Sarah Johnson', 'sarah.johnson@techcorp.com', 'Senior Recruiter', true),
    (1, 'Michael Chen', 'michael.chen@techcorp.com', 'Technical Lead', true),
    (1, 'Emma Williams', 'emma.williams@techcorp.com', 'HR Manager', true),
    
    -- InnovateSoft Inc
    (2, 'David Martinez', 'david.martinez@innovatesoft.com', 'Recruiting Manager', true),
    (2, 'Lisa Anderson', 'lisa.anderson@innovatesoft.com', 'Engineering Manager', true),
    
    -- DataDrive Analytics
    (3, 'James Wilson', 'james.wilson@datadrive.com', 'Talent Acquisition', true),
    (3, 'Maria Garcia', 'maria.garcia@datadrive.com', 'CTO', true),
    
    -- CloudNine Systems
    (4, 'Robert Taylor', 'robert.taylor@cloudnine.com', 'HR Director', true),
    
    -- AI Ventures Ltd
    (5, 'Jennifer Lee', 'jennifer.lee@aiventures.com', 'Head of Recruitment', true),
    (5, 'Thomas Brown', 'thomas.brown@aiventures.com', 'Tech Lead', true);

-- =====================================================
-- 3. TIPOS DE ENTREVISTA
-- =====================================================

INSERT INTO interview_type (name, description) VALUES
    ('Phone Screening', 'Initial phone call to assess basic qualifications and interest'),
    ('Technical Interview', 'In-depth technical assessment covering programming skills and problem-solving'),
    ('System Design', 'Evaluation of system architecture and design capabilities'),
    ('Behavioral Interview', 'Assessment of soft skills, culture fit, and past experiences'),
    ('HR Interview', 'Discussion of compensation, benefits, and company policies'),
    ('Final Round', 'Meeting with senior leadership and final decision makers'),
    ('Coding Challenge', 'Live coding session to evaluate programming proficiency');

-- =====================================================
-- 4. FLUJOS DE ENTREVISTA
-- =====================================================

INSERT INTO interview_flow (description, is_active) VALUES
    ('Standard Software Engineer Flow', true),
    ('Senior Engineer Fast Track', true),
    ('Junior Developer Flow', true),
    ('Data Scientist Flow', true),
    ('Product Manager Flow', true);

-- =====================================================
-- 5. PASOS DE ENTREVISTA
-- =====================================================

-- Flow 1: Standard Software Engineer
INSERT INTO interview_step (interview_flow_id, interview_type_id, name, order_index) VALUES
    (1, 1, 'Initial Phone Screen', 1),
    (1, 2, 'Technical Interview Round 1', 2),
    (1, 7, 'Coding Challenge', 3),
    (1, 4, 'Behavioral Interview', 4),
    (1, 6, 'Final Interview with Team Lead', 5);

-- Flow 2: Senior Engineer Fast Track
INSERT INTO interview_step (interview_flow_id, interview_type_id, name, order_index) VALUES
    (2, 1, 'Phone Screening', 1),
    (2, 3, 'System Design Interview', 2),
    (2, 4, 'Culture Fit Discussion', 3),
    (2, 6, 'Executive Interview', 4);

-- Flow 3: Junior Developer
INSERT INTO interview_step (interview_flow_id, interview_type_id, name, order_index) VALUES
    (3, 1, 'Initial Call', 1),
    (3, 7, 'Basic Coding Test', 2),
    (3, 2, 'Technical Review', 3),
    (3, 5, 'HR Final Interview', 4);

-- Flow 4: Data Scientist
INSERT INTO interview_step (interview_flow_id, interview_type_id, name, order_index) VALUES
    (4, 1, 'Screening Call', 1),
    (4, 2, 'Technical Assessment', 2),
    (4, 3, 'Data Architecture Discussion', 3),
    (4, 6, 'Leadership Interview', 4);

-- =====================================================
-- 6. POSICIONES
-- =====================================================

INSERT INTO position (
    company_id, interview_flow_id, title, description, status, is_visible,
    location, requirements, responsibilities, salary_min, salary_max,
    employment_type, benefits, application_deadline
) VALUES
    (1, 1, 'Senior Full Stack Developer', 
     'We are looking for an experienced Full Stack Developer to join our growing team.',
     'open', true, 'San Francisco, CA',
     E'• 5+ years of experience in web development\n• Proficiency in React and Node.js\n• Experience with PostgreSQL\n• Strong problem-solving skills',
     E'• Design and implement scalable web applications\n• Collaborate with cross-functional teams\n• Mentor junior developers\n• Participate in code reviews',
     120000.00, 180000.00, 'full-time',
     E'• Health insurance\n• 401(k) matching\n• Flexible work hours\n• Remote work options',
     '2026-03-31'),
    
    (1, 2, 'Principal Software Engineer',
     'Lead our engineering team in building next-generation cloud solutions.',
     'open', true, 'San Francisco, CA / Remote',
     E'• 10+ years of software engineering experience\n• Experience leading technical teams\n• Deep knowledge of distributed systems\n• Cloud architecture expertise (AWS/GCP)',
     E'• Lead technical direction and architecture\n• Mentor engineering teams\n• Drive technical innovation\n• Collaborate with product and design teams',
     180000.00, 250000.00, 'full-time',
     E'• Comprehensive health benefits\n• Stock options\n• Unlimited PTO\n• Learning budget',
     '2026-06-30'),
    
    (2, 3, 'Junior Frontend Developer',
     'Join our team to learn and grow as a frontend developer.',
     'open', true, 'New York, NY',
     E'• 0-2 years of experience\n• Basic knowledge of HTML, CSS, JavaScript\n• Familiar with React or Vue.js\n• Eager to learn and grow',
     E'• Develop user interface components\n• Work with senior developers\n• Participate in daily standups\n• Learn best practices',
     60000.00, 80000.00, 'full-time',
     E'• Health insurance\n• Professional development\n• Mentorship program',
     '2026-02-28'),
    
    (3, 4, 'Data Scientist',
     'Use data science and machine learning to solve complex business problems.',
     'open', true, 'Austin, TX',
     E'• Master''s degree in relevant field\n• 3+ years of experience in data science\n• Proficiency in Python and R\n• Experience with ML frameworks',
     E'• Build predictive models\n• Analyze large datasets\n• Present findings to stakeholders\n• Collaborate with engineering teams',
     100000.00, 150000.00, 'full-time',
     E'• Health insurance\n• 401(k) matching\n• Conference attendance\n• Research time',
     '2026-04-30'),
    
    (4, 1, 'Backend Developer',
     'Build robust and scalable backend services for our platform.',
     'open', true, 'Seattle, WA',
     E'• 3+ years of backend development\n• Experience with microservices\n• Strong database skills\n• Knowledge of API design',
     E'• Design and implement APIs\n• Optimize database queries\n• Ensure system reliability\n• Write technical documentation',
     90000.00, 130000.00, 'full-time',
     E'• Health benefits\n• Stock options\n• Gym membership\n• Free lunch',
     '2026-05-31'),
    
    (5, 2, 'Machine Learning Engineer',
     'Develop and deploy ML models at scale.',
     'open', true, 'Boston, MA / Remote',
     E'• 4+ years in ML engineering\n• Deep learning experience\n• Production ML systems\n• Strong Python skills',
     E'• Build ML pipelines\n• Deploy models to production\n• Optimize model performance\n• Research new techniques',
     130000.00, 200000.00, 'full-time',
     E'• Equity package\n• Full benefits\n• Research budget\n• Flexible schedule',
     '2026-07-31'),
    
    (1, 1, 'DevOps Engineer',
     'Manage and automate our cloud infrastructure.',
     'open', true, 'Remote',
     E'• 3+ years DevOps experience\n• Kubernetes expertise\n• CI/CD pipeline experience\n• Infrastructure as Code (Terraform)',
     E'• Maintain cloud infrastructure\n• Implement monitoring solutions\n• Automate deployment processes\n• Ensure system security',
     100000.00, 150000.00, 'full-time',
     E'• Full remote\n• Health insurance\n• Equipment allowance\n• Flexible hours',
     '2026-12-31');

-- =====================================================
-- 7. CANDIDATOS
-- =====================================================

INSERT INTO candidate (first_name, last_name, email, phone, address) VALUES
    ('Alex', 'Rodriguez', 'alex.rodriguez@email.com', '+1-555-0101', '123 Main St, San Francisco, CA'),
    ('Emily', 'Thompson', 'emily.thompson@email.com', '+1-555-0102', '456 Oak Ave, New York, NY'),
    ('Marcus', 'Johnson', 'marcus.johnson@email.com', '+1-555-0103', '789 Pine Rd, Austin, TX'),
    ('Sophie', 'Chen', 'sophie.chen@email.com', '+1-555-0104', '321 Elm St, Seattle, WA'),
    ('Daniel', 'Kim', 'daniel.kim@email.com', '+1-555-0105', '654 Maple Dr, Boston, MA'),
    ('Olivia', 'Garcia', 'olivia.garcia@email.com', '+1-555-0106', '987 Cedar Ln, San Francisco, CA'),
    ('William', 'Anderson', 'william.anderson@email.com', '+1-555-0107', '147 Birch Ave, New York, NY'),
    ('Isabella', 'Martinez', 'isabella.martinez@email.com', '+1-555-0108', '258 Spruce St, Austin, TX'),
    ('Ethan', 'Taylor', 'ethan.taylor@email.com', '+1-555-0109', '369 Willow Rd, Seattle, WA'),
    ('Ava', 'Wilson', 'ava.wilson@email.com', '+1-555-0110', '741 Ash Dr, Boston, MA'),
    ('Noah', 'Davis', 'noah.davis@email.com', '+1-555-0111', '852 Oak St, San Francisco, CA'),
    ('Mia', 'Lopez', 'mia.lopez@email.com', '+1-555-0112', '963 Pine Ave, New York, NY'),
    ('Lucas', 'Gonzalez', 'lucas.gonzalez@email.com', '+1-555-0113', '159 Elm Rd, Austin, TX'),
    ('Charlotte', 'Hernandez', 'charlotte.hernandez@email.com', '+1-555-0114', '357 Maple St, Seattle, WA'),
    ('James', 'Moore', 'james.moore@email.com', '+1-555-0115', '753 Cedar Ave, Boston, MA');

-- =====================================================
-- 8. EDUCACIÓN
-- =====================================================

INSERT INTO education (candidate_id, institution, title, start_date, end_date) VALUES
    (1, 'MIT', 'BS in Computer Science', '2015-09-01', '2019-05-15'),
    (1, 'MIT', 'MS in Computer Science', '2019-09-01', '2021-05-15'),
    (2, 'Stanford University', 'BS in Software Engineering', '2016-09-01', '2020-06-01'),
    (3, 'UC Berkeley', 'BS in Data Science', '2017-09-01', '2021-05-20'),
    (4, 'Carnegie Mellon', 'BS in Computer Science', '2018-09-01', '2022-05-15'),
    (5, 'Harvard University', 'MS in Data Science', '2019-09-01', '2021-06-01'),
    (6, 'Stanford University', 'BS in Computer Science', '2014-09-01', '2018-06-01'),
    (7, 'Columbia University', 'BS in Information Systems', '2017-09-01', '2021-05-15'),
    (8, 'UT Austin', 'BS in Computer Engineering', '2016-09-01', '2020-05-20'),
    (9, 'University of Washington', 'MS in Computer Science', '2018-09-01', '2020-06-15'),
    (10, 'Boston University', 'BS in Computer Science', '2019-09-01', NULL);  -- Still studying

-- =====================================================
-- 9. EXPERIENCIA LABORAL
-- =====================================================

INSERT INTO work_experience (candidate_id, company, position, description, start_date, end_date) VALUES
    (1, 'Google', 'Software Engineer', 'Worked on Google Cloud Platform infrastructure', '2021-06-01', '2023-12-31'),
    (1, 'Facebook', 'Senior Software Engineer', 'Leading frontend development team', '2024-01-01', NULL),
    (2, 'Microsoft', 'Junior Developer', 'Developed internal tools', '2020-07-01', '2022-06-30'),
    (2, 'Amazon', 'Software Engineer', 'Working on AWS services', '2022-07-01', NULL),
    (3, 'IBM', 'Data Analyst', 'Analyzed business data and created reports', '2021-06-01', '2023-03-31'),
    (3, 'Salesforce', 'Data Scientist', 'Building ML models for customer insights', '2023-04-01', NULL),
    (4, 'Uber', 'Backend Engineer', 'Developed microservices', '2022-06-01', NULL),
    (5, 'Netflix', 'ML Engineer', 'Working on recommendation systems', '2021-07-01', NULL),
    (6, 'Apple', 'Software Engineer', 'iOS development', '2018-07-01', '2021-12-31'),
    (6, 'Tesla', 'Senior Software Engineer', 'Autonomous driving software', '2022-01-01', NULL),
    (7, 'LinkedIn', 'Full Stack Developer', 'Building professional networking features', '2021-06-01', NULL),
    (8, 'Twitter', 'Frontend Engineer', 'User interface development', '2020-07-01', '2023-06-30'),
    (9, 'Airbnb', 'DevOps Engineer', 'Cloud infrastructure management', '2020-07-01', NULL),
    (10, 'Stripe', 'Junior Developer', 'Payment processing systems', '2023-01-01', NULL);

-- =====================================================
-- 10. CURRÍCULOS
-- =====================================================

INSERT INTO resume (candidate_id, file_path, file_type, upload_date) VALUES
    (1, '/uploads/resumes/alex_rodriguez_2024.pdf', 'pdf', '2024-01-15 10:30:00'),
    (2, '/uploads/resumes/emily_thompson_cv.pdf', 'pdf', '2024-02-01 14:20:00'),
    (3, '/uploads/resumes/marcus_johnson_resume.pdf', 'pdf', '2024-02-10 09:15:00'),
    (4, '/uploads/resumes/sophie_chen_cv.docx', 'docx', '2024-03-05 11:45:00'),
    (5, '/uploads/resumes/daniel_kim_resume.pdf', 'pdf', '2024-03-15 16:30:00'),
    (6, '/uploads/resumes/olivia_garcia_cv.pdf', 'pdf', '2024-04-01 08:00:00'),
    (7, '/uploads/resumes/william_anderson_resume.pdf', 'pdf', '2024-04-20 13:25:00'),
    (8, '/uploads/resumes/isabella_martinez_cv.pdf', 'pdf', '2024-05-10 10:10:00'),
    (9, '/uploads/resumes/ethan_taylor_resume.pdf', 'pdf', '2024-06-01 15:40:00'),
    (10, '/uploads/resumes/ava_wilson_cv.pdf', 'pdf', '2024-06-15 09:30:00');

-- =====================================================
-- 11. APLICACIONES
-- =====================================================

INSERT INTO application (position_id, candidate_id, application_date, status, notes) VALUES
    -- Position 1: Senior Full Stack Developer
    (1, 1, '2025-01-10', 'interview', 'Strong technical background, proceeding to final round'),
    (1, 6, '2025-01-12', 'under_review', 'Reviewing portfolio'),
    (1, 11, '2025-01-15', 'rejected', 'Insufficient experience'),
    
    -- Position 2: Principal Software Engineer
    (2, 1, '2025-01-20', 'accepted', 'Excellent system design skills, offer extended'),
    (2, 6, '2025-01-22', 'interview', 'Impressive leadership experience'),
    
    -- Position 3: Junior Frontend Developer
    (3, 2, '2025-02-01', 'interview', 'Good potential, junior level appropriate'),
    (3, 10, '2025-02-05', 'under_review', 'Recent graduate, checking references'),
    (3, 7, '2025-02-08', 'submitted', 'New application'),
    
    -- Position 4: Data Scientist
    (4, 3, '2025-02-15', 'interview', 'Strong ML background'),
    (4, 5, '2025-02-18', 'accepted', 'Excellent data science skills, offer accepted'),
    (4, 13, '2025-02-20', 'rejected', 'Looking for more experience'),
    
    -- Position 5: Backend Developer
    (5, 4, '2025-03-01', 'interview', 'Good microservices experience'),
    (5, 9, '2025-03-05', 'under_review', 'Solid DevOps background'),
    (5, 12, '2025-03-08', 'submitted', 'Pending initial review'),
    
    -- Position 6: Machine Learning Engineer
    (6, 5, '2025-03-15', 'interview', 'Netflix experience is valuable'),
    (6, 3, '2025-03-18', 'under_review', 'Reviewing ML projects'),
    
    -- Position 7: DevOps Engineer
    (7, 9, '2025-04-01', 'interview', 'Kubernetes expertise noted'),
    (7, 4, '2025-04-05', 'submitted', 'Awaiting technical assessment');

-- =====================================================
-- 12. ENTREVISTAS
-- =====================================================

-- Application 1 (Alex for Senior Full Stack)
INSERT INTO interview (application_id, interview_step_id, employee_id, interview_date, result, score, notes) VALUES
    (1, 1, 1, '2025-01-11 10:00:00', 'passed', 85, 'Good communication, strong technical understanding'),
    (1, 2, 2, '2025-01-13 14:00:00', 'passed', 90, 'Excellent problem-solving skills'),
    (1, 3, 2, '2025-01-15 10:00:00', 'passed', 88, 'Clean code, good architectural decisions'),
    (1, 4, 3, '2025-01-17 15:00:00', 'passed', 92, 'Great culture fit, team player'),
    (1, 5, 2, '2025-01-19 11:00:00', 'pending', NULL, 'Final round scheduled');

-- Application 2 (Alex for Principal Engineer) - ACCEPTED
INSERT INTO interview (application_id, interview_step_id, employee_id, interview_date, result, score, notes) VALUES
    (2, 6, 4, '2025-01-21 10:00:00', 'passed', 95, 'Exceptional technical depth'),
    (2, 7, 5, '2025-01-23 14:00:00', 'passed', 93, 'Outstanding system design skills'),
    (2, 8, 4, '2025-01-25 16:00:00', 'passed', 90, 'Strong leadership qualities'),
    (2, 9, 5, '2025-01-27 10:00:00', 'passed', 95, 'Perfect fit for the role');

-- Application 6 (Emily for Junior Frontend)
INSERT INTO interview (application_id, interview_step_id, employee_id, interview_date, result, score, notes) VALUES
    (6, 11, 4, '2025-02-02 10:00:00', 'passed', 75, 'Good basics, needs mentoring'),
    (6, 12, 5, '2025-02-04 14:00:00', 'passed', 78, 'Decent coding skills for junior level'),
    (6, 13, 5, '2025-02-06 10:00:00', 'passed', 80, 'Shows good learning potential'),
    (6, 14, 4, '2025-02-08 15:00:00', 'pending', NULL, 'HR interview scheduled');

-- Application 9 (Marcus for Data Scientist)
INSERT INTO interview (application_id, interview_step_id, employee_id, interview_date, result, score, notes) VALUES
    (9, 16, 6, '2025-02-16 10:00:00', 'passed', 88, 'Strong statistical background'),
    (9, 17, 7, '2025-02-18 14:00:00', 'passed', 85, 'Good ML knowledge'),
    (9, 18, 7, '2025-02-20 16:00:00', 'passed', 90, 'Excellent data architecture skills'),
    (9, 19, 6, '2025-02-22 11:00:00', 'pending', NULL, 'Leadership interview upcoming');

-- Application 10 (Daniel for Data Scientist) - ACCEPTED
INSERT INTO interview (application_id, interview_step_id, employee_id, interview_date, result, score, notes) VALUES
    (10, 16, 6, '2025-02-19 10:00:00', 'passed', 95, 'Outstanding ML expertise'),
    (10, 17, 7, '2025-02-21 14:00:00', 'passed', 93, 'Impressive project portfolio'),
    (10, 18, 7, '2025-02-23 16:00:00', 'passed', 92, 'Strong technical depth'),
    (10, 19, 6, '2025-02-25 10:00:00', 'passed', 94, 'Excellent fit, offer extended');

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Ver estadísticas
SELECT 
    'Companies' as entity, COUNT(*) as count FROM company
UNION ALL
SELECT 'Employees', COUNT(*) FROM employee
UNION ALL
SELECT 'Positions', COUNT(*) FROM position
UNION ALL
SELECT 'Candidates', COUNT(*) FROM candidate
UNION ALL
SELECT 'Applications', COUNT(*) FROM application
UNION ALL
SELECT 'Interviews', COUNT(*) FROM interview;

COMMENT ON SCHEMA public IS 'Schema poblado con datos de prueba - ATS System';
