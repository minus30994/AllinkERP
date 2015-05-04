
-- =============================================
-- Author: 郭凯斌
-- Create Date: 2013-06-07
-- Description: 返回某个预算项目(辅助项目)的预算/下拨/报账数据(加锁)
-- =============================================

Create Function F_Budget_Get_Value_Lock(
@Category VARCHAR(255), -- 取数类型
@Budget_Center_ID INT, -- 预算中心ID
@Date VARCHAR(10), -- 日期
@Budget_Item_ID INT, -- 预算项目ID
@Assistant_Item_ID INT -- 辅助项目ID
)
Returns Decimal(18,4)
As
Begin

Declare @Return Decimal(18,4)

Declare @Year_Target Decimal(18,4)

Declare @Account_Year VARCHAR(4)

Declare @Account_Period VARCHAR(2)

Declare @Value Decimal(18,4)

Declare @Budget_Form_ID INT

Declare @Time TinyInt

Declare @Column VARCHAR(255)

Declare @Start_Date VARCHAR(10)

Declare @End_Date VARCHAR(10)

Declare @Year_Target_Start_Date VARCHAR(10)

Declare @Year_Target_End_Date VARCHAR(10)

Declare @Ignore VARCHAR(255)

Declare @ID_Array VARCHAR(4000)

Declare @Position TinyInt

If CharIndex(' ',@Category)>0 And Len(@Category)>0 And (Not @Category Is Null)
Begin
	Set @Position=CharIndex(' ',@Category)
	Set @ID_Array=Right(@Category,Len(@Category) -@Position)
	Set @Category=Left(@Category,@Position -1)
End

If @Assistant_Item_ID Is Null
Begin
	Set @Assistant_Item_ID=0
End

Set @Account_Year=(
Select
Convert(VARCHAR(4),FYear)
From T_AccountPeriod With(NoLock)
Where
1=1
And Convert(VARCHAR(7),FBegDate,20)<=Left(@Date,7)
And Convert(VARCHAR(7),FEndDate,20)>=Left(@Date,7)
)

Set @Account_Period=(
Select
Right('0'+Convert(VARCHAR(2),FPeriod),2)
From T_AccountPeriod With(NoLock)
Where
1=1
And Convert(VARCHAR(7),FBegDate,20)<=Left(@Date,7)
And Convert(VARCHAR(7),FEndDate,20)>=Left(@Date,7)
)

If (Not Len(IsNull(@Account_Year,''))>0)
Or (Not Len(IsNull(@Account_Period,''))>0)
	Return 0

Set @Budget_Form_ID=(
Select
H.FID
From T_Budget_Form_Detail D With(NoLock)
Inner Join T_Budget_Form_Header H With(NoLock) On D.FID=H.FID
Where
1=1
And Convert(VARCHAR(7),H.FStart_Date,20)<=Left(@Date,7)
And Convert(VARCHAR(7),H.FEnd_Date,20)>=Left(@Date,7)
And H.FBudget_Center_ID=@Budget_Center_ID
And D.FBudget_Item_ID=@Budget_Item_ID
And D.FAssistant_Item_ID=@Assistant_Item_ID
)

Set @Ignore=(
Select
FValue
From T_SYSProfile With(NoLock)
Where
1=1
And Lower(FSubSYS)=Lower('Budget')
And FAliasName='预算报账-忽略报表/下拨'
)

If (
1<>1
Or (Not @Budget_Form_ID>0)
Or @Budget_Form_ID Is Null
)
And @Ignore='是'
Begin
	Set @Budget_Form_ID=(
	Select
	Top 1
	H.FID
	From T_Budget_Form_Detail D With(NoLock)
	Inner Join T_Budget_Form_Header H With(NoLock) On D.FID=H.FID
	Where
	1=1
	And Convert(VARCHAR(7),H.FYear_Target_Start_Date,20)<=Left(@Date,7)
	And Convert(VARCHAR(7),H.FYear_Target_End_Date,20)>=Left(@Date,7)
	And H.FBudget_Center_ID=@Budget_Center_ID
	And D.FBudget_Item_ID=@Budget_Item_ID
	And D.FAssistant_Item_ID=@Assistant_Item_ID
	Order By
	Convert(VARCHAR(7),H.FStart_Date,20)+'-'+Convert(VARCHAR(7),H.FEnd_Date,20) DESC
	)
End

If Not IsNull(@Budget_Form_ID,0)>0
	Return 0

