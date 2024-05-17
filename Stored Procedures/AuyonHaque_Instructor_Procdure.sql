SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Author:      Auyon Haque
-- Create date: 05/12/2024
-- Description: Load data into instructor
CREATE OR ALTER PROCEDURE [Project3].[Load_Instructor] @UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables to store the current datetime for various timestamps
    DECLARE @DateAdded [Udt].[Dateof];
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate [Udt].[Dateof];
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime [Udt].[Dateof];
    SET @StartingDateTime = SYSDATETIME();

    -- Common Table Expressions (CTEs) to process instructor data
    WITH CTE_Instructor_Temp1 AS (
        -- Extract and process instructor names and department names from the course offerings
        SELECT DISTINCT 
            CASE 
                WHEN LEN(Instructor) < 2 THEN 'TBA' -- Handle short instructor names
                ELSE COALESCE(NULLIF(SUBSTRING(Instructor, 1, 
                                CASE 
                                    WHEN CHARINDEX(',', Instructor) = 0 OR CHARINDEX(' ', Instructor) = 0 
                                    THEN LEN(Instructor)
                                    ELSE CHARINDEX(',', Instructor) - 1 
                                END), ''), 'TBA') -- Extract last name
            END AS InstructorLastName1,
            COALESCE(NULLIF(SUBSTRING(Instructor, CHARINDEX(' ', Instructor) + 1, LEN(Instructor)), ''), 'TBA') AS InstructorFirstName1, -- Extract first name
            COALESCE(NULLIF(Instructor, ''), 'TBA') AS InstructorFullName1, -- Full name
            COALESCE(NULLIF(SUBSTRING([Course (hr, crd)], 0, CHARINDEX(' ', [Course (hr, crd)])), ' '), 'TBA') AS DepartmentName1 -- Department name
        FROM Uploadfile.CurrentSemesterCourseOfferings
    ),
    CTE_Instructor_Temp2 AS (
        -- Ensure names and department are not empty or blank spaces; replace with 'TBA' if necessary
        SELECT DISTINCT 
            COALESCE(NULLIF(InstructorLastName1, ' '), 'TBA') AS InstructorLastName2,
            COALESCE(NULLIF(InstructorFirstName1, ' '), 'TBA') AS InstructorFirstName2,
            COALESCE(NULLIF(InstructorFullName1, ' '), 'TBA') AS InstructorFullName2,
            COALESCE(NULLIF(DepartmentName1, ' '), 'TBA') AS DepartmentName2
        FROM CTE_Instructor_Temp1
    ),
    CTE_Instructor_Temp3 AS (
        -- Assign a unique key to each department name
        SELECT DISTINCT 
            DepartmentName2, 
            ROW_NUMBER() OVER(ORDER BY DepartmentName2) AS DepartmentKey
        FROM CTE_Instructor_Temp2
        GROUP BY DepartmentName2
    )
    
    -- Insert processed instructor data into the Department.Instructor table
    INSERT INTO Department.Instructor (
        InstructorFirstName, 
        InstructorLastName, 
        InstructorFullName, 
        DepartmentName, 
        DepartmentKey, 
        UserAuthorizationKey, 
        DateAdded, 
        DateOfLastUpdate
    ) 
    SELECT 
        a.InstructorFirstName2 as InstructorFirstName, 
        a.InstructorLastName2 as InstructorLastName,
        a.InstructorFullName2 as InstructorFullName,
        a.DepartmentName2 as DepartmentName,
        b.DepartmentKey as DepartmentKey,
        @UserAuthorizationKey,
        @DateAdded,
        @DateOfLastUpdate
    FROM CTE_Instructor_Temp2 AS a
    INNER JOIN CTE_Instructor_Temp3 AS b
        ON a.DepartmentName2 = b.DepartmentName2;

    -- Declare variable to store the ending datetime of the procedure execution
    DECLARE @EndingDateTime [Udt].[Dateof];
    SET @EndingDateTime = SYSDATETIME();

    -- Declare variable to count the number of rows in the Department.Instructor table
    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*) FROM [Department].[Instructor]);
	
    -- Execute the stored procedure to track the workflow, passing necessary parameters
    EXEC [Process].[usp_TrackWorkFlow] 
        'Loads data into [Department].[ModeOfInstruction]',
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @UserAuthorizationKey;

    -- Select all rows from the Department.Instructor table to return as the result set
    SELECT *
    FROM [Department].[Instructor];
END;
GO
