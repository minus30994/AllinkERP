﻿
-- =============================================
-- AUTHOR: 郭凯斌
-- CREATE DATE: 2013-11-07
-- DESCRIPTION: 预算调整审核
-- =============================================
Create Procedure P_Budget_Adjust_Commit(
-- ADD THE PARAMETERS FOR THE STORED PROCEDURE HERE
@LS_CATEGORY VARCHAR(200),
@LI_BUDGET_ADJUST_ID INT
)
AS

BEGIN

-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
-- INTERFERING WITH SELECT STATEMENTS.

SET NOCOUNT ON;

-- INSERT STATEMENTS FOR PROCEDURE HERE

DECLARE @LI_BUDGET_FORM_ID INT
DECLARE @LI_BUDGET_ITEM_ID INT
DECLARE @LI_ASSISTANT_ITEM_ID INT
DECLARE @LI_TIME TINYINT
DECLARE @LS_DATE VARCHAR(7)
DECLARE @LD_VALUE MONEY
DECLARE @LS_YEAR VARCHAR(4)
DECLARE @LS_PERIOD VARCHAR(2)
DECLARE @LS_COLUMN VARCHAR(200)
DECLARE @LS_COLUMN_YEAR VARCHAR(200)
DECLARE @LS_COLUMN_SEASON VARCHAR(200)
DECLARE @LI_PARENT_BUDGET_ITEM_ID INT

SET @LI_BUDGET_FORM_ID=(SELECT FBUDGET_FORM_ID FROM T_BUDGET_ADJUST_HEADER WITH(NOLOCK) WHERE FID=@LI_BUDGET_ADJUST_ID)

IF @LI_BUDGET_FORM_ID IS NULL OR (NOT @LI_BUDGET_FORM_ID>0)
	RETURN

DECLARE LDS_ADJUST_DETAIL CURSOR FOR
SELECT
D.FBUDGET_ITEM_ID,
D.FASSISTANT_ITEM_ID,
(
SELECT
FD.FTIME
FROM T_BUDGET_FORM_DETAIL FD WITH(NOLOCK)
WHERE
1=1
AND FD.FID=H.FBUDGET_FORM_ID
AND FD.FBUDGET_ITEM_ID=D.FBUDGET_ITEM_ID
AND FD.FASSISTANT_ITEM_ID=D.FASSISTANT_ITEM_ID
),
CONVERT(VARCHAR(7),D.FDATE,20),
D.FVALUE
FROM T_BUDGET_ADJUST_DETAIL D WITH(NOLOCK)
INNER JOIN T_BUDGET_ADJUST_HEADER H WITH(NOLOCK) ON H.FID=D.FID
WHERE
D.FID=@LI_BUDGET_ADJUST_ID

OPEN LDS_ADJUST_DETAIL

FETCH NEXT FROM LDS_ADJUST_DETAIL
INTO
@LI_BUDGET_ITEM_ID,
@LI_ASSISTANT_ITEM_ID,
@LI_TIME,
@LS_DATE,
@LD_VALUE