Set @Time=(
Select
FTime
From T_Budget_Form_Detail With(NoLock)
Where
1=1
And FID=@Budget_Form_ID
And FBudget_Item_ID=@Budget_Item_ID
And FAssistant_Item_ID=@Assistant_Item_ID
)

If @Time Is Null
	Return 0

Set @Year_Target_Start_Date=(
Select
Convert(VARCHAR(10),FYear_Target_Start_Date,20)
From T_Budget_Form_Header With(NoLock)
Where
1=1
And FID=@Budget_Form_ID
)

Set @Year_Target_End_Date=(
Select
Convert(VARCHAR(10),FYear_Target_End_Date,20)
From T_Budget_Form_Header With(NoLock)
Where
1=1
And FID=@Budget_Form_ID
)

If @Category In ('指定成本中心，成本要素管理用料总发生额')
Begin
	
	Set @Return=IsNull((
	Select
	Sum(Case IsNull(H.Frob,0) When 0 Then I.FAmount Else I.FAmount * -1 End)
	From TIC_InstockItems I With(TABLock)
	Inner Join TIC_Instock H With(NoLock) On I.FID=H.FID
	Inner Join T_ICTransType T With(NoLock) On T.FTransType=H.Ftranstype
	Inner Join T_Material M With(NoLock) On M.FMaterialID=I.FMaterialID
	Inner Join T_CostCenter C With(NoLock) On C.FCostCenterID=H.FBillOBJID
	Inner Join T_CO_CostElement E With(NoLock) On E.FCostElementID=I.FCostOBJID
	Inner Join TIC_INVAmount V With(NoLock) On H.FID=V.FSCDOCID And I.FRow=V.FSCDOCItemID
	Where
	1=1
	And T.FDOCType=12
	And T.FInOut=1
	And H.FState=2
	And C.FCostCenterID=@Budget_Center_ID
	And E.FCostElementID=@Budget_Item_ID
	And I.FAssistant_Item_ID=@Assistant_Item_ID
	And ((
	Left(C.FCCNO,6) In ('913005','913006')
	And Left(@Date,4)='2011'
	And Convert(VARCHAR(7),H.FDate,20)>='2011-03'
	)
	Or
	(
	(Not (Left(C.FCCNO,6) In ('913005','913006')
	And Left(@Date,4)='2011'))
	And Convert(VARCHAR(4),H.FDate,20)=Left(@Date,4)
	))
	And (
	(I.FBudget_Report_ID Is Null Or (Not I.FBudget_Report_ID>0))
	Or (Not Exists(
	Select
	R.FID
	From T_Budget_Report_Header R With(NoLock)
	Where
	R.FID=I.FBudget_Report_ID
	)
	)
	)
	),0)
	
	Return @Return
End

If @Category In ('剩余年度指标')
Begin
	If @Assistant_Item_ID>=0
	Begin
		Set @Year_Target=(
		Select
		Sum(IsNull(FYear_Target,0))
		From T_Budget_Form_Detail With(TABLock)
		Where
		1=1
		And FID=@Budget_Form_ID
		And FBudget_Item_ID=@Budget_Item_ID
		And FAssistant_Item_ID=@Assistant_Item_ID
		)
	End	
	Else
	Begin
		Set @Year_Target=(
		Select
		Sum(IsNull(FYear_Target,0))
		From T_Budget_Form_Detail With(TABLock)
		Where
		1=1
		And FID=@Budget_Form_ID
		And FBudget_Item_ID=@Budget_Item_ID
		And IsNull(FAssistant_Item_ID,0)=0
		)
	End	
	
	Set @Column='by000000'+@Account_Year+'00'
	
	If @Assistant_Item_ID>=0
	Begin
		Set @Return=@Year_Target -IsNull((
		Select
		Sum(V.FValue)
		From T_Budget_Form_Value V With(TABLock)
		Inner Join T_Budget_Form_Header H With(NoLock) On V.FID=H.FID
		Where
		1=1
		And H.FID<>@Budget_Form_ID
		And H.FBudget_Center_ID=@Budget_Center_ID
		And V.FBudget_Item_ID=@Budget_Item_ID
		And V.FAssistant_Item_ID=@Assistant_Item_ID
		And V.FColumn=@Column
		And Convert(VARCHAR(10),H.FYear_Target_Start_Date,20)<=@Date
		And Convert(VARCHAR(10),H.FYear_Target_End_Date,20)>=@Date
		),0)
	End
	Else
	Begin
		Set @Return=@Year_Target -IsNull((
		Select
		Sum(V.FValue)
		From T_Budget_Form_Value V With(TABLock)
		Inner Join T_Budget_Form_Header H With(NoLock) On V.FID=H.FID
		Where
		1=1
		And H.FID<>@Budget_Form_ID
		And H.FBudget_Center_ID=@Budget_Center_ID
		And V.FBudget_Item_ID=@Budget_Item_ID
		And IsNull(V.FAssistant_Item_ID,0)=0
		And V.FColumn=@Column
		And Convert(VARCHAR(10),H.FYear_Target_Start_Date,20)<=@Date
		And Convert(VARCHAR(10),H.FYear_Target_End_Date,20)>=@Date
		),0)
	End
	
	Return @Return
