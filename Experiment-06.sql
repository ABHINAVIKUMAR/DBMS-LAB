# Experiment 06

## Aim
--Create a stored procedure transfer_employee(emp_id, new_dept_id) with validation and error handling. Implement triggers for salary validation and audit logging. Test edge cases. 

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Employee_Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    old_dept_id INT,
    new_dept_id INT,
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(50) DEFAULT (CURRENT_USER())
);

INSERT INTO Department (dept_id, dept_name) VALUES
(1, 'Engineering'),
(2, 'Human Resources'),
(3, 'Finance');

INSERT INTO Employee (emp_id, emp_name, salary, dept_id) VALUES
(101, 'Aarav Sharma', 75000.00, 1),
(102, 'Priya Patel', 50000.00, 2),
(103, 'Rohan Verma', 60000.00, 3);

DELIMITER $$

CREATE TRIGGER trg_validate_employee_salary
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Salary must be strictly positive.';
    END IF;

    IF NEW.salary < (OLD.salary * 0.5) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Salary decrease exceeds maximum allowable reduction (50%).';
    END IF;
END$$

CREATE TRIGGER trg_audit_employee_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NOT (OLD.dept_id <=> NEW.dept_id) THEN
        INSERT INTO Employee_Audit_Log (emp_id, action_type, old_dept_id, new_dept_id, old_salary, new_salary)
        VALUES (NEW.emp_id, 'DEPARTMENT_TRANSFER', OLD.dept_id, NEW.dept_id, OLD.salary, NEW.salary);
    END IF;

    IF OLD.salary != NEW.salary THEN
        INSERT INTO Employee_Audit_Log (emp_id, action_type, old_dept_id, new_dept_id, old_salary, new_salary)
        VALUES (NEW.emp_id, 'SALARY_CHANGE', OLD.dept_id, NEW.dept_id, OLD.salary, NEW.salary);
    END IF;
END$$

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_emp_exists INT DEFAULT 0;
    DECLARE v_dept_exists INT DEFAULT 0;
    DECLARE v_current_dept_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*), dept_id 
    INTO v_emp_exists, v_current_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id
    GROUP BY dept_id;

    IF v_emp_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Failed: Specified employee ID does not exist.';
    END IF;

    SELECT COUNT(*) 
    INTO v_dept_exists
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF v_dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Failed: Target department ID does not exist.';
    END IF;

    IF v_current_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Failed: Employee is already assigned to this department.';
    END IF;

    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;
    SELECT CONCAT('Success: Employee ', p_emp_id, ' transferred to Department ', p_new_dept_id) AS Status;
END$$

DELIMITER ;

CALL transfer_employee(101, 2);

SELECT * FROM Employee WHERE emp_id = 101;
SELECT * FROM Employee_Audit_Log;
