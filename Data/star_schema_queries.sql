\c ncstaffsql

-- Which manager has the lowest-rated staff member?

SELECT dim_s.manager_name
FROM dim_staff AS dim_s 
JOIN fact_staff_performance AS fact_s ON dim_s.staff_id = fact_s.staff_id
WHERE fact_s.mentees_staff_rating = (SELECT MIN(mentees_staff_rating) FROM fact_staff_performance);

-- Which staff member has worked the most cohorts based on how much they charge per event and the total revenue so far?

SELECT dim_s.full_name AS staff_member, CAST((fact_s.revenue / fact_s.daily_rate) AS INT) AS num_cohorts_worked
FROM dim_staff AS dim_s
JOIN fact_staff_performance AS fact_s ON dim_s.staff_id = fact_s.staff_id
ORDER BY num_cohorts_worked DESC
LIMIT 1;    

-- Which quarter is the busiest for our staff members?

WITH quarters AS (
    SELECT 
        CASE
            WHEN next_cohort_date < '2024-04-01' THEN 1
            WHEN next_cohort_date < '2024-07-01' THEN 2
            WHEN next_cohort_date < '2024-10-01' THEN 3
        ELSE
            4 
        END AS quarter
    FROM dim_cohort
)
SELECT quarter, COUNT(quarter) AS num_cohorts 
FROM quarters
GROUP BY quarter
ORDER by num_cohorts DESC
LIMIT 1;

-- What is the total revenue for that quarter?

SELECT SUM(fact_s.daily_rate) AS total_revenue
FROM fact_staff_performance AS fact_s 
JOIN dim_cohort AS dim_c ON fact_s.cohort_id = dim_c.cohort_id
WHERE next_cohort_date < '2024-04-01';

-- Which course brings in the most revenue?

SELECT dim_c.course, SUM(fact_s.revenue) AS total_revenue
FROM dim_cohort AS dim_c
JOIN fact_staff_performance AS fact_s ON dim_c.cohort_id = fact_s.cohort_id
GROUP BY dim_c.course
ORDER BY total_revenue DESC
LIMIT 1;

-- How many mentees are represented by staff members who are based in Manchester?

SELECT dim_s.area, SUM(fact_s.mentees) AS num_mentees
FROM dim_staff AS dim_s
JOIN fact_staff_performance AS fact_s ON dim_s.staff_id = fact_s.staff_id
WHERE dim_s.area = 'Manchester'
GROUP BY dim_s.area;

-- How much does it cost to hire all staff members that are represented by David and Joe?

SELECT SUM(fact_s.daily_rate) AS total_cost
FROM fact_staff_performance AS fact_s
JOIN dim_staff AS dim_s ON fact_s.staff_id = dim_s.staff_id
WHERE dim_s.manager_name IN ('David Bartlett', 'Joe Mulvey');

-- Which staff member works with the most number of mentees?

SELECT dim_s.full_name AS staff_member, SUM(fact_s.mentees) AS num_mentees
FROM dim_staff AS dim_s
JOIN fact_staff_performance AS fact_s ON dim_s.staff_id = fact_s.staff_id
GROUP BY dim_s.full_name
ORDER BY num_mentees DESC
LIMIT 1;