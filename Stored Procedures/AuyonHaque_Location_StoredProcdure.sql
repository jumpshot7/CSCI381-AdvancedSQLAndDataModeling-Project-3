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

CREATE PROCEDURE [Project3].[Load_RoomLocation]
	@UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateAdded [Udt].[DateOf];
    SET @DateAdded = SYSDATETIME();

    DECLARE @DateOfLastUpdate [Udt].[DateOf];
    SET @DateOfLastUpdate = SYSDATETIME();

    DECLARE @StartingDateTime [Udt].[DateOf];
    SET @StartingDateTime = SYSDATETIME();

	
	DECLARE @SQL AS NVARCHAR(MAX)
    SET @SQL='CREATE OR ALTER VIEW project3.RoomLocation AS SELECT DISTINCT COALESCE(NULLIF([Location],'' ''), ''AA TBA'') AS RoomLocation FROM Uploadfile.CurrentSemesterCourseOfferings;'
    EXEC (@SQL)

	DECLARE @SQL2 AS NVARCHAR(MAX)
	SET @SQL2='CREATE OR ALTER VIEW project3.BuildingRoomNumber AS
	SELECT SUBSTRING([RoomLocation], 3, 100) AS RoomNumber
	FROM project3.RoomLocation;'
	EXEC (@SQL2)

INSERT INTO [Location].[RoomLocation]
(RoomLocation, UserAuthorizationKey, DateAdded, DateOfLastUpdate)

SELECT CS.RoomNumber, @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate
FROM project3.BuildingRoomNumber AS CS;


    DECLARE @EndingDateTime DATETIME2;
    SET @EndingDateTime = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount =
    (
        SELECT COUNT(*) FROM [Location].[RoomLocation]
    );

    EXEC [Process].[usp_TrackWorkFlow] 'Loads data into [Project3].[RoomLocation]',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @UserAuthorizationKey;

SELECT *
FROM [Location].[RoomLocation];

END;

