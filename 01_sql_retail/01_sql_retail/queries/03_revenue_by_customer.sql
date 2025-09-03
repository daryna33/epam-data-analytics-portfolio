SELECT c.name, c.country, SUM(s.quantity * p.price) AS revenue
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
JOIN products  p ON p.product_id  = s.product_id
GROUP BY c.customer_id, c.name, c.country
ORDER BY revenue DESC;
