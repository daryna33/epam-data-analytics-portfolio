WITH m AS (
  SELECT substr(s.date,1,7) AS ym,
         SUM(s.quantity * p.price) AS revenue
  FROM sales s
  JOIN products p ON p.product_id = s.product_id
  GROUP BY ym
)
SELECT ym,
       revenue,
       ROUND(AVG(revenue) OVER (ORDER BY ym ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS ma3
FROM m
ORDER BY ym;
