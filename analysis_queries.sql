use classicmodels;
select * from customers limit 10;
select * from employees limit 10;
select * from offices limit 10;
select * from orderdetails limit 10;
select * from orders limit 10;
select * from payments limit 10;
select * from productlines limit 10;
select * from products limit 10;
show tables;

-- Monthly Revenue & Growth
SELECT 
    YEAR(paymentDate) AS Sales_Year,
    MONTH(paymentDate) AS Sales_Month,
    SUM(amount) AS Total_Revenue,
    LAG(SUM(amount)) OVER (ORDER BY YEAR(paymentDate), MONTH(paymentDate)) AS Previous_Month_Revenue
FROM payments
GROUP BY YEAR(paymentDate), MONTH(paymentDate)
ORDER BY Sales_Year, Sales_Month;


-- RFM Customer Segmentation
WITH Customer_RFM AS (
    SELECT 
        c.customerNumber,
        c.customerName,
        MAX(p.paymentDate) AS Last_Purchase_Date,
        COUNT(DISTINCT o.orderNumber) AS Total_Orders,
        SUM(p.amount) AS Total_Spent
    FROM customers c
    JOIN payments p ON c.customerNumber = p.customerNumber
    JOIN orders o ON c.customerNumber = o.customerNumber
    GROUP BY c.customerNumber, c.customerName
)
SELECT 
    customerName,
    Total_Orders,
    Total_Spent,
    DENSE_RANK() OVER (ORDER BY Total_Spent DESC) AS Revenue_Rank
FROM Customer_RFM;


-- Unsold Inventory / Slow-Moving Products
SELECT 
    p.productName,
    p.productLine,
    p.quantityInStock,
    COALESCE(SUM(od.quantityOrdered), 0) AS Total_Sold
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.productLine, p.quantityInStock
HAVING Total_Sold < 100
ORDER BY p.quantityInStock DESC;



CREATE VIEW View_Top_Customers AS
SELECT 
    c.customerNumber,
    c.customerName,
    c.country,
    SUM(p.amount) AS TotalSpent
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName, c.country
ORDER BY TotalSpent DESC;


