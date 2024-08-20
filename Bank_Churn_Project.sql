Create DATABASE CapstoneBankCRM;
SHOW Databases;
USE CapstoneBankCRM;

Create Table BankChurn(
    RowNumber INT,
    CustomerID INT ,
    CreditScore INT,
    CreditScoreCategory Varchar(50),
    Tenure INT,
    Balance INT,
    NumofProducts INT,
    HasCrCard bool,
    CreditCard Varchar(50),
    IsActiveMember Bool,
    ActiveCustomer Varchar(50),
    Exited Bool,
    ExitCustomer Varchar(50)
);

CREATE TABLE Customerinfo (
    RowNumber INT,
    CustomerID INT PRIMARY KEY,
    Surname VARCHAR(50),
    Age INT,
    GenderID BOOL,
    Gender VARCHAR(50),
    EstimatedSalary INT,
    GeographyID BOOL,
    Geography VARCHAR(50),
    BankDOJ DATE
);

-- OBJECTIVE QUESTIONS

-- 1.	What is the distribution of account balances across different regions?

SELECT 
    c.Geography,
    COUNT(c.customerID) AS NumofCustomers,
    ROUND(AVG(b.balance), 2) AS AvgBalance
FROM
    customerinfo c
        JOIN
    bankchurn b ON c.customerID = b.customerID
GROUP BY Geography;


-- 2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year.

Select 
    customerID,
    Surname,
    EstimatedSalary AS Salary,
    BankDOJ
From customerinfo
Where BankDOJ Between '2019-10-01' AND '2019-12-31'
Order by Salary DESC
LIMIT 5; 

-- 3. Calculate the average number of products used by customers who have a credit card.

Select
    AVG(NumofProducts) AS AverageProducts
From Bankchurn
Where Has_creditcard = 1;


-- 4. Determine the churn rate by gender for the most recent year in the dataset.

Select 
    Gender,
    ROUND(COUNT(b.customerID)) AS ChurnCount
from customerinfo c 
JOIN bankchurn b ON c.customerID = b.customerID
Where Year(BankDOJ) = 2019
AND ExitCustomer LIKE 'Exit'
Group by gender;

-- 5. Compare the average credit score of customers who have exited and those who remain.

Select 
	ExitCustomer AS ExitedCustomer,
    ROUND(AVG(CreditScore),1) AS AverageCreditScore
From Bankchurn
Group by ExitedCustomer;


-- 6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? 

WITH GenderStatus AS(
Select
	c.Gender,
    AVG(c.EstimatedSalary) AS AvgSalary,
    SUM(Case When b.ActiveCustomer = 'Active' Then 1 ELSE 0 END) AS ActiveAccounts
From customerinfo c LEFT JOIN bankchurn b
ON c.customerID = b.customerID
Group by Gender)

Select
   Gender,
   ROUND((AvgSalary),2) as AvgSalary,
   ActiveAccounts
From GenderStatus
Where AvgSalary = (Select MAX(AvgSalary) from GenderStatus);


-- 7. Segment the customers based on their credit score and identify the segment with the highest exit rate.

-- I have already segmented the customers on the Excel by using IF function so there is no need for doing it here.
-- I am aware of doing it by using Case When Function which will allow me to segment the customers based on Credit Score criteria.
-- I have used this approach for the Segmentation -
-- Credit score: 
-- Excellent: 800–850
-- Very Good: 740–799
-- Good: 670–739
-- Fair: 580–669
-- Poor: 300–579


SELECT 
    CreditScoreCategory,
    COUNT(*) AS TotalCustomers,
    SUM(CASE
        WHEN ExitCustomer = 'Exit' THEN 1
        ELSE 0
    END) AS ExitedCustomers
FROM
    Bankchurn
GROUP BY CreditScoreCategory
ORDER BY ExitedCustomers DESC
LIMIT 1;

-- 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.

Select 
    Geography,
    COUNT(c.customerID) AS NumberOFCustomers
From customerInfo c JOIN
Bankchurn b ON
c.customerID = b.customerID
Where ActiveCustomer LIKE 'Active'
AND Tenure > 5
Group by Geography
Order by NumberOfCustomers DESC
LIMIT 1;

-- 9. What is the impact of having a credit card on customer churn, based on the available data?

Select 
    CreditCard,
    SUM(Case When ActiveCustomer = 'Active' Then 1 Else 0 END) AS ActiveCustomers,
    SUM(Case When ActiveCustomer = 'Inactive' Then 1 Else 0 END) AS InactiveCustomers,
    SUM(Case When ExitCustomer = 'Exit' Then 1 ELSE 0 END) AS ExitCustomers,
    SUM(Case WHen ExitCustomer = 'Retain' Then 1 Else 0 END) AS RetainedCustomers,
    COUNT(customerID) AS OverallTotalCustomers