End

If @Category='年度指标'
Begin
	If IsNull(@Assistant_Item_ID,0)>=0
	Begin
		Set @Return=IsNull((
		Select
		Max(D.FYear_Target)
		From T_Budget_Form_Detail D With(TABLock)
		Inner Join T_Budget_Form_Header H With(NoLock) On H.FID=D.FID
		Where
		1=1
		And H.FID=@Budget_Form_ID
		And D.FBudget_Item_ID=@Budget_Item_ID
		And D.FAssistant_Item_ID=@Assistant_Item_ID
		And Convert(VARCHAR(7),H.FYear_Target_Start_Date,20)<=Left(@Date,7)
		And Convert(VARCHAR(7),H.FYear_Target_End_Date,20)>=Left(@Date,7)
		),0)
	End
	Else
	Begin
		Set @Return=IsNull((
		Select
		Max(D.FYear_Target)
		From T_Budget_Form_Detail D With(TABLock)
		Inner Join T_Budget_Form_Header H With(NoLock) On H.FID=D.FID
		Where
		1=1
		And H.FID=@Budget_Form_ID
		And D.FBudget_Item_ID=@Budget_Item_ID
		And IsNull(D.FAssistant_Item_ID,0)=0
		And Convert(VARCHAR(7),H.FYear_Target_Start_Date,20)<=Left(@Date,7)
		And Convert(VARCHAR(7),H.FYear_Target_End_Date,20)>=Left(@Date,7)
		),0)
	End
	
	Return @Return
End

