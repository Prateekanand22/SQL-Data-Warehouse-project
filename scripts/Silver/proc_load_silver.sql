/*
==============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;

==============================================================================
*/
create or alter procedure silver.load_silver as
begin
    declare @start_time datetime, @end_time datetime , @batch_start_time datetime, @batch_end_time datetime;
    begin try
        set @batch_start_time = GETDATE();
        print '====================================='
        print 'loading silver layer';
        print '====================================='

        print'______________________________________'
        print'loading CRM Tables';
        print'--------------------------------------'

        --loading silver.crm_cust_info
        
print '>> truncating table:silver.crm_cust_info';
truncate table silver.crm_cust_info;
print '>> inserting data ito:silver.crm_cust_info';
INSERT INTO silver.crm_cust_info(
     cst_id,
     cst_key,
     cst_firstname,
     cst_lastname,
     cst_material_status,
     cst_gndr,
     cst_create_date
)

SELECT
   cst_id,
   cst_key,
   TRIM(cst_firstname) AS cst_firstname,
   TRIM(cst_lastname) AS cst_lastname,
   case
      when upper(trim (cst_marital_status)) = 'S' then 'Single' --we are giving a finished looked to the column
      when upper(trim (cst_marital_status)) = 'M' then 'Married' --of marital status
   Else 'n/a' --here instead of NULL we added a not available value
 END cst_marital_status,
   case
      when upper(trim (cst_gndr)) = 'F' then 'Female'-- here we are again giving a finished
      when upper(trim (cst_gndr)) = 'M' then 'Male'-- look to the gndr column
   Else 'n/a'
 end cst_gndr,
cst_create_date
FROM
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY cst_id    -- In this code of window function we are removing the duplicate rows
ORDER BY cst_create_date DESC
) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;


print '>> inserting data ito:silver.crm_sale_details';
truncate table silver.crm_sale_details;
print '>> inserting data into: silver.crm_sale_details';
insert into silver.crm_sale_details(
    sls_ord_num, 
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
select
sls_ord_num,
sls_prd_key,
sls_cust_id,

CASE
    WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END,

CASE
    WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END,

CASE
    WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END,

CASE
    WHEN sls_sales IS NULL
         OR sls_sales <= 0
         OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END,

sls_quantity,

CASE
    WHEN sls_price IS NULL
         OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price
END
FROM bronze.crm_sales_details;


print '>> truncating table:silver.crm_prd_info';
truncate table silver.crm_prd_info;
print '>> inserting data ito:silver.crm_prd_info';
INSERT INTO silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt,
    dwh_create_date
)

SELECT prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','') AS cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
prd_nm,

ISNULL(prd_cost,0) AS prd_cost,

CASE UPPER(TRIM(prd_line))
    WHEN 'M' THEN 'Mountain'
    WHEN 'R' THEN 'Road'
    WHEN 'S' THEN 'Other Sales'
    WHEN 'T' THEN 'Touring'
    ELSE 'n/a'
END AS prd_line,

CAST(prd_start_dt AS DATE) AS prd_start_dt,

CAST(
    LEAD(prd_start_dt)
    OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1
    AS DATE
) AS prd_end_dt,

GETDATE() AS dwh_create_date
FROM bronze.crm_prd_info;



print '>> truncating table:silver.erp_CUST_AZ12';
truncate table silver.erp_CUST_AZ12;
print '>> inserting data ito:silver.erp_CUST_AZ12';
insert into silver.erp_CUST_AZ12 (cid, bdate, gen)
select
case
when cid like 'NAS%' then substring(cid, 4 , len(cid)) -- remove 'NAS' prefix if present
else cid
end as cid,
case
when bdate > getdate() then null
else bdate
end as bdate,-- set future birthdates to null
case
when upper (trim(gen)) in ('F', 'FEMALE') then 'Female'
when upper (trim(gen)) in ('M', 'MALE') then 'Male'
else 'n/a'
end as gen -- normalize gender values and handle unkown cases
from bronze.erp_CUST_AZ12



print '>> truncating table:silver.erp_loc_a101';
truncate table silver.erp_loc_a101;
print '>> inserting data ito:silver.erp_loc_a101';
insert into silver.erp_loc_a101
(cid, cntry)
select
replace(cid,'-', '') cid,
case when trim(cntry) = 'DE' then 'Germnay'
when trim(cntry) in ('US', 'USA') then 'United States'
when trim(cntry) = '' or cntry is null then 'n/a'
else trim(cntry)
end as cntry
from bronze.erp_loc_a101


print '>> truncating table:silver.PX_CAT_G1V2';
truncate table silver.PX_CAT_G1V2;
print '>> inserting data ito:silver.PX_CAT_G1V2';
insert into silver.PX_CAT_G1V2
(id, cat, subcat,maintenance)
select
id,
cat,
subcat,
maintenance
from bronze.PX_CAT_G1V2

--check for unwanted spaces
select * from bronze.PX_CAT_G1V2
where cat!= trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance)
--data standardization & consistency
select distinct
maintenance
from bronze.PX_CAT_G1V2;

select 
* 
from silver.PX_CAT_G1V2;

end try
BEGIN CATCH
    print'============================================'
    print'error occured during loading bronze layer'
    print'error message' + ERROR_MESSAGE();
    print'error message' + CAST (ERROR_NUMBER() AS NVARCHAR);
    print'error message' + CAST (ERROR_STATE() AS NVARCHAR);
    END CATCH
end
