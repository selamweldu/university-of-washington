
use [AdventureWorks2012]
go
DECLARE @DateTimeTest TABLE
(
TestDateTime DATETIME
)

INSERT INTO @DateTimeTest VALUES ('2017-04-10 00:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-10 04:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-10 08:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-10 12:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-10 16:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-10 20:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-11 00:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-11 04:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-11 08:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-11 12:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-11 16:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-11 20:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-12 00:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-12 04:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-12 08:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-12 12:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-12 16:00:00')
INSERT INTO @DateTimeTest VALUES ('2017-04-12 20:00:00')

SELECT [TestDateTime]
FROM @DateTimeTest
WHERE TestDateTime NOT IN('2017-04-10 00:00:00', '2017-04-11 00:00:00','2017-04-12 00:00:00')
-- question2
select ProductID from [Production].[Product] where color IS NULL
-- question3
select ProductID, ISNULL(Color,'undefined color') from [Production].[Product]
--question4
select  YEAR(ModifiedDate) as Year ,DATEPART(QUARTER,ModifiedDate) as quarter ,SUM(LineTotal) as Sale 
from [Sales].[SalesOrderDetail]
Group By YEAR(ModifiedDate),DATEPART(QUARTER,ModifiedDate)
order by YEAR(ModifiedDate),DATEPART(QUARTER,ModifiedDate)
--question5
DECLARE @summaryofquarterlysale TABLE
(
[YEAR] int,
[quarter] int,
sale money
)
INSERT INTO @summaryofquarterlysale ([YEAR],[quarter],sale)
select  YEAR(ModifiedDate),DATEPART(QUARTER,ModifiedDate) as quarter ,SUM(LineTotal) as Sale 
from [Sales].[SalesOrderDetail]
Group By YEAR(ModifiedDate),DATEPART(QUARTER,ModifiedDate)
order by YEAR(ModifiedDate),DATEPART(QUARTER,ModifiedDate)
select * from @summaryofquarterlysale
--self join
DECLARE @BASEYEAR INT = 2005
select c.[year] as currentquarteryear, c.[quarter] as currentquarter, c.sale as currentquartersale, 
p.[year] as previousquarteryear, p.[quarter] as previousquarter, p.sale as prevousquartersale,
 (c.sale/p.sale) * 100 as saleperformancePCT
from @summaryofquarterlysale as c JOIN @summaryofquarterlysale as p 
ON c.[year] = p.[YEAR] and c.[quarter] = p.[quarter] + 1
 or c.[year]-1 = p.[year] and c.[quarter] = 1 and p.[quarter]=4
order by c.[YEAR], c.[quarter] 
--question 6 
 use AdventureWorks2012
 go 
 CREATE PROCEDURE updatingProduct
  @ProductID INT ,
  @ProductSubcategoryID INT,
  @ProductCategoryID INT,
  @CostChange  FLOAT
  AS

 BEGIN TRANSACTION 
 -- 1) Update and close old cost in [Production].[ProductCostHistory] --   !>
  --How can you be sure you are updating only the last entry inthe history table?
--<! Getting the last entry from the history
 SELECT [ProductID], MAX([StartDate]) [Last Entry] --, COUNT(*) [Entries] 
 FROM [Production].[ProductCostHistory] 
 WHERE [ProductID] = @ProductID GROUP BY [ProductID]


UPDATE [H] 
SET [H].[EndDate] = GETDATE(), [H].[ModifiedDate] = GETDATE() 
FROM [Production].[ProductCostHistory] AS [H]
    JOIN (
	SELECT [ProductID], MAX([StartDate]) [Last Entry] --, COUNT(*) [Entries] 
FROM [Production].[ProductCostHistory] 
WHERE [ProductID] = @ProductID GROUP BY [ProductID]
	) AS [LE] 
    ON [LE].[ProductID] = [H].[ProductID] AND [LE].[Last Entry] = [H]. [StartDate]



  -- 2)Insert new cost history in [Production].[ProductCostHistory] 
  -- (this should be easy, becausethere's only one (1) row to add... as you're dealing with one (1) [ProductID])
   INSERT INTO [Production].[ProductCostHistory] ([ProductID], [StartDate], [EndDate], [StandardCost], [ModifiedDate])
   SELECT [ProductID], GETDATE(), NULL, (1 + @CostChange/100.0) * [StandardCost], GETDATE() 
   FROM [Production].[Product] 
   WHERE [ProductID] = @ProductID

   -- 3)Update the cost in [Production].[Product] 


UPDATE [P] SET [StandardCost] = (1 + @CostChange/100.0) * [StandardCost]  , [ModifiedDate] = GETDATE() 
FROM [Production].[Product] [P] WHERE [ProductID] = @ProductID or [ProductSubcategoryID]=@ProductSubcategoryID

UPDATE [P] SET [ModifiedDate] = GETDATE() 
FROM [Production].[ProductCategory] [P] WHERE [ProductCategoryID] = @ProductCategoryID



SELECT * FROM [Production].[ProductCostHistory] WHERE [ProductID] = @ProductID
SELECT * FROM [Production].[Product] WHERE [ProductID] = @ProductID
SELECT * FROM [Production].[ProductCategory] WHERE [ProductCategoryID] = @ProductCategoryID
ROLLBACK
 

GO

EXECUTE updatingProduct 771,1,1,5.5
 -- question7
 use AdventureWorks2012
Go

DECLARE @SampleSize FLOAT = 50
DECLARE @FilterValue FLOAT
DECLARE @TableSize FLOAT
-- > assigning values to variables
SELECT @TableSize = COUNT(*) 
 FROM [Sales].[SalesOrderDetail]  
SELECT @FilterValue = (@SampleSize / @TableSize) * 2 

DECLARE @account INT
 SET @account=0

 WHILE @account <100
 BEGIN 
 SELECT TOP 50 [SalesOrderID], [SalesOrderDetailID]
FROM [Sales].[SalesOrderDetail]
WHERE cast((checksum(newid(),[SalesOrderID], [SalesOrderDetailID]) & 0x7fffffff) as float)/cast((checksum(newid(),
[SalesOrderDetailID]) & 0x7fffffff) as int) < @FilterValue
ORDER BY cast((checksum(newid(),[SalesOrderID], [SalesOrderDetailID]) & 0x7fffffff) as float)/cast(0x7fffffff as int)
  SET @account= @account +1
END

 