If @Category In ('预算','已下拨')
Begin
	
	If @Time=0
	Begin
		Set @Column='by000000'+@Account_Year+'00'
	End
	
	If @Time=1
	Begin
		If @Account_Period In ('01','02','03')
			Set @Column='bs000000'+@Account_Year+'01'
		If @Account_Period In ('04','05','06')
			Set @Column='bs000000'+@Account_Year+'02'
		If @Account_Period In ('07','08','09')
			Set @Column='bs000000'+@Account_Year+'03'
		If @Account_Period In ('10','11','12')
			Set @Column='bs000000'+@Account_Year+'04'
	End
	
	If @Time=2
	Begin
		Set @Column='bm'+Left(@Date,4)+SubString(@Date,6,2)+@Account_Year+@Account_Period
	End
	
	If @Category='预算'
	Begin
		Set @Return=IsNull((
		Select
		V.FValue
		From T_Budget_Form_Value V With(TABLock)
		Inner Join T_Budget_Form_Header H With(NoLock) On V.FID=H.FID
		Where
		1=1
		And V.FID=@Budget_Form_ID
		And V.FBudget_Item_ID=@Budget_Item_ID
		And IsNull(V.FAssistant_Item_ID,0)=@Assistant_Item_ID
		And V.FColumn=@Column
		And Convert(VARCHAR(7),H.FStart_Date,20)<=Left(@Date,7)
		And Convert(VARCHAR(7),H.FEnd_Date,20)>=Left(@Date,7)
		),0)
		
		Return @Return
	End
	
	If @Category='已下拨'
	Begin
		If @Time=0
		Begin
			Set @Start_Date=(
			Select
			Convert(VARCHAR(7),Min(P.FBegDate),20)
			From T_AccountPeriod P With(NoLock)
			Where
			1=1
			And P.FYear=(
			Select
			P1.FYear
			From T_AccountPeriod P1 With(NoLock)
			Where
			1=1
			And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
			And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
			)
			)
			
			Set @End_Date=(
			Select
			Convert(VARCHAR(7),Max(P.FEndDate),20)
			From T_AccountPeriod P With(NoLock)
			Where
			1=1
			And P.FYear=(
			Select
			P1.FYear
			From T_AccountPeriod P1 With(NoLock)
			Where
			1=1
			And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
			And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
			)
			)
			
			If @Assistant_Item_ID>=0 
				Set @Return=IsNull((
				Select
				Sum(D.FValue)
				From T_Budget_Allocate_Detail D With(TABLock)
				Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
				Where
				1=1
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And D.FAssistant_Item_ID=@Assistant_Item_ID
				And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
				),0)
			Else
				Set @Return=IsNull((
				Select
				Sum(D.FValue)
				From T_Budget_Allocate_Detail D With(TABLock)
				Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
				Where
				1=1
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
				),0)
		End
		
		If @Time=1
		Begin
			If @Account_Period In ('01','02','03')
			Begin
				Set @Start_Date=(
				Select
				Convert(VARCHAR(7),Min(P.FBegDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (1,2,3)
				)
				
				Set @End_Date=(
				Select
				Convert(VARCHAR(7),Max(P.FEndDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (1,2,3)
				)
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID
					),0)
				Else
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					),0)
			End
			If @Account_Period In ('04','05','06')
			Begin
				Set @Start_Date=(
				Select
				Convert(VARCHAR(7),Min(P.FBegDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (4,5,6)
				)
				
				Set @End_Date=(
				Select
				Convert(VARCHAR(7),Max(P.FEndDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (4,5,6)
				)
				
				If @Assistant_Item_ID>=0  
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID
					),0)
				Else
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					),0)
			End
			If @Account_Period In ('07','08','09')
			Begin
				Set @Start_Date=(
				Select
				Convert(VARCHAR(7),Min(P.FBegDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (7,8,9)
				)
				
				Set @End_Date=(
				Select
				Convert(VARCHAR(7),Max(P.FEndDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (7,8,9)
				)
				
				If @Assistant_Item_ID>=0  
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID
					),0)
				Else
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					),0)
			End
			If @Account_Period In ('10','11','12')
			Begin
				Set @Start_Date=(
				Select
				Convert(VARCHAR(7),Min(P.FBegDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (10,11,12)
				)
				
				Set @End_Date=(
				Select
				Convert(VARCHAR(7),Max(P.FEndDate),20)
				From T_AccountPeriod P With(NoLock)
				Where
				1=1
				And P.FYear=(
				Select
				P1.FYear
				From T_AccountPeriod P1 With(NoLock)
				Where
				1=1
				And Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
				And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
				)
				And P.FPeriod In (10,11,12)
				)

				If @Assistant_Item_ID>=0
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID
					),0)
				Else
					Set @Return=IsNull((
					Select
					Sum(D.FValue)
					From T_Budget_Allocate_Detail D With(TABLock)
					Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
					Where
					1=1
					And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					),0)
			End
		End
		
		If @Time=2
		Begin
			If @Assistant_Item_ID>=0
				Set @Return=IsNull((
				Select
				Sum(D.FValue)
				From T_Budget_Allocate_Detail D With(TABLock)
				Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
				Where
				1=1
				And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)=Left(@Date,7)
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And D.FAssistant_Item_ID=@Assistant_Item_ID
				),0)
			Else
				Set @Return=IsNull((
				Select
				Sum(D.FValue)
				From T_Budget_Allocate_Detail D With(TABLock)
				Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock) On F.FID=@Budget_Form_ID
				Where
				1=1
				And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)=Left(@Date,7)
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				),0)	
		End
				
		Return @Return
	End
End

