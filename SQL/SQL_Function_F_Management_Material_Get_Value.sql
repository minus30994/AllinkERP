﻿
-- =============================================
-- AUTHOR: 郭凯斌
-- CREATE DATE: 2013-11-09
-- DESCRIPTION: 返回某个成本要素(辅助项目)的可报账数
-- =============================================

Create Function F_Management_Material_Get_Value (
@LI_COST_CENTER_ID INT,
@LS_DATE VARCHAR(10),
@LI_COST_ELEMENT_ID INT,
@LS_CATEGORY VARCHAR(200),
@LI_ASSISTANT_ITEM_ID INT
)
RETURNS MONEY
AS
BEGIN

DECLARE @LI_BUDGET_CENTER_ID INT
DECLARE @LI_BUDGET_ITEM_ID INT
DECLARE @LM_REMAIN_ALLOCATE MONEY
DECLARE @LS_ACCOUNT_YEAR VARCHAR(4)
DECLARE @LS_ACCOUNT_PERIOD VARCHAR(2)
DECLARE @LS_IGNORE VARCHAR(10)
DECLARE @LI_BUDGET_FORM_ID INT
DECLARE @LM_BUDGET MONEY
DECLARE @LI_TIME INT
DECLARE @LS_START_DATE VARCHAR(10)
DECLARE @LS_END_DATE VARCHAR(10)
DECLARE @LS_COST_CENTER_CODE VARCHAR(10)

IF (NOT @LI_COST_CENTER_ID>0)
OR @LI_COST_CENTER_ID IS NULL
OR (NOT LEN(@LS_DATE)>0)
OR @LS_DATE IS NULL
	RETURN 0

IF @LI_ASSISTANT_ITEM_ID IS NULL
SET @LI_ASSISTANT_ITEM_ID=0

SET @LS_COST_CENTER_CODE=(SELECT FCCNO FROM T_COSTCENTER WITH(NOLOCK) WHERE FCOSTCENTERID=@LI_COST_CENTER_ID)

IF (NOT LEN(@LS_COST_CENTER_CODE)>0) OR @LS_COST_CENTER_CODE IS NULL
	RETURN 0

SET @LS_ACCOUNT_YEAR=(SELECT CONVERT(VARCHAR(4),A.FYEAR) FROM T_ACCOUNTPERIOD AS A WHERE
CONVERT(VARCHAR(7),A.FBEGDATE,20)<=LEFT(@LS_DATE,7)
AND CONVERT(VARCHAR(7),A.FENDDATE,20)>=LEFT(@LS_DATE,7))

SET @LS_ACCOUNT_PERIOD=(SELECT CONVERT(VARCHAR(2),A.FPERIOD) FROM T_ACCOUNTPERIOD AS A WHERE
CONVERT(VARCHAR(7),A.FBEGDATE,20)<=LEFT(@LS_DATE,7)
AND CONVERT(VARCHAR(7),A.FENDDATE,20)>=LEFT(@LS_DATE,7))

IF NOT LEN(@LS_ACCOUNT_YEAR)>0 OR @LS_ACCOUNT_YEAR IS NULL OR NOT LEN(@LS_ACCOUNT_PERIOD)>0 OR @LS_ACCOUNT_PERIOD IS NULL
	RETURN 0

IF LEN(@LS_ACCOUNT_PERIOD)=1
	SET @LS_ACCOUNT_PERIOD='0'+@LS_ACCOUNT_PERIOD

SET @LS_IGNORE=(SELECT FVALUE FROM T_SYSPROFILE WITH(NOLOCK) WHERE FSUBSYS='BUDGET' AND FALIASNAME='预算报账-忽略报表/下拨')

SET @LI_BUDGET_CENTER_ID=NULL
SET @LI_BUDGET_ITEM_ID=NULL
SET @LM_REMAIN_ALLOCATE=NULL
SET @LI_BUDGET_FORM_ID=NULL
SET @LM_BUDGET=NULL

SET @LI_BUDGET_CENTER_ID=(
SELECT
FBUDGET_CENTER_ID
FROM T_COSTCENTER_TELEMENT WITH(NOLOCK)
WHERE
1=1
AND FCOSTCENTERID=@LI_COST_CENTER_ID
AND FCOSTELEMENTID=@LI_COST_ELEMENT_ID
)

SET @LI_BUDGET_ITEM_ID=(
SELECT
FBUDGET_ITEM_ID
FROM T_COSTCENTER_TELEMENT WITH(NOLOCK)
WHERE
1=1
AND FCOSTCENTERID=@LI_COST_CENTER_ID
AND FCOSTELEMENTID=@LI_COST_ELEMENT_ID
)

IF (NOT @LI_COST_ELEMENT_ID>0) OR @LI_COST_ELEMENT_ID IS NULL
	RETURN 0

IF (NOT @LI_BUDGET_CENTER_ID>0) OR @LI_BUDGET_CENTER_ID IS NULL OR
(NOT @LI_BUDGET_ITEM_ID>0) OR @LI_BUDGET_ITEM_ID IS NULL
	RETURN 0

SET @LI_BUDGET_FORM_ID=(
SELECT
TOP 1
D.FID
FROM T_BUDGET_FORM_DETAIL AS D WITH(NOLOCK)
INNER JOIN T_BUDGET_FORM_HEADER AS H WITH(NOLOCK) ON D.FID=H.FID
WHERE
1=1
AND CONVERT(VARCHAR(7),H.FSTART_DATE,20)<=LEFT(@LS_DATE,7)
AND CONVERT(VARCHAR(7),H.FEND_DATE,20)>=LEFT(@LS_DATE,7)
AND H.FBUDGET_CENTER_ID=@LI_BUDGET_CENTER_ID
AND D.FBUDGET_ITEM_ID=@LI_BUDGET_ITEM_ID
AND D.FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
)

