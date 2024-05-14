SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/13/2024
-- Description:	Drop Foreign Keys
-- =============================================

CREATE PROCEDURE [Project3].[DropForeignKeys] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    ALTER TABLE [Course].[Class]
    DROP CONSTRAINT FK_Class_ModeOfInstruction
    ALTER TABLE [Course].[Class]
    DROP CONSTRAINT FK_Class_Course
    ALTER TABLE [Department].[Instructor]
    DROP CONSTRAINT FK_Instructor_Department
    ALTER TABLE [Location].[BuildingLocation]
    DROP CONSTRAINT FK_BuildingLocation_RoomLocation
    ALTER TABLE [Process].[WorkflowSteps]
    DROP CONSTRAINT FK_WorkFlowSteps_UserAuthorization
    ALTER TABLE [Course].[Class]
    DROP CONSTRAINT FK_Class_UserAuthorization
    ALTER TABLE [Course].[Course]
    DROP CONSTRAINT FK_Course_UserAuthorization
    ALTER TABLE [Course].[ModeOfInstruction]
    DROP CONSTRAINT FK_ModeOfInstruction_UserAuthorization
    ALTER TABLE [Department].[Department]
    DROP CONSTRAINT FK_Department_UserAuthorization
    ALTER TABLE [Department].[Instructor]
    DROP CONSTRAINT FK_Instructor_UserAuthorization
    ALTER TABLE [Location].[BuildingLocation]
    DROP CONSTRAINT FK_BuildingLocation_UserAuthorization
    ALTER TABLE [Location].[RoomLocation]
    DROP CONSTRAINT FK_RoomLocation_UserAuthorization

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] 'Drop Foreign Keys',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;