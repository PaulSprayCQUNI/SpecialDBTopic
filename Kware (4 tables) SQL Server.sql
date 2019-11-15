--*****************************************************************
--
-- Title:    KWare database creation script.
--
-- Platform: SQL Server
--
--*****************************************************************
--
------------------------ create database --------------------------------------
-- if database already exists, drop it...
USE master; 
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name='Kware') DROP DATABASE Kware; 
GO
CREATE DATABASE Kware;
GO
USE Kware;
GO
-- create Customer table...
CREATE TABLE Customer(
 CID             int           NOT NULL IDENTITY(1,1),
 Name            nvarchar(255) NOT NULL,
 Street          nvarchar(255) NOT NULL,
 Suburb          nvarchar(255) NOT NULL,
 State           nvarchar(255) NOT NULL,
 Postcode        smallint      NOT NULL,
 DiscountPercent real          NOT NULL DEFAULT 0,
 Email           nvarchar(255)     NULL,
 CONSTRAINT PKCustomer PRIMARY KEY (CID),
 CONSTRAINT CKCustomerState CHECK (State IN ('NSW','VIC','QLD','SA','WA','TAS','NT','ACT')),
 CONSTRAINT CKCustomerPostcode CHECK (Postcode>=0 AND (Len(Postcode) BETWEEN 3 AND 4)),
 CONSTRAINT CKCustomerDiscount CHECK (DiscountPercent BETWEEN 0 AND 100)
 );
-- create Product table...
CREATE TABLE Product(
 PID             int           NOT NULL IDENTITY(1,1),
 Code            char(9)       NOT NULL,
 Category        nvarchar(255) NOT NULL,
 Description     nvarchar(255) NOT NULL,
 Price           money         NOT NULL,
 NbrItemsInStock int           NOT NULL  DEFAULT 0,
 CONSTRAINT PKProduct PRIMARY KEY (PID),
 CONSTRAINT UKProductCode UNIQUE (Code),
 CONSTRAINT CKProductCategory CHECK (Category IN ('Glassware','Cookware')),
 CONSTRAINT CKProductPrice CHECK (Price>=0),
 CONSTRAINT CKProductNbrItemsInStock CHECK (NbrItemsInStock>=0)
);
-- create SalesOrder table...
CREATE TABLE SalesOrder(
 SOID            int           NOT NULL  IDENTITY(1,1),
 CID             int           NOT NULL, 
 [Number]        int           NOT NULL,
 [Date]          datetime      NOT NULL  DEFAULT GetDate(),
 FullPrice       money         NOT NULL  DEFAULT 0,
 Discount        money         NOT NULL  DEFAULT 0,
 FinalPrice      money         NOT NULL  DEFAULT 0,
 TotalPaid       money         NOT NULL  DEFAULT 0,
 Status          nvarchar(50)  NOT NULL  DEFAULT 'Open',
 CONSTRAINT PKSalesOrder PRIMARY KEY (SOID),
 CONSTRAINT FKSalesOrderCID FOREIGN KEY (CID) REFERENCES Customer(CID) ON DELETE NO ACTION ON UPDATE CASCADE,
 CONSTRAINT UKSalesOrderNumber UNIQUE ([Number]),
 CONSTRAINT CKSalesOrderNumber CHECK ([Number] BETWEEN 10000000 AND 99999999),
 CONSTRAINT CKSalesOrderFullPrice CHECK (FullPrice>=0),
 CONSTRAINT CKSalesOrderDiscount CHECK (Discount>=0),
 CONSTRAINT CKSalesOrderFinalPrice CHECK (FinalPrice>=0 AND FinalPrice=FullPrice-Discount),
 CONSTRAINT CKSalesOrderStatus CHECK (Status IN ('Open','Placed'))
 );