WHILE @@FETCH_STATUS=0
BEGIN
	SET @LS_COLUMN=NULL
	SET @LS_COLUMN_YEAR=NULL
	SET @LS_COLUMN_SEASON=NULL
	SET @LI_PARENT_BUDGET_ITEM_ID=NULL
	
	IF @LI_TIME=0
	BEGIN
		SET @LS_YEAR=(SELECT CONVERT(VARCHAR(4),FYEAR) FROM T_ACCOUNTPERIOD WITH(NOLOCK)
		WHERE
		CONVERT(VARCHAR(7),FBEGDATE,20)<=@LS_DATE
		AND CONVERT(VARCHAR(7),FENDDATE,20)>=@LS_DATE)
		
		SET @LS_COLUMN='BY000000'+@LS_YEAR+'00'
	END
	IF @LI_TIME=1
	BEGIN
		SET @LS_YEAR=(SELECT CONVERT(VARCHAR(4),FYEAR) FROM T_ACCOUNTPERIOD WITH(NOLOCK)
		WHERE
		CONVERT(VARCHAR(7),FBEGDATE,20)<=@LS_DATE
		AND CONVERT(VARCHAR(7),FENDDATE,20)>=@LS_DATE)
		
		SET @LS_PERIOD=(SELECT CONVERT(VARCHAR(2),FPERIOD) FROM T_ACCOUNTPERIOD WITH(NOLOCK)
		WHERE
		CONVERT(VARCHAR(7),FBEGDATE,20)<=@LS_DATE
		AND CONVERT(VARCHAR(7),FENDDATE,20)>=@LS_DATE)
		
		IF LEN(@LS_PERIOD)=1
			SET @LS_PERIOD='0'+@LS_PERIOD
		
		IF @LS_PERIOD IN ('01','02','03')
			SET @LS_COLUMN='BS000000'+@LS_YEAR+'01'
		IF @LS_PERIOD IN ('04','05','06')
			SET @LS_COLUMN='BS000000'+@LS_YEAR+'02'
		IF @LS_PERIOD IN ('07','08','09')
			SET @LS_COLUMN='BS000000'+@LS_YEAR+'03'
		IF @LS_PERIOD IN ('10','11','12')
			SET @LS_COLUMN='BS000000'+@LS_YEAR+'04'
	END
	IF @LI_TIME=2
	BEGIN
		SET @LS_YEAR=(SELECT CONVERT(VARCHAR(4),FYEAR) FROM T_ACCOUNTPERIOD WITH(NOLOCK)
		WHERE
		CONVERT(VARCHAR(7),FBEGDATE,20)<=@LS_DATE
		AND CONVERT(VARCHAR(7),FENDDATE,20)>=@LS_DATE)
		
		SET @LS_PERIOD=(SELECT CONVERT(VARCHAR(2),FPERIOD) FROM T_ACCOUNTPERIOD WITH(NOLOCK)
		WHERE
		CONVERT(VARCHAR(7),FBEGDATE,20)<=@LS_DATE
		AND CONVERT(VARCHAR(7),FENDDATE,20)>=@LS_DATE)
		
		IF LEN(@LS_PERIOD)=1
			SET @LS_PERIOD='0'+@LS_PERIOD
		
		SET @LS_COLUMN='BM'+LEFT(@LS_DATE,4)+RIGHT(@LS_DATE,2)+@LS_YEAR+@LS_PERIOD
	END
	
	SET @LI_PARENT_BUDGET_ITEM_ID=@LI_BUDGET_ITEM_ID
	WHILE @LI_PARENT_BUDGET_ITEM_ID>0 AND NOT @LI_PARENT_BUDGET_ITEM_ID IS NULL
	BEGIN
		IF EXISTS(SELECT
		1
		FROM T_BUDGET_FORM_DETAIL WITH(NOLOCK)
		WHERE
		1=1
		AND FID=@LI_BUDGET_FORM_ID
		AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
		AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
		)
		BEGIN
			
			IF @LS_CATEGORY='审核'
			BEGIN
				UPDATE T_BUDGET_FORM_VALUE SET FVALUE=ISNULL(FVALUE,0)+@LD_VALUE
				WHERE
				FID=@LI_BUDGET_FORM_ID
				AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
				AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
				AND FCOLUMN=@LS_COLUMN
			END
			IF @LS_CATEGORY='反审核'
			BEGIN
				UPDATE T_BUDGET_FORM_VALUE SET FVALUE=ISNULL(FVALUE,0) -@LD_VALUE
				WHERE
				FID=@LI_BUDGET_FORM_ID
				AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
				AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
				AND FCOLUMN=@LS_COLUMN
			END
			
			IF @LI_TIME IN (1,2)
			BEGIN
				SET @LS_COLUMN_YEAR='BY000000'+@LS_YEAR+'00'
				
				IF @LS_CATEGORY='审核'
				BEGIN
					UPDATE T_BUDGET_FORM_VALUE SET FVALUE=ISNULL(FVALUE,0)+@LD_VALUE
					WHERE
					FID=@LI_BUDGET_FORM_ID
					AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
					AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
					AND FCOLUMN=@LS_COLUMN_YEAR
				END
				IF @LS_CATEGORY='反审核'
				BEGIN
					UPDATE T_BUDGET_FORM_VALUE SET FVALUE=ISNULL(FVALUE,0) -@LD_VALUE
					WHERE
					FID=@LI_BUDGET_FORM_ID
					AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
					AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
					AND FCOLUMN=@LS_COLUMN_YEAR
				END
			END
			IF @LI_TIME=2
			BEGIN
				IF @LS_PERIOD IN ('01','02','03')
					SET @LS_COLUMN_SEASON='BS000000'+@LS_YEAR+'01'
				IF @LS_PERIOD IN ('04','05','06')
					SET @LS_COLUMN_SEASON='BS000000'+@LS_YEAR+'02'
				IF @LS_PERIOD IN ('07','08','09')
					SET @LS_COLUMN_SEASON='BS000000'+@LS_YEAR+'03'
				IF @LS_PERIOD IN ('10','11','12')
					SET @LS_COLUMN_SEASON='BS000000'+@LS_YEAR+'04'
				
				IF @LS_CATEGORY='审核'
				BEGIN
					UPDATE T_BUDGET_FORM_VALUE SET FVALUE=ISNULL(FVALUE,0)+@LD_VALUE
					WHERE
					FID=@LI_BUDGET_FORM_ID
					AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
					AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
					AND FCOLUMN=@LS_COLUMN_SEASON
				END
				IF @LS_CATEGORY='反审核'
				BEGIN
					UPDATE T_BUDGET_FORM_VALUE SET FVALUE=ISNULL(FVALUE,0) -@LD_VALUE
					WHERE
					FID=@LI_BUDGET_FORM_ID
					AND FBUDGET_ITEM_ID=@LI_PARENT_BUDGET_ITEM_ID
					AND FASSISTANT_ITEM_ID=@LI_ASSISTANT_ITEM_ID
					AND FCOLUMN=@LS_COLUMN_SEASON
				END
			END
		END
		
		SET @LI_PARENT_BUDGET_ITEM_ID=(SELECT FPARENT_ID FROM T_BUDGET_ITEM WITH(NOLOCK) WHERE FID=@LI_PARENT_BUDGET_ITEM_ID)
	END
		
	FETCH NEXT FROM LDS_ADJUST_DETAIL
	INTO
	@LI_BUDGET_ITEM_ID,
	@LI_ASSISTANT_ITEM_ID,
	@LI_TIME,
	@LS_DATE,
	@LD_VALUE
	
END

CLOSE LDS_ADJUST_DETAIL
DEALLOCATE LDS_ADJUST_DETAIL

End
