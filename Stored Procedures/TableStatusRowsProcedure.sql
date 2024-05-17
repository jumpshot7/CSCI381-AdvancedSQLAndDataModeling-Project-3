USE QueensClassSchedule;
-- The database context is set to 'QueensClassSchedule' for all subsequent operations.

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- These settings ensure SQL Server handles NULL values and identifiers like table and column names correctly.

-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/16/2024
-- Description:	Creating the Table Status Row Count Procedure
-- =============================================
-- Metadata about the procedure including the author, creation date, and a description of its purpose.

CREATE or ALTER PROCEDURE [Project3].[ShowTableStatusRowCount] @TableStatus VARCHAR(64), @UserAuthorizationKey INT 
AS
BEGIN
    -- Procedure declaration with parameters for table status and user authorization key.

    SET NOCOUNT ON;
    -- Prevents the sending of DONE_IN_PROC messages to the client, which can improve performance by reducing network traffic.

    DECLARE @DateAdded DATETIME2;
    SET @DateAdded = SYSDATETIME();
    -- Declares a variable to store the current date and time when the procedure is executed.

    DECLARE @DateOfLastUpdate DATETIME2;
    SET @DateOfLastUpdate = SYSDATETIME();
    -- Similar to @DateAdded, stores the current date and time to track when the last update occurred.

    DECLARE @StartingDateTime DATETIME2;
    SET @StartingDateTime = SYSDATETIME();
    -- Tracks the start time of the procedure execution for performance monitoring.

    DECLARE @EndingDateTime DATETIME2;
    -- Declares a variable to store the end time of the procedure execution.

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    -- Initializes a counter for workflow step table rows, potentially used for tracking or logging.

    -- The following series of SELECT statements union results from different tables,
    -- inserting the specified table status, the table name, and the row count of each table.
    SELECT  @TableStatus AS 'TableStatus',
           'Course.Class' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM Course.Class
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
            'Course.Course' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM Course.Course
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
           'Department.Instructor' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM Department.Instructor
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
            'Course.ModeofInstruction' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM Course.ModeOfInstruction
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
            'Department.Department' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM Department.Department
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
           'Location.BuildingLocation' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM [Location].BuildingLocation
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
            'Location.RoomLocation' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM [Location].RoomLocation
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
           'DbSecurity.UserAuthorization'AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM [DbSecurity].UserAuthorization
    UNION ALL
    SELECT @TableStatus AS 'TableStatus',
           'Process.WorkflowSteps' AS 'TableName ',
           COUNT(*) AS 'ROW COUNT'
    FROM [Process].WorkflowSteps;
    
    -- Repeated for various tables under different schemas like Course, Department, Location, DbSecurity, and Process.

    SET @EndingDateTime = SYSDATETIME();
    -- Stores the end time of the procedure execution.

    -- Calls another stored procedure to log or process information about the current procedure's execution,
    -- passing relevant information such as the name, count of workflow steps processed, start and end times, and user authorization key.
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: [Project3].[ShowStatusRowCount]  loads data into [Project3].[ShowTableStatusRowCount]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

END;
