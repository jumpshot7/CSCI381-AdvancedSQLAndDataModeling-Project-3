-- Uses the QueensClassSchedule database for all subsequent operations
USE QueensClassSchedule;

-- Setting SQL behavior flags for handling NULLs and quoted identifiers
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/16/2024
-- Description:	Procedure to load data for the application, handling data integrity and setup.
-- =============================================
CREATE or alter PROCEDURE [Project3].[LoadData] @UserAuthorizationKey INT
AS
BEGIN
    -- Prevents extra messages from interfering with client applications
    SET NOCOUNT ON;

    -- Records the start time of the procedure execution
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    -- Calls the procedure to drop all foreign keys to allow table truncation
    EXEC [Project3].[DropForeignKeys] @UserAuthorizationKey = 1;

    -- Captures the status and row counts of tables before data truncation
    EXEC [Project3].[ShowTableStatusRowCount]
         @UserAuthorizationKey = 1,
         @TableStatus = N'Pre-truncate of tables';

    -- Truncates data from all relevant tables to ensure clean slate for loading
    EXEC [Project3].[TruncateData] @UserAuthorizationKey = 1;

    -- Loads data into individual tables in a specified order for schema consistency
    EXEC [Project3].[Load_ModeOfInstruction] @UserAuthorizationKey = 1;
    EXEC [Project3].[Load_Course] @UserAuthorizationKey = 8;
    EXEC [Project3].[Load_Class] @UserAuthorizationKey = 1;
    EXEC [Project3].[Load_Department] @UserAuthorizationKey = 2;
    EXEC [Project3].[Load_Instructor] @UserAuthorizationKey = 2;
    EXEC [Project3].[Load_RoomLocation] @UserAuthorizationKey = 2;
    EXEC [Project3].[Load_BuildingLocation] @UserAuthorizationKey = 5;

    -- Recaptures the status and row counts of tables after data is loaded
    EXEC [Project3].[ShowTableStatusRowCount]
         @UserAuthorizationKey = 1,
         @TableStatus = N'Row Count after loading';

    -- Restores foreign key constraints to maintain data integrity
    EXEC [Project3].[AddForeignKeys] @UserAuthorizationKey = 1;

    -- Records the end time of the procedure execution
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;

    -- Logs the completion of data loading, including workflow steps and duration
    EXEC [Process].[usp_TrackWorkFlow] 'Load Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
