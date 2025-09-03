SELECT SUM(s.quantity * p.price) AS total_revenue
FROM sales s
JOIN products p ON p.product_id = s.product_id;
