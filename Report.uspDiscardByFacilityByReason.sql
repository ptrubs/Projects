USE [BloodnetReportingV2]
GO
/****** Object:  StoredProcedure [Report].[uspDiscardByFacilityByReason]    Script Date: 01/22/2013 08:44:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pete Trubshaw
-- Create date: 2010-01-18
-- Description:	Retrieves discards from facilities and groups them by component and discard reason
-- =============================================
ALTER PROCEDURE [Report].[uspDiscardByFacilityByReason] 
		@FacilityID int = NULL
		AS
BEGIN

SELECT	
	C.ComponentName
	,DiscardGroup = ISNULL(LEFT(DR.Status,CHARINDEX(' ', DR.Status,0)), DR.Status)
			,DR.Status AS DiscardReason	
		,CNL.Qty
		,F.FacilityID
		,F.FacilityName
		,dec.PublishedPrice
		,CNL.[Group]
		,left(ABO.ABO+' ',2) + CASE when BG.Rh = 1 then '+' else '-' end as BloodGroup
		,ABO.ABOID
FROM DiscardReason DR
LEFT JOIN DiscardEpisode DE on DR.DiscardReasonID = DE.DiscardReasonID
INNER JOIN DiscardEpisodeComponent DEC on DEC.DiscardEpisodeID = DE.DiscardEpisodeID

INNER JOIN Facility F on F.FacilityID = DE.FacilityID
INNER JOIN ConsignmentNoteLine CNL on CNL.ConsignmentNoteLineID = DEC.ConsignmentNoteLineID
Right JOIN Component C on C.ComponentID = CNL.ComponentID
INNER JOIN ABO on ABO.ABOID = CNL.ABOID
INNER JOIN BloodGroup BG on BG.Rh = CNL.RhD
Where F.FacilityId =isNull(@FacilityID,F.FacilityID)
Order by FacilityName,C.OrderIndex
END
