/*
======================================================
DDL Script: Create Bronze Tables
======================================================
Script Purpose
    This script creates Tables in the 'bronze' schema, dropping existing tables
    if they already exist.
    run this script to re-define the DDL structure of 'bronze' tables
========================================================    
*/

IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
   DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE [Bronze].[crm_cust_info](
	[cst_id] [int] NULL,
	[cst_key] [nvarchar](50) NULL,
	[cst_firstname] [nvarchar](50) NULL,
	[cst_lastname] [nvarchar](50) NULL,
	[cst_material_status] [nvarchar](50) NULL,
	[cst_gndr] [nvarchar](50) NULL,
	[cst_create_date] [date] NULL
);
GO

IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL
   DROP TABLE bronze.crm_prd_info;
GO   

CREATE TABLE [Bronze].[crm_prd_info](
	[prd_id] [int] NULL,
	[prd_key] [nvarchar](50) NULL,
	[prd_nm] [nvarchar](50) NULL,
	[prd_cost] [int] NULL,
	[prd_line] [nvarchar](50) NULL,
	[prd_start_dt] [datetime] NULL,
	[prd_end_dt] [datetime] NULL
) ON [PRIMARY]
GO

IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
   DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE [Bronze].[crm_sales_details](
	[sls_ord_num] [nvarchar](50) NULL,
	[sls_prd_key] [nvarchar](50) NULL,
	[sls_cust_id] [int] NULL,
	[sls_order_dt] [int] NULL,
	[sls_ship_dt] [int] NULL,
	[sls_due_dt] [int] NULL,
	[sls_sales] [int] NULL,
	[sls_quantity] [int] NULL,
	[sls_price] [int] NULL
) ON [PRIMARY]
GO

IF OBJECT_ID('bronze.erp_CUST_AZ12','U') IS NOT NULL
   DROP TABLE bronze.erp_CUST_AZ12;
GO
CREATE TABLE [Bronze].[erp_CUST_AZ12](
	[CID] [nvarchar](50) NULL,
	[BDATE] [date] NULL,
	[GEN] [nvarchar](50) NULL
) ON [PRIMARY]
GO

IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
   DROP TABLE bronze.erp_loc_a101;
   
GO
CREATE TABLE [Bronze].[erp_loc_a101](
	[CID] [nvarchar](50) NULL,
	[cntry] [nvarchar](50) NULL
) ON [PRIMARY]
GO

IF OBJECT_ID('bronze.PX_CAT_G1V2','U') IS NOT NULL
   DROP TABLE bronze.PX_CAT_G1V2;
   
GO
CREATE TABLE [Bronze].[PX_CAT_G1V2](
	[ID] [nvarchar](50) NULL,
	[CAT] [nvarchar](50) NULL,
	[SUBCAT] [nvarchar](50) NULL,
	[Maintenance] [nvarchar](50) NULL
) ON [PRIMARY]
GO
























