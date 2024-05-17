USE QueensClassSchedule;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/16/2024
-- Description:	Procedure responsible for loading data into ModeOfInstruction table.
-- =============================================
CREATE PROCEDURE [Project3].[Load_ModeOfInstruction] @UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded [Udt].[DateOf];
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate [Udt].[DateOf];
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime [Udt].[DateOf];
    SET @StartingDateTime = SYSDATETIME();

	WITH ModeOfInstructionCTE AS (
    SELECT DISTINCT 
        COALESCE(NULLIF([Mode of Instruction], ''), 'TBA') AS ModeOfInstruction
    FROM 
        Uploadfile.CurrentSemesterCourseOfferings)
    INSERT INTO Course.ModeOfInstruction (ModeOfInstruction, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT 
    ModeOfInstruction, 
    @UserAuthorizationKey, 
    @DateAdded, 
    @DateOfLastUpdate
FROM 
    ModeOfInstructionCTE;

    DECLARE @EndingDateTime [Udt].[DateOf];
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount =
    (
        SELECT COUNT(*) FROM [Course].[ModeOfInstruction]
    );

    EXEC [Process].[usp_TrackWorkFlow] 'Loads data into [Course].[ModeOfInstruction]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @ClassTime,
                                       @UserAuthorizationKey;
    SELECT *
    FROM [Course].[ModeOfInstruction];
END;