From bankchurn
Group by CreditCard;

-- 10.	For customers who have exited, what is the most common number of products they have used?


Select
    NumofProducts,
    COUNT(CustomerID) AS NumOfCustomers
From Bankchurn
Where ExitCustomer = 'Exit'
Group by NumofProducts
Order by NumofCustomers DESC
LIMIT 1;

-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

-- Yearly Trend
Select 
    YEAR(BankDOJ) AS JoiningYear,
    COUNT(CustomerID) AS NumofCustomers
From customerINFO
Group by JoiningYear
Order by joiningyear;

-- Monthly Trend
Select 
    YEAR(BankDOJ) AS JoiningYear,
    Month(BankDOJ) AS JoiningMonth,
    COUNT(customerID) AS NumOfCustomers
From customerInfo
Group by JoiningYear, JoiningMonth
Order by JoiningYear, JoiningMonth;


-- 12. Analyze the relationship between the number of products and the account balance for customers who have exited.

Select
    NumofProducts,
    AVG(Balance) AS AvgBalance,
    MIN(Balance) AS MinBalance,
    MAX(Balance) AS MaxBalance,
    SUM(Balance) AS TotalBalance
From BankChurn
WHere ExitCustomer = 'Exit'
Group by NumofProducts;

-- 13. Identify any potential outliers in terms of balance among customers who have remained with the bank.

Select * from customerinfo;
Select * from bankchurn;

Select
   customerID,
   Exitcustomer,
   Balance
From Bankchurn
Where ExitCustomer LIKE 'Retain'
Order by Balance DESC;


-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value.

Select 
    GeographyID,
    Geography,
    Gender,
    ROUND(AVG(EstimatedSalary),2) AS AverageSalary,
    RANK() OVER(Partition by geography Order by AVG(EstimatedSalary) DESC) AS GenderRank
From customerINFO
Group by GeographyID, Geography, Gender
Order by Geography;


-- 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

Select
   Case 
   When AGE Between 18 And 30 Then '18-30'
   When AGE Between 31 and 50 Then '31-50'
   ELSE '50+' END AS AgeBracket,
   ROUND(AVG(tenure),1) AS AverageTenure
From customerinfo c
JOIN Bankchurn b ON
c.customerID = b.customerID
Where ExitCustomer = 'Exit'
Group by AgeBracket;

-- 19. Rank each bucket of credit score as per the number of customers who have churned the bank.

Select 
    CreditScoreCategory,
    COUNT(*) AS NumOfCustomers,
    RANK() OVER(Order by COUNT(*) DESC) AS Ranking
FROM Bankchurn
Where ExitCustomer = 'Exit'
Group by CreditScoreCategory
Order by NumofCustomers DESC, Ranking;

-- 20. According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.

With AgeBuckets AS(
   Select
      Case
         When Age Between 18 AND 30 Then '18-30'
         When Age Between 31 AND 50 Then '31-50'
         Else '50+' 
	  END AS AgeBucket,
      CreditCard
	From Customerinfo c
    JOIN bankchurn b ON
    c.customerID = b.customerID
    ),
BucketCounts AS(
    Select
	  AgeBucket,
      CreditCard,
      Count(*) AS NumOfCustomers
	From AgeBuckets
    Group by AgeBucket, CreditCard
    ),
AvgCreditCards AS (
     Select
       AgeBucket,
       AVG(NumOfCustomers) OVER(Partition by AgeBucket) AS AvgNumofCreditCards
	 From BucketCounts
     Where CreditCard = 'credit card holder'
     )
Select
    AgeBucket,
    AvgNumofCreditCards
From AvgCreditCards
Where AvgNumofCreditCards < (
     Select
         AVG(AvgNumofCreditCards)
	 From AvgCreditCards);

-- 21. Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

Select 
    Location,
    ChurnedCustomers,
    RANK() OVER(Order by ChurnedCustomers DESC) AS ChurnRank,
    AverageBalance,
    RANK() OVER(Order by AverageBalance DESC) AS BalanceRank
From
(Select
   c.Geography AS Location,
   COUNT(b.ExitCustomer) AS ChurnedCustomers,
   AVG(b.Balance) AS AverageBalance
From bankchurn b JOIN customerinfo c ON
b.customerID = c.customerID
Group by Location) AS Subquery;


-- 22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
-- now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, 
-- come up with a column where the format is “CustomerID_Surname”.

Select 
    b.*,
    CONCAT(b.customerid, '_', c.Surname) AS CustomerID_Surname
