USE QueensClassSchedule;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/16/2024
-- Description:	Truncating data
-- =============================================
CREATE PROCEDURE [Project3].[TruncateData]
	@UserAuthorizationKey int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

	TRUNCATE TABLE Course.Class;
	TRUNCATE TABLE Course.Course;
	TRUNCATE TABLE Department.Instructor;
	TRUNCATE TABLE Course.ModeOfInstruction;
	TRUNCATE TABLE Department.Department;
	TRUNCATE TABLE [Location].BuildingLocation;
	TRUNCATE TABLE [Location].RoomLocation;
	

	DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] 'Truncate Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
end