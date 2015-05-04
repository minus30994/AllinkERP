
/*ERP数据库*/
Use KingdeeERP

--创建T_Function表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Function')
And Lower(Name)=Lower('T_Function')
)
Begin

Create Table T_Function(
FunctionID INT,
FunctionName VARCHAR(200),
Explain VARCHAR(200),
PID INT,
Style VARCHAR(200),
FunctionCode VARCHAR(200),
FObjectName VARCHAR(200),
FNoMenu Bit,
FIsWorkshop Bit,
FPICLoad VARCHAR(200),
FWSObject VARCHAR(200),
FSTANFUNC Bit,
FAppend INT,
FAppendTable VARCHAR(200),
FDISPSYSType TinyINT,
FPictureRoute VARCHAR(200),
FActionName VARCHAR(200),
Constraint PK_T_Function Primary Key Nonclustered(FunctionID)
)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970000000
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970000000','预算管理','预算管理',0,'功能',Null,0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010000
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010000','基础资料','基础资料',970000000,'功能',Null,0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010100
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010100','预算中心','预算中心',970010000,'功能','W_Budget_Center',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010300
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010300','预算项目','预算项目',970010000,'功能','W_Budget_Item',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010400
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010400','预算中心-预算项目','预算中心-预算项目',970010000,'功能','W_Budget_Center_Item',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010500
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010500','权限设置','权限设置',970010000,'功能','W_Budget_Permission',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010600
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010600','模块设置','模块设置',970010000,'功能','W_Budget_Option',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010800
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010800','差旅费报账项目','差旅费报账项目',970010000,'功能','W_BT_I',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970010900
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970010900','记账凭证类型-会计科目','记账凭证类型-会计科目',970010000,'功能','W_Budget_Voucher_Type_Account',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970011000
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970011000','用户权限(预算管理)','用户权限(预算管理)',970010000,'功能','W_User_Set_Budget',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020100
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020100','预算模板','预算模板',970000000,'功能','W_Budget_Model',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020200
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020200','预算方案','预算方案',970000000,'功能','W_Budget_Case',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020201
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020201','年度指标','年度指标',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020202
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020202','删除','删除',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020203
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020203','更新指标','更新指标',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020204
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020204','新增','新增',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020205
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020205','年度指标开始/结束日期','年度指标开始/结束日期',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020206
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020206','设置下拨比例','设置下拨比例',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020207
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020207','设置限制下拨比例','设置限制下拨比例',970020200,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020300
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020300','预算报表','预算报表',970000000,'功能','W_Budget_Form',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020400
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020400','预算调整','预算调整',970000000,'功能','W_Budget_Adjust',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970020700
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970020700','预算下拨','预算下拨',970000000,'功能','W_Budget_Allocate',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970030000
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970030000','预算报账','预算报账',970000000,'功能','W_Budget_Report',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970030100
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970030100','记账/反记账','记账/反记账',970030000,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970030200
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970030200','差旅费报账','差旅费报账',970000000,'功能','W_BT',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970040000
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970040000','数据查询','数据查询',970000000,'功能',Null,0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970040100
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970040100','自定义统计表','自定义统计表',970040000,'功能','W_Budget_Report2',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970040200
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970040200','自定义统计图','自定义统计图',970040000,'功能','W_Budget_Statistics',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970040400
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970040400','预算跟踪','预算跟踪',970040000,'功能','W_Budget_Trace',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970170000
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970170000','年度指标申请','年度指标申请',970000000,'功能','W_Budget_Year_Target_Submit',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970170100
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970170100','查看审核记录','查看审核记录',970170000,'功能',Null,1,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970011100
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970011100','辅助项目','辅助项目',970010000,'功能','W_Budget_Assistant_Item',0,0,2)

End

If Not Exists(
Select
1
From T_Function With(NoLock)
Where
1=1
And FunctionID=970011200
)
Begin

Insert Into T_Function(
FunctionID,
FunctionName,
Explain,
PID,
Style,
FObjectName,
FNoMenu,
FAppend,
FDISPSYSType
)
Values('970011200','归口部门审核设置','归口部门审核设置',970010000,'功能','W_Budget_CD_Permission',0,0,2)

End

--创建T_Budget_Adjust_Header表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Adjust_Header')
And Lower(Name)=Lower('T_Budget_Adjust_Header')
)
Begin

