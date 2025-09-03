-- Helpful indexes (speed up joins/filters)
CREATE INDEX IF NOT EXISTS idx_sales_customer ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_product  ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date     ON sales(date);

-- Optional uniqueness on ids
CREATE UNIQUE INDEX IF NOT EXISTS ux_customers_id ON customers(customer_id);
CREATE UNIQUE INDEX IF NOT EXISTS ux_products_id  ON products(product_id);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sales_id     ON sales(sale_id);

-- Enriched analysis view
CREATE VIEW IF NOT EXISTS v_sales_enriched AS
SELECT s.sale_id, s.date, s.quantity,
       c.customer_id, c.name AS customer_name, c.country,
       p.product_id, p.product_name, p.category, p.price,
       (s.quantity * p.price) AS revenue
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
JOIN products  p ON p.product_id  = s.product_id;
