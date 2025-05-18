-- QUESTION 1 
-- Create the initial table ProductDetail and insert data (for testing purposes)
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(255),
    Products VARCHAR(255)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Query to transform ProductDetail to 1NF using a recursive CTE (MySQL 8.0+)
WITH RECURSIVE ProductSplit AS (
    -- Anchor member: selects the first product and the rest of the string
    SELECT
        OrderID,
        CustomerName,
        -- Extract the first product (substring before the first comma)
        TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
        -- Get the rest of the string after the first comma
        CASE
            WHEN LOCATE(',', Products) > 0 THEN TRIM(SUBSTRING(Products, LOCATE(',', Products) + 1))
            ELSE NULL
        END AS RemainingProducts
    FROM
        ProductDetail
    WHERE Products IS NOT NULL AND Products != ''

    UNION ALL

    -- Recursive member: continues to split the RemainingProducts
    SELECT
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(RemainingProducts, ',', 1)) AS Product,
        CASE
            WHEN LOCATE(',', RemainingProducts) > 0 THEN TRIM(SUBSTRING(RemainingProducts, LOCATE(',', RemainingProducts) + 1))
            ELSE NULL
        END AS RemainingProducts
    FROM
        ProductSplit
    WHERE
        RemainingProducts IS NOT NULL AND RemainingProducts != ''
)
SELECT
    OrderID,
    CustomerName,
    Product
FROM
    ProductSplit
ORDER BY
    OrderID, Product;

-- To see the result as a new table (optional):
CREATE TABLE ProductDetail_1NF AS
WITH RECURSIVE ProductSplit AS (
    SELECT
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
        CASE
            WHEN LOCATE(',', Products) > 0 THEN TRIM(SUBSTRING(Products, LOCATE(',', Products) + 1))
            ELSE NULL
        END AS RemainingProducts
    FROM
        ProductDetail
    WHERE Products IS NOT NULL AND Products != ''
    UNION ALL
    SELECT
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(RemainingProducts, ',', 1)) AS Product,
        CASE
            WHEN LOCATE(',', RemainingProducts) > 0 THEN TRIM(SUBSTRING(RemainingProducts, LOCATE(',', RemainingProducts) + 1))
            ELSE NULL
        END AS RemainingProducts
    FROM
        ProductSplit
    WHERE
        RemainingProducts IS NOT NULL AND RemainingProducts != ''
)
SELECT
    OrderID,
    CustomerName,
    Product
FROM
    ProductSplit;

SELECT * FROM ProductDetail_1NF;



-- QUESTION 2
-- Create the initial OrderDetails table and insert data (for testing purposes)
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255),
    Quantity INT
);

INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 1: Create the new 'Orders' table
CREATE TABLE Orders (
    OrderID INT,
    CustomerName VARCHAR(255),
    PRIMARY KEY (OrderID) -- Define OrderID as the primary key
);

-- Step 2: Populate the 'Orders' table with distinct OrderID-CustomerName pairs
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT
    OrderID,
    CustomerName
FROM
    OrderDetails;

-- Step 3: Create the new 'OrderItems' table
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product), -- Define a composite Primary Key
    CONSTRAINT fk_orderitems_orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) -- Define Foreign Key
);

-- Step 4: Populate the 'OrderItems' table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT
    OrderID,
    Product,
    Quantity
FROM
    OrderDetails;

-- Step 5: (Optional) Drop the original OrderDetails table if it's no longer needed
-- DROP TABLE OrderDetails;

-- To verify the transformation, you can select data from the new tables:
SELECT * FROM Orders;
SELECT * FROM OrderItems;