Create Table T_Budget_Adjust_Header(
FID INT,
FNO VARCHAR(200),
FBudget_Form_ID INT,
FState TinyINT,
FConfirm_State TinyINT,
FCreate_ID INT,
FCreate_Date DateTime,
FConfirm_ID INT,
FConfirm_Date DateTime,
FLevel TinyINT,
FRemark Text,
Constraint PK_T_T_Budget_Adjust_Header Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Adjust_Detail表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Adjust_Detail')
And Lower(Name)=Lower('T_Budget_Adjust_Detail')
)
Begin

Create Table T_Budget_Adjust_Detail(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FDate DateTime,
FValue Money,
FRemark Text,
Constraint PK_T_Budget_Adjust_Detail Primary Key Nonclustered(FID,FBudget_Item_ID,FAssistant_Item_ID,FDate)
)

End

--创建T_Budget_Allocate_Header表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Allocate_Header')
And Lower(Name)=Lower('T_Budget_Allocate_Header')
)
Begin

Create Table T_Budget_Allocate_Header(
FID INT,
FNO VARCHAR(200),
FDate DateTime,
FBudget_Center_ID INT,
FValue_Budget_Center_ID INT,
FState TinyINT,
FConfirm_State TinyINT,
FCreate_ID INT,
FCreate_Date DateTime,
FConfirm_ID INT,
FConfirm_Date DateTime,
FLevel TinyINT,
FRemark Text,
Constraint PK_T_Budget_Allocate_Header Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Allocate_Detail表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Allocate_Detail')
And Lower(Name)=Lower('T_Budget_Allocate_Detail')
)
Begin

Create Table T_Budget_Allocate_Detail(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FValue Money,
Constraint PK_T_Budget_Allocate_Detail Primary Key Nonclustered(FID,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Attach表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Attach')
And Lower(Name)=Lower('T_Budget_Attach')
)
Begin

Create Table T_Budget_Attach(
FID INT,
FCategory VARCHAR(200),
FDocument_ID INT,
FRow INT,
FDescribe VARCHAR(200),
FAttach Image,
Constraint PK_T_Budget_Attach Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Case_Header表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Case_Header')
And Lower(Name)=Lower('T_Budget_Case_Header')
)
Begin

Create Table T_Budget_Case_Header(
FID INT,
FNO VARCHAR(200),
FName VARCHAR(200),
FState TinyINT,
FStart_Date DateTime,
FEnd_Date DateTime,
FYear_Target_Start_Date DateTime,
FYear_Target_End_Date DateTime,
FYear_Target Bit,
FCreate_ID INT,
FCreate_Date DateTime,
FConfirm_ID INT,
FConfirm_Date DateTime,
FRemark Text,
Constraint PK_T_Budget_Case_Header Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Case_Detail表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Case_Detail')
And Lower(Name)=Lower('T_Budget_Case_Detail')
)
Begin

Create Table T_Budget_Case_Detail(
FID INT,
FBudget_Model_ID INT,
Constraint PK_T_Budget_Case_Detail Primary Key Nonclustered(FID,FBudget_Model_ID)
)

End

--创建T_Budget_Case_Center表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Case_Center')
And Lower(Name)=Lower('T_Budget_Case_Center')
)
Begin

Create Table T_Budget_Case_Center(
FBudget_Case_ID INT,
FBudget_Center_ID INT,
Constraint PK_T_Budget_Case_Center Primary Key Nonclustered(FBudget_Case_ID,FBudget_Center_ID)
)

End

--创建T_Budget_Case_Item表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Case_Item')
And Lower(Name)=Lower('T_Budget_Case_Item')
)
Begin

