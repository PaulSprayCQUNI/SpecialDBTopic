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
 -- DELETE FROM SalesOrderProduct;
 -- DELETE FROM SalesOrder;
 -- DELETE FROM Product;
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
  
  -- turn on row update reporting...
  SET NOCOUNT OFF 
END
------------ end of ResetSampleData procedure ------------
GO
--  insert sample data...
EXECUTE ResetSampleData;
