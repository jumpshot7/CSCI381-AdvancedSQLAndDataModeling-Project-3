SET ANSI_NULLS ON --  configure SQL Server settings to ensure consistent behavior regarding null comparisons and the use of quoted identifiers.
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:       Zackaria Mamdouh
-- Create date: 5/13/2024
-- Description: Track Work Flow
-- =============================================

CREATE PROCEDURE [Process].[usp_TrackWorkFlow] -- This command creates a new stored procedure named usp_TrackWorkFlow in the Process schema.
    -- Add  parameters as need be
    @WorkflowDescription [Udt].[Description], -- Description of the workflow step. The data type [Udt].[Description] indicates that a user-defined data type (UDT) is being used.
    @WorkFlowStepTableRowCount [Udt].[Count], -- The number of rows processed in the workflow step.
    @StartingDateTime [Udt].[DateOf], -- The starting date and time of the workflow step.
    @EndingDateTime [Udt].[DateOf], -- The ending date and time of the workflow step.
    @UserAuthorizationKey [Udt].[SurrogateKeyInt] -- A key to authorize the user executing the workflow step.

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    

        -- Insert statements for procedure here
    INSERT INTO [Process].[WorkflowSteps] -- his command inserts a new record into the WorkflowSteps table within the Process schema.
    (
        WorkFlowStepDescription, -- The description of the workflow step.
        WorkFlowStepTableRowCount, -- The number of rows processed in the workflow step.
        StartingDateTime, -- The starting date and time of the workflow step.
        EndingDateTime, -- The ending date and time of the workflow step.
        [Class Time], -- This column is hardcoded to '9:15'. This might be a default value or a specific time related to the workflow.
        UserAuthorizationKey -- The user authorization key to track who executed the workflow step.
    )
    VALUES
    (@WorkflowDescription, @WorkFlowStepTableRowCount, @StartingDateTime, @EndingDateTime, '9:15',
     @UserAuthorizationKey);
END;
