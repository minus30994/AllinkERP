
-- =============================================
-- Author: 郭凯斌
-- Create Date: 2013-06-07
-- Description: 获取预算中心层级
-- =============================================

Create  Function F_Budget_Center_Level (
@ID INT, --ID
@Field VARCHAR(10) --显示的字段，可填写'ID','编码','名称'
)
Returns VARCHAR(200)
As
Begin

Declare @Return VARCHAR(200)

Declare @Parent_ID INT

If (Not @ID>0) Or @ID Is Null

Return Null

Set @Parent_ID=(Select FParent_ID From T_Budget_Center With(NoLock) Where FID=@ID)

If Lower(@Field)='id'
Set @Return=' '+(Select Cast(FID As VARCHAR(20)) From T_Budget_Center With(NoLock) Where FID=@ID)+' '

If Lower(@Field)='编码'
Set @Return=' '+(Select IsNull(FNO,'') From T_Budget_Center With(NoLock) Where FID=@ID)+' '

If Lower(@Field)='名称'
Set @Return=' '+(Select IsNull(FName,'') From T_Budget_Center With(NoLock) Where FID=@ID)+' '

If (Not @Parent_ID>0) or @Parent_ID Is Null

Return @Return

While @Parent_ID>0 And Not @Parent_ID Is Null
Begin
	If Lower(@Field)='id'
	Set @Return=' '+(Select Cast(FID As VARCHAR(20)) From T_Budget_Center With(NoLock) Where FID=@Parent_ID)+' ,'+@Return
	
	If Lower(@Field)='编码'
	Set @Return=' '+(Select IsNull(FNO,'') From T_Budget_Center With(NoLock) Where FID=@Parent_ID)+' ,'+@Return
	
	If Lower(@Field)='名称'
	Set @Return=' '+(Select IsNull(FName,'') From T_Budget_Center With(NoLock) Where FID=@Parent_ID)+' ,'+@Return
	
	Set @Parent_ID=(Select FParent_ID From T_Budget_Center With(NoLock) Where FID=@Parent_ID)
End

Return @Return

End
