SET SQL_SAFE_UPDATES = 0;
UPDATE customer_info SET Gender = NULL WHERE Gender = '';
UPDATE customer_info  SET Age = NULL WHERE Age = '';

ALTER TABLE customer_info  MODIFY Age INT NULL;
SELECT COUNT(*)
FROM customer_info;
SELECT * FROM customer_info LIMIT 10;

CREATE TABLE Transactions 
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL (10,3),
Sum_payment DECIMAL (10,2)
); 


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS.csv'
INTO TABLE Transactions
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM Transactions LIMIT 10;

#1
SELECT t.ID_client,
COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) AS active_months,
AVG(t.Sum_payment) AS avg_check, 
SUM(t.Sum_payment) / COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) AS avg_monthly_purchase, 
COUNT(t.Id_check) AS total_transactions
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client
HAVING active_months = 12;
 
 #2a
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, 
AVG(t.Sum_payment) AS avg_check
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

#2b
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, 
COUNT(t.Id_check) AS total_operations, 
COUNT(t.Id_check) / COUNT(DISTINCT t.ID_client) AS avg_operations_per_client
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

#2c
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, 
COUNT(DISTINCT t.ID_client) AS avg_clients
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

#2d
WITH yearly_totals AS (
    SELECT COUNT(Id_check) AS yearly_operations, 
	SUM(Sum_payment) AS yearly_amount
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
)
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, 
COUNT(t.Id_check) / (SELECT yearly_operations FROM yearly_totals) AS monthly_operation_share,
SUM(t.Sum_payment) / (SELECT yearly_amount FROM yearly_totals) AS monthly_amount_share
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

#2e
WITH total_clients AS (
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, COUNT(DISTINCT t.ID_client) AS total_clients
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')
), 
total_spending AS (
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, SUM(t.Sum_payment) AS total_spending
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')
)
SELECT tc.month,c.Gender,
COUNT(DISTINCT t.ID_client) * 100.0 / tc.total_clients AS gender_percentage,
SUM(t.Sum_payment) * 100.0 / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY tc.month) AS spending_share
FROM transactions t
JOIN customer_info c ON t.ID_client = c.Id_client
JOIN total_clients tc ON DATE_FORMAT(t.date_new, '%Y-%m') = tc.month
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY tc.month, c.Gender
ORDER BY tc.month, c.Gender;

#3
SELECT 
    CASE 
        WHEN c.Age IS NULL THEN 'Unknown'
        WHEN c.Age BETWEEN 0 AND 10 THEN '0-10'
        WHEN c.Age BETWEEN 11 AND 20 THEN '11-20'
        WHEN c.Age BETWEEN 21 AND 30 THEN '21-30'
        WHEN c.Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN c.Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN c.Age BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+'
    END AS age_group, 
    COUNT(t.Id_check) AS total_transactions, 
    SUM(t.Sum_payment) AS total_spent
FROM customer_info c
JOIN transactions t 
ON c.Id_client = t.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group
ORDER BY age_group;

SELECT 
    CASE 
        WHEN c.Age IS NULL THEN 'Unknown'
        WHEN c.Age BETWEEN 0 AND 10 THEN '0-10'
        WHEN c.Age BETWEEN 11 AND 20 THEN '11-20'
        WHEN c.Age BETWEEN 21 AND 30 THEN '21-30'
        WHEN c.Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN c.Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN c.Age BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+'
    END AS age_group,
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter, 
    COUNT(t.Id_check) AS total_transactions, 
    SUM(t.Sum_payment) AS total_spent,
    AVG(t.Sum_payment) AS avg_spent_per_transaction,
    (COUNT(t.Id_check) * 100.0 / SUM(COUNT(t.Id_check)) OVER (PARTITION BY CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)))) AS transaction_percentage,
    (SUM(t.Sum_payment) * 100.0 / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)))) AS spending_percentage
FROM customer_info c
JOIN transactions t 
ON c.Id_client = t.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group, quarter
ORDER BY quarter, age_group;





















