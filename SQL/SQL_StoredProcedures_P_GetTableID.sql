
-- =============================================
-- Author: 郭凯斌
-- Create Date: 2013-06-07
-- Description: 获取单据ID存储过程
-- =============================================

Create Procedure P_GetTableID (
@TableName VARCHAR(50), --表名
@ID INT OutPut --ID
) As
Begin
	Select @ID=FCURRID From T_TableID With(NoLock) Where FTable=@TableName
	
	If @ID>0
	Begin
		Update T_TableID Set FCURRID=FCURRID+1 Where FTable=@TableName
		
		If @@Error=0
		Begin
			Set @ID=@ID+1
		End
		Else
		Begin
			Set @ID=1
		End
	End
	Else
	Begin
		Delete From T_TableID Where FTable=@TableName
		
		If @@Error<>0
		Begin
			Set @ID=1
			Return @ID
		End
		
		Insert Into T_TableID(FTable,FCURRID) Values(@TableName,1000)

		If @@Error=0
		Begin
			Set @ID=1000
		End
		Else
		Begin
			Set @ID=1
		End
	End
	
	Return @ID
End
