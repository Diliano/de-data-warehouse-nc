\c ncstaffsql


-- fact_staff_performance:
-- staff_perf_id, staff_id REF, cohort_id REF, mentees, mentees_staff_rating, daily_rate, revenue

-- dim_staff:
-- staff_id, first_name, last_name, area, manager

-- dim_cohort:
-- cohort_id, course, next_cohort_date


DROP TABLE IF EXISTS fact_staff_performance;
DROP TABLE IF EXISTS dim_cohort;
DROP TABLE IF EXISTS dim_staff;

-- create dim_staff

CREATE TABLE dim_staff (
    staff_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    area VARCHAR(50),
    manager_name VARCHAR(100)
);

-- create dim_cohort

CREATE TABLE dim_cohort (
    cohort_id SERIAL PRIMARY KEY,
    course VARCHAR(50),
    next_cohort_date DATE
);

-- create fact_staff_performance

CREATE TABLE fact_staff_performance (
    staff_perf_id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES dim_staff(staff_id),
    cohort_id INT REFERENCES dim_cohort(cohort_id),
    mentees INT,
    mentees_staff_rating INT,
    daily_rate DECIMAL(6, 2),
    revenue DECIMAL(7, 2)
);

-- migrate into dim_staff

INSERT INTO dim_staff 
    (staff_id, full_name, area, manager_name)
SELECT
    staff_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    area,
    manager AS manager_name
FROM staff;

SELECT * FROM dim_staff;

-- migrate into dim_cohort

INSERT INTO dim_cohort
    (course, next_cohort_date)
SELECT DISTINCT
    course,
    TO_DATE(next_cohort_date, 'DD Month YYYY')
FROM staff;

SELECT * FROM dim_cohort;

-- migrate into fact_staff_performance

INSERT INTO fact_staff_performance 
    (staff_id, cohort_id, mentees, mentees_staff_rating, daily_rate, revenue)
SELECT 
    s.staff_id,
    dim_c.cohort_id,
    s.mentees,
    s.mentees_staff_rating,
    s.daily_rate,
    s.revenue
FROM staff AS s
JOIN dim_cohort AS dim_c ON s.course = dim_c.course
    AND TO_DATE(s.next_cohort_date, 'DD Month YYYY') = dim_c.next_cohort_date;

SELECT * FROM fact_staff_performance;

