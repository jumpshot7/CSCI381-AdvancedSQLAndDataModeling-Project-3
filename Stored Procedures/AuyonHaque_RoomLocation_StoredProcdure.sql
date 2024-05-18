SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Author: Auyon Haque
-- Procedure: Project3.Load_RoomLocation
-- Create Date: 5/15/2024
-- Description: Loads data into RoomLocation
DROP PROCEDURE IF EXISTS [Project3].[Load_RoomLocation];
GO

-- Create the stored procedure to load data into RoomLocation
CREATE PROCEDURE [Project3].[Load_RoomLocation]
    @UserAuthorizationKey [Udt].[SurrogateKeyInt]  -- Input parameter for user authorization key
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare and initialize variables to store the current datetime for various timestamps
    DECLARE @DateAdded [Udt].[DateOf];
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate [Udt].[DateOf];
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime [Udt].[DateOf];
    SET @StartingDateTime = SYSDATETIME();

    -- Create or alter a view to extract and process room location data
    DECLARE @SQL AS NVARCHAR(MAX);
    SET @SQL = 'CREATE OR ALTER VIEW project3.RoomLocation AS 
                SELECT DISTINCT 
                    COALESCE(NULLIF([Location], '' ''), ''AA TBA'') AS RoomLocation 
                FROM Uploadfile.CurrentSemesterCourseOfferings;';
    EXEC (@SQL);

    -- Create or alter a view to extract room numbers from the RoomLocation view
    DECLARE @SQL2 AS NVARCHAR(MAX);
    SET @SQL2 = 'CREATE OR ALTER VIEW project3.BuildingRoomNumber AS
                 SELECT 
                     SUBSTRING([RoomLocation], 3, 100) AS RoomNumber
                 FROM project3.RoomLocation;';
    EXEC (@SQL2);

    -- Insert processed room location data into the Location.RoomLocation table
    INSERT INTO [Location].[RoomLocation]
    (RoomLocation, UserAuthorizationKey, DateAdded, DateOfLastUpdate)
    SELECT 
        CS.RoomNumber, 
        @UserAuthorizationKey, 
        @DateAdded, 
        @DateOfLastUpdate
    FROM project3.BuildingRoomNumber AS CS;

    -- Declare and initialize a variable to store the ending datetime of the procedure execution
    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    -- Declare a variable to count the number of rows in the Location.RoomLocation table
    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*) FROM [Location].[RoomLocation]);

    -- Execute the stored procedure to track the workflow, passing necessary parameters
    EXEC [Process].[usp_TrackWorkFlow] 'Loads data into [Project3].[RoomLocation]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

    -- Select all rows from the Location.RoomLocation table to return as the result set
    SELECT *
    FROM [Location].[RoomLocation];
END;
