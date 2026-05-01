DROP SCHEMA IF EXISTS GasStationHQ;
CREATE SCHEMA GasStationHQ;
USE GasStationHQ;

CREATE TABLE HQ (
    HQID INT NOT NULL,
    loadingBayNo INT NOT NULL CHECK (10 >= loadingBayNo AND loadingBayNo > 0),
    deliveryStatus VARCHAR(50),
    PRIMARY KEY (HQID, loadingBayNo)
);

CREATE TABLE Staff (
	staffID INT PRIMARY KEY NOT NULL,
    staffFirstName VARCHAR(50)NOT NULL,
    staffLastName VARCHAR(50) NOT NULL,
    staffRole VARCHAR(50) NOT NULL CHECK (staffRole IN ('Manager', 'HQ Associate', 'Driver'))
);

CREATE TABLE Store (
	storeID INT PRIMARY KEY,
	storeCity CHAR(50),
    staffID INT NOT NULL,
    FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON UPDATE CASCADE ON DELETE RESTRICT,
	pumpNo INT CHECK (20 >= pumpNo AND pumpNo >= 0)
);

CREATE TABLE Orders (
    orderNo INT PRIMARY KEY AUTO_INCREMENT,
    orderDate DATE NOT NULL,
    orderStatus VARCHAR(50) NOT NULL,
    deliveryStatus VARCHAR(50) NOT NULL CHECK (deliveryStatus IN ('Unassigned', 'IP', 'Complete')),
    storeID INT,
    HQID INT,
    loadingBayNo INT,
    managerID INT,
    FOREIGN KEY (storeID) REFERENCES Store(storeID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (HQID, loadingBayNo) REFERENCES HQ(HQID, loadingBayNo) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (managerID) REFERENCES Staff(staffID) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE gasOrders (
	orderNo INT,
    galDiesel INT NOT NULL DEFAULT 0 CHECK (80000 >= galDiesel AND galDiesel >= 0),
    galRegular INT NOT NULL DEFAULT 0 CHECK (15000 >= galRegular AND galRegular >= 0),
    galPremium INT NOT NULL DEFAULT 0 CHECK (5000 >= galPremium AND galPremium >= 0),
    PRIMARY KEY (orderNo),
    FOREIGN KEY (orderNo) REFERENCES Orders(orderNo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE backstockOrders (
	orderNo INT,
	hotdogs INT NOT NULL DEFAULT 0 CHECK (10000 >= hotdogs AND hotdogs >= 0),
    cigarettes INT NOT NULL DEFAULT 0 CHECK (10000 >= cigarettes AND cigarettes >= 0),
    PRIMARY KEY (orderNo),
    FOREIGN KEY (orderNo) REFERENCES Orders(orderNo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE staffUpdatesOrder (
	orderNo INT,
    staffID INT,
    orderStatus BOOLEAN,
    deliveryStatus VARCHAR(50),
    PRIMARY KEY (orderNo, staffID),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (orderNo) REFERENCES Orders(orderNo) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Fleet (
    vehicleID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    truckType VARCHAR(10) NOT NULL CHECK (truckType IN ('Gas', 'Freight')),
    available BOOLEAN NOT NULL,
    HQID INT,
    loadingBayNo INT,
    FOREIGN KEY (HQID, loadingBayNo) REFERENCES HQ(HQID, loadingBayNo) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Deliveries (
	vehicleID INT,
    orderNo INT,
    storeID INT,
	FOREIGN KEY (vehicleID) REFERENCES Fleet(vehicleID) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (orderNo) REFERENCES Orders(orderNo) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (storeID) REFERENCES Store(storeID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (orderNo, vehicleID)
);


-- Below is simple insertion of data
INSERT INTO HQ (HQID, loadingBayNo, deliveryStatus) VALUES
(1, 1, FALSE),
(1, 2, FALSE),
(1, 3, TRUE),
(1, 4, FALSE),
(1, 5, TRUE),
(1, 2, False):

INSERT INTO Staff (staffID, staffFirstName, staffLastName, staffRole) VALUES
(1, 'Alice', 'Johnson', 'Manager'),
(2, 'Bob', 'Smith', 'HQ Associate'),
(3, 'Carlos', 'Rivera', 'Driver'),
(4, 'Diana', 'Lee', 'Manager'),
(5, 'Evan', 'Brown', 'Driver');

INSERT INTO Store (storeID, storeCity, staffID, pumpNo) VALUES
(1, 'Cedar Rapids', 1, 8),
(2, 'Iowa City', 4, 12),
(3, 'Des Moines', 1, 6),
(4, 'Dubuque', 4, 20),
(5, 'Fort Dodge', 4, 4);

INSERT INTO Orders (orderDate, orderStatus, deliveryStatus, storeID, HQID, loadingBayNo, managerID) VALUES
('2026-04-01', FALSE, 'IP', 1, 1, 1, 1),
('2026-04-03', FALSE, 'Unassigned', 3, 1, 3, 1),
('2026-04-04', TRUE, 'Complete', 4, 1, 4, 4),
('2026-04-05', TRUE, 'Complete', 5, 1, 5, 4),
('2026-05-01', FALSE, 'IP', 2, 1, 2, 2);

INSERT INTO gasOrders (orderNo, galDiesel, galRegular, galPremium) VALUES
(1, 500, 3000, 1000),
(3, 200, 2000, 500),
(5, 0, 5000, 2000);

INSERT INTO backstockOrders (orderNo, hotdogs, cigarettes) VALUES
(4, 500, 200),
(8, 200, 600);

INSERT INTO Fleet (truckType, available, HQID, loadingBayNo) VALUES
('Gas', FALSE, 1, 1),
('Freight', FALSE, 1, 2),
('Gas', TRUE, 1, 3),
('Freight', TRUE, 1, 4),
('Gas', TRUE, 1, 5);

INSERT INTO Deliveries (vehicleID, orderNo, storeID) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(2, 8, 2);

INSERT INTO staffUpdatesOrder (orderNo, staffID, orderStatus, deliveryStatus) VALUES
(1, 2, FALSE, 'Unassigned'),
(8, 3, FALSE, 'IP'),
(3, 2, TRUE, 'Complete'),
(4, 3, FALSE, 'Unassigned'),
(5, 2, TRUE, 'Complete');


-- Views (created since queries reference them)
CREATE VIEW OrderTruckStore AS
    SELECT 
        o.orderNo,
        o.orderDate,
        o.deliveryStatus,
        f.truckType,
        s.storeCity,
        s.storeID
    FROM Orders o
    JOIN Deliveries d ON o.orderNo = d.orderNo
    JOIN Fleet f ON d.vehicleID = f.vehicleID
    JOIN Store s ON d.storeID = s.storeID;

CREATE VIEW StaffOrderUpdates AS
    SELECT
        st.staffID,
        st.staffFirstName,
        st.staffLastName,
        st.staffRole,
        suo.orderNo,
        suo.orderStatus,
        suo.deliveryStatus
    FROM Staff st
    JOIN staffUpdatesOrder suo ON st.staffID = suo.staffID;


-- Queries (8 total)

-- Query 1 (JOIN): Which store placed each order and what is its delivery status?
-- Shows each order and the store that placed it as well as current delivery status
SELECT 
    o.orderNo,
    o.orderDate,
    s.storeCity,
    s.storeID,
    o.deliveryStatus
FROM Orders o
JOIN Store s ON o.storeID = s.storeID;

-- Query 2 (AGGREGATION): What is the total gallons of each fuel type ordered across all gas orders?
-- Aggregates total fuel demand across all gas orders
SELECT 
    SUM(galDiesel) AS totalDiesel,
    SUM(galRegular) AS totalRegular,
    SUM(galPremium) AS totalPremium
FROM gasOrders;

-- Query 3 (JOIN): Which staff members have updated orders, and what orders did they update?
-- Joins staff with their order updates to show who is managing what
SELECT 
    st.staffFirstName,
    st.staffLastName,
    st.staffRole,
    suo.orderNo,
    suo.orderStatus,
    suo.deliveryStatus
FROM Staff st
JOIN staffUpdatesOrder suo ON st.staffID = suo.staffID;

-- Query 4 (AGGREGATION and SUBQUERY): Which stores have placed more than one order?
-- Uses aggregation and subquerying to find stores with multiple orders
SELECT 
    storeID,
    storeCity
FROM Store
WHERE storeID IN (
    SELECT storeID
    FROM Orders
    GROUP BY storeID
    HAVING COUNT(orderNo) > 1
);

-- Query 5 (JOIN and VIEW): List all orders with their assigned truck type and destination city
-- Uses the OrderTruckStore view
SELECT 
    orderNo,
    orderDate,
    deliveryStatus,
    truckType,
    storeCity
FROM OrderTruckStore;

-- Query 6 (AGGREGATION): What is the average number of hotdogs and cigarettes ordered per backstock order?
-- Aggregates average quantities across all backstock orders
SELECT 
    AVG(hotdogs) AS avgHotdogs,
    AVG(cigarettes) AS avgCigarettes
FROM backstockOrders;

-- Query 7 (JOIN): Which trucks are currently unavailable and what order are they delivering?
-- Joins Fleet, Deliveries, and Orders to show active deliveries
SELECT 
    f.vehicleID,
    f.truckType,
    d.orderNo,
    o.deliveryStatus,
    o.orderDate
FROM Fleet f
JOIN Deliveries d ON f.vehicleID = d.vehicleID
JOIN Orders o ON d.orderNo = o.orderNo
WHERE f.available = FALSE
AND o.deliveryStatus = 'IP';

-- Query 8 (SUBQUERY): Which stores have only ever placed gas orders and never backstock orders?
-- Uses subquery to filter stores based on order type history
SELECT 
    storeID,
    storeCity
FROM Store
WHERE storeID IN (
    SELECT storeID FROM Orders
    WHERE orderNo IN (SELECT orderNo FROM gasOrders)
)
AND storeID NOT IN (
    SELECT storeID FROM Orders
    WHERE orderNo IN (SELECT orderNo FROM backstockOrders)
);



-- Triggers

-- Trigger 1: When an order's deliveryStatus is updated to "Complete" it automatically sets orderStatus to TRUE
DELIMITER //
CREATE TRIGGER orderCompleteStatus
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.deliveryStatus = 'Complete' THEN
        SET NEW.orderStatus = TRUE;
        UPDATE Fleet f
        JOIN Deliveries d ON f.vehicleID = d.vehicleID
        SET f.available = TRUE
        WHERE d.orderNo = NEW.orderNo;
    END IF;
END //
DELIMITER ;

-- Trigger 2: When a truck is assigned to a delivery, the truck's "available" value is set to FALSE
DELIMITER //
CREATE TRIGGER truckUnavailableWhenOrderIP
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.deliveryStatus = 'IP' AND OLD.deliveryStatus <> 'IP' THEN
        UPDATE Fleet
        SET available = FALSE
        WHERE HQID = NEW.HQID
          AND loadingBayNo = NEW.loadingBayNo;
    END IF;
END //
DELIMITER ;

-- Trigger 3: When an order is inserted it automatically sets the loading bay's deliveryStatus in HQ to TRUE showing active
DELIMITER //
CREATE TRIGGER hqBayActiveOnOrder
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    UPDATE HQ
    SET deliveryStatus = TRUE
    WHERE HQID = NEW.HQID AND loadingBayNo = NEW.loadingBayNo;
END //
DELIMITER ;



-- Procedure 

-- Takes in all necessary order details and inserts into Orders,
-- then inserts into either gasOrders or backstockOrders based on type
DELIMITER // 
CREATE PROCEDURE placeOrder(
	IN p_orderDate DATE,
    IN p_storeID INT,
    IN p_loadingBayNo INT,
    IN p_managerID INT,
    IN p_orderType VARCHAR(10),
    -- Gas order params
    IN p_galDiesel INT,
    IN p_galRegular INT,
    IN p_galPremium INT,
    -- Backstock order params
    IN p_hotdogs INT,
    In p_cigarettes INT
)
BEGIN 
	DECLARE newOrderNo INT;
    
    -- Insert into Orders
    INSERT INTO Orders (orderDate, orderStatus, deliveryStatus, storeID, HQID, loadingBayNo, managerID)
	VALUES (p_orderDate, FALSE, 'Unassigned', p_storeID, 1, p_loadingBayNo, p_managerID);
    
    -- Get the auto incremented orderNo
    SET newOrderNo = LAST_INSERT_ID(); 
    
    -- Insert into the correct subtype table based on order type
    IF p_orderType = 'Gas' THEN
		INSERT INTO gasOrders (orderNo, galDiesel, galRegular, galPremium)
		VALUES (newOrderNo, p_galDiesel, p_galRegular, p_galPremium);
    ELSEIF p_orderType = 'Backstock' THEN
		INSERT INTO backstockOrders (orderNo, hotdogs, cigarettes)
        VALUES (newOrderNo, p_hotdogs, p_cigarettes);
	END IF; 
END //
DELIMITER ; 



-- Function

-- Get the total number of trucks currently available
DELIMITER //
CREATE FUNCTION getAvailableTruckCount()
RETURNS INT
DETERMINISTIC
BEGIN
	Declare total INT DEFAULT 0;
    SELECT COUNT(*)
    INTO total
    FROM Fleet
    WHERE available = TRUE;
    RETURN total;
END //
DELIMITER ;

