-- Database: gce_al_dw;

-- ============================================================
-- GCE A/L EXAMINATION DATA WAREHOUSE
-- PostgreSQL
-- ============================================================


-- ============================================================
-- 1. DIMENSION: STUDENT
-- ============================================================

CREATE TABLE dim_student (
    student_key SERIAL PRIMARY KEY,
    student_id VARCHAR(30) UNIQUE NOT NULL,
    gender VARCHAR(20),
    date_of_birth DATE
);


-- ============================================================
-- 2. DIMENSION: SUBJECT
-- ============================================================

CREATE TABLE dim_subject (
    subject_key SERIAL PRIMARY KEY,
    subject_code VARCHAR(20),
    subject_name VARCHAR(100) NOT NULL,
    subject_category VARCHAR(50)
);


-- ============================================================
-- 3. DIMENSION: STREAM
-- ============================================================

CREATE TABLE dim_stream (
    stream_key SERIAL PRIMARY KEY,
    stream_code VARCHAR(20),
    stream_name VARCHAR(100) NOT NULL,
    stream_category VARCHAR(100)
);


-- ============================================================
-- 4. DIMENSION: LOCATION
-- ============================================================

CREATE TABLE dim_location (
    location_key SERIAL PRIMARY KEY,
    district VARCHAR(100),
    province VARCHAR(100),
    examination_region VARCHAR(100)
);


-- ============================================================
-- 5. DIMENSION: DATE
-- ============================================================

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    day INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    quarter INTEGER,
    year INTEGER
);


-- ============================================================
-- 6. DIMENSION: GRADE
-- ============================================================

CREATE TABLE dim_grade (
    grade_key SERIAL PRIMARY KEY,
    grade_code VARCHAR(10) NOT NULL,
    grade_description VARCHAR(50),
    grade_points NUMERIC(5,2),
    pass_flag BOOLEAN
);


-- ============================================================
-- 7. FACT TABLE: EXAM RESULT
-- ============================================================

CREATE TABLE fact_exam_result (
    result_key BIGSERIAL PRIMARY KEY,

    student_key INTEGER NOT NULL,
    subject_key INTEGER NOT NULL,
    stream_key INTEGER NOT NULL,
    location_key INTEGER,
    date_key INTEGER NOT NULL,
    grade_key INTEGER,

    marks NUMERIC(5,2),
    z_score NUMERIC(6,3),

    pass_flag BOOLEAN,
    attempt_number INTEGER,

    candidate_count INTEGER DEFAULT 1,

    -- Foreign Keys
    CONSTRAINT fk_fact_student
        FOREIGN KEY (student_key)
        REFERENCES dim_student(student_key),

    CONSTRAINT fk_fact_subject
        FOREIGN KEY (subject_key)
        REFERENCES dim_subject(subject_key),

    CONSTRAINT fk_fact_stream
        FOREIGN KEY (stream_key)
        REFERENCES dim_stream(stream_key),

    CONSTRAINT fk_fact_location
        FOREIGN KEY (location_key)
        REFERENCES dim_location(location_key),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_fact_grade
        FOREIGN KEY (grade_key)
        REFERENCES dim_grade(grade_key)
);


-- ============================================================
-- 8. INDEXES FOR FACT TABLE
-- ============================================================

CREATE INDEX idx_fact_student
ON fact_exam_result(student_key);

CREATE INDEX idx_fact_subject
ON fact_exam_result(subject_key);

CREATE INDEX idx_fact_stream
ON fact_exam_result(stream_key);

CREATE INDEX idx_fact_location
ON fact_exam_result(location_key);

CREATE INDEX idx_fact_date
ON fact_exam_result(date_key);

CREATE INDEX idx_fact_grade
ON fact_exam_result(grade_key);


-- ============================================================
-- END OF DATA WAREHOUSE CREATION
-- ============================================================






INSERT INTO dim_date (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d AS full_date,
    EXTRACT(DAY FROM d)::INTEGER AS day,
    EXTRACT(MONTH FROM d)::INTEGER AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    EXTRACT(YEAR FROM d)::INTEGER AS year
FROM generate_series(
    '2020-01-01'::DATE,
    '2020-12-31'::DATE,
    '1 day'::INTERVAL
) AS d;



SELECT *
FROM dim_date
ORDER BY full_date
LIMIT 10;



INSERT INTO dim_grade
    (grade_code, grade_description, grade_points, pass_flag)
VALUES
    ('A', 'Excellent Pass', 4.00, TRUE),
    ('B', 'Very Good Pass', 3.00, TRUE),
    ('C', 'Credit Pass', 2.00, TRUE),
    ('S', 'Simple Pass', 1.00, TRUE),
    ('F', 'Fail', 0.00, FALSE),
    ('W', 'Absent/Withheld', 0.00, FALSE);


	INSERT INTO dim_stream
    (stream_code, stream_name, stream_category)
VALUES
    ('ART', 'Arts', 'General'),
    ('BIO', 'Biological Science', 'Science'),
    ('COM', 'Commerce', 'General'),
    ('PHY', 'Physical Science', 'Science'),
    ('BST', 'Biosystems Technology', 'Technology'),
    ('ET', 'Engineering Technology', 'Technology');



	INSERT INTO dim_subject
    (subject_code, subject_name, subject_category)
VALUES
    ('BIO', 'Biology', 'Biological Science'),
    ('CHE', 'Chemistry', 'Physical Science'),
    ('PHY', 'Physics', 'Physical Science'),
    ('COM', 'Accounting', 'Commerce'),
    ('ECO', 'Economics', 'Commerce'),
    ('ICT', 'Information and Communication Technology', 'Technology');



	