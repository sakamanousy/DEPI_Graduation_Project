-- 1. Retrieve specific rows based on their RowID
SELECT * FROM SuperStore
WHERE ROWID IN (182,431,432,1407,1970,1972);

-- 2. Display all rows ordered by RowID in ascending order
SELECT * FROM SuperStore ss
ORDER BY RowID ASC;

-- 3. Load all data from the SuperStore table (assuming it already exists)
SELECT * FROM SuperStore ss;

-- 4. Display column names and their data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'SuperStore';

-- 5. Count the number of rows and columns in the table
SELECT 
    (SELECT COUNT(*) FROM SuperStore) AS Total_Rows, -- Count total rows
    (SELECT COUNT(COLUMN_NAME) 
     FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'SuperStore') AS Total_Columns; -- Count total columns

-- 6. Identify duplicate rows using a Common Table Expression (CTE)
WITH DuplicateRows_CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ORDERID, OrderDate, ShipDate, ShipMode, 
                              CustomerID, CustomerName, Segment, Country, City, State, 
                              PostalCode, Region, ProductID, Category, SubCategory, 
                              ProductName, Sales, Quantity, Discount, Profit 
                              ORDER BY (SELECT NULL)) AS rn
    FROM SuperStore
)
SELECT * FROM DuplicateRows_CTE WHERE rn > 1; -- Fetch only duplicate rows

-- 7. Retrieve specific rows based on their RowID
SELECT * FROM SuperStore
WHERE RowID IN (3407,432, 431,3406);

-- 8. Delete duplicate rows using a CTE
WITH DeleteDuplicatedRows_CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ORDERID, OrderDate, ShipDate, ShipMode, 
                              CustomerID, CustomerName, Segment, Country, City, State, 
                              PostalCode, Region, ProductID, Category, SubCategory, 
                              ProductName, Sales, Quantity, Discount, Profit 
                              ORDER BY (SELECT NULL)) AS rn
    FROM SuperStore
)
DELETE FROM SuperStore
WHERE RowID IN (
    SELECT RowID FROM DeleteDuplicatedRows_CTE WHERE rn > 1
);

-- 9. Check for missing (NULL) values in key columns
SELECT 
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Sales_Missing_Values,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Profit_Missing_Values,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Quantity_Missing_Values,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS Discount_Missing_Values
FROM SuperStore;

-- 10. Display rows with missing values
SELECT * FROM SuperStore 
WHERE Sales IS NULL OR Quantity IS NULL OR Discount IS NULL OR Profit IS NULL;

-- 11. Handle missing values by replacing them with median or average values
-- Replace missing Sales values with the median Sales value
WITH MedianCTE AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Sales) 
    OVER () AS MedianValue
    FROM SuperStore
)
UPDATE SuperStore
SET Sales = (SELECT DISTINCT MedianValue FROM MedianCTE)
WHERE Sales IS NULL;

-- Replace missing Quantity values with the average Quantity value
UPDATE SuperStore 
SET Quantity = (SELECT AVG(Quantity) FROM SuperStore) 
WHERE Quantity IS NULL;

-- Replace missing Discount values with the average Discount value
UPDATE SuperStore 
SET Discount = (SELECT AVG(Discount) FROM SuperStore) 
WHERE Discount IS NULL;

-- Replace missing Profit values with the median Profit value
WITH MedianCTE AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Profit) 
    OVER () AS MedianValue
    FROM SuperStore
)
UPDATE SuperStore
SET Profit = (SELECT DISTINCT MedianValue FROM MedianCTE)
WHERE Profit IS NULL;

-- 12. Convert Quantity column data type to integer
ALTER TABLE SuperStore 
ALTER COLUMN Quantity INT;

-- 13. Convert Order Date and Ship Date columns to date format
ALTER TABLE SuperStore 
ALTER COLUMN OrderDate DATE;

ALTER TABLE SuperStore 
ALTER COLUMN ShipDate DATE;

-- 14. Display column information after modifications
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'SuperStore';