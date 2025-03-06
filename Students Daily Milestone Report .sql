WITH RankedData AS (SELECT
	 M.PERSON_FULL_NAME
	,M.SyStudentID
	,M.STUDENT_ID
	,M.PERSON_ID
	,CAST(M.OriginalExpStartDate AS DATE) AS OriginalStartDate
	,CAST(M.ExpStartDate AS DATE) AS ExpStartDate
	,CAST(M.START_DATE AS DATE) AS [START_DATE]
	,CAST(M.ReEntryDate AS DATE) AS ReEntryDate
	,CAST(M.GradDate AS DATE) AS GradDate
	,CAST(M.AppRecDate AS DATE) AS AppRecDate
	,CAST(M.EnrollDate AS DATE) AS EnrollDate
	,M.StudentStatusReasonDesc AS SchoolStatus
	,M.Program
	,M.ProgramDesc AS ProgramVersion
	,M.ShiftDesc AS 'Shift'
	,M.CampusName AS Campus
	,M.REP_NAME AS AdmRep
	,P.Descrip AS PackagingStatus
	,M.FINANCIAL_AID_STATUS_CODE 
	,M.FINANCIAL_AID_STATUS_DESC
	,M.PHONE_NUMBER
	,M.PHONE_2_NUMBER 
	,M.PRIMARY_EMAIL_ADDRESS
	,M.OTHER_EMAIL_ADDRESS
	,M.ENROLLED_FLAG 
	,M.CANCELLED_FLAG 
	,M.FUTURE_STUDENT_FLAG
	,CASE 
		WHEN M.FUTURE_STUDENT_FLAG = 1 AND M.FINANCIAL_AID_STATUS_CODE NOT LIKE '%8%' 
		THEN 1
		ELSE 0
	END AS WORKABLE_FLAG 
	,CASE WHEN P.Descrip = '0 - Not Packaged' THEN 1 ELSE 0 END AS [0 - Not Packaged]
	,CASE WHEN P.Descrip = '1 - Overview Complete' THEN 1 ELSE 0 END AS [1 - Overview Complete]
	,CASE WHEN P.Descrip = '1 - ISIR Received' THEN 1 ELSE 0 END AS [1 - ISIR Received]
	,CASE WHEN P.Descrip = '2 - Pending Docs' THEN 1 ELSE 0 END AS [2 - Pending Docs]
	,CASE WHEN P.Descrip = '2- Verification' THEN 1 ELSE 0 END AS [2- Verification]
	,CASE WHEN P.Descrip = '2 - Pending ISIR' THEN 1 ELSE 0 END AS [1 - 2 - Pending ISIR]
	,CASE WHEN P.Descrip = '3 - Ready to Submit' THEN 1 ELSE 0 END AS [3 - Ready to Submit]
	,CASE WHEN P.Descrip = '4 - Packaged' THEN 1 ELSE 0 END AS [4 - Packaged]
	,CASE WHEN P.Descrip = '5 - VA Student' THEN 1 ELSE 0 END AS [5 - VA Student]
	,CASE WHEN P.Descrip = '5.1 - VA Ready for Packaging' THEN 1 ELSE 0 END AS [5.1 - VA Ready for Packaging]
	,CASE WHEN P.Descrip = '5.2 - VA Packaged Ready for Finance Plan' THEN 1 ELSE 0 END AS [5.2 - VA Packaged Ready for Finance Plan]
	,CASE WHEN P.Descrip = '5.3 - VA Ready to Submit' THEN 1 ELSE 0 END AS [5.3 - VA Ready to Submit]
	,CASE WHEN P.Descrip = '5.4 - VA Packaged' THEN 1 ELSE 0 END AS [5.4 - VA Packaged]
	,CASE WHEN M.FINANCIAL_AID_STATUS_DESC = '900 - FA COMPLETE' OR	
			   M.FINANCIAL_AID_STATUS_DESC = '700 - FULLY FUNDED, MISSING DOCUMENTS' 
			   THEN 1 
			   ELSE 0 
END AS FullyFunded   
	,DATEDIFF(DAY, M.AppRecDate, GETDATE()) AS [Age of Enrollment]
	,CASE WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) <= 7 THEN '0-7 Days'
		  WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) > 7 AND DATEDIFF(DAY, M.AppRecDate, GETDATE()) < 15 THEN '8-14 Days'
		  WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) > 14 AND DATEDIFF(DAY, M.AppRecDate, GETDATE()) < 22 THEN '15-21 Days'
		  WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) > 21 AND DATEDIFF(DAY, M.AppRecDate, GETDATE()) < 29 THEN '22-28 Days'
		  WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) > 28 AND DATEDIFF(DAY, M.AppRecDate, GETDATE()) < 36 THEN '29-35 Days'
		  WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) > 35 AND DATEDIFF(DAY, M.AppRecDate, GETDATE()) < 50 THEN '36-49 Days'
		  WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) > 49 AND DATEDIFF(DAY, M.AppRecDate, GETDATE()) < 65 THEN '50-64 Days'
    ELSE '>64 Days'