-- create SalesOrderProduct table...
CREATE TABLE SalesOrderProduct(
 SOPID              int    NOT NULL  IDENTITY(1,1),
 SOID               int    NOT NULL,
 PID                int    NOT NULL,
 ItemPrice          money  NOT NULL,
 NbrItemsRequested  int    NOT NULL,
 ExtendedPrice      money  NOT NULL,
 NbrItemsDispatched int    NOT NULL  DEFAULT 0,
 CONSTRAINT PKSalesOrderProduct PRIMARY KEY (SOPID),
 CONSTRAINT FKSalesOrderProductSOID FOREIGN KEY (SOID) REFERENCES SalesOrder(SOID) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT FKSalesOrderProductPID FOREIGN KEY (PID) REFERENCES Product(PID) ON DELETE NO ACTION ON UPDATE CASCADE,
 CONSTRAINT UKSalesOrderProduct UNIQUE (SOID,PID),
 CONSTRAINT CKSalesOrderProductItemPrice CHECK (ItemPrice>=0),
 CONSTRAINT CKSalesOrderProductNbrItemsRequested CHECK (NbrItemsRequested>0),
 CONSTRAINT CKSalesOrderProductExtendedPrice CHECK (ExtendedPrice>=0 AND ExtendedPrice=ItemPrice*NbrItemsRequested),
 CONSTRAINT CKSalesOrderProductNbrItemsDispatched CHECK (NbrItemsDispatched>=0)
);
GO
------------------ create ResetSampleData procedure ------------------
-- procedure: to generate/reset sample data 
--   written: MPG@CQUni, Feb 2010
CREATE PROCEDURE ResetSampleData
AS
BEGIN
  -- declare local variables...
  DECLARE @ThisYear varchar(4), @LastYear varchar(4);
  -- turn off row update reporting...
  SET NOCOUNT ON; 
  -- remove any existing rows...
  DELETE FROM SalesOrderProduct;
  DELETE FROM SalesOrder;
  DELETE FROM Product;
  DELETE FROM Customer;
  -- insert Customer rows...
  SET IDENTITY_INSERT Customer ON -- enable explicit insert of IDENTITY values
  INSERT INTO Customer(CID,Name,Street,Suburb,State,Postcode,DiscountPercent,Email) VALUES(1,'Best Kitchens','1 Beef Highway','Parkhurst','QLD',4702,10,'parkhurst@bestkitchens.com.au');
  INSERT INTO Customer(CID,Name,Street,Suburb,State,Postcode,DiscountPercent,Email) VALUES(2,'Best Kitchens','2 Rum Road','Bargara','QLD',4670,10,'bargara@bestkitchens.com.au');
  INSERT INTO Customer(CID,Name,Street,Suburb,State,Postcode,DiscountPercent,Email) VALUES(3,'Sheila Smith','3 Sugar Street','Andergrove','QLD',4740,0,'sheila.smith@freemail.com');
  INSERT INTO Customer(CID,Name,Street,Suburb,State,Postcode,DiscountPercent,Email) VALUES(4,'Samir Singh','4 River Road','Milton','QLD',4064,0,'samirsingh@umail.com');
  INSERT INTO Customer(CID,Name,Street,Suburb,State,Postcode,DiscountPercent,Email) VALUES(5,'Lee Chin','5 Harbour Close','Cremorne','NSW',2090,0,'lee.chin@freemail.com');
  INSERT INTO Customer(CID,Name,Street,Suburb,State,Postcode,DiscountPercent,Email) VALUES(6,'Bruce Jones','6 Bay Way','Elwood','VIC',3184,0,'bruce.jones@freemail.com');
  SET IDENTITY_INSERT Customer OFF -- disable explicit insert of IDENTITY values
  -- insert Product rows...
  SET IDENTITY_INSERT Product ON -- enable explicit insert of IDENTITY values
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(1,'BLLY00001','Cookware','Billy 2L Saucepan',63,4);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(2,'BLLY00002','Cookware','Billy 3L Saucepan',73,0);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(3,'BLLY00003','Cookware','Billy 4L Saucepan',93,5);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(4,'RAJA00001','Glassware','Raja Glass Decanter',120,0);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(5,'RAJA00002','Glassware','Raja Glass Goblet',75,6);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(6,'QIAN00001','Glassware','Qi Flutes (set of 6)',50,8);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(7,'QIAN00002','Glassware','Qi Wine Glasses (set of 6)',60,9);
  INSERT INTO Product(PID,Code,Category,Description,Price,NbrItemsInStock) VALUES(8,'QIAN00003','Glassware','Qi Glass Pitcher',39,3);
  SET IDENTITY_INSERT Product OFF -- disable explicit insert of IDENTITY values
  -- insert SalesOrder rows...
  SET IDENTITY_INSERT SalesOrder ON -- enable explicit insert of IDENTITY values
  SET @LastYear = CAST(Year(GetDate())-1 AS varchar(4));
  SET @ThisYear = CAST(Year(GetDate()) AS varchar(4));
  INSERT INTO SalesOrder(SOID,CID,[Number],[Date],FullPrice,Discount,FinalPrice,TotalPaid,Status) VALUES(1,1,10000001,@LastYear + '-12-23',1374.00,137.40,1236.60,1236.60,'Placed');
  INSERT INTO SalesOrder(SOID,CID,[Number],[Date],FullPrice,Discount,FinalPrice,TotalPaid,Status) VALUES(2,2,10000002,@ThisYear + '-01-10',220.00,22.00,198.00,198.00,'Placed');
  INSERT INTO SalesOrder(SOID,CID,[Number],[Date],FullPrice,Discount,FinalPrice,TotalPaid,Status) VALUES(3,1,10000003,@ThisYear + '-01-13',1260.00,126.00,1134.00,1134.00,'Placed');
  INSERT INTO SalesOrder(SOID,CID,[Number],[Date],FullPrice,Discount,FinalPrice,TotalPaid,Status) VALUES(4,3,10000004,@ThisYear + '-01-17',48.00,0.00,48.00,48.00,'Placed');
  INSERT INTO SalesOrder(SOID,CID,[Number],[Date],FullPrice,Discount,FinalPrice,TotalPaid,Status) VALUES(5,4,10000005,@ThisYear + '-01-17',0.00,0.00,0.00,0.00,'Open');
  SET IDENTITY_INSERT SalesOrder OFF -- disable explicit insert of IDENTITY values
  -- insert SalesOrderProduct rows...
  SET IDENTITY_INSERT SalesOrderProduct ON -- enable explicit insert of IDENTITY values
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(1,1,1,6,6,63,378.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(2,1,2,6,2,73,438.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(3,1,3,6,6,93,558.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(4,2,6,2,2,50,100.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(5,2,7,2,2,60,120.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(6,3,5,12,12,75,900.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(7,3,4,3,1,120,360.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(8,4,5,4,4,12,48.00);
  INSERT INTO SalesOrderProduct(SOPID,SOID,PID,NbrItemsRequested,NbrItemsDispatched,ItemPrice,ExtendedPrice) VALUES(9,5,1,1,0,63,63);
  SET IDENTITY_INSERT SalesOrderProduct OFF -- disable explicit insert of IDENTITY values
  -- turn on row update reporting...
  SET NOCOUNT OFF 
END
------------ end of ResetSampleData procedure ------------
GO
--  insert sample data...
EXECUTE ResetSampleData;