If @Category In ('下拨','已报账')
Begin
	
	If @Category='下拨'
	Begin
		If @Time=0
		Begin
			Set @Start_Date=(Select Convert(VARCHAR(7),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
			Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
			Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)))
			
			Set @End_Date=(Select Convert(VARCHAR(7),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
			Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
			Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)))
			
			If @Assistant_Item_ID>=0 
				Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock)
				On F.FID=@Budget_Form_ID
				Where
				H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And D.FAssistant_Item_ID=@Assistant_Item_ID
				And H.FState=2
				And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)),0)
			Else
				Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock)
				On F.FID=@Budget_Form_ID
				Where
				H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And H.FState=2
				And Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)),0)
		End
		
		If @Time=1
		Begin
			If @Account_Period In ('01','02','03')
			Begin
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (1,2,3))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (1,2,3))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
			End
			If @Account_Period In ('04','05','06')
			Begin
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (4,5,6))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (4,5,6))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
			End
			If @Account_Period In ('07','08','09')
			Begin
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (7,8,9))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (7,8,9))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
			End
			If @Account_Period In ('10','11','12')
			Begin
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (10,11,12))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (10,11,12))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
					Inner Join T_Budget_Form_Header F With(NoLock)
					On F.FID=@Budget_Form_ID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
					And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FState=2
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
			End
		End
		
		If @Time=2
		Begin
			If @Assistant_Item_ID>=0 
				Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock)
				On F.FID=@Budget_Form_ID
				Where
				Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)=Left(@Date,7)
				And H.FState=2
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
			Else
				Set @Return=IsNull((Select Sum(D.FValue) From T_Budget_Allocate_Detail D With(TABLock) Inner Join T_Budget_Allocate_Header H With(NoLock) On D.FID=H.FID
				Inner Join T_Budget_Form_Header F With(NoLock)
				On F.FID=@Budget_Form_ID
				Where
				Convert(VARCHAR(7),H.FDate,20)>=Convert(VARCHAR(7),F.FStart_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)<=Convert(VARCHAR(7),F.FEnd_Date,20)
				And Convert(VARCHAR(7),H.FDate,20)=Left(@Date,7)
				And H.FState=2
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID),0)
		End
		
		Return @Return
	End
	
	If @Category='已报账'
	Begin
		If @Time=0
		Begin
			Set @Start_Date=(Select Convert(VARCHAR(7),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
			Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
			Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)))
			
			Set @End_Date=(Select Convert(VARCHAR(7),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
			Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
			Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)))
			
			If @Assistant_Item_ID>=0 
				Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
				Where
				H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And D.FAssistant_Item_ID=@Assistant_Item_ID
				And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)),0)
				+
				IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
				Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
				Where
				H.FValue_Budget_Center_ID=@Budget_Center_ID
				And H.FBudgetitemid=@Budget_Item_ID
				And H.FAssistant_Item_ID=@Assistant_Item_ID
				And Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)),0)
			Else
				Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
				Where
				H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)),0)
				+
				IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
				Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
				Where
				H.FValue_Budget_Center_ID=@Budget_Center_ID
				And H.FBudgetitemid=@Budget_Item_ID
				And Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)),0)
		End
		
		If @Time=1
		Begin
			If @Account_Period In ('01','02','03')
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (1,2,3))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (1,2,3))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID
					And H.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID),0)
				
			If @Account_Period In ('04','05','06')
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (4,5,6))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (4,5,6))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID
					And H.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID),0)
			If @Account_Period In ('07','08','09')
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (7,8,9))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (7,8,9))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID
					And H.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID),0)

			If @Account_Period In ('10','11','12')
				Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (10,11,12))
				
				Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
				Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
				Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
				And P.FPeriod In (10,11,12))
				
				If @Assistant_Item_ID>=0 
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID
					And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID
					And H.FAssistant_Item_ID=@Assistant_Item_ID),0)
				Else
					Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And D.FBudget_Item_ID=@Budget_Item_ID),0)
					+
					IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
					Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
					Where
					Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
					And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
					And H.FValue_Budget_Center_ID=@Budget_Center_ID
					And H.FBudgetitemid=@Budget_Item_ID),0)
		End
		
		If @Time=2
		Begin
			Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
			Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
			Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
			And P.FPeriod=cast(@Account_Period As INT))
			
			Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
			Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
			Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
			And P.FPeriod=cast(@Account_Period As INT))
			
			If @Assistant_Item_ID>=0 
				Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
				Where
				Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID
				And D.FAssistant_Item_ID=@Assistant_Item_ID),0)
				+
				IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
				Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
				Where
				Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And H.FBudgetitemid=@Budget_Item_ID
				And H.FAssistant_Item_ID=@Assistant_Item_ID),0)
			Else
				Set @Return=IsNull((Select Sum(D.Famount) From T_Budget_Report_Detail D With(TABLock) Inner Join T_Budget_Report_Header H With(NoLock) On D.FID=H.FID
				Where
				Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And D.FBudget_Item_ID=@Budget_Item_ID),0)
				+
				IsNull((Select Sum(D.Famount) From t_bt H With(NoLock)
				Inner Join t_bt_d D With(NoLock) On D.FID=H.FID
				Where
				Convert(VARCHAR(7),H.FPeriod,20)>=Left(@Start_Date,7)
				And Convert(VARCHAR(7),H.FPeriod,20)<=Left(@End_Date,7)
				And H.FValue_Budget_Center_ID=@Budget_Center_ID
				And H.FBudgetitemid=@Budget_Item_ID),0)
		End
		
		Return @Return
	End
End

