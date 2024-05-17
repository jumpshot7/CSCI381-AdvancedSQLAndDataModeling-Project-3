SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/13/2024
-- Description:	Drop Foreign Keys
-- =============================================

-- Creates a stored procedure named DropForeignKeys under the Project3 schema
CREATE PROCEDURE [Project3].[DropForeignKeys] @UserAuthorizationKey INT
AS
BEGIN
    -- Sets NOCOUNT to ON to stop the message that shows the number of rows affected by a SQL statement
    SET NOCOUNT ON;
    
    -- Declares a variable to store the start time of the operation
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    -- Drops the foreign key constraint FK_Class_ModeOfInstruction from the [Course].[Class] table
    ALTER TABLE [Course].[Class]
    DROP CONSTRAINT FK_Class_ModeOfInstruction;

    -- Drops the foreign key constraint FK_Class_Course from the [Course].[Class] table
    ALTER TABLE [Course].[Class]
    DROP CONSTRAINT FK_Class_Course;

    -- Drops the foreign key constraint FK_Instructor_Department from the [Department].[Instructor] table
    ALTER TABLE [Department].[Instructor]
    DROP CONSTRAINT FK_Instructor_Department;

    -- Drops the foreign key constraint FK_BuildingLocation_RoomLocation from the [Location].[BuildingLocation] table
    ALTER TABLE [Location].[BuildingLocation]
    DROP CONSTRAINT FK_BuildingLocation_RoomLocation;

    -- Drops the foreign key constraint FK_WorkFlowSteps_UserAuthorization from the [Process].[WorkflowSteps] table
    ALTER TABLE [Process].[WorkflowSteps]
    DROP CONSTRAINT FK_WorkFlowSteps_UserAuthorization;

    -- Drops additional foreign key constraints related to UserAuthorization from various tables
    ALTER TABLE [Course].[Class]
    DROP CONSTRAINT FK_Class_UserAuthorization;

    ALTER TABLE [Course].[Course]
    DROP CONSTRAINT FK_Course_UserAuthorization;

    ALTER TABLE [Course].[ModeOfInstruction]
    DROP CONSTRAINT FK_ModeOfInstruction_UserAuthorization;

    ALTER TABLE [Department].[Department]
    DROP CONSTRAINT FK_Department_UserAuthorization;

    ALTER TABLE [Department].[Instructor]
    DROP CONSTRAINT FK_Instructor_UserAuthorization;

    ALTER TABLE [Location].[BuildingLocation]
    DROP CONSTRAINT FK_BuildingLocation_UserAuthorization;

    ALTER TABLE [Location].[RoomLocation]
    DROP CONSTRAINT FK_RoomLocation_UserAuthorization;

    -- Declares a variable to store the count of rows in WorkflowSteps table (though it is set to 0 and not changed)
    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;

    -- Declares a variable to store the end time of the operation
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();

    -- Calls another stored procedure to track the execution of the current procedure with the relevant details
    EXEC [Process].[usp_TrackWorkFlow] 'Drop Foreign Keys',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
