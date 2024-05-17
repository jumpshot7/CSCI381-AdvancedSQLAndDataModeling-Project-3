USE QueensClassSchedule;

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Author:      Zackaria Mamdouh
-- Create date: 5/17/2024
-- Description:  This procedure is responsible for loading data into the Course.Class table 
--               with transformations applied for compatibility and clarity.
-- =============================================
CREATE PROCEDURE [Project3].[Load_Class] @UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    -- Disables the message that shows the count of rows affected by SQL statements.
    SET NOCOUNT ON;

    -- Declare variables to track the datetime of operation, useful for data auditing.
    DECLARE @DateAdded [Udt].[DateOf];
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate [Udt].[DateOf];
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime [Udt].[DateOf];
    SET @StartingDateTime = SYSDATETIME();

    -- Truncates the Class table to clear any existing data ensuring fresh state for data loading.
    TRUNCATE TABLE Course.Class;

    -- Define a CTE to prepare and transform data from the CoursesSpring2017 table before insertion into Class.
    WITH ClassData AS (
    SELECT 
        c.CourseKey,
        a.Sec AS Section,
        a.Code AS CourseCode,
        SUBSTRING(a.[Course (hr, crd)], 1, 8) AS CourseName, -- Extracts a portion of the course string as name.
        c.CourseDescription,
        COALESCE(NULLIF(a.Instructor, ''), 'TBA') AS InstructorFullName, -- Handles missing instructor names.
        COALESCE(NULLIF(a.DAY, ' '), 'TBA') AS Day, -- Replaces empty days with 'TBA'.
        COALESCE(NULLIF(a.time, '-'), 'TBA') AS Hours, -- Converts time placeholders to 'TBA'.
        CASE 
            WHEN a.[Course (hr, crd)] != '' THEN 
                SUBSTRING(a.[Course (hr, crd)], CHARINDEX(',', a.[Course (hr, crd)]) + 2, 
                          LEN(a.[Course (hr, crd)]) - (CHARINDEX(',', a.[Course (hr, crd)]) + 2))
            ELSE NULL
        END AS NumberOfCredits, -- Calculates the number of credits from course details.
        a.Enrolled AS NumberEnrolled,
        a.Limit,
        CASE 
            WHEN CAST(a.Enrolled AS INT) > CAST(a.Limit AS INT) 
            THEN CAST(a.Enrolled AS INT) - CAST(a.Limit AS INT) 
            ELSE 0 
        END AS OverTally, -- Computes overflow in class enrollment.
        mo.ModeOfInstructionKey,
        COALESCE(a.[Mode of Instruction], 'TBA') AS ModeOfInstruction -- Ensures mode of instruction is never blank.
    FROM 
        groupnUploadfile.CoursesSpring2017 AS a
    INNER JOIN [Course].[Course] AS c ON a.[Course (hr, crd)] = c.CourseName
    INNER JOIN Course.ModeOfInstruction AS mo ON a.[Mode of Instruction] = mo.ModeOfInstruction
    WHERE 
        a.description != ''
)
   -- Inserts the transformed data into the Class table.
    INSERT INTO Course.Class
        (CourseKey, Section, CourseCode, CourseName, CourseDescription, InstructorFullName, Day, Hours, NumberOfCredits,
        NumberEnrolled, Limit, OverTally, ModeOfInstructionKey, ModeOfInstruction, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT 
        *, @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate
    FROM 
        ClassData;

    -- Records the end time of the data loading process.
    DECLARE @EndingDateTime [Udt].[DateOf];
    SET @EndingDateTime = SYSDATETIME();

    -- Counts the rows inserted into the Class table for verification and auditing.
    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount =
        (SELECT COUNT(*) FROM [Course].[Class]);

    -- Calls a stored procedure to log the operation for workflow tracking and audit.
    EXEC [Process].[usp_TrackWorkFlow] 'Loads data into [Project3].[Class]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
