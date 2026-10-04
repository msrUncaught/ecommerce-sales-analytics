-- ====================================================================
-- E-COMMERCE SALES & PROFIT ANALYTICS - CASE STUDY QUERIES
-- Database Table: sales_data
-- ====================================================================

-- 1. EXECUTIVE OVERVIEW (TOTALS & PROFIT MARGIN %)
SELECT 
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Overall_Profit_Margin_Pct
FROM sales_data;

-- 2. CATEGORY BREAKDOWN & MARGIN ANALYSIS
SELECT 
    Category,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Category_Profit_Margin_Pct
FROM sales_data
GROUP BY Category
ORDER BY Total_Revenue DESC;

-- 3. TOP 3 PRODUCTS PER CATEGORY USING RANK() & CTE
WITH Ranked_Products AS (
    SELECT 
        Category,
        Product,
        SUM(Sales) AS Product_Revenue,
        SUM(Profit) AS Product_Profit,
        DENSE_RANK() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS Revenue_Rank
    FROM sales_data
    GROUP BY Category, Product
)
SELECT 
    Category,
    Product,
    Product_Revenue,
    Product_Profit,
    Revenue_Rank
FROM Ranked_Products
WHERE Revenue_Rank <= 3;

-- 4. MONTH-OVER-MONTH (MoM) GROWTH USING LAG() WINDOW FUNCTION
WITH Monthly_Sales AS (
    SELECT 
        EXTRACT(MONTH FROM Order_Date) AS Month_Num,
        TO_CHAR(Order_Date, 'Month') AS Month_Name,
        SUM(Sales) AS Current_Month_Sales
    FROM sales_data
    GROUP BY EXTRACT(MONTH FROM Order_Date), TO_CHAR(Order_Date, 'Month')
)
SELECT 
    Month_Num,
    TRIM(Month_Name) AS Month,
    Current_Month_Sales,
    LAG(Current_Month_Sales, 1) OVER (ORDER BY Month_Num) AS Previous_Month_Sales,
    ROUND(
        ((Current_Month_Sales - LAG(Current_Month_Sales, 1) OVER (ORDER BY Month_Num)) 
        / LAG(Current_Month_Sales, 1) OVER (ORDER BY Month_Num)) * 100, 
        2
    ) AS MoM_Growth_Pct
FROM Monthly_Sales
ORDER BY Month_Num;