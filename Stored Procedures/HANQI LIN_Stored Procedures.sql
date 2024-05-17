USE QueensClassSchedule
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      HANQI LIN
-- Create date: 05/14/2024
-- Description: Load Data into Course; [Project3].[Load_Course]
-- =============================================
CREATE OR ALTER PROCEDURE [Project3].[Load_Course]
    @UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded [Udt].[DateOf] = SYSDATETIME();
    DECLARE @DateOfLastUpdate [Udt].[DateOf] = SYSDATETIME();
    DECLARE @StartingDateTime [Udt].[DateOf] = SYSDATETIME();

    /*----- DELETE -----*/
    DECLARE @SQL2 AS NVARCHAR(MAX) = N'
        DROP VIEW IF EXISTS [CourseView];
        DROP VIEW IF EXISTS [CourseView1];';
    EXEC(@SQL2);

    /*=============VIEW=================*/
    DECLARE @SQL AS NVARCHAR(MAX) = N'
        CREATE VIEW [CourseView] AS
        SELECT DISTINCT 
            [Course (hr, crd)] AS CourseName,
            [Description]
        FROM [QueensClassSchedule].[Uploadfile].[CurrentSemesterCourseOfferings];';
    EXEC(@SQL);

    /*====================================*/
    DECLARE @SQL3 AS NVARCHAR(MAX) = N'
        CREATE OR ALTER VIEW [CourseView1] AS
        SELECT DISTINCT 
            COALESCE(NULLIF([CourseName], ''''), ''TBA'') AS CourseName,
            COALESCE(NULLIF([Description], ''''), ''TBA'') AS Description 
        FROM [CourseView];';
    EXEC(@SQL3);

    ;WITH CourseCTE AS (
        SELECT [CourseName], [Description]
        FROM [CourseView1]
    )
    INSERT INTO [Course].[Course] (CourseName, CourseDescription, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT [CourseName], [Description], @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate
    FROM CourseCTE;

    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @WorkFlowStepTableRowCount INT = (SELECT COUNT(*) FROM [Course].[Course]);

    /**EXEC [Process].[usp_TrackWorkFlow] 
        'Loads data into [Project3].[ModeOfInstruction]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey; */

    SELECT *
    FROM [Course].[Course];
END;

EXEC  [Project3].[Load_Course] @UserAuthorizationKey = 8;  