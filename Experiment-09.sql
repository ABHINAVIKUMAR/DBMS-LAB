# Experiment 09

## Aim
--Create a Railway Booking table with at least 5,000 records. Benchmark query performance before and after creating single and composite indexes. Use EXPLAIN to compare execution plans. 

--1. Create Railway Booking Table
CREATE TABLE Railway_Booking (
    Booking_ID INT PRIMARY KEY,
    Passenger_Name VARCHAR(100),
    Train_Number INT,
    Train_Name VARCHAR(100),
    Source VARCHAR(50),
    Destination VARCHAR(50),
    Journey_Date DATE,
    Seat_Number INT,
    Booking_Status VARCHAR(20),
    Ticket_Price DECIMAL(10,2)
);

--2. Insert 5,000 Records
INSERT INTO Railway_Booking
SELECT
    i,
    'Passenger_' || i,
    12000 + (i % 20),
    'Express_' || (i % 20),
    'Delhi',
    'Mumbai',
    DATE '2026-01-01' + (i % 30),
    i % 100 + 1,
    'Confirmed',
    500 + (i % 1000)
FROM generate_series(1, 5000) AS s(i);

--3. Check Total Records
SELECT COUNT(*)
FROM Railway_Booking;

--4. Check Performance Before Indexing
EXPLAIN ANALYZE
SELECT *
FROM Railway_Booking
WHERE Train_Number = 12005;

--5. Create Single-Column Index
CREATE INDEX idx_train
ON Railway_Booking(Train_Number);

--6. Create Composite Index
CREATE INDEX idx_train_date
ON Railway_Booking(Train_Number, Journey_Date);

--7. Check Performance After Indexing
EXPLAIN ANALYZE
SELECT *
FROM Railway_Booking
WHERE Train_Number = 12005
AND Journey_Date = '2026-01-10';

--8. Display All Indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'railway_booking';

--9. Delete Index
DROP INDEX idx_train;
