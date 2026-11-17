--*************************************************************************--
-- Title: Assignment06
-- Author: NhanPhan
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-11-12,NhanPhan,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_NhanPhan')
	 Begin 
	  Alter Database [Assignment06DB_NhanPhan] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_NhanPhan;
	 End
	Create Database Assignment06DB_NhanPhan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_NhanPhan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

---- Step 1.1 Create view for Categories table 
go

CREATE VIEW vCategories
WITH SCHEMABINDING 
AS
	SELECT 
		CategoryID,
		CategoryName
	FROM dbo.Categories;

---- Step 1.2 Create view for Products table 
go

CREATE VIEW vProducts
WITH SCHEMABINDING 
AS
	SELECT 
		ProductID,
		ProductName,
		CategoryID,
		UnitPrice
	FROM dbo.Products;


---- Step 1.3 Create view for Employees table 
go  

CREATE VIEW vEmployees 
WITH SCHEMABINDING
AS 
	SELECT 
		EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
	FROM dbo.Employees;

---- Step 1.4 Create view for Inventories table 
go

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT
		InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		Count
	FROM dbo.Inventories;



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
go

DENY SELECT ON Categories to PUBLIC;
DENY SELECT ON Products to PUBLIC;
DENY SELECT ON Employees to PUBLIC;
DENY SELECT ON Inventories to PUBLIC;

GRANT SELECT ON vCategories to PUBLIC;
GRANT SELECT ON vProducts to PUBLIC;
GRANT SELECT ON vEmployees to PUBLIC;
GRANT SELECT ON vInventories to PUBLIC;



-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
---- Step 3.1 get list of category name from the view of Categories
-- SELECT CategoryName from vCategories;

---- Step 3.2 get list of product name and unit price from the view of Products
-- SELECT 
-- 	ProductName,
-- 	UnitPrice
-- FROM vProducts;

---- Step 3.3 joining the result of step 3.1 and 3.2 
---- order result by CategoryName and ProductName
-- SELECT TOP 
-- 		[CategoryName] = vc.CategoryName,
-- 		[ProductName] = vp.ProductName,
-- 		[UnitPrice] = vp.UnitPrice
-- 	FROM vCategories as vc  
-- 	JOIN vProducts as vp  
-- 	ON vc.CategoryID = vp.CategoryID
-- 	ORDER BY CategoryName, ProductName;

---- Step 3.4 create view from step 3.3 results
go  
CREATE VIEW vProductsByCategories
AS 
	SELECT TOP 10000000
		[CategoryName] = vc.CategoryName,
		[ProductName] = vp.ProductName,
		[UnitPrice] = vp.UnitPrice
	FROM vCategories as vc  
	JOIN vProducts as vp  
	ON vc.CategoryID = vp.CategoryID
	ORDER BY CategoryName, ProductName;
go  




-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

---- step 4.1 list the columns and tables that we want 
-- SELECT ProductName from vProducts;
-- SELECT 
-- 	InventoryDate,
-- 	Count
-- FROM vInventories;

---- step 4.2 Joint the results from step 4.1 by ProductID 

-- SELECT 
-- 	[ProductName] = vp.ProductName,
-- 	[InventoryDate] = vi.InventoryDate,
-- 	[Count] = vi.count 
-- FROM vProducts AS vp 
-- JOIN vInventories AS vi 
-- ON vp.ProductID = vi.ProductID
-- ORDER BY ProductName, InventoryDate, Count;

---- step 4.3 create view using results of step 4.2 and order the result by Product, Date, and Count
go  

CREATE VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 10000000
		[ProductName] = vp.ProductName,
		[InventoryDate] = vi.InventoryDate,
		[Count] = vi.count 
	FROM vProducts AS vp 
	JOIN vInventories AS vi 
	ON vp.ProductID = vi.ProductID
	ORDER BY ProductName, InventoryDate, Count
	;

go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

---- step 5.1 list the columns and tables we want
-- SELECT InventoryDate FROM vInventories;
-- SELECT 
-- 	EmployeeFirstName,
-- 	EmployeeLastName
-- FROM vEmployees;

---- step 5.2 join step 5.1 tables and columns using EmployeeID 
---- concatinating EmployeeFirstName and EmployeeLastName to Column EmployeeName
---- also use GROUP BY to make sure it return one row per date
---- and order the results by Date

-- SELECT 
-- 	[InventoryDate] = vi.InventoryDate,
-- 	[EmployeeName] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
-- FROM vInventories as vi  
-- JOIN vEmployees as ve
-- ON vi.EmployeeID = ve.EmployeeID
-- GROUP BY vi.InventoryDate, ve.EmployeeFirstName, ve.EmployeeLastName
-- ORDER BY [InventoryDate];