From Bankchurn b
JOIN customerinfo c ON 
b.customerID = c.customerID;

-- 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

Select 
    customerID,
    Exited,
    CASE
    When Exited = 1 Then 'Exit'
    ELSE 'Retain' END AS ExitCategory
From bankchurn;

-- 25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

Select
    CustomerID,
    Surname AS LastName
From customerinfo
Where Surname LIKE "%on";

-- SUBJECTIVE QUESTIONS

-- 2. Product Affinity Study: Which bank products or services are most commonly used together, and how might this influence cross-selling strategies?
Select
    NumofProducts,
    CreditCard,
    COUNT(*) AS UsageCount
From bankchurn
Group by NumofProducts, CreditCard
Order by UsageCount DESC;

-- 3. Geographic Market Trends: How do economic indicators in different geographic regions correlate with the number of active accounts and customer churn rates?

Select
   c.Geography AS Location,
   AVG(c.EstimatedSalary) AS AverageSalary,
   SUM(CASE WHEN b.ActiveCustomer = 'Active' THEN 1 ELSE 0 END) AS ActiveAccounts,
   SUM(CASE WHEN b.ExitCustomer = 'Exit' THEN 1 ELSE 0 END) AS ChurnedCustomers
From bankchurn b
JOIN customerinfo c ON b.customerID = c.customerID
Group by Location;

-- 4. Risk Management Assessment: Based on customer profiles, which demographic segments appear to pose the highest financial risk to the bank, and why?

Select 
    c.Geography,
    AVG(b.CreditScore) AS AverageCreditScore,
    AVG(c.Age) AS AverageAge,
    COUNT(c.CustomerID) AS CustomerCount
From CustomerINFO c
JOIN Bankchurn b ON
c.CustomerID = b.CustomerID
Group by Geography;

-- 5. Customer Tenure Value Forecast: How would you use the available data to model and predict the lifetime (tenure) value in the bank of different customer segments?

Select
    c.Geography,
    AVG(b.Tenure) AS AverageTenure,
    AVG(b.Balance) AS AverageAccountBalance
From customerinfo c
JOIN bankchurn b ON
c.customerID = b.customerID
Group by Geography;
 
 
-- 9. Utilize SQL queries to segment customers based on demographics and account details.

-- Segmenting by Geography
Select
    Geography,
    COUNT(CustomerID) AS CustomerCount
From CustomerInfo
Group by Geography
Order by CustomerCount DESC;

-- Segmenting by Age Group
Select
    Case
         When Age Between 18 AND 30 Then '18-30'
         When Age Between 31 AND 50 Then '31-50'
         Else '50+' 
	  END AS AgeGroup,
	COUNT(CustomerID) AS CustomerCount
From CustomerInfo
Group by AgeGroup;

-- Segmenting by Number of Products
Select
    NumofProducts,
    COUNT(CustomerID) AS CustomersCount
From Bankchurn
Group by NumofProducts
Order by CustomersCount DESC;

-- Segmenting by Credit Score
Select
    CreditScoreCategory,
    COUNT(CustomerID) AS CustomersCount
From bankchurn
Group by CreditScoreCategory
Order by CustomersCount DESC;


-- 10. How can we create a conditional formatting setup to visually highlight customers at risk of churn and 
-- to evaluate the impact of credit card rewards on customer retention?

-- Calculating Churn Risk Scores

Select
    CustomerID,
    Case
       When Tenure < 4 AND NumofProducts = 1 Then 'High'
       When Tenure >= 4 AND NumofProducts > 1 Then 'Low'
       ELSE 'Medium'
	END AS ChurnRisk
From Bankchurn;


-- 11.	What is the current churn rate per year and overall as well in the bank? 
-- Can you suggest some insights to the bank about which kind of customers are more likely to churn and what different strategies can be used to decrease the churn rate?

-- Churn Rate Per Year
Select
    YEAR(BankDOJ) AS JoiningYear,
    SUM(Exited) AS ChurnedCustomers,
    COUNT(b.CustomerID) AS TotalCustoemrs,
    SUM(Exited) / COUNT(b.CustomerID) AS ChurnRate
From Bankchurn b
JOIN CustomerInfo c ON
b.customerID = c.customerID
Group by JoiningYear
Order by ChurnRate;


-- Overall Churn Rate
Select
    SUM(Exited) AS TotalChurnedCustomers,
    COUNT(CustomerID) AS TotalCustomers,
    SUM(Exited) / COUNT(CustomerID) AS OverallChurnRate
From Bankchurn;


-- 14.	In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?

Alter Table Bankchurn
Rename Column HasCrCard to Has_creditcard;
Select * from bankchurn;