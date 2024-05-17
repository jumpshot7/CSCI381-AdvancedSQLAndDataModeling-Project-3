SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Author:      Auyon Haque
-- Create date: 5/12/2024
-- Description: Load Data Into Department
CREATE OR ALTER PROCEDURE [Project3].[Load_Department] @UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variable to store the current datetime for when the data is added
    DECLARE @DateAdded [Udt].[DateOf];
    SET @DateAdded = SYSDATETIME();

    -- Declare variable to store the current datetime for the last update
    DECLARE @DateOfLastUpdate [Udt].[DateOf];
    SET @DateOfLastUpdate = SYSDATETIME();

    -- Declare variable to store the starting datetime of the procedure execution
    DECLARE @StartingDateTime [Udt].[DateOf];
    SET @StartingDateTime = SYSDATETIME();

    -- Common Table Expressions (CTEs) to process department names
    WITH CTE_Department AS (
        -- Extract the department name from the course details by using substring and charindex functions
        SELECT DISTINCT 
            SUBSTRING([Course (hr, crd)], 0, CHARINDEX(' ', [Course (hr, crd)])) AS [DepartmentName]
        FROM Uploadfile.CurrentSemesterCourseOfferings
    ),
    CTE_Department1 AS (
        -- Ensure department names are not empty; replace empty names with 'TBA'
        SELECT DISTINCT 
            COALESCE(NULLIF([DepartmentName], ''), 'TBA') AS DepartmentName
        FROM CTE_Department
    )

    -- Insert processed department names into the Department.Department table
    INSERT INTO Department.Department (
        DepartmentName,
        UserAuthorizationKey,
        DateAdded,
        DateOfLastUpdate
    )
    SELECT 
        DepartmentName,
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM CTE_Department1;

    -- Declare variable to store the ending datetime of the procedure execution
    DECLARE @EndingDateTime [Udt].[DateOf];
    SET @EndingDateTime = SYSDATETIME();

    -- Declare variable to count the number of rows in the Department.Department table
    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*) FROM [Department].[Department]);

    -- Execute the stored procedure to track the workflow, passing necessary parameters
    EXEC [Process].[usp_TrackWorkFlow] 
        'Loads data into [Department].[Department]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey;

    -- Select all rows from the Department.Department table to return as the result set
    SELECT *
    FROM [Department].[Department];
END;
GO

