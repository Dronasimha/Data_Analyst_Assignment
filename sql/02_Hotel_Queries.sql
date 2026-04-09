#1
SELECT user_id, room_no
FROM (
    SELECT user_id, room_no, 
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY booking_date DESC) as last_one
    	FROM bookings
) AS my_list
WHERE last_one = 1;


#2
SELECT 
	b.booking_id, 
    SUM(bc.item_quantity * i.item_rate) AS total_billing_amount
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE b.booking_date >= '2021-11-01' AND b.booking_date <= '2021-11-30'
GROUP BY b.booking_id;


#3
SELECT 
    bill_id, 
    SUM(item_quantity * item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01' AND bc.bill_date <= '2021-10-31'
GROUP BY bill_id
HAVING SUM(item_quantity * item_rate) > 1000;


#4
WITH MonthlyCounts AS (
    SELECT 
        MONTH(bc.bill_date) AS month_num,
        i.item_name,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), i.item_name
),
RankedItems AS (
    SELECT 
        month_num,
        item_name,
        total_qty,
        RANK() OVER(PARTITION BY month_num ORDER BY total_qty DESC) as rank_most,
        RANK() OVER(PARTITION BY month_num ORDER BY total_qty ASC) as rank_least
    FROM MonthlyCounts
)
SELECT 
    month_num,
    item_name,
    total_qty,
    CASE 
        WHEN rank_most = 1 THEN 'Most Ordered'
        WHEN rank_least = 1 THEN 'Least Ordered'
    END AS status
FROM RankedItems
WHERE rank_most = 1 OR rank_least = 1
ORDER BY month_num, status DESC;


#5
WITH BillTotals AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month_year,
        bc.bill_id,
        SUM(bc.item_quantity * i.item_rate) AS total_amount
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY 1, 2
),
RankedBills AS (
    SELECT 
        month_year,
        bill_id,
        total_amount,
        DENSE_RANK() OVER(PARTITION BY month_year ORDER BY total_amount DESC) AS ranking
    FROM BillTotals
)
SELECT 
    month_year,
    bill_id,
    total_amount
FROM RankedBills
WHERE ranking = 2;