IF (NOT @LI_BUDGET_FORM_ID>0) OR @LI_BUDGET_FORM_ID IS NULL AND @LS_IGNORE='是'
BEGIN
	SET @LI_BUDGET_FORM_ID=(
	SELECT
	TOP 1
	D.FID
	FROM T_BUDGET_FORM_VALUE AS D WITH(NOLOCK)
	INNER JOIN T_BUDGET_FORM_HEADER AS H WITH(NOLOCK) ON D.FID=H.FID
	WHERE
	1=1
	AND CONVERT(VARCHAR(7),H.FYEAR_TARGET_START_DATE,20)<=LEFT(@LS_DATE,7)
	AND CONVERT(VARCHAR(7),H.FYEAR_TARGET_END_DATE,20)>=LEFT(@LS_DATE,7)
	AND H.FBUDGET_CENTER_ID=@LI_BUDGET_CENTER_ID
	AND D.FBUDGET_ITEM_ID=@LI_BUDGET_ITEM_ID
	AND D.FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
	ORDER BY
	CONVERT(VARCHAR(7),H.FSTART_DATE,20)+'-'+CONVERT(VARCHAR(7),H.FEND_DATE,20) DESC)
END

IF NOT @LI_BUDGET_FORM_ID>0 OR @LI_BUDGET_FORM_ID IS NULL
	RETURN 0

SET @LI_TIME=(SELECT FTIME FROM T_BUDGET_FORM_DETAIL WITH(NOLOCK) WHERE FID=@LI_BUDGET_FORM_ID AND FBUDGET_ITEM_ID=@LI_BUDGET_ITEM_ID AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID)

IF @LI_TIME IS NULL
	RETURN 0

SET @LM_BUDGET=(
SELECT
TOP 1
DBO.F_BUDGET_GET_VALUE('总预算',@LI_BUDGET_CENTER_ID,CONVERT(VARCHAR(10),@LS_DATE,20),@LI_BUDGET_ITEM_ID,@LI_ASSISTANT_ITEM_ID)
FROM T_SYSPROFILE WITH(NOLOCK)
)

--IF (NOT @LM_BUDGET>0) OR @LM_BUDGET IS NULL
--	RETURN 0

IF LEFT(@LS_COST_CENTER_CODE,6) IN ('913005','913006') AND LEFT(@LS_DATE,4)='2011'
	SET @LS_START_DATE='2011-03' --电机这边上述两个车间的预算是从3月开始做的，之前都只做到上级分厂
ELSE
	SET @LS_START_DATE=(SELECT CONVERT(VARCHAR(7),F.FYEAR_TARGET_START_DATE,20) FROM T_BUDGET_FORM_HEADER AS F WITH(NOLOCK)
	WHERE F.FID=@LI_BUDGET_FORM_ID)

SET @LS_END_DATE=(SELECT CONVERT(VARCHAR(7),F.FYEAR_TARGET_END_DATE,20) FROM T_BUDGET_FORM_HEADER AS F WITH(NOLOCK)
WHERE F.FID=@LI_BUDGET_FORM_ID)

SET @LM_REMAIN_ALLOCATE=
(
SELECT
TOP 1
DBO.F_BUDGET_GET_VALUE('已审核总下拨',@LI_BUDGET_CENTER_ID,CONVERT(VARCHAR(10),@LS_DATE,20),@LI_BUDGET_ITEM_ID,@LI_ASSISTANT_ITEM_ID)
-
DBO.F_BUDGET_GET_VALUE('总报账',@LI_BUDGET_CENTER_ID,CONVERT(VARCHAR(10),@LS_DATE,20),@LI_BUDGET_ITEM_ID,@LI_ASSISTANT_ITEM_ID)
-
ISNULL((
SELECT
SUM(CASE ISNULL(H.FROB,0) WHEN 0 THEN I.FAMOUNT ELSE I.FAMOUNT * -1 END)
FROM TIC_INSTOCKITEMS I WITH(NOLOCK)
INNER JOIN TIC_INSTOCK H WITH(NOLOCK) ON I.FID=H.FID
INNER JOIN T_ICTRANSTYPE T WITH(NOLOCK) ON T.FTRANSTYPE=H.FTRANSTYPE
WHERE
1=1
AND CONVERT(VARCHAR(7),H.FDATE,20)>=LEFT(@LS_START_DATE,7)
AND CONVERT(VARCHAR(7),H.FDATE,20)<=LEFT(@LS_END_DATE,7)
AND T.FDOCTYPE=12
AND T.FINOUT=1
AND H.FSTATE=2
AND I.FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
AND EXISTS(
SELECT
*
FROM T_COSTCENTER_TELEMENT R WITH(NOLOCK)
WHERE
R.FBUDGET_CENTER_ID=@LI_BUDGET_CENTER_ID
AND R.FBUDGET_ITEM_ID=@LI_BUDGET_ITEM_ID
AND R.FCOSTCENTERID=H.FBILLOBJID
AND R.FCOSTELEMENTID=I.FCOSTOBJID
)
AND (I.FBUDGET_REPORT_ID IS NULL OR (NOT I.FBUDGET_REPORT_ID>0))
AND EXISTS(
SELECT
*
FROM TIC_INVAMOUNT V WITH(NOLOCK)
WHERE
H.FID=V.FSCDOCID
AND I.FROW=V.FSCDOCITEMID
)
),0)
FROM T_SYSPROFILE WITH(NOLOCK))

IF  @LM_REMAIN_ALLOCATE IS NULL
	SET @LM_REMAIN_ALLOCATE=0

RETURN @LM_REMAIN_ALLOCATE

End
