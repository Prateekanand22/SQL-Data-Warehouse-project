/*
Create Database and schemas

script Purpose: This script creates a new 'database' after checking if it already exists.
if the database exists , it is dropped and recreated. Additionally,the script sets up three schemas
within the database: 'Bronze' , 'Silver', and 'Gold'

WARNING:
    Running this script will drop the entire 'DataWarehouse ' database if it exists.
    All data in the database will be permanetly deleted. Proceed with caution
    and ensure you have proper backups before running this script.
    */

USE master;
GO

--Drop and recreate the 'dataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name= 'DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
     DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' database

CREATE DATABASE Datawarehouse;

USE Datawarehouse;
go

--Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
go
