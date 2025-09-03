SELECT p.product_name, SUM(s.quantity * p.price) AS revenue
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;