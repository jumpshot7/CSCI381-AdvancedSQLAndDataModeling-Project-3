USE QueensClassSchedule
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- Author:	Shengwei Jiang
-- Create date: 5/15/2024
-- Description:	Load Data Into BuildingLocation
CREATE PROCEDURE [Project3].[Load_BuildingLocationmodifier] 
    @UserAuthorizationKey [Udt].[SurrogateKeyInt]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded [Udt].[DateOf] = SYSDATETIME();
    DECLARE @DateOfLastUpdate [Udt].[DateOf] = SYSDATETIME();
    DECLARE @StartingDateTime [Udt].[DateOf] = SYSDATETIME();

    WITH CTE_BuildingLocation AS (

        SELECT DISTINCT

            COALESCE(NULLIF([Location], ''), 'TBA') AS Location,

            COALESCE(NULLIF(SUBSTRING([Location], 1, 2), ''), 'TBA') AS BuildingLocation,

            COALESCE(NULLIF(SUBSTRING([Location], 3, 6), ''), 'TBA') AS RoomLocation

        FROM Uploadfile.CurrentSemesterCourseOfferings

    ), CTE_BuildingLocation AS (

        SELECT 
     BL.[Location],

            BL.BuildingLocation,
            BL.RoomLocation,
            RL.RoomLocationKey
        FROM CTE_BuildingLocation AS BL
        LEFT OUTER JOIN Location.RoomLocation AS RL

        ON BL.RoomLocation = RL.RoomLocation
        WHERE BL.[Location] != 'TBA'
     

    )


    INSERT INTO [Location].BuildingLocation

  (BuildingLocation, RoomLocation, RoomLocationKey, UserAuthorizationKey, DateAdded, DateOfLastUpdate)


    SELECT DISTINCT 

        BuildingLocation, RoomLocation, RoomLocationKey, @UserAuthorizationKey, @DateAdded, @DateOfLastUpdate 


    FROM CTE_BuildingLocationJoin;



    DECLARE @EndingDateTime [Udt].[DateOf] = SYSDATETIME();


    DECLARE @WorkFlowStepTableRowCount INT;


    SET @WorkFlowStepTableRowCount = (SELECT COUNT(*) FROM [Location].[BuildingLocation]);


    EXEC [Process].[usp_TrackWorkFlow] 


    'Load data into [Location].[BuildingLocation]',

     @WorkFlowStepTableRowCount,

     @StartingDateTime,

     @EndingDateTime,
     @UserAuthorizationKey;



END;

