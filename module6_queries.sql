-- https://www.w3resource.com/mysql/mysql-procedure.php
-- setup
CREATE DATABASE shop;
USE shop;
show privileges;

CREATE TABLE sales1 (
    Store VARCHAR(10) NOT NULL,
    Week integer NOT NULL,
    Day VARCHAR(10) NOT NULL,
    SalesPerson VARCHAR(55) NOT NULL,
    SalesAmount FLOAT(2) NOT NULL,
    Month CHAR(3) NOT NULL
);

INSERT INTO sales1
(Store, Week, Day,SalesPerson, SalesAmount,Month)
VALUES
('London', 1, 'Monday', 'Frank', 56.25, 'May'),
('London', 5, 'Tuesday', 'Frank', 76.32, 'Sep'),
('London', 5, 'Monday', 'Bill', 98.42, 'Sep'),
('London', 5, 'Saturday', 'Bill', 73.90, 'Dec'),
('London', 1, 'Tuesday', 'Josie', 44.27, 'Sep'),
('Dusseldorf', 4, 'Monday', 'Manfred', 77.00, 'Jul'),
('Dusseldorf', 3, 'Tuesday', 'Inga', 9.99, 'Jun'),
('Dusseldorf', 4, 'Wednesday', 'Manfred', 86.81, 'Jul'),
('London', 6, 'Friday', 'Josie', 74.02, 'Oct'),
('Dusseldorf', 1, 'Saturday', 'Manfred', 43.11, 'Apr');

