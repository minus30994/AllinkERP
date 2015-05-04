
-- =============================================
-- Author: 郭凯斌
-- Create Date: 2013-06-07
-- Description: 返回某个预算项目(辅助项目)的当前年度指标
-- =============================================

Create Function F_Budget_Get_Current_Year_Target(
@Year INT, -- 年度
@Budget_Center_ID INT, -- 预算中心ID
@Budget_Item_ID INT, -- 预算项目ID
@Assistant_Item_ID INT -- 辅助项目ID
)
Returns Decimal(18,4)
As
Begin

Declare @Return Decimal(18,4)

If (Not @Year>0) Or @Year Is Null
Return Null

If (Not @Budget_Center_ID>0) Or @Budget_Center_ID Is Null
Return Null

If (Not @Budget_Item_ID>0) Or @Budget_Item_ID Is Null
Return Null

If @Assistant_Item_ID Is Null
Begin
	Set @Assistant_Item_ID = 0
End

If IsNull(@Assistant_Item_ID,0)>=0
Begin
	Set @Return=IsNull((
	Select
	Sum(D.FAudit_Amount)
	From T_Budget_Year_Target_Submit_H H With(NoLock)
	Inner Join T_Budget_Year_Target_Submit_D D With(NoLock) On D.FID=H.FID
	Where
	1=1
	And IsNull(H.FState,0)=2
	And IsNull(H.FYear,0)=@Year
	And H.FBudget_Center_ID=@Budget_Center_ID
	And D.FBudget_Item_ID=@Budget_Item_ID
	And D.FAssistant_Item_ID=@Assistant_Item_ID
	),0)
End
Else
Begin
	Set @Return=IsNull((
	Select
	Sum(D.FAudit_Amount)
	From T_Budget_Year_Target_Submit_H H With(NoLock)
	Inner Join T_Budget_Year_Target_Submit_D D With(NoLock) On D.FID=H.FID
	Where
	1=1
	And IsNull(H.FState,0)=2
	And IsNull(H.FYear,0)=@Year
	And H.FBudget_Center_ID=@Budget_Center_ID
	And D.FBudget_Item_ID=@Budget_Item_ID
	),0)
End

Return @Return

End
