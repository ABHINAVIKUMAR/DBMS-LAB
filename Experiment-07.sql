# Experiment 07

## Aim
--Given a denormalized Sales table, identify functional dependencies and normalize step-by-step from UNF to 3NF and BCNF. Verify lossless join and dependency preservation using SQL queries. 

--Step 1: Create Database Tables
CREATE TABLE Customers (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Customer_City VARCHAR(50)
);

CREATE TABLE Salespersons (
    Salesperson_ID VARCHAR(10) PRIMARY KEY,
    Salesperson_Name VARCHAR(50)
);

CREATE TABLE Products (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Name VARCHAR(50)
);

CREATE TABLE Sales (
    Sale_ID INT PRIMARY KEY,
    Sale_Date DATE,
    Customer_ID VARCHAR(10),
    Salesperson_ID VARCHAR(10),

    FOREIGN KEY (Customer_ID)
    REFERENCES Customers(Customer_ID),

    FOREIGN KEY (Salesperson_ID)
    REFERENCES Salespersons(Salesperson_ID)
);

CREATE TABLE Sale_Details (
    Sale_ID INT,
    Product_ID VARCHAR(10),
    Quantity INT,
    Unit_Price DECIMAL(10,2),

    PRIMARY KEY (Sale_ID, Product_ID),

    FOREIGN KEY (Sale_ID)
    REFERENCES Sales(Sale_ID),

    FOREIGN KEY (Product_ID)
    REFERENCES Products(Product_ID)
);

--Step 2: Insert Sample Data
INSERT INTO Customers VALUES
('C01', 'Rahul', 'Delhi'),
('C02', 'Aman', 'Mumbai');

INSERT INTO Salespersons VALUES
('S01', 'Amit'),
('S02', 'Neha');

INSERT INTO Products VALUES
('P01', 'Laptop'),
('P02', 'Mouse');

INSERT INTO Sales VALUES
(101, '2026-01-10', 'C01', 'S01'),
(102, '2026-01-11', 'C02', 'S02');

INSERT INTO Sale_Details VALUES
(101, 'P01', 2, 50000),
(101, 'P02', 3, 500),
(102, 'P01', 1, 50000);

--Step 3: Display Normalized Sales Data
SELECT
    s.Sale_ID,
    s.Sale_Date,
    c.Customer_Name,
    c.Customer_City,
    p.Product_Name,
    sd.Quantity,
    sd.Unit_Price,
    sp.Salesperson_Name
FROM Sales s
JOIN Customers c
    ON s.Customer_ID = c.Customer_ID
JOIN Salespersons sp
    ON s.Salesperson_ID = sp.Salesperson_ID
JOIN Sale_Details sd
    ON s.Sale_ID = sd.Sale_ID
JOIN Products p
    ON sd.Product_ID = p.Product_ID
ORDER BY s.Sale_ID;

--Verification of Lossless JoinSELECT
    s.Sale_ID,
    s.Sale_Date,
    c.Customer_Name,
    p.Product_Name,
    sd.Quantity
FROM Sales s
JOIN Customers c
    ON s.Customer_ID = c.Customer_ID
JOIN Sale_Details sd
    ON s.Sale_ID = sd.Sale_ID
JOIN Products p
    ON sd.Product_ID = p.Product_ID;
