import os, sqlite3
import pandas as pd

BASE = os.path.dirname(__file__)
RAW  = os.path.join(BASE, "data", "raw")
DB   = os.path.join(BASE, "analytics.db")

def load_csv(name): return pd.read_csv(os.path.join(RAW, f"{name}.csv"))

def main():
    customers = load_csv("customers")
    products  = load_csv("products")
    sales     = load_csv("sales")

    sales["date"] = pd.to_datetime(sales["date"]).dt.strftime("%Y-%m-%d")
    for c in ["customer_id","product_id","quantity"]: sales[c] = sales[c].astype("int64")
    products["price"] = products["price"].astype("float64")

    dim_customer = customers.copy()
    dim_product  = products.copy()
    dim_date = (sales[["date"]].drop_duplicates().sort_values("date")
                .assign(year=lambda d:d["date"].str[:4].astype(int),
                        month=lambda d:d["date"].str[5:7].astype(int),
                        day=lambda d:d["date"].str[8:].astype(int)))

    fact_sales = sales.merge(products[["product_id","price"]], on="product_id", how="left")
    fact_sales["net_amount"] = fact_sales["quantity"] * fact_sales["price"]

    with sqlite3.connect(DB) as conn:
        dim_customer.to_sql("dim_customer", conn, if_exists="replace", index=False)
        dim_product.to_sql("dim_product", conn, if_exists="replace", index=False)
        dim_date.to_sql("dim_date", conn, if_exists="replace", index=False)
        fact_sales.to_sql("fact_sales", conn, if_exists="replace", index=False)
        conn.executescript("""
        CREATE INDEX IF NOT EXISTS ix_fact_date ON fact_sales(date);
        CREATE INDEX IF NOT EXISTS ix_fact_product ON fact_sales(product_id);
        CREATE INDEX IF NOT EXISTS ix_fact_customer ON fact_sales(customer_id);
        CREATE VIEW IF NOT EXISTS v_fact_enriched AS
          SELECT f.*, c.name AS customer_name, c.country,
                 p.product_name, p.category
          FROM fact_sales f
          JOIN dim_customer c ON c.customer_id = f.customer_id
          JOIN dim_product  p ON p.product_id  = f.product_id;
        """)

    print(f"Loaded star schema into {DB}")

if __name__ == "__main__":
    main()