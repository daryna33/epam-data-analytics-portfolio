WITH last_tx AS (
  SELECT s.customer_id,
         MAX(s.date) AS last_date,
         COUNT(*) AS frequency,
         SUM(s.quantity * p.price) AS monetary
  FROM sales s
  JOIN products p ON p.product_id = s.product_id
  GROUP BY s.customer_id
),
ref AS (SELECT MAX(date) AS max_date FROM sales),
rfm AS (
  SELECT l.customer_id,
         julianday((SELECT max_date FROM ref)) - julianday(l.last_date) AS recency_days,
         l.frequency,
         l.monetary
  FROM last_tx l
)
SELECT customer_id,
       NTILE(5) OVER (ORDER BY -recency_days) AS R,
       NTILE(5) OVER (ORDER BY frequency)     AS F,
       NTILE(5) OVER (ORDER BY monetary)      AS M
FROM rfm
ORDER BY R DESC, F DESC, M DESC
LIMIT 20;