-- View practice
-- syntax below
-- CREATE
--     [OR REPLACE]
--     [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
--     [DEFINER = { user | CURRENT_USER }]
--     [SQL SECURITY { DEFINER | INVOKER }]
--     VIEW view_name [(column_list)]
--     AS select_statement
--     [WITH [CASCADED | LOCAL] CHECK OPTION]

-- Let's use our DB shop, table Sales1 that we created a while ago 
-- Alternatively any default DB such as world or sakila can be used for examples. 

USE shop;
SELECT * FROM shop.sales1;

-- create view
CREATE VIEW vw_salesmen
AS 
SELECT SalesPerson, SalesAmount FROM sales1;

SELECT * FROM vw_salesmen;

-- you can query the view in exactly the same way as a table
SELECT DISTINCT SalesPerson, Max(SalesAmount)
FROM vw_salesmen
WHERE SalesAmount > 70 
GROUP BY SalesPerson;

DROP View vw_salesmen;

-- view staff table
use practice; -- or create any other temporary DB
-- PART 1
CREATE TABLE practice.staff (
  `employeeID` INT NOT NULL,
  `firstname` VARCHAR(45) NOT NULL,
  `lastname` VARCHAR(45) NOT NULL,
  `jobtitle` VARCHAR(45) NOT NULL,
  `managerID` INT NOT NULL,
  `department` VARCHAR(45) NULL,
  `salary` INT NOT NULL,
  `dateofbirth` DATE NOT NULL,
  PRIMARY KEY (`employeeID`));

INSERT INTO staff(employeeID, firstName, lastName, jobtitle, managerID, department, salary, dateofbirth) 
VALUES(1245,'Julie','Smith','DBA','3333','Database Administrators',50000,'1985-10-20'),
	  (4578,'Jame','Blogs','DBA','3333','Database Administrators',52000,'1970-10-22');

ALTER TABLE practice.staff 
CHANGE COLUMN `salary` `salary` INT(11) NULL DEFAULT 0 ,
CHANGE COLUMN `dateofbirth` `dateofbirth` DATE NULL DEFAULT '1900-01-01' ;

SELECT * FROM practice.staff;

-- create a new view
CREATE OR REPLACE VIEW vw_staff_common AS
    SELECT employeeID, firstName, lastName, jobtitle, managerID, department
        -- we don't want anyone except from HR to see people's salaries or dob, so the view would hid ethe info
    FROM staff
    WHERE jobtitle LIKE '%DB%';
   
-- vw_staff_common is a simple view, so it is possible to update it
-- Let's insert a row into the staff table through the vw_staff_common view.
INSERT INTO vw_staff_common (employeeID, firstName, lastName, jobtitle, managerID, department) 
VALUES(8888,'Mike','Davies','Developer',2323,'Database Administrators');

-- NBthat the newly created employee is not visible through the vw_staff_common view 
-- because employee's job title is Developer, which is not like the %DB% pattern. Y
select * from vw_staff_common; -- cannot see the new person
select * from staff;  --  can see the new person

-- PART 2
-- Let's modify the view to add WITH CHECK OPTION and see how it behaves. 
CREATE OR REPLACE VIEW vw_staff_common2 AS
    SELECT employeeID,firstName,lastName,jobtitle,managerID,department
    FROM staff 
    WHERE jobtitle LIKE '%DB%'
	WITH CHECK OPTION;
    
-- Again let's try to insert a row into the staff table through vw_staff_common2
INSERT INTO vw_staff_common2 (employeeID,firstName,lastName,jobtitle,managerID,department) 
VALUES(5555,'Thomas','Fisher','Developer',8989,'Database Administrators');
-- our attempt FAILS!!
-- now try to insert a record that complies with the '%DB%' condition
INSERT INTO vw_staff_common2 (employeeID,firstName,lastName,jobtitle,managerID,department)  
VALUES(5555,'Thomas','Fisher','DB Developer',8989,'Database Administrators');

select * from vw_staff_common;

-- cleanup inserted rows. (optional)
-- Delete from staff where employeeID in (1245,4578,8888,5555);

-- stored function examples
-- syntax
-- CREATE FUNCTION function_name(func_parameter1, func_parameter2, ..)
--           RETURN datatype [characteristics]
--           func_body
use bank;

DELIMITER //
CREATE FUNCTION is_eligible(
    balance INT
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE customer_status VARCHAR(20);
    IF balance > 100 THEN
        SET customer_status = 'YES';
    ELSEIF (balance >= 50 AND 
            balance <= 100) THEN
        SET customer_status = 'MAYBE';
    ELSEIF balance < 50 THEN
        SET customer_status = 'NO';
    END IF;
    RETURN (customer_status);
END//balance
DELIMITER ;

select * from bank.accounts;

SELECT account_holder_name,account_holder_surname,balance,is_eligible(balance) FROM accounts;
-- stored proceedure examples
use practice;
-- STORED PROCEDURE syntax
-- CREATE [DEFINER = { user | CURRENT_USER }]          
-- PROCEDURE sp_name ([proc_parameter[,...]])          
-- [characteristic ...] routine_body    
-- proc_parameter: [ IN | OUT | INOUT ] param_name type    
-- type:          
-- Any valid MySQL data type    
-- characteristic:          
-- COMMENT 'string'     
-- | LANGUAGE SQL      
-- | [NOT] DETERMINISTIC      
-- | { CONTAINS SQL | NO SQL | READS SQL DATA 
-- | MODIFIES SQL DATA }      
-- | SQL SECURITY { DEFINER | INVOKER }    
-- routine_body:      
-- Valid SQL routine statement

-- NOT DETERMINISTIC, is informational, a routine is considered "deterministic"  if it always produces the same result for the same 
-- input parameters, and "not deterministic" otherwise.

-- Local variables are declared within stored procedures and are only valid within the BEGIN…END block where they are declared
-- Local variables can have any SQL data type
-- User variables are referenced with an ampersand (@) prefixed to the user variable
-- The main difference between local variables and user-defined variable is that local variable is reinitialized with NULL value each time 
-- whenever stored procedure is called while session-specific variable or user-defined variable does not reinitialized with NULL. 
-- A user-defined variable set by one user can not be seen by other user.Whatever session variable for a given user is automatically destroyed 
-- when user exits.

-- Create Stored Procedure
-- Change Delimiter
DELIMITER //
CREATE PROCEDURE Greetings( GreetingWorld VARCHAR(100), FirstName VARCHAR(100))
BEGIN
    -- local variable
	DECLARE FullGreeting VARCHAR(200);
	SET FullGreeting = CONCAT(GreetingWorld,' ',FirstName);
    -- user variable
    SET @testvalue = @testvalue + 10;
	
	IF isnull(@testvalue)
	THEN   
	SET @message = 'no testvalue set';   
    ELSE
    SET @message = 'user provided testvalue'; 
	END IF;      

	IF(@generateerror= 'Y') THEN 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Bummer. Something went wrong in stored proc named Greetings';
	END IF;
    
	SELECT FullGreeting, @testvalue, @message;
END//
-- Change Delimiter again
DELIMITER ;

-- DELIMITER $$
-- SHOW CREATE PROCEDURE Greetings$$

-- Call Stored Procedure
SET @testvalue = 10;
SET @generateerror='N';
CALL Greetings('Bonjour,', 'Dave');
CALL Greetings('Hola,', 'Dora');
CALL Greetings('Terve,', 'Elena');


-- Clean up function and stored procedure (optional)
-- drop function is_eligible;
-- drop procedure Greetings;
-- ---------------------
use bakery;
SELECT * FROM sweet;

-- Change Delimiter
DELIMITER //
-- Create Stored Procedure
CREATE PROCEDURE InsertValue(
IN id INT, 
IN sweetItem VARCHAR(100),
IN price FLOAT)
BEGIN
INSERT INTO sweet(id,item_name, price) VALUES (id,sweetItem, price);
END//
-- Change Delimiter again
DELIMITER ;
CALL InsertValue (11, 'cherry_cake', 5);
SELECT * FROM sweet;
DROP PROCEDURE InsertValue;

-- example using out variable
-- change delimiter
DELIMITER $$
CREATE PROCEDURE my_proc_OUT (OUT highest_price INT)
BEGIN
 SELECT sum(price) INTO highest_price FROM sweet;
END$$

DELIMITER ;
-- invoke the procedure
CALL my_proc_OUT(@M);

-- display the value obtained
SELECT @M;

-- clean up by removing the procedure
drop procedure my_proc_OUT;

-- inout stored proc example
-- change delimiter
DELIMITER $$
DROP PROCEDURE IF EXISTS my_proc_INOUT$$

DELIMITER $$
CREATE PROCEDURE my_proc_INOUT (INOUT highest_price INT)
BEGIN
SELECT sum(price) INTO highest_price FROM sweet where price < highest_price;
END$$
DELIMITER ;
-- invoke the procedure
SET @highestpriceval=0.5;
CALL my_proc_INOUT(@highestpriceval);
-- display the value obtained
SELECT @highestpriceval;

-- TRIGGERS in mysql
-- Syntax below
-- CREATE     
-- [DEFINER = { user | CURRENT_USER }]     
-- TRIGGER trigger_name     
-- trigger_time trigger_event     
-- ON tbl_name FOR EACH ROW     
-- trigger_body
-- trigger_time: { BEFORE | AFTER } 
-- trigger_event: { INSERT | UPDATE | DELETE }

-- There is two MySQL extension to triggers 'OLD' and 'NEW'. OLD and NEW are not case sensitive.
-- Within the trigger body, the OLD and NEW keywords enable you to access columns in the rows affected by a trigger
-- In an INSERT trigger, only NEW.col_name can be used.
-- In a UPDATE trigger, you can use OLD.col_name to refer to the columns of a row before it is updated and NEW.col_name to refer to the columns of the row after it is updated.
-- In a DELETE trigger, only OLD.col_name can be used; there is no new row.

-- trigger examples
SELECT * FROM bakery.sweet;

-- BEFORE Trigger Example - this one ensures font consistency for inserted items
-- Change Delimiter
DELIMITER //
CREATE TRIGGER sweetItem_Before_Insert
BEFORE INSERT on sweet
FOR EACH ROW
BEGIN
	SET NEW.item_name = CONCAT(UPPER(SUBSTRING(NEW.item_name,1,1)),
						LOWER(SUBSTRING(NEW.item_name FROM 2)));
END//
-- Change Delimiter
DELIMITER ;

-- Insert Data
INSERT INTO sweet (id, item_name, price) VALUES (123, 'apple_pie', 1.2);
INSERT INTO sweet (id, item_name, price) VALUES (456, 'CARamel slice', 0.9);
INSERT INTO sweet (id, item_name, price) VALUES (789, 'YUM YUM', 0.65);

SELECT * FROM bakery.sweet;

-- clean up trigger and inserted rows (optional)
-- Drop trigger sweetItem_Before_Insert; 
-- Delete from bakery.sweet where id in (11,123,456,789);

-- events examples
-- Turn ON Event Scheduler 
SET GLOBAL event_scheduler = ON;
USE practice;

-- EXAMPLE 1 --> one time event

CREATE TABLE monitoring_events
(ID INT NOT NULL AUTO_INCREMENT, 
Last_Update TIMESTAMP,
PRIMARY KEY (ID));
-- We are creating an event that will be scheduled for us
-- Change Delimiter
DELIMITER //
CREATE EVENT one_time_event
ON SCHEDULE AT NOW() + INTERVAL 1 MINUTE
DO BEGIN
	INSERT INTO monitoring_events(Last_Update)	VALUES (NOW());
END//
-- Change Delimiter
DELIMITER ;

-- Select Data to see that our table is empty
-- Then Select data again in approx 1 min to see what happened. 
SELECT * FROM monitoring_events;

-- Clean up (optional)
-- DROP TABLE monitoring_events;
-- DROP EVENT one_time_event;

-- EXAMPLE 2 --> reccuring event

CREATE TABLE monitoring_events_version2
(ID INT NOT NULL AUTO_INCREMENT, 
Last_Update TIMESTAMP,
PRIMARY KEY (ID));
-- Change Delimiter

DELIMITER //
CREATE EVENT recurring_time_event
ON SCHEDULE EVERY 2 SECOND
STARTS NOW()
DO BEGIN
	INSERT INTO monitoring_events_version2(Last_Update) VALUES (NOW());
END//
-- Change Delimiter
DELIMITER ;

-- Select Data
SELECT * FROM monitoring_events_version2 ORDER BY ID DESC;

-- Clean up - this is necessary, otherwise your table will keep on being populated by the event
-- DROP TABLE monitoring_events_version2;
-- DROP EVENT recurring_time_event;