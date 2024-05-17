
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

    DECLARE @DateAdded [Udt].[DateOf];
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate [Udt].[DateOf];
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime [Udt].[DateOf];
    SET @StartingDateTime = SYSDATETIME();

    -- Common Table Expressions (CTEs)
    WITH CTE_Department AS (
        SELECT DISTINCT 
            SUBSTRING([Course (hr, crd)], 0, CHARINDEX(' ', [Course (hr, crd)])) AS [DepartmentName]
        FROM Uploadfile.CurrentSemesterCourseOfferings
    ),
    CTE_Department1 AS (
        SELECT DISTINCT 
            COALESCE(NULLIF([DepartmentName], ''), 'TBA') AS DepartmentName
        FROM CTE_Department
    )

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

    DECLARE @EndingDateTime [Udt].[DateOf];
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*) FROM [Department].[Department]);

    EXEC [Process].[usp_TrackWorkFlow] 
        'Loads data into [Department].[Department]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey;

    SELECT *
    FROM [Department].[Department];
END;
GO