Create Table T_Budget_Case_Item(
FID INT,
FRow INT,
FBudget_Center_ID INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FValue_Type TinyINT,
FYear_Target Money,
FLimit_Allocate Money,
FLimit_Allocate_Value_Type TinyINT,
FAllocate Money,
FAllocate_Value_Type TinyINT,
Constraint PK_T_Budget_Case_Item Primary Key Nonclustered(FID,FBudget_Center_ID,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Case_Item_History表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Case_Item_History')
And Lower(Name)=Lower('T_Budget_Case_Item_History')
)
Begin

Create Table T_Budget_Case_Item_History(
FID INT,
FVersion VARCHAR(50),
FRow INT,
FBudget_Center_ID INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FValue_Type TinyINT,
FYear_Target Money,
FLimit_Allocate Money,
FLimit_Allocate_Value_Type TinyINT,
FAllocate Money,
FAllocate_Value_Type TinyINT,
FCreate_ID INT,
FCreate_Time DateTime,
Constraint PK_T_Budget_Case_Item_History Primary Key Nonclustered(FID,FVersion,FBudget_Center_ID,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Item表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Item')
And Lower(Name)=Lower('T_Budget_Item')
)
Begin

Create Table T_Budget_Item(
FID INT,
FNO VARCHAR(200),
FName VARCHAR(200),
FPY VARCHAR(200),
FParent_ID INT,
FState TinyINT,
FType TinyINT,
FTime TinyINT,
FDebit_ID INT,
FCost_Element_ID INT,
FFormula Text,
FReport_Formula Text,
FSet_Sell_Year Bit,
FSet_Ensure_Item Bit,
FRequiredAI Bit,
FIsCentralized Bit,
FCentralized_Department_ID INT,
FRemark Text,
FCreate_ID INT,
FCreate_Date DateTime,
Constraint PK_T_Budget_Item Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Item_Element表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Item_Element')
And Lower(Name)=Lower('T_Budget_Item_Element')
)
Begin

Create Table T_Budget_Item_Element(
FBudget_Item_ID INT,
FRow INT,
FName VARCHAR(200),
FRemark Text,
Constraint PK_T_Budget_Item_Element Primary Key Nonclustered(FBudget_Item_ID,FName)
)

End

--创建T_Budget_Center表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Center')
And Lower(Name)=Lower('T_Budget_Center')
)
Begin

Create Table T_Budget_Center(
FID INT,
FNO VARCHAR(200),
FName VARCHAR(200),
FPY VARCHAR(200),
FParent_ID INT,
FState TinyINT,
FDepartment_ID INT,
FCost_Center_ID INT,
FRemark Text,
FCreate_ID INT,
FCreate_Date DateTime,
Constraint PK_T_Budget_Center Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Center_Item表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Center_Item')
And Lower(Name)=Lower('T_Budget_Center_Item')
)
Begin

Create Table T_Budget_Center_Item(
FBudget_Center_ID INT,
FBudget_Item_ID INT,
FDebit_ID INT,
FCost_Element_ID INT,
FType TinyINT,
FTime TinyINT,
FFormula Text,
FReport_Formula Text,
FRemark Text,
FRequiredAI Bit,
FIsCentralized Bit,
FCentralized_Department_ID INT,
FCreate_ID INT,
FCreate_Date DateTime,
Constraint PK_T_Budget_Center_Item Primary Key Nonclustered(FBudget_Center_ID,FBudget_Item_ID)
)

End

--创建T_Budget_Center_Item_Element表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Center_Item_Element')
And Lower(Name)=Lower('T_Budget_Center_Item_Element')
)
Begin

Create Table T_Budget_Center_Item_Element(
FBudget_Center_ID INT,
FBudget_Item_ID INT,
FRow INT,
FName VARCHAR(200),
FRemark Text,
Constraint PK_T_Budget_Center_Item_Element Primary Key Nonclustered(FBudget_Center_ID,FBudget_Item_ID,FName)
)

End

--创建T_Budget_Form_Header表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Form_Header')
And Lower(Name)=Lower('T_Budget_Form_Header')
)
Begin

Create Table T_Budget_Form_Header(
FID INT,
FNO VARCHAR(200),
FName VARCHAR(200),
FBudget_Center_ID INT,
FState TinyINT,
FConfirm_State TinyINT,
FStart_Date DateTime,
FEnd_Date DateTime,
FYear_Target Bit,
FYear_Target_Start_Date DateTime,
FYear_Target_End_Date DateTime,
FCreate_ID INT,
FCreate_Date DateTime,
FConfirm_ID INT,
FConfirm_Date DateTime,
FLevel TinyINT,
FRemark Text,
Constraint PK_T_Budget_Form_Header Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Form_Detail表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Form_Detail')
And Lower(Name)=Lower('T_Budget_Form_Detail')
)
Begin