END AS [Enroll Age Group]
	,CASE WHEN DATEDIFF(DAY, M.AppRecDate, GETDATE()) <= 30 THEN 1 
	ELSE 0 
END AS [Enroll < 30 days]
	,CASE 
        WHEN MONTH(M.START_DATE) IN (10, 11, 12) THEN 'Q1'
        WHEN MONTH(M.START_DATE) IN (1, 2, 3) THEN 'Q2'
        WHEN MONTH(M.START_DATE) IN (4, 5, 6) THEN 'Q3'
        WHEN MONTH(M.START_DATE) IN (7, 8, 9) THEN 'Q4'
END AS Quarter
	,S.SALES_DIVISION_CODE AS [Sales Division]
	,S.SALES_CHANNEL AS [Sales Channel]
	,CASE WHEN P.Descrip LIKE '%5%' THEN 'Yes'
	      ELSE 'NO'
END AS [MSC Team] 
	,CASE WHEN P.Descrip LIKE '%5%' THEN 1
	      ELSE 0
END AS [Military Count]
,CASE WHEN P.Descrip IN ('4 - Packaged', '5.4 - VA File Complete', 'Complete', '5.4 - VA Packaged') THEN 'Fully Funded FA Complete'
	 WHEN P.Descrip IN ('0 - Not Packaged', '5 - VA Student') THEN 'No FAFSA/No COE'
	 WHEN P.Descrip IN ('2 - Pending Docs', '2 - Pending ISIR', '2- Verification', '5.2 - VA FP Complete Missing TIV docs', '5.3 - VA Review and/or Missing Trans') THEN 'Pending Docs'
	 WHEN P.Descrip IN ('1 - ISIR Received', '5.2 - VA Packaged Ready for Finance Plan', '5.1 - VA Ready for Packaging', '1 - Overview Complete') THEN 'Ready for FAP'
	 WHEN P.Descrip IN ('3 - Ready to Submit','5.3 - VA Ready to Submit') THEN 'Ready to Submit for Q/A'
	 WHEN P.Descrip IN ('8.8 - Red Flag - Postpone or Cancel', '8 - Not Packaged - No Contact', '8.1 - ISIR Received - No Contact', '8.5 - VA Student - No Contact', 
	 '8.2 - Pending Docs/ISIR - No Contact', '8.3 - Ready to Submit - No Contact', '8.4 - Packaged - No Contact') THEN 'SF unable to Contact'
	 ELSE 'Unknown'
END AS [FA Status Grouping]
,ROW_NUMBER() OVER (PARTITION BY M.STUDENT_ID ORDER BY A.Sequence DESC) AS rn
FROM [Acquisition].[dbo].[MIAT_STUDENTS] M
    LEFT JOIN [Acquisition].[MIAT].[AdEnroll_vw] E 
        ON M.AdEnrollID = E.AdEnrollID
	JOIN [Acquisition].[MIAT].[FaStudentAY_vw] A 
        ON E.AdEnrollID = A.AdEnrollID
	JOIN [Acquisition].[MIAT].[FaPackStatus_vw] P 
        ON P.FaPackStatusID = A.FaPackStatusID
        AND E.ExpStartDate = A.StartDate
	JOIN [Acquisition].[MIAT].[MIAT_STUDENTS_VW] MM 
        ON M.STUDENT_ID = MM.STUDENT_ID
    JOIN [EDW].[dbo].[DW_SALES_TEAM_HIER_VW] S 
        ON MM.SALES_TEAM_HIER_KEY = S.SALES_TEAM_HIER_KEY
    WHERE M.CURR_REC_IND = 'Y'
      AND M.ENROLLED_FLAG = 1
	  AND M.START_DATE > (GETDATE()-1)
)
SELECT * 
FROM RankedData 
WHERE rn = 1