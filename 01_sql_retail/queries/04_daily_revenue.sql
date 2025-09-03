SELECT date, SUM(quantity * price) AS revenue
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY date
ORDER BY date;
