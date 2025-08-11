select name from sys.tables;
select * from ecommerce_dataset;

SELECT 
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity_Ordered * Price_Each) AS Total_Revenue,
    AVG(Quantity_Ordered * Price_Each) AS Average_Order_Value
FROM ecommerce_dataset;

WITH MonthlySales AS (
    SELECT 
        FORMAT(Order_Date, 'yyyy-MM') AS Sales_Month,
        SUM(Quantity_Ordered * Price_Each) AS Monthly_Revenue
    FROM ecommerce_dataset
    GROUP BY FORMAT(Order_Date, 'yyyy-MM')
)
SELECT *,
       LAG(Monthly_Revenue) OVER (ORDER BY Sales_Month) AS Prev_Month_Revenue,
       ROUND(
           (CAST(Monthly_Revenue AS FLOAT) - LAG(Monthly_Revenue) OVER (ORDER BY Sales_Month)) 
           / NULLIF(LAG(Monthly_Revenue) OVER (ORDER BY Sales_Month), 0) * 100, 2
       ) AS MoM_Growth_Percent
FROM MonthlySales;

SELECT TOP 10 
    Product,
    SUM(Quantity_Ordered * Price_Each) AS Total_Revenue
FROM ecommerce_dataset
GROUP BY Product
ORDER BY Total_Revenue DESC;

SELECT 
    DATEPART(HOUR, Order_Date) AS Order_Hour,
    COUNT(*) AS Total_Orders,
    SUM(Quantity_Ordered * Price_Each) AS Hourly_Revenue
FROM ecommerce_dataset
GROUP BY DATEPART(HOUR, Order_Date)
ORDER BY Order_Hour;

SELECT 
    TRIM(SUBSTRING(Purchase_Address, 
        CHARINDEX(',', Purchase_Address) + 2,
        CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) + 1) 
        - CHARINDEX(',', Purchase_Address) - 2)) AS City,
    SUM(Quantity_Ordered * Price_Each) AS Total_Revenue,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Quantity_Ordered * Price_Each) / COUNT(DISTINCT Order_ID), 2) AS Avg_Order_Value
FROM ecommerce_dataset
GROUP BY 
    TRIM(SUBSTRING(Purchase_Address, 
        CHARINDEX(',', Purchase_Address) + 2,
        CHARINDEX(',', Purchase_Address, CHARINDEX(',', Purchase_Address) + 1) 
        - CHARINDEX(',', Purchase_Address) - 2))
ORDER BY Total_Revenue DESC;

WITH ProductMonth AS (
    SELECT 
        Product,
        FORMAT(Order_Date, 'yyyy-MM') AS Sales_Month,
        SUM(Quantity_Ordered * Price_Each) AS Product_Revenue
    FROM ecommerce_dataset
    GROUP BY Product, FORMAT(Order_Date, 'yyyy-MM')
)
SELECT *,
       LAG(Product_Revenue) OVER (PARTITION BY Product ORDER BY Sales_Month) AS Prev_Month_Revenue,
       ROUND(
           (CAST(Product_Revenue AS FLOAT) - LAG(Product_Revenue) OVER (PARTITION BY Product ORDER BY Sales_Month)) 
           / NULLIF(LAG(Product_Revenue) OVER (PARTITION BY Product ORDER BY Sales_Month), 0) * 100, 2
       ) AS MoM_Growth_Percent
FROM ProductMonth;

SELECT *
FROM ecommerce_dataset
WHERE Quantity_Ordered * Price_Each < 2000;


SELECT *
FROM ecommerce_dataset
WHERE Quantity_Ordered * Price_Each > 2000;

SELECT 
    Order_ID,
    STRING_AGG(Product, ', ') AS Products_In_Order
FROM ecommerce_dataset
GROUP BY Order_ID
HAVING COUNT(Product) > 1;

CREATE VIEW vw_Ecommerce_KPIs AS
SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS Sales_Month,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity_Ordered * Price_Each) AS Revenue,
    AVG(Quantity_Ordered * Price_Each) AS AOV
FROM ecommerce_dataset
GROUP BY FORMAT(Order_Date, 'yyyy-MM');

