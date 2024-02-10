# All the Tables in the littlelemon database contains my own made up (but valid) data. So, the outputs may not 
# refer to the outputs stated in coursera platform, but I hope you'll find all the required procedures, statements,
# virtual tables etc. just as required by the course task.

show databases;
USE littlelemondb;

-- Inserting into Customer table
INSERT INTO Customer (CustomerID, FullName, ContactNumber, Email)
VALUES
(1, 'John Doe', '123-456-7890', 'john@example.com'),
(2, 'Jane Smith', '987-654-3210', 'jane@example.com'),
(3, 'Alice Johnson', '555-555-5555', 'alice@example.com'),
(4, 'Bob Brown', '444-444-4444', 'bob@example.com');

-- Inserting into Deliverystatus table
INSERT INTO Deliverystatus (DeliveryID, DeliveryDate)
VALUES
(1, '2024-02-09'),
(2, '2024-02-10'),
(3, '2024-02-11'),
(4, '2024-02-12');

-- Inserting into Menu table
INSERT INTO Menu (MenuID, Name, Description)
VALUES
(1, 'Breakfast Menu', 'Start your day with our delicious breakfast options'),
(2, 'Lunch Menu', 'Enjoy a variety of lunch dishes'),
(3, 'Dinner Menu', 'Savor our exquisite dinner selections'),
(4, 'Dessert Menu', 'Indulge in our decadent desserts');

-- Inserting into Menuitems table
INSERT INTO Menuitems (MenuItemID, CourseName, StarterName, DesertName)
VALUES
(1, 'Main Course', 'Caesar Salad', 'Chocolate Cake'),
(2, 'Appetizer', 'Bruschetta', 'Tiramisu'),
(3, 'Main Course', 'Grilled Salmon', 'Cheesecake'),
(4, 'Appetizer', 'Caprese Salad', 'Apple Pie');

-- Inserting into Menus table
INSERT INTO Menus (Menu_ID, MenuItemsID, MenuName, Cuisine, Orders_OrderID)
VALUES
(1, 1, 'Italian Lunch', 'Italian', 1),
(2, 2, 'Italian Dinner', 'Italian', 2),
(3, 3, 'Seafood Dinner', 'Seafood', 3),
(4, 4, 'American Lunch', 'American', 4);

-- Inserting into Orders table
INSERT INTO Orders (OrderID, Date, Quantity, TotalCost, Booking_BookingID, Customer_CustomerID, Menu_MenuID, DeliveryStatus_DeliveryID)
VALUES

(1, '2024-02-09', 2, 250, 1, 1, 2, 1),
(2, '2024-02-10', 3, 450, 2, 3, 2, 2),
(3, '2024-02-11', 3, 150, 3, 2, 1, 3),
(4, '2024-02-12', 2, 100, 4, 1, 3, 4);

-- Inserting into Staff table
INSERT INTO Staff (StaffID, FullName, ContactNumber, Email, Role, Salary, Customer_CustomerID)
VALUES
(1, 'Michael Johnson', '111-111-1111', 'michael@example.com', 'Waiter', 2500, NULL),
(2, 'Emily Brown', '222-222-2222', 'emily@example.com', 'Chef', 3500, NULL),
(3, 'David Lee', '333-333-3333', 'david@example.com', 'Bartender', 2800, NULL),
(4, 'Sarah Clark', '444-444-4444', 'sarah@example.com', 'Manager', 4000, NULL);


# Exercise: Create a virtual table to summarize data 
# Task 1 : 
CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost
FROM Orders
WHERE Quantity > 2;

SELECT * FROM OrdersView;

# Task 2 : 
SELECT customers.CustomerID, customers.FullName, orders.OrderID, orders.TotalCost, menus.MenuName, menuitems.CourseName, menuitems.StarterName
FROM customers INNER JOIN orders
ON customers.CustomerID = orders.customerID
INNER JOIN menus ON orders.MenuID = menus.MenuID
INNER JOIN menuitems ON menuitems.MenuItemID = menus.MenuItemsID 
WHERE TotalCost > 150 
ORDER BY TotalCost;

# Task 3 :
SELECT Name FROM menu WHERE MenuID=ANY (SELECT MenuID FROM Orders WHERE Quantity>2);


# Exercise: Create optimized queries to manage and analyze data 
# Task 1 :
CREATE PROCEDURE GetMaxQuantity()
SELECT max(quantity) AS "Max Qunatity in Order" FROM orders;

CALL GetMaxQuantity();

# Task 2 : 
PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM Orders where OrderID=?';
SET @id = 1;
EXECUTE GetOrderDetail USING @id;

# Task 3 : 
CREATE PROCEDURE CancelOrder (IN OrderID INT)
DELETE FROM orders;

CALL CancelOrder(5);


# Exercise: Create SQL queries to check available bookings based on user input
# Task 1 : 
INSERT INTO Booking(BookingID, BookingDate, TableNumber, CustomerID) VALUES
(1,'2022-10-10',5,1),
(2,'2022-11-12',3,3),
(3,'2022-10-11',2,2),
(4,'2022-10-13',2,1);

# Task 2 :
DELIMITER //
CREATE PROCEDURE CheckBooking(booking_date DATE, table_number INT)
BEGIN
    DECLARE bookedTable INT DEFAULT 0;
    SELECT COUNT(*)
    INTO bookedTable
    FROM Booking
    WHERE BookingDate = booking_date AND TableNumber = table_number;
    
    IF bookedTable > 0 THEN
        SELECT CONCAT("Table", table_number, " is already booked") AS "Booking status";
    ELSE
        SELECT CONCAT("Table", table_number, " is not booked") AS "Booking status";
    END IF;
END//
DELIMITER ;

Call CheckBooking('2022-11-12',3);

# Task 3 : 
CREATE PROCEDURE AddValidBooking (IN Booking_Date DATE, IN Table_Number INT)
START TRANSACTION;
SELECT BookingDate, TableNumber
WHERE EXISTS (SELECT * FROM Booking WHERE BookingDate = Booking_Date and TableNumber = Table_Number);
	
    INSERT INTO Booking (BookingDate, TableNumber)
    VALUES (Booking_Date,Table_Number);
    
    COMMIT;

    
# Exercise: Create SQL queries to add and update bookings    
# Task 1 : 
DELIMITER //
CREATE PROCEDURE AddBooking (IN Booking_ID INT, IN Customer_ID INT, IN Table_Number INT, IN Booking_Date DATE)
BEGIN
    INSERT INTO Booking (BookingID, CustomerID, TableNumber, BookingDate) 
    VALUES (Booking_ID, Customer_ID, Table_Number, Booking_Date);
    SELECT 'New booking added' AS 'Confirmation';
END//
DELIMITER ;

Call AddBooking(9,3,4,'2022-12-30');

#Task 2 :
DELIMITER //
CREATE DEFINER='admin1'@'%' PROCEDURE UpdateBooking (IN Booking_ID INT, IN Booking_Date DATE)
BEGIN
	UPDATE Booking SET BookingDate = Booking_Date WHERE BookingID = Booking_ID;
    SELECT CONCAT('Booking',Booking_ID,'updated') AS 'Confirmation';
END//
DELIMITER ;

CALL UpdateBooking(9,'2022-12-17');

# Task 3 :
DELIMITER //
CREATE DEFINER='admin1'@'%' PROCEDURE CancelBooking (IN Booking_ID INT)
BEGIN
	DELETE FROM Booking WHERE BokingID = Booking_ID;
    SELECT CONCAT('Booking',Booking_ID,'cancelled') AS 'Confirmation';
END  //I
DELIMITER ;  

CALL CancelBooking(9);