If @Category In ('总预算','总下拨','总报账','已审核总预算','已审核总下拨')
Begin
	Set @Start_Date=(Select Convert(VARCHAR(10),Min(P.FBegDate),20) From T_AccountPeriod P With(NoLock)
	Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
	Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
	)
	
	Set @End_Date=(Select Convert(VARCHAR(10),Max(P.FEndDate),20) From T_AccountPeriod P With(NoLock)
	Where P.FYear=(Select P1.FYear From T_AccountPeriod P1 With(NoLock)
	Where Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7) And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7))
	)
	
	If @Category='总预算'
	Begin
		If @Assistant_Item_ID>=0 
			Set @Return=IsNull(
			(
			Select
			Sum(V.FValue)
			From T_Budget_Form_Value V With(TABLock)
			Inner Join T_Budget_Form_Detail D With(NoLock) on
			1=1
			And D.FID=V.FID
			And D.FBudget_Item_ID=V.FBudget_Item_ID
			And D.FAssistant_Item_ID=V.FAssistant_Item_ID
			Inner Join T_Budget_Form_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FBudget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And V.FAssistant_Item_ID=@Assistant_Item_ID
			And Left(V.FColumn,2)='by'
			And Convert(VARCHAR(10),H.FStart_Date,20)<=@End_Date
			And Convert(VARCHAR(10),H.FEnd_Date,20)>=@Start_Date
			),0)
		Else
			Set @Return=IsNull(
			(
			Select
			Sum(V.FValue)
			From T_Budget_Form_Value V With(TABLock)
			Inner Join T_Budget_Form_Detail D With(NoLock) on
			1=1
			And D.FID=V.FID
			And D.FBudget_Item_ID=V.FBudget_Item_ID
			And D.FAssistant_Item_ID=V.FAssistant_Item_ID
			Inner Join T_Budget_Form_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FBudget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And Left(V.FColumn,2)='by'
			And Convert(VARCHAR(10),H.FStart_Date,20)<=@End_Date
			And Convert(VARCHAR(10),H.FEnd_Date,20)>=@Start_Date
			),0)
	End
	
	If @Category='总下拨'
	Begin
		If @Assistant_Item_ID>=0 
			Set @Return=IsNull(
			(
			Select
			Sum(D.FValue)
			From T_Budget_Allocate_Detail D With(TABLock)
			Inner Join T_Budget_Allocate_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FValue_Budget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And D.FAssistant_Item_ID=@Assistant_Item_ID
			And Convert(VARCHAR(10),H.FDate,20)>=@Start_Date
			And Convert(VARCHAR(10),H.FDate,20)<=@End_Date
			),0)
		Else
			Set @Return=IsNull(
			(
			Select
			Sum(D.FValue)
			From T_Budget_Allocate_Detail D With(TABLock)
			Inner Join T_Budget_Allocate_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FValue_Budget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And Convert(VARCHAR(10),H.FDate,20)>=@Start_Date
			And Convert(VARCHAR(10),H.FDate,20)<=@End_Date
			),0)
	End
	
	If @Category='总报账'
	Begin
		If @Assistant_Item_ID>=0 
			Set @Return=IsNull(
			(
			IsNull((Select
			Sum(d1.FAmount)
			From T_Budget_Report_Detail d1 With(TABLock)
			Inner Join T_Budget_Report_Header h1 With(NoLock) On h1.FID=d1.FID
			Inner Join T_Budget_Center c1 With(NoLock) On c1.FID=h1.FValue_Budget_Center_ID
			Inner Join T_Budget_Item i1 With(NoLock) On i1.FID=d1.FBudget_Item_ID
			Where
			C1.FID=@Budget_Center_ID
			And I1.FID=@Budget_Item_ID
			And D1.FAssistant_Item_ID=@Assistant_Item_ID
			And Convert(VARCHAR(10),h1.FDate,20)>=@Start_Date
			And Convert(VARCHAR(10),h1.FDate,20)<=@End_Date),0)
			+
			IsNull((Select
			Sum(d2.FAmount)
			From t_bt_d D2 With(TABLock)
			Inner Join t_bt H2 With(NoLock) On h2.FID=d2.FID
			Inner Join T_Budget_Center c2 With(NoLock) On c2.FID=h2.FValue_Budget_Center_ID
			Inner Join T_Budget_Item i2 With(NoLock) On i2.FID=h2.FBudgetitemid
			Where
			c2.FID=@Budget_Center_ID
			And i2.FID=@Budget_Item_ID
			And h2.FAssistant_Item_ID=@Assistant_Item_ID
			And Convert(VARCHAR(10),h2.FPeriod,20)>=@Start_Date
			And Convert(VARCHAR(10),h2.FPeriod,20)<=@End_Date),0)
			),0)
		Else
			Set @Return=IsNull(
			(
			IsNull((Select
			Sum(d1.FAmount)
			From T_Budget_Report_Detail d1 With(TABLock)
			Inner Join T_Budget_Report_Header h1 With(NoLock) On h1.FID=d1.FID
			Inner Join T_Budget_Center c1 With(NoLock) On c1.FID=h1.FValue_Budget_Center_ID
			Inner Join T_Budget_Item i1 With(NoLock) On i1.FID=d1.FBudget_Item_ID
			Where
			c1.FID=@Budget_Center_ID
			And i1.FID=@Budget_Item_ID
			And Convert(VARCHAR(10),h1.FDate,20)>=@Start_Date
			And Convert(VARCHAR(10),h1.FDate,20)<=@End_Date),0)
			+
			IsNull((Select
			Sum(d2.FAmount)
			From t_bt_d d2 With(TABLock)
			Inner Join t_bt h2 With(NoLock) On h2.FID=d2.FID
			Inner Join T_Budget_Center c2 With(NoLock) On c2.FID=h2.FValue_Budget_Center_ID
			Inner Join T_Budget_Item i2 With(NoLock) On i2.FID=h2.FBudgetitemid
			Where
			c2.FID=@Budget_Center_ID
			And i2.FID=@Budget_Item_ID
			And Convert(VARCHAR(10),h2.FPeriod,20)>=@Start_Date
			And Convert(VARCHAR(10),h2.FPeriod,20)<=@End_Date),0)
			),0)
	End
	
	If @Category='已审核总预算'
	Begin
		If @Assistant_Item_ID>=0 
			Set @Return=IsNull(
			(
			Select
			Sum(V.FValue)
			From T_Budget_Form_Value V With(TABLock)
			Inner Join T_Budget_Form_Detail D With(NoLock) on
			1=1
			And D.FID=V.FID
			And D.FBudget_Item_ID=V.FBudget_Item_ID
			And D.FAssistant_Item_ID=V.FAssistant_Item_ID
			Inner Join T_Budget_Form_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FBudget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And V.FAssistant_Item_ID=@Assistant_Item_ID
			And Left(V.FColumn,2)='by'
			And Convert(VARCHAR(10),H.FStart_Date,20)<=@End_Date
			And Convert(VARCHAR(10),H.FEnd_Date,20)>=@Start_Date
			And H.FState=2
			),0)
		Else
			Set @Return=IsNull(
			(
			Select
			Sum(V.FValue)
			From T_Budget_Form_Value V With(TABLock)
			Inner Join T_Budget_Form_Detail D With(NoLock) on
			1=1
			And D.FID=V.FID
			And D.FBudget_Item_ID=V.FBudget_Item_ID
			And D.FAssistant_Item_ID=V.FAssistant_Item_ID
			Inner Join T_Budget_Form_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FBudget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And Left(V.FColumn,2)='by'
			And Convert(VARCHAR(10),H.FStart_Date,20)<=@End_Date
			And Convert(VARCHAR(10),H.FEnd_Date,20)>=@Start_Date
			And H.FState=2
			),0)
	End
	
	If @Category='已审核总下拨'
	Begin
		If @Assistant_Item_ID>=0 
			Set @Return=IsNull(
			(
			Select
			Sum(D.FValue)
			From T_Budget_Allocate_Detail D With(TABLock)
			Inner Join T_Budget_Allocate_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FValue_Budget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And D.FAssistant_Item_ID=@Assistant_Item_ID
			And Convert(VARCHAR(10),H.FDate,20)>=@Start_Date
			And Convert(VARCHAR(10),H.FDate,20)<=@End_Date
			And H.FState=2
			),0)
		Else
			Set @Return=IsNull(
			(
			Select
			Sum(D.FValue)
			From T_Budget_Allocate_Detail D With(TABLock)
			Inner Join T_Budget_Allocate_Header H With(NoLock) On H.FID=D.FID
			Inner Join T_Budget_Center C With(NoLock) On C.FID=H.FValue_Budget_Center_ID
			Inner Join T_Budget_Item I With(NoLock) On I.FID=D.FBudget_Item_ID
			Where
			c.FID=@Budget_Center_ID
			And I.FID=@Budget_Item_ID
			And Convert(VARCHAR(10),H.FDate,20)>=@Start_Date
			And Convert(VARCHAR(10),H.FDate,20)<=@End_Date
			And H.FState=2
			),0)
	End
	
	Return @Return