---- step 5.3 create view using results of step 5.2 
go  
CREATE VIEW vInventoriesByEmployeesByDates
AS 
	SELECT TOP 10000000
		[InventoryDate] = vi.InventoryDate,
		[EmployeeName] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
	FROM vInventories as vi  
	JOIN vEmployees as ve
	ON vi.EmployeeID = ve.EmployeeID
	GROUP BY vi.InventoryDate, ve.EmployeeFirstName, ve.EmployeeLastName
	ORDER BY [InventoryDate];
go  



-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

---- step 6.1 List the columns and tables we want
-- SELECT CategoryName FROM vCategories;
-- SELECT ProductName FROM vPRoducts;
-- SELECT 
-- 	InventoryDate,
-- 	Count
-- FROM vInventories;

---- step 6.2 join the columns and tables from step 6.1 by CategoryID and ProductID 
---- order the Order the results from by Category, Product, Date, and Count

-- SELECT 
-- 	[CategoryName] = vc.CategoryName,
-- 	[ProductName] = vp.ProductName,
-- 	[InventoryDate] = vi.InventoryDate,
-- 	[Count] = vi.Count  
-- FROM vCategories as vc  
-- JOIN vProducts as vp 
-- ON vc.CategoryID = vp.CategoryID
-- JOIN vInventories as vi 
-- ON vp.ProductID = vi.ProductID
-- ORDER BY CategoryName, ProductName, InventoryDate, Count;

---- step 6.3 create view using with results from step 6.3 
go  
CREATE VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 10000000
		[CategoryName] = vc.CategoryName,
		[ProductName] = vp.ProductName,
		[InventoryDate] = vi.InventoryDate,
		[Count] = vi.Count  
	FROM vCategories as vc  
	JOIN vProducts as vp 
	ON vc.CategoryID = vp.CategoryID
	JOIN vInventories as vi 
	ON vp.ProductID = vi.ProductID
	ORDER BY CategoryName, ProductName, InventoryDate, Count;
go  



-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

---- step 7.1 list out the columns and tables we need
-- SELECT CategoryName FROM vCategories;
-- SELECT ProductName FROM vPRoducts;
-- SELECT 
-- 	InventoryDate,
-- 	Count
-- FROM vInventories;
-- SELECT 
-- 	EmployeeFirstName,
-- 	EmployeeLastName
-- FROM vEmployees;

---- step 7.2 join the columns and tables from step 7.1 
---- by CategoryID, ProductID, and EmployeeID
---- order by Inventory Date, Category, Product and Employee
-- SELECT  
-- 	[CategoryName] = vc.CategoryName,
-- 	[ProductName] = vp.ProductName,
-- 	[InventoryDate] = vi.InventoryDate,
-- 	[Count] = vi.Count,  
-- 	[EmployeeName] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
-- FROM vCategories as vc  
-- JOIN vProducts as vp 
-- ON vc.CategoryID = vp.CategoryID
-- JOIN vInventories as vi 
-- ON vp.ProductID = vi.ProductID
-- JOIN vEmployees as ve 
-- ON vi.EmployeeID = ve.EmployeeID
-- ORDER BY [InventoryDate], [CategoryName], [ProductName], [EmployeeName];


---- step 7.3 create the view from step 7.2 results
go   
CREATE VIEW vInventoriesByProductsByEmployees
AS
	SELECT TOP 10000000
		[CategoryName] = vc.CategoryName,
		[ProductName] = vp.ProductName,
		[InventoryDate] = vi.InventoryDate,
		[Count] = vi.Count,  
		[EmployeeName] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
	FROM vCategories as vc  
	JOIN vProducts as vp 
	ON vc.CategoryID = vp.CategoryID
	JOIN vInventories as vi 
	ON vp.ProductID = vi.ProductID
	JOIN vEmployees as ve 
	ON vi.EmployeeID = ve.EmployeeID
	ORDER BY [InventoryDate], [CategoryName], [ProductName], [EmployeeName];
go


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

---- step 8.1 use results of 7.2 and add WHERE condtion to check 
---- ProductID in the list of ProductName is either 'Chai' or Chang
---- and order by Inventory Date, Category, Product and Employee

-- SELECT 
-- 	[CategoryName] = vc.CategoryName,
-- 	[ProductName] = vp.ProductName,
-- 	[InventoryDate] = vi.InventoryDate,
-- 	[Count] = vi.Count,  
-- 	[EmployeeName] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
-- FROM vCategories as vc  
-- JOIN vProducts as vp 
-- ON vc.CategoryID = vp.CategoryID
-- JOIN vInventories as vi 
-- ON vp.ProductID = vi.ProductID
-- JOIN vEmployees as ve 
-- ON vi.EmployeeID = ve.EmployeeID
-- WHERE vp.ProductID in (
-- 	SELECT ProductID 
-- 	FROM Products
-- 	WHERE ProductName = 'Chai' OR ProductName = 'Chang'
-- )
-- ORDER BY [InventoryDate], [CategoryName], [ProductName], [EmployeeName];


