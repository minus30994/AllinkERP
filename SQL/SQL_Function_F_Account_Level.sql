
-- =============================================
-- Author: 郭凯斌
-- Create Date: 2013-06-07
-- Description: 获取会计科目层级
-- =============================================

Create  Function F_Account_Level (
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

Set @Parent_ID=(Select FParentID From T_Account With(NoLock) Where FACCID=@ID)

If Lower(@Field)='id'
Set @Return=' '+(Select Cast(FACCID As VARCHAR(20)) From T_Account With(NoLock) Where FACCID=@ID)+' '

If Lower(@Field)='编码'
Set @Return=' '+(Select IsNull(FAccountNo,'') From T_Account With(NoLock) Where FACCID=@ID)+' '

If Lower(@Field)='名称'
Set @Return=' '+(Select IsNull(FAccountName,'') From T_Account With(NoLock) Where FACCID=@ID)+' '

If (Not @Parent_ID>0) or @Parent_ID Is Null

Return @Return

While @Parent_ID>0 And Not @Parent_ID Is Null
Begin
	If Lower(@Field)='id'
	Set @Return=' '+(Select Cast(FACCID As VARCHAR(20)) From T_Account With(NoLock) Where FACCID=@Parent_ID)+' ,'+@Return
	
	If Lower(@Field)='编码'
	Set @Return=' '+(Select IsNull(FAccountNo,'') From T_Account With(NoLock) Where FACCID=@Parent_ID)+' ,'+@Return
	
	If Lower(@Field)='名称'
	Set @Return=' '+(Select IsNull(FAccountName,'') From T_Account With(NoLock) Where FACCID=@Parent_ID)+' ,'+@Return
	
	Set @Parent_ID=(Select FParentID From T_Account With(NoLock) Where FACCID=@Parent_ID)
End

Return @Return

End