Create Table T_Budget_Form_Detail(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FValue_Type TinyINT,
FFormula Text,
FValue_Formula Text,
FType TinyINT,
FTime TinyINT,
FYear_Target Money,
FRemark Text,
Constraint PK_T_Budget_Form_Detail Primary Key Nonclustered(FID,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Form_Value表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Form_Value')
And Lower(Name)=Lower('T_Budget_Form_Value')
)
Begin

Create Table T_Budget_Form_Value(
FID INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FColumn VARCHAR(200),
FName VARCHAR(200),
FValue Money,
FYear_Target Money,
FRemark Text,
FRow INT,
Constraint PK_T_Budget_Form_Value Primary Key Nonclustered(FID,FRow,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Form_Element表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Form_Element')
And Lower(Name)=Lower('T_Budget_Form_Element')
)
Begin

Create Table T_Budget_Form_Element(
FID INT,
FBudget_Item_ID INT,
FColumn VARCHAR(200),
FName VARCHAR(200),
FValue Money,
FRemark Text,
FRow INT,
Constraint PK_T_Budget_Form_Element Primary Key Nonclustered(FID,FBudget_Item_ID,FColumn,FName)
)

End

--创建T_Budget_Log_Confirm表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Log_Confirm')
And Lower(Name)=Lower('T_Budget_Log_Confirm')
)
Begin

Create Table T_Budget_Log_Confirm(
FID INT,
FCategory VARCHAR(200),
FDocument_ID INT,
FLevel TinyINT,
FPass Bit,
FUser_ID INT,
FDate DateTime,
FRemark Text,
Constraint PK_T_Budget_Log_Confirm Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Model_Header表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Model_Header')
And Lower(Name)=Lower('T_Budget_Model_Header')
)
Begin

Create Table T_Budget_Model_Header(
FID INT,
FNO VARCHAR(200),
FName VARCHAR(200),
FCreate_ID INT,
FCreate_Date DateTime,
FRemark Text,
Constraint PK_T_Budget_Model_Header Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Model_Detail表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Model_Detail')
And Lower(Name)=Lower('T_Budget_Model_Detail')
)
Begin

Create Table T_Budget_Model_Detail(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FValue_Type TinyINT,
FValue_Formula Text,
FRemark Text,
Constraint PK_T_Budget_Model_Detail Primary Key Nonclustered(FID,FBudget_Item_ID)
)

End

--创建T_Budget_Model_Element表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Model_Element')
And Lower(Name)=Lower('T_Budget_Model_Element')
)
Begin

Create Table T_Budget_Model_Element(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FName VARCHAR(200),
FRemark Text,
Constraint PK_T_Budget_Model_Element Primary Key Nonclustered(FID,FBudget_Item_ID,FName)
)

End

--创建T_Budget_Permission_Confirm表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Permission_Confirm')
And Lower(Name)=Lower('T_Budget_Permission_Confirm')
)
Begin

Create Table T_Budget_Permission_Confirm(
FCategory VARCHAR(200),
FBudget_Center_ID INT,
FLevel TinyINT,
FUser_ID INT,
Constraint PK_T_Budget_Permission_Confirm Primary Key Nonclustered(FCategory,FBudget_Center_ID,FLevel,FUser_ID)
)

End

--创建T_Budget_Permission_View表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Permission_View')
And Lower(Name)=Lower('T_Budget_Permission_View')
)
Begin

Create Table T_Budget_Permission_View(
FCategory VARCHAR(200),
FBudget_Center_ID INT,
FUser_ID INT,
Constraint PK_T_Budget_Permission_View Primary Key Nonclustered(FCategory,FBudget_Center_ID,FUser_ID)
)

End

--创建T_Budget_Report_Header表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Report_Header')
And Lower(Name)=Lower('T_Budget_Report_Header')
)
Begin

Create Table T_Budget_Report_Header(
FID INT,
FNO VARCHAR(200),
FDate DateTime,
FBudget_Center_ID INT,
FValue_Budget_Center_ID INT,
FState TinyINT,
FConfirm_State TinyINT,
FCheck Bit,
FProduct_Type Bit,
FDepartment Bit,
FDepartment_ID INT,
FCreate_ID INT,
FCreate_Date DateTime,
FConfirm_ID INT,
FConfirm_Date DateTime,
FTally_ID INT,
FTally_Date DateTime,
FVoucher_ID INT,
FLevel TinyINT,
FRemark Text,
Constraint PK_T_Budget_Report_Header Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Report_Detail表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Report_Detail')
And Lower(Name)=Lower('T_Budget_Report_Detail')
)
Begin

