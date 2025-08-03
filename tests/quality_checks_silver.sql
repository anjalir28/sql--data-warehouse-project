
/*
=============================================================================================
Quality Checks
=============================================================================================
Script Purpose:
    This scriptt performs various quality checks for data consistency, accuracy, and 
    standardization across the 'silver' schemas. It includes checks for:
   - Null or duplicate primary keys.
   - Unwanted spaces in string fields.
   - Data Standardization and consistency.
   - Invalid date ranges and orders.
   - Data Consistency between related fields.

Usage Notes:
   - Run these checks after data loading Silver Layer.
   - Investigate and resolve any discrepencies found during the checks.
================================================================================================
*/

-- =============================================================================
-- Checking 'silver.crm_cust_info'
-- =============================================================================

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
  cst_id,
  COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Checks for Unwanted Spaces
-- Expectation: No Results
SELECT 
  cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
   cst_marital_status
FROM silver.crm_cust_info;

-- =============================================================================
-- Checking 'silver.crm_prd_info'
-- =============================================================================
-- Check for nulls and Duplicates in Primary Key
-- Expectation:No Result
SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted Spaces
-- Expectations: No Results
 SELECT 
   prd_nm
 FROM silver.crm_prd_info
 WHERE prd_nm != TRIM(prd_nm);

--- Check For Nulls or Negative Values in Cost
--- Expectation: No Results
SELECT 
  prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--- Data Standardization & Consistency 
SELECT DISTINCT 
    prd_line
FROM silver.crm_prd_info

-- Check for Invalid Dates Orders (Start date > End Date)
-- Expectation: No Results
SELECT
  *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =============================================================================
-- Checking 'silver.crm_sales_details'
-- =============================================================================
 -- Check for Invalid Dates 
-- Expectation: No Results 
SELECT 
      NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
      OR LEN(sls_order_dt) != 8
      OR sls_order_dt > 20500101
      OR sls_order_dt < 19000101;

--Check for Invalid Dates Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results 
SELECT 
* 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
  OR sls_order_dt > sls_due_dt;


-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, Zero, Or negative.

SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
  OR sls_sales IS NULL 
  OR sls_quantity IS NULL 
  OR sls_price IS NULL
  OR sls_sales <= 0 
  OR sls_quantity <= 0 
  OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =============================================================================
-- Checking 'silver.erp_cust_az12'
-- =============================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT
  gen
FROM silver.erp_cust_az12;

-- =============================================================================
-- Checking 'silver.erp_loc_a101'
-- =============================================================================
-- Data Standardization & Consistency 

SELECT DISTINCT 
  cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =============================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =============================================================================
-- Checks for Unwanted Spaces
-- Expectation: No Results

SELECT 
  * 
FROM 
  silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
  OR subcat != TRIM(subcat) 
  OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT
  maintenance
FROM silver.erp_px_cat_g1v2;

