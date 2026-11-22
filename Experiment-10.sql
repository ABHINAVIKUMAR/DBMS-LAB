# Experiment 10

## Aim
--Generate a dataset with at least 10,000 rows. Write five slow queries, analyze using EXPLAIN, optimize using indexing and query rewriting, and compare execution time before and after optimization.

--1. Create Orders Table
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(100),
    City VARCHAR(50),
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10,2),
    Order_Date DATE,
    Status VARCHAR(30)
);

--2. Insert 10,000 Records
INSERT INTO Orders
SELECT
    i,
    'Customer_' || i,
    CASE
        WHEN i % 4 = 0 THEN 'Delhi'
        WHEN i % 4 = 1 THEN 'Mumbai'
        WHEN i % 4 = 2 THEN 'Chandigarh'
        ELSE 'Lucknow'
    END,
    'Product_' || (i % 100),
    'Electronics',
    (i % 10) + 1,
    100 + (i % 5000),
    DATE '2026-01-01' + (i % 365),
    'Completed'
FROM generate_series(1, 10000) AS s(i);

--3. Count Total Records
SELECT COUNT(*) FROM Orders;

--4. Analyze Query Performance (Before Index)
EXPLAIN ANALYZE
SELECT *
FROM Orders
WHERE City = 'Delhi';

--5. Create Single-Column Index
CREATE INDEX idx_city
ON Orders(City);

--6. Create Composite Index
CREATE INDEX idx_city_status
ON Orders(City, Status);

--7. Optimize Date Query
Before:
SELECT *
FROM Orders
WHERE EXTRACT(YEAR FROM Order_Date) = 2026;

After:
SELECT *
FROM Orders
WHERE Order_Date >= '2026-01-01'
AND Order_Date < '2027-01-01';

--8. Analyze Query After Optimization
EXPLAIN ANALYZE
SELECT *
FROM Orders
WHERE City = 'Delhi';
