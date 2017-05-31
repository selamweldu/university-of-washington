use adventureworks2012
go
-- Question1
SELECT count(*), count(CustomerID), count(SalesPersonID) FROM [Sales].[SalesOrderHeader]
-- Question2
SELECT YEAR(ModifiedDate)As "YEAR" ,MONTH(ModifiedDate) As "MONTH" ,SUM(LineTotal) As TOTAL, 
SUM(OrderQty) As ITEMS from [Sales].[SalesOrderDetail]
Group By YEAR(ModifiedDate),MONTH(ModifiedDate) 
ORDER BY YEAR(ModifiedDate), MONTH(ModifiedDate)
-- Question3
SELECT YEAR(ModifiedDate) As "YEAR",MONTH(ModifiedDate) As "MONTH" , 
AVG(OrderQty) As AVEOFTOTAL, AVG(LineTotal)As AVEOFITEMS from [Sales].[SalesOrderDetail]
Group By YEAR(ModifiedDate),MONTH(ModifiedDate) ORDER BY YEAR(ModifiedDate), MONTH(ModifiedDate)
--Question4
select Name as country, Sum(TotalDue) as Total, SUM(Freight)as cost,
[Sales].[SalesOrderHeader].TotalDue-[Sales].[SalesOrderHeader].Freight as Margin
from [Sales].[SalesTerritory] Join [Sales].[SalesOrderHeader] 
on [Sales].[SalesOrderHeader].[TerritoryID]=[Sales].[SalesTerritory].TerritoryID
Group by [Sales].[SalesTerritory].Name
--

-- question5
select Top 5 BusinessEntityID from [Sales].[SalesPerson] order by SalesLastYear DESC

--question 6
SELECT CustomerID 
from [Sales].[SalesOrderHeader]
WHERE YEAR(OrderDate)=2007
Except
SELECT CustomerID 
from [Sales].[SalesOrderHeader]
WHERE YEAR(OrderDate)=2008
--
--question 7 
select YEAR(ModifiedDate) As Year, SUM(SubTotal) As TotalByYear from [Sales].[SalesOrderHeader]
 Group by YEAR(ModifiedDate) order by YEAR(ModifiedDate) 
 --
 -- question 8
 Select * from[Sales].[SalesPerson]
 select [Sales].[SalesPerson].[BusinessEntityID], YEAR(QuotaDate), MONTH(QuotaDate), [Sales].[SalesPerson].SalesQuota from 
 [Sales].[SalesPersonQuotaHistory]Join [Sales].[SalesPerson]
 on [Sales].[SalesPersonQuotaHistory].[BusinessEntityID]=[Sales].[SalesPerson].[BusinessEntityID]
 Order By [Sales].[SalesPerson].[BusinessEntityID]
 