---- step 8.2 create the view using results of step 8.1
go 
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT TOP 10000000
		[CategoryName] = vc.CategoryName,
		[ProductName] = vp.ProductName,
		[InventoryDate] = vi.InventoryDate,
		[Count] = vi.Count,  
		[EmployeeName] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
	FROM vCategories as vc  
	JOIN vProducts as vp 
	ON vc.CategoryID = vp.CategoryID
	JOIN vInventories as vi 
	ON vp.ProductID = vi.ProductID
	JOIN vEmployees as ve 
	ON vi.EmployeeID = ve.EmployeeID
	WHERE vp.ProductID in (
		SELECT ProductID 
		FROM Products
		WHERE ProductName = 'Chai' OR ProductName = 'Chang'
	)
	ORDER BY [InventoryDate], [CategoryName], [ProductName], [EmployeeName];
go  



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

---- Step 9.1 get list of Employee names 
-- SELECT 
-- 	EmployeeFirstName,
-- 	EmployeeLastName
-- FROM vEmployees;

---- Step 9.2 get list of employeeid an d managerid 
-- SELECT 
-- 	EmployeeID,
-- 	ManagerID
-- FROM vEmployees;


---- step 9.3 self join view vEmployees to get the list of Manager and Employee who report to them
---- and order the results by the Manager's name

-- SELECT 
-- 	[Manager] = veM.EmployeeFirstName + ' ' + veM.EmployeeLastName,
-- 	[Employee] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
-- FROM vEmployees as veM
-- JOIN vEmployees as ve  
-- ON veM.EmployeeID = ve.ManagerID
-- ORDER BY [Manager], [Employee]; 

---- step 9.4 create view from results of step 9.3
go
CREATE VIEW vEmployeesByManager
AS 
	SELECT TOP 10000000
		[Manager] = veM.EmployeeFirstName + ' ' + veM.EmployeeLastName,
		[Employee] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName
	FROM vEmployees as veM
	JOIN vEmployees as ve  
	ON veM.EmployeeID = ve.ManagerID
	ORDER BY [Manager], [Employee]; 
go



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.


---- step 10.1 List out the columns and the views we want
	-- [CategoryID] from vCategories
	-- [CategoryName] from vCategories
	-- [ProductID] from vProducts
	-- [ProductName] from vProducts
	-- [UnitPrice] from vProducts
	-- [InventoryID] from vInventories
	-- [InventoryDate] from vInventories
	-- [Count] from vInventories
	-- [EmployeeID] from vEmployees
	-- [Employee] = EmployeeFirstName + ' ' + EmployeeLastName from vEmployees
	-- [Manager] = EmployeeFirstName + ' ' + EmployeeLastName from vEmployees

---- step 10.2 join columns in step 10.1 by
---- categoryID, productID, employeeID, managerID
---- and  order the results by Category, Product, InventoryID, and Employee.
-- SELECT 
-- 	[CategoryID] = vc.CategoryID,
-- 	[CategoryName] = vc.CategoryName,
-- 	[ProductID] = vp.ProductID,
-- 	[ProductName] = vp.ProductName,
-- 	[UnitPrice] = vp.UnitPrice,
-- 	[InventoryID] = vi.InventoryID,
-- 	[InventoryDate] = vi.InventoryDate,
-- 	[Count] = vi.Count,
-- 	[EmployeeID] = ve.EmployeeID,
-- 	[Employee] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName,
-- 	[Manager] = veM.EmployeeFirstName + ' ' + veM.EmployeeLastName
-- FROM vCategories as vc
-- JOIN vProducts as vp
-- ON vc.CategoryID = vp.CategoryID
-- JOIN vInventories as vi  
-- ON vi.ProductID = vp.ProductID
-- JOIN vEmployees as ve
-- ON ve.EmployeeID = vi.EmployeeID
-- JOIN vEmployees as veM  
-- ON veM.EmployeeID = ve.ManagerID
-- ORDER BY [CategoryName], [ProductName], [InventoryID], [Employee];


---- step 10.3 create the view from results of step 10.2 
go
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT TOP 10000000
		[CategoryID] = vc.CategoryID,
		[CategoryName] = vc.CategoryName,
		[ProductID] = vp.ProductID,
		[ProductName] = vp.ProductName,
		[UnitPrice] = vp.UnitPrice,
		[InventoryID] = vi.InventoryID,
		[InventoryDate] = vi.InventoryDate,
		[Count] = vi.Count,
		[EmployeeID] = ve.EmployeeID,
		[Employee] = ve.EmployeeFirstName + ' ' + ve.EmployeeLastName,
		[Manager] = veM.EmployeeFirstName + ' ' + veM.EmployeeLastName
	FROM vCategories as vc
	JOIN vProducts as vp
	ON vc.CategoryID = vp.CategoryID
	JOIN vInventories as vi  
	ON vi.ProductID = vp.ProductID
	JOIN vEmployees as ve
	ON ve.EmployeeID = vi.EmployeeID
	JOIN vEmployees as veM  
	ON veM.EmployeeID = ve.ManagerID
	ORDER BY [CategoryName], [ProductName], [InventoryID], [Employee];
go



-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/