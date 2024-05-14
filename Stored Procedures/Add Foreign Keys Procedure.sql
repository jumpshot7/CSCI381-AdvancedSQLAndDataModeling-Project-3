SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Zackaria Mamdouh
-- Create date: 5/13/2024
-- Description:	Adding Foreign Keys
-- =============================================

CREATE PROCEDURE [Project3].[AddForeignKeys] @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    -- This is a command to stop the message indicating the number of rows affected by a T-SQL statement from being returned.
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

        ALTER TABLE [Course].[Class] --This section adds foreign key constraints to various tables. A foreign key constraint ensures that the value in a column (or a group of columns) must match the values in another table's primary key or unique key column.
    ADD CONSTRAINT FK_Class_ModeOfInstruction
        FOREIGN KEY (ModeOfInstructionKey)
        REFERENCES [Course].[ModeOfInstruction] (ModeOfInstructionKey);

    ALTER TABLE [Course].[Class]
    ADD CONSTRAINT FK_Class_Course
        FOREIGN KEY (CourseKey)
        REFERENCES [Course].[Course] (CourseKey);

    ALTER TABLE [Department].[Instructor]
    ADD CONSTRAINT FK_Instructor_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES [Department].[Department] (DepartmentKey);

    ALTER TABLE [Location].[BuildingLocation]
    ADD CONSTRAINT FK_BuildingLocation_RoomLocation
        FOREIGN KEY (RoomLocationKey)
        REFERENCES [Location].[RoomLocation] (RoomLocationKey);

    ALTER TABLE [Process].[WorkflowSteps]
    ADD CONSTRAINT FK_WorkFlowSteps_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Course].[Class]
    ADD CONSTRAINT FK_Class_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Course].[Course]
    ADD CONSTRAINT FK_Course_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Course].[ModeOfInstruction]
    ADD CONSTRAINT FK_ModeOfInstruction_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Department].[Department]
    ADD CONSTRAINT FK_Department_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Department].[Instructor]
    ADD CONSTRAINT FK_Instructor_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Location].[BuildingLocation]
    ADD CONSTRAINT FK_BuildingLocation_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    ALTER TABLE [Location].[RoomLocation]
    ADD CONSTRAINT FK_RoomLocation_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].UserAuthorization (UserAuthorizationKey);

    DECLARE @WorkFlowStepTableRowCount INT; -- Declares a variable to store the row count
    SET @WorkFlowStepTableRowCount = 0; -- Initializes the row count to zero.
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME(); -- Captures the current date and time at the end of the procedure's execution.
    EXEC [Process].[usp_TrackWorkFlow] 'Add Foreign Keys', -- Calls another stored procedure (usp_TrackWorkFlow) to track the workflow steps. It passes parameters including the description of the step ('Add Foreign Keys'), the row count, the start and end times, and the user authorization key.
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;
END;
