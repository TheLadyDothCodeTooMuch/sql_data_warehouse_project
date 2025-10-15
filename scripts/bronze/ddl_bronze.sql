-- Description:  Stored procedure to perform a full refresh of the bronze layer tables from CRM and ERP source CSV files. 
--               This procedure can be safely run multiple times. It first truncates each target table to remove all existing
--               data, then performs a bulk insert from the corresponding CSV file.
--
-- Features:
--   * Error Handling: Uses a TRY...CATCH block to gracefully handle any failures
--     during the load process and reports the specific error message.
--   * Logging: Provides real-time progress updates and load duration for each table.
--
-- Usage:
--   EXEC bronze.load_bronze;
--
-- IMPORTANT PREREQUISITE:
--   This script assumes the source CSV files are located in specific folders
--   (e.g., \source_crm, \source_erp) at the root of the drive where the
--   SQL Server service is running (e.g., C:\source_crm\cust_info.csv).
--   Ensure these folders and files exist before execution.


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Declare variables for measuring the duration of each load operation.
    DECLARE @start_time DATETIME, @end_time DATETIME;

    -- Use a TRY...CATCH block for robust error handling. If any statement
    -- within the TRY block fails, execution will jump to the CATCH block.
    BEGIN TRY

        PRINT '=====================';
        PRINT 'Loading Bronze Layer';
        PRINT '=====================';

        PRINT '----------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '\source_crm\cust_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            -- Skip the header row in the CSV file
            FIRSTROW = 2,
            -- TABLOCK is used to improve bulk insert performance by acquiring a table-level lock
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' secs';


        SET @start_time = GETDATE();
        PRINT '>> Truncating Table bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '\source_crm\prd_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            -- Skip the header row in the CSV file
            FIRSTROW = 2,
            -- TABLOCK is used to improve bulk insert performance by acquiring a table-level lock
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' secs';

        
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '\source_crm\sales_details.csv'
        WITH (
            FIELDTERMINATOR = ',',
            -- Skip the header row in the CSV file
            FIRSTROW = 2,
            -- TABLOCK is used to improve bulk insert performance by acquiring a table-level lock
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' secs';


        SET @start_time = GETDATE();
        PRINT '----------------------';
        PRINT 'Loading ERP Tables';
        PRINT '----------------------';

        PRINT '>> Truncating Table bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM '\source_erp\CUST_AZ12.csv'
        WITH (
            FIELDTERMINATOR = ',',
            -- Skip the header row in the CSV file
            FIRSTROW = 2,
            -- TABLOCK is used to improve bulk insert performance by acquiring a table-level lock
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' secs';


        SET @start_time = GETDATE();
        PRINT '>> Truncating Table bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '\source_erp\LOC_A101.csv'
        WITH (
            FIELDTERMINATOR = ',',
            -- Skip the header row in the CSV file
            FIRSTROW = 2,
            -- TABLOCK is used to improve bulk insert performance by acquiring a table-level lock
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' secs';


        SET @start_time = GETDATE();
        PRINT '>> Truncating Table bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIELDTERMINATOR = ',',
            -- Skip the header row in the CSV file
            FIRSTROW = 2,
            -- TABLOCK is used to improve bulk insert performance by acquiring a table-level lock
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' secs';
    END TRY

    BEGIN CATCH
        PRINT '=====================';
        PRINT 'An error occurred loading the bronze layer';
        -- ERROR_MESSAGE() is a system function that returns the text of the error that occurred.
        PRINT 'Error Message: ' + error_message();
        PRINT '=====================';
    END CATCH
END;