End

If @Category In ('管理用料发生额','管理用料总发生额')
Begin
	Set @Start_Date=IsNull((
	Select
	Convert(VARCHAR(7),Min(P.FBegDate),20)
	From T_AccountPeriod P With(NoLock)
	Where
	p.FYear=(
	Select
	P1.FYear
	From T_AccountPeriod P1 With(NoLock)
	Where
	Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
	And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
	)
	And (((
	@Time=0
	Or (
	@Time=1
	And @Account_Period In ('01','02','03')
	And P.FPeriod In (1,2,3))
	Or (
	@Time=1
	And @Account_Period In ('04','05','06')
	And P.FPeriod In (4,5,6))
	Or (
	@Time=1
	And @Account_Period In ('07','08','09')
	And P.FPeriod In (7,8,9))
	Or (
	@Time=1
	And @Account_Period In ('10','11','12')
	And P.FPeriod In (10,11,12))
	Or (
	@Time=2
	And P.FPeriod=cast(@Account_Period As INT))
	)
	And @Category='管理用料发生额'
	)
	Or @Category='管理用料总发生额'
	)
	),'')
	
	Set @End_Date=IsNull((
	Select
	Convert(VARCHAR(7),Max(P.FEndDate),20)
	From T_AccountPeriod P With(NoLock)
	Where
	p.FYear=(
	Select
	P1.FYear
	From T_AccountPeriod P1 With(NoLock)
	Where
	Convert(VARCHAR(7),P1.FBegDate,20)<=Left(@Date,7)
	And Convert(VARCHAR(7),P1.FEndDate,20)>=Left(@Date,7)
	)
	And (((
	@Time=0
	Or (
	@Time=1
	And @Account_Period In ('01','02','03')
	And P.FPeriod In (1,2,3))
	Or (
	@Time=1
	And @Account_Period In ('04','05','06')
	And P.FPeriod In (4,5,6))
	Or (
	@Time=1
	And @Account_Period In ('07','08','09')
	And P.FPeriod In (7,8,9))
	Or (
	@Time=1
	And @Account_Period In ('10','11','12')
	And P.FPeriod In (10,11,12))
	Or (
	@Time=2
	And P.FPeriod=cast(@Account_Period As INT))
	)
	And @Category='管理用料发生额'
	)
	Or @Category='管理用料总发生额'
	)
	),'')
	
	Set @Return=IsNull((
	Select
	Sum(Case IsNull(H.Frob,0) When 0 Then I.FAmount Else I.FAmount * -1 End)
	From TIC_InstockItems I With(TABLock)
	Inner Join TIC_Instock H With(NoLock) On I.FID=H.FID
	Inner Join T_ICTransType T With(NoLock) On T.FTransType=H.Ftranstype
	Inner Join T_Material M With(NoLock) On M.FMaterialID=I.FMaterialID
	Inner Join T_CostCenter C With(NoLock) On C.FCostCenterID=H.FBillOBJID
	Inner Join T_CostCenter_telement R With(NoLock) On R.FCostCenterID=H.FBillOBJID And R.FCostElementID=I.FCostOBJID
	Where
	T.FDOCType=12
	And T.FInOut=1
	And Exists(
	Select
	1
	From TIC_INVAmount V With(NoLock)
	Where
	H.FID=V.FSCDOCID
	And I.FRow=V.FSCDOCItemID
	)
	And ((
	Left(C.FCCNO,6) In ('913005','913006')
	And Left(@Start_Date,4)='2011'
	And Convert(VARCHAR(7),H.FDate,20)>='2011-03'
	)
	Or
	(
	(Not (Left(C.FCCNO,6) In ('913005','913006')
	And Left(@Start_Date,4)='2011'))
	And Convert(VARCHAR(7),H.FDate,20)>=Left(@Start_Date,7)
	))
	And Convert(VARCHAR(7),H.FDate,20)<=Left(@End_Date,7)
	And H.FState=2
	And (
	(I.FBudget_Report_ID Is Null Or (Not I.FBudget_Report_ID>0))
	Or (Not Exists(
	Select
	R.FID
	From T_Budget_Report_Header R With(NoLock)
	Where
	R.FID=I.FBudget_Report_ID
	)
	)
	)
	And R.FBudget_Center_ID=@Budget_Center_ID
	And R.FBudget_Item_ID=@Budget_Item_ID
	And ((
	Len(@ID_Array)>0
	And (Not @ID_Array Is Null)
	And (Not CharIndex(' '+cast(H.FID As VARCHAR(50))+' ,',@ID_Array)>0)
	)
	Or (
	(Not Len(@ID_Array)>0)
	Or @ID_Array Is Null
	)
	)
	),0)
End

Return @Return

End