Create Table T_Budget_Report_Detail(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FApply Money,
FAmount Money,
FRevise Money,
FSummary VARCHAR(200),
FCredit_ID INT,
FDebit_ID INT,
FProduct_Type VARCHAR(200),
FProduct_Type_ID INT,
FMaterial_ID INT,
FEmployee_ID INT,
FSell_Year SmallINT,
Constraint PK_T_Budget_Report_Detail Primary Key Nonclustered(FID,FRow)
)

End

--创建T_Budget_Statistics表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Statistics')
And Lower(Name)=Lower('T_Budget_Statistics')
)
Begin

Create Table T_Budget_Statistics(
FID INT,
FLabel VARCHAR(200),
FSyntax Image,
FFormat Image,
Constraint PK_T_Budget_Statistics Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Voucher_Type_Account表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Voucher_Type_Account')
And Lower(Name)=Lower('T_Budget_Voucher_Type_Account')
)
Begin

Create Table T_Budget_Voucher_Type_Account(
FVoucher_Type_ID INT,
FAccount_ID INT,
Constraint PK_T_Budget_Voucher_Type_Account Primary Key Nonclustered(FVoucher_Type_ID,FAccount_ID)
)

End

--创建T_BT表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT')
And Lower(Name)=Lower('T_BT')
)
Begin

Create Table T_BT(
FID INT,
FNO VARCHAR(200),
FEMPID INT,
FContent Text,
FState TinyINT,
FConfirm_State TinyINT,
FLevel TinyINT,
FBudgetCenterID INT,
FValue_Budget_Center_ID INT,
FBudgetItemID INT,
FAssistant_Item_ID INT,
FPeriod DateTime,
FACCDOCID INT,
FCreditACCID INT,
FDepartmentID INT,
FDebit_ID INT,
FProduct_Type Bit,
FCheck Bit,
FUserID INT,
FDate DateTime,
FConfirm_ID INT,
FConfirm_Date DateTime,
FTally_ID INT,
FTally_Date DateTime,
Constraint PK_T_BT Primary Key Nonclustered(FID)
)

End

--创建T_BT_D表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_D')
And Lower(Name)=Lower('T_BT_D')
)
Begin

Create Table T_BT_D(
FID INT,
FNO INT,
FItemID INT,
FContent Text,
FContent2 Text,
FApply Money,
FAmount Money,
FStandard Money,
FRemark Text,
Constraint PK_T_BT_D Primary Key Nonclustered(FID,FNO)
)

End

--创建T_BT_P表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_P')
And Lower(Name)=Lower('T_BT_P')
)
Begin

Create Table T_BT_P(
FID INT,
FRow INT,
FProduct_Type VARCHAR(200),
FProduct_Type_ID INT,
FRate Money,
FMaterial_ID INT,
FSell_Year SmallINT,
Constraint PK_T_BT_P Primary Key Nonclustered(FID,FRow)
)

End

--创建T_BT_I表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_I')
And Lower(Name)=Lower('T_BT_I')
)
Begin

Create Table T_BT_I(
FID INT,
FName VARCHAR(200),
FCompute VARCHAR(200),
FFormula Text,
FMemo Text,
Constraint PK_T_BT_I Primary Key Nonclustered(FID)
)

End

--创建T_BT_I_P表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_I_P')
And Lower(Name)=Lower('T_BT_I_P')
)
Begin

Create Table T_BT_I_P(
FItemID INT,
FNO TinyINT,
FParameter VARCHAR(200),
FSystem INT,
FRequired Bit,
Constraint PK_T_BT_I_P Primary Key Nonclustered(FItemID,FNO)
)

End

--创建T_BT_I_P_S表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_I_P_S')
And Lower(Name)=Lower('T_BT_I_P_S')
)
Begin

Create Table T_BT_I_P_S(
FItemID INT,
FNO TinyINT,
FSelection VARCHAR(200)
Constraint PK_T_BT_I_P_S Primary Key Nonclustered(FItemID,FNO,FSelection)
)

End

--创建T_BT_I_S表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_I_S')
And Lower(Name)=Lower('T_BT_I_S')
)
Begin

Create Table T_BT_I_S(
FID INT,
FItemID INT,
FStandard Text,
FLimit Bit,
Constraint PK_T_BT_I_S Primary Key Nonclustered(FID,FItemID)
)

End

--创建T_BT_I_SP表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_I_SP')
And Lower(Name)=Lower('T_BT_I_SP')
)
Begin

Create Table T_BT_I_SP(
FID INT,
FName VARCHAR(200),
FContent Text,
Constraint PK_T_BT_I_SP Primary Key Nonclustered(FID)
)

End

--创建T_BT_I_V表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_BT_I_V')
And Lower(Name)=Lower('T_BT_I_V')
)
Begin

Create Table T_BT_I_V(
FID INT,
FItemID INT,
FPermission Text,
Constraint PK_T_BT_I_V Primary Key Nonclustered(FID,FItemID)
)

End

--创建T_Budget_Year_Target_Submit_H表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Year_Target_Submit_H')
And Lower(Name)=Lower('T_Budget_Year_Target_Submit_H')
)
Begin

Create Table T_Budget_Year_Target_Submit_H(
FID INT,
FNO VARCHAR(200),
FYear SmallINT,
FState TinyINT,
FAudit_State TinyINT,
FCentralized_Audit_State TinyINT,
FCentralized_Audit_Level TinyINT,
FLevel TinyINT,
FBudget_Center_ID INT,
FRemark Text,
FCreator_ID INT,
FCreate_Date DateTime,
FAuditor_ID INT,
FAudit_Date DateTime,
Constraint PK_T_Budget_Year_Target_Submit_H Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Year_Target_Submit_D表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Year_Target_Submit_D')
And Lower(Name)=Lower('T_Budget_Year_Target_Submit_D')
)
Begin

Create Table T_Budget_Year_Target_Submit_D(
FID INT,
FRow INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
FSubmit_Amount Money,
FAudit_Amount Money,
Constraint PK_T_Budget_Year_Target_Submit_D Primary Key Nonclustered(FID,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Assistant_Item表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Assistant_Item')
And Lower(Name)=Lower('T_Budget_Assistant_Item')
)
Begin

Create Table T_Budget_Assistant_Item(
FID INT,
FNumber VARCHAR(200),
FName VARCHAR(200),
FCreator_ID INT,
FCreate_Time DateTime,
FLast_Update_User_ID INT,
FLast_Update_Time DateTime,
Constraint PK_T_Budget_Assistant_Item Primary Key Nonclustered(FID)
)

End

--创建T_Budget_Item_Assistant_Item表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Item_Assistant_Item')
And Lower(Name)=Lower('T_Budget_Item_Assistant_Item')
)
Begin

Create Table T_Budget_Item_Assistant_Item(
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
Constraint PK_T_Budget_Item_Assistant_Item Primary Key Nonclustered(FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Center_Item_Assistant_Item表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Center_Item_Assistant_Item')
And Lower(Name)=Lower('T_Budget_Center_Item_Assistant_Item')
)
Begin

Create Table T_Budget_Center_Item_Assistant_Item(
FBudget_Center_ID INT,
FBudget_Item_ID INT,
FAssistant_Item_ID INT,
Constraint PK_T_Budget_Center_Item_Assistant_Item Primary Key Nonclustered(FBudget_Center_ID,FBudget_Item_ID,FAssistant_Item_ID)
)

End

--创建T_Budget_Year_Target_Submit_CH表
If Not Exists(Select
1
From SYS.Objects With(NoLock)
Where
1=1
And Object_ID=Object_ID('T_Budget_Year_Target_Submit_CH')
And Lower(Name)=Lower('T_Budget_Year_Target_Submit_CH')
)
Begin

Create Table T_Budget_Year_Target_Submit_CH(
FID INT,
FYear_Target_Submit_ID INT,
FYear_Target_Submit_Row INT,
FSubmit_Amount Money,
FAudit_Amount Money,
FLevel TinyINT,
FPass Bit,
FUser_ID INT,
FDate DateTime,
FRemark Text,
Constraint PK_T_Budget_Year_Target_Submit_CH Primary Key Nonclustered(FID,FYear_Target_Submit_ID,FYear_Target_Submit_Row)
)

End
