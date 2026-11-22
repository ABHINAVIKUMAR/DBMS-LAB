# Experiment 08

## Aim
--Implement banking-style transactions using BEGIN, COMMIT, ROLLBACK, and SAVEPOINT. Simulate partial failures. Demonstrate isolation levels and concurrency anomalies using two sessions.

--1. Create Banking Table
CREATE TABLE Accounts (
    Account_ID INT PRIMARY KEY,
    Account_Holder VARCHAR(50),
    Balance DECIMAL(10,2)
);

INSERT INTO Accounts VALUES
(101, 'Rahul', 10000),
(102, 'Aman', 8000),
(103, 'Priya', 5000);

SELECT * FROM Accounts;

--2. BEGIN and COMMIT (Money Transfer)
BEGIN;

UPDATE Accounts
SET Balance = Balance - 2000
WHERE Account_ID = 101;

UPDATE Accounts
SET Balance = Balance + 2000
WHERE Account_ID = 102;

COMMIT;

SELECT * FROM Accounts;

--3. ROLLBACK (Cancel Transaction)
BEGIN;

UPDATE Accounts
SET Balance = Balance - 1000
WHERE Account_ID = 101;

ROLLBACK;

SELECT * FROM Accounts;

--4. SAVEPOINT
BEGIN;

UPDATE Accounts
SET Balance = Balance + 1000
WHERE Account_ID = 101;

SAVEPOINT sp1;

UPDATE Accounts
SET Balance = Balance - 2000
WHERE Account_ID = 101;

ROLLBACK TO SAVEPOINT sp1;

COMMIT;

SELECT * FROM Accounts;

--5. Partial Transaction Failure
BEGIN;

UPDATE Accounts
SET Balance = Balance - 2000
WHERE Account_ID = 101;

UPDATE Accounts
SET Balance = Balance + 2000
WHERE Account_ID = 999;

ROLLBACK;

SELECT * FROM Accounts;

--6. Isolation Levels
--Read Committed
BEGIN TRANSACTION
ISOLATION LEVEL READ COMMITTED;

SELECT * FROM Accounts;

COMMIT;

--Repeatable Read
BEGIN TRANSACTION
ISOLATION LEVEL REPEATABLE READ;

SELECT * FROM Accounts;

COMMIT;

--Serializable
BEGIN TRANSACTION
ISOLATION LEVEL SERIALIZABLE;

SELECT * FROM Accounts;

COMMIT;

--7. Non-Repeatable Read (Two Sessions)
--Session 1:
BEGIN TRANSACTION
ISOLATION LEVEL READ COMMITTED;

SELECT Balance
FROM Accounts
WHERE Account_ID = 101;

--Session 2:
UPDATE Accounts
SET Balance = 8500
WHERE Account_ID = 101;

--Session 1:
SELECT Balance
FROM Accounts
WHERE Account_ID = 101;

COMMIT;

--8. Phantom Read (Two Sessions)
--Session 1:
BEGIN TRANSACTION
ISOLATION LEVEL READ COMMITTED;

SELECT * FROM Accounts
WHERE Balance >= 8000;

--Session 2:
INSERT INTO Accounts
VALUES (104, 'Neha', 12000);

--Session 1:
SELECT * FROM Accounts
WHERE Balance >= 8000;

COMMIT;
