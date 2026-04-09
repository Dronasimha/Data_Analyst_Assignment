#1
SELECT sales_channel, SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;


#2
SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;


#3
WITH MonthlyRevenue AS (
    SELECT MONTH(datetime) as month_num, SUM(amount) as rev
    FROM clinic_sales WHERE YEAR(datetime) = 2021 GROUP BY 1
),
MonthlyExpenses AS (
    SELECT MONTH(datetime) as month_num, SUM(amount) as exp
    FROM expenses WHERE YEAR(datetime) = 2021 GROUP BY 1
)
SELECT 
    r.month_num,
    r.rev AS revenue,
    e.exp AS expense,
    (r.rev - e.exp) AS profit,
    IF((r.rev - e.exp) > 0, 'profitable', 'not-profitable') AS status
FROM MonthlyRevenue r
JOIN MonthlyExpenses e ON r.month_num = e.month_num;


#4
WITH ClinicProfit AS (
    SELECT 
        c.city,
        c.clinic_name,
        (SUM(IFNULL(s.amount, 0)) - SUM(IFNULL(e.amount, 0))) AS net_profit
    FROM clinics c
    LEFT JOIN clinic_sales s ON c.cid = s.cid AND MONTH(s.datetime) = 9 AND YEAR(s.datetime) = 2021
    LEFT JOIN expenses e ON c.cid = e.cid AND MONTH(e.datetime) = 9 AND YEAR(e.datetime) = 2021
    GROUP BY c.city, c.clinic_name
),
CityRankings AS (
    SELECT 
        city,
        clinic_name,
        net_profit,
        RANK() OVER(PARTITION BY city ORDER BY net_profit DESC) as profit_rank
    FROM ClinicProfit
)

SELECT city, clinic_name, net_profit
FROM CityRankings
WHERE profit_rank = 1;


#5
WITH ClinicProfit AS (
    SELECT 
        c.state,
        c.clinic_name,
        (SUM(IFNULL(s.amount, 0)) - SUM(IFNULL(e.amount, 0))) AS net_profit
    FROM clinics c
    LEFT JOIN clinic_sales s ON c.cid = s.cid AND MONTH(s.datetime) = 9 AND YEAR(s.datetime) = 2021
    LEFT JOIN expenses e ON c.cid = e.cid AND MONTH(e.datetime) = 9 AND YEAR(e.datetime) = 2021
    GROUP BY c.state, c.clinic_name
),
StateRankings AS (
    SELECT 
        state,
        clinic_name,
        net_profit,
        DENSE_RANK() OVER(PARTITION BY state ORDER BY net_profit ASC) as low_profit_rank
    FROM ClinicProfit
)
SELECT state, clinic_name, net_profit
FROM StateRankings
WHERE low_profit_rank = 2;