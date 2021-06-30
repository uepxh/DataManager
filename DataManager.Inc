;*****************************************************************
; 控件ID
;*****************************************************************
IDM_MAIN	equ	1000
IDM_EXIT	equ	32774
IDM_NEW		equ	32775
IDM_OPEN	equ	32776
IDM_SAVE	equ	32777
IDM_SAVEAS	equ	32778
IDM_ABOUT	equ 	32779
IDD_ABOUTBOX	equ	102
IDE_COL1	equ 	10001
IDE_COL2	equ	10002
IDE_COL3	equ 	10003
IDE_COL4	equ	10004
IDE_COL5	equ 	10005
IDE_COL6	equ	10006
IDE_COL7	equ 	10007
IDE_COL8	equ	10008
IDE_COL9	equ 	10009
IDE_COL0	equ	10010
IDE_COLINDEX	equ	10011
IDE_COLTITLE	equ	10012
IDCB_COL1	equ	10013
IDCB_COL2	equ	10014
IDCB_COL3	equ	10015
IDCB_COL4	equ	10016
IDCB_COL5	equ	10017
IDCB_COL6	equ	10018
IDCB_COL7	equ	10019
IDCB_COL8	equ	10020
IDCB_COL9	equ	10021
IDCB_COL0	equ	10022
IDB_INSERT	equ	10023
IDB_MODIFY	equ	10024
IDB_DELETE	equ	10025
IDB_CLEAR	equ	10026
IDB_FIND	equ	10027
IDB_RETURN	equ	10034
IDCB_INDEX	equ	10032
IDB_COLMODIFY	equ	10028
IDC_LISTVIEW	equ	10029
IDC_COLINDEX	equ	10030
IDC_COLTITLE	equ	10031
IDE_INDEX	equ	10035
ICO_MAIN	equ	2

;*****************************************************************
; 常量定义
;*****************************************************************
		.const
szClassName	db	'DataProcess',0
szCaptionMain	db	'学生信息管理系统',0
szButton	db	'button',0
szStatic	db	'static',0
szEdit		db	'edit',0
szListView	db	'SysListView32',0
szInsert	db	'插入',0
szDelete	db	'删除',0
szModify	db	'修改',0
szFind		db	'查找',0
szReturn	db	'返回',0
szClear		db	'清空',0
szCol0		db	'col0',0
szCol1		db	'col1',0
szCol2		db	'col2',0
szCol3		db	'col3',0
szCol4		db	'col4',0
szCol5		db	'col5',0
szCol6		db	'col6',0
szCol7		db	'col7',0
szCol8		db	'col8',0
szCol9		db	'col9',0
szIndex		db	'索引',0
szColIndex	db	'列索引：',0
szColTitle	db	'列标题：',0
szNull		db	0
szIndexError	db	'索引错误！',0
szError		db	'错误：',0
szNotFound	db	'未找到！',0
szNotFoundText	db	'未找到符合条件的数据！',0
szFmt		db	'%d',0
szFilter	db	'学生信息文件(*.info)',0,'*.info',0,'所有文件(*.*)',0,'*.*',0,0
szDefExt	db	'info',0
szColPart1	db	'{Col:name0=',34,0
szColPart2	db	34,',name1=',34,0
szColPart3	db	34,',name2=',34,0
szColPart4	db	34,',name3=',34,0
szColPart5	db	34,',name4=',34,0
szColPart6	db	34,',name5=',34,0
szColPart7	db	34,',name6=',34,0
szColPart8	db	34,',name7=',34,0
szColPart9	db	34,',name8=',34,0
szColPart10	db	34,',name9=',34,0
szColPart11	db	34,'}',10,0
szColPart11Load db	34,'}',0
szItemPart1	db	'{data:col0=',34,0
szItemPart2	db	34,',col1=',34,0
szItemPart3	db	34,',col2=',34,0
szItemPart4	db	34,',col3=',34,0
szItemPart5	db	34,',col4=',34,0
szItemPart6	db	34,',col5=',34,0
szItemPart7	db	34,',col6=',34,0
szItemPart8	db	34,',col7=',34,0
szItemPart9	db	34,',col8=',34,0
szItemPart10	db	34,',col9=',34,0
szItemPart11	db	34,'}',10,0
szItemPart11Load db	34,'}',0
szSaveText	db	'当前文件已改动，是否需要保存?',0
szSaveTitle	db	'文件已改动',0
szTempFileName	db	'last.dat',0



;*****************************************************************
; 宏：InsertColumn
; 参数：col - 列数据结构体
;	index - 列索引
;	caption - 列标题
; 功能：插入列
;*****************************************************************
InsertColumn	macro	col,index,caption
	invoke RtlZeroMemory,addr col,sizeof LVCOLUMN	
	;pszText、lx、fmt三个属性有效
	mov col.imask,LVCF_TEXT or LVCF_WIDTH or LVCF_FMT
	mov col.iSubItem,0
	;标题居中
	mov col.fmt,LVCFMT_CENTER
	;列宽80
	mov col.lx,80
	mov col.pszText,offset caption
	mov col.cchTextMax,30
	invoke SendMessage,hListView,LVM_INSERTCOLUMN,index,addr col
endm

;*****************************************************************
; 宏：CreateButton
; 参数：caption - 标题
;	x - x坐标
;	y - y坐标
;	ID - 组件ID
; 功能：创建按钮
;*****************************************************************
CreateButton	macro	caption,x,y,ID
	invoke	CreateWindowEx,NULL,\
		offset szButton,offset caption,\
		WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
		x,y,80,24,\
		hWnd,ID,hInstance,NULL
endm

;*****************************************************************
; 宏：CreateCheckBox
; 参数：caption - 标题
;	y - y坐标
;	ID - 组件ID
;	handle - 句柄
; 功能：创建选择框
;*****************************************************************
CreateCheckBox	macro	caption,y,ID,handle
	invoke	CreateWindowEx,NULL,\
			offset szButton,offset caption,\
			WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX,\
			832,y,64,24,\
			hWnd,ID,hInstance,NULL
			mov handle,eax
endm

;*****************************************************************
; 宏：CreateLabel
; 参数：caption - 标题
;	y - y坐标
;	ID - 组件ID
; 功能：创建标签
;*****************************************************************
CreateLabel	macro	caption,y,ID
	invoke	CreateWindowEx,NULL,\
				offset szStatic,offset caption,\
				WS_CHILD or WS_VISIBLE or SS_SIMPLE,\
				832,y,56,24,\
				hWnd,ID,hInstance,NULL
endm

;*****************************************************************
; 宏：CreateEdit
; 参数：y - y坐标
;	ID - 组件ID
;	handle - 句柄
; 功能：创建编辑框
;*****************************************************************
CreateEdit	macro	y,ID,handle
	invoke	CreateWindowEx,NULL,\
			offset szEdit,offset szNull,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or WS_BORDER,\
			925,y,120,24,\
			hWnd,ID,hInstance,NULL
			mov handle,eax
endm

;*****************************************************************
; 宏：GetNum
; 参数：handle - 句柄
; 功能：将handle中文本转换为数值存储到buffer中
;*****************************************************************
GetNum		macro	handle
	invoke GetWindowText,handle,offset buffer,100
	invoke StrToInt,offset buffer
endm

;*****************************************************************
; 宏：InsertItem
; 参数：handle - 存放插入内容的编辑框句柄
;	item - 列表项结构体指针
;	index - 插入行索引
;	caption - 插入的标题
; 功能：插入列表项
;*****************************************************************
InsertItem	macro handle,item,index,caption
	invoke RtlZeroMemory,offset buffer,sizeof buffer
	invoke GetWindowText,handle,offset buffer,100
	invoke RtlZeroMemory,addr item,sizeof item
	mov item.imask,LVIF_TEXT
	mov item.pszText,offset caption
	push index
	pop item.iItem
	mov item.iSubItem,0
	invoke SendMessage,hListView,LVM_INSERTITEM,0,addr item
endm

;*****************************************************************
; 宏：SetItem
; 参数：handle - 存放设置文本内容的编辑框句柄
;	item - 列表项结构体指针
;	index - 行索引
;	colindex - 列索引
;	caption - 插入的标题
; 功能：设置列表项标题
;*****************************************************************
SetItem		macro handle,item,index,colindex,caption
	invoke RtlZeroMemory,offset buffer,sizeof buffer
	invoke GetWindowText,handle,offset buffer,100
	invoke RtlZeroMemory,addr item,sizeof item
	mov item.imask,LVIF_TEXT
	mov item.pszText,offset caption
	push index
	pop item.iItem
	mov item.iSubItem,0
	mov item.iSubItem,colindex
	invoke SendMessage,hListView,LVM_SETITEM,0,addr item
endm

;*****************************************************************
; 宏：ClearList
; 功能：清空列表框
;*****************************************************************
ClearList	macro 
	invoke SendMessage,hListView,LVM_DELETEALLITEMS,0,0
endm

;*****************************************************************
; 宏：ItemIsSelected
; 参数：index - 欲检测的行索引
; 功能：检测索引为index的行是否被选中
;*****************************************************************
ItemIsSelected	macro	index
	invoke SendMessage,hListView,LVM_GETITEMSTATE,index,LVIS_STATEIMAGEMASK
	shr index,12
	dec index
endm

;*****************************************************************
; 宏：GetLineCount
; 功能：获取列表框行数
;*****************************************************************
GetLineCount	macro
	invoke SendMessage,hListView,LVM_GETITEMCOUNT,0,0
endm

;*****************************************************************
; 宏：DeleteItem
; 参数：index - 欲删除数据的行索引
; 功能：删除索引为index的行数据
;*****************************************************************
DeleteItem	macro	index
	invoke SendMessage,hListView,LVM_DELETEITEM,index,0
endm

;*****************************************************************
; 宏：SetCheckBoxText
; 参数：index - 列索引
;	handle - 选择框句柄
; 功能：设置列数据对应的选择框标题
;*****************************************************************
SetCheckBoxText	macro	index,handle
	invoke SendMessage,hListView,LVM_GETCOLUMN,index,addr ColInfo
	invoke SetWindowText,handle,ColInfo.pszText
endm

;*****************************************************************
; 宏：ResetCheckBox
; 功能：将选择框标题同步为对应的列标题
;*****************************************************************
ResetCheckBox	macro
	SetCheckBoxText 0,hCol0Check
	SetCheckBoxText 1,hCol1Check
	SetCheckBoxText 2,hCol2Check
	SetCheckBoxText 3,hCol3Check
	SetCheckBoxText 4,hCol4Check
	SetCheckBoxText 5,hCol5Check
	SetCheckBoxText 6,hCol6Check
	SetCheckBoxText 7,hCol7Check
	SetCheckBoxText 8,hCol8Check
	SetCheckBoxText 9,hCol9Check
endm

;*****************************************************************
; 宏：FindByIndex
; 功能：按索引查找列表框数据
;*****************************************************************
FindByIndex	macro
	;索引查找被选中
	invoke SendMessage,hIndexCheck,BM_GETCHECK,0,0
	.if eax == BST_CHECKED
		;取得索引自
		GetNum hIndexEdit
		mov @index,eax
		;索引非法
		.if @index < 0
			invoke MessageBox,hWnd,offset szIndexError,offset szError,MB_OK
		.endif
		;删除从0~索引值之间的数据
		xor eax,eax
		.while eax < @index
			mov @cnt,eax
			DeleteItem 0
			mov eax,@cnt
			inc eax
		.endw
		;重新获得剩余列表项数
		GetLineCount
		mov @LineCount,eax
		;此时结果索引值为0，删除结果后的数据
		xor eax,eax
		.while eax < @index
			mov @cnt,eax
			DeleteItem 1
			mov eax,@cnt
			inc eax
		.endw				
	.endif
endm

;*****************************************************************
; 宏：FindByCol
; 参数：hCheck - 检测是否选中的选择框句柄
;	hEdit - 存放查找数据的编辑框句柄
;	index - 列索引
; 功能：按列查找列表框数据
;*****************************************************************
FindByCol	macro hCheck,hEdit,index
	;当前列属性是否被选中
	invoke SendMessage,hCheck,BM_GETCHECK,0,0
	.if eax == BST_CHECKED
		invoke RtlZeroMemory,offset buffer,sizeof buffer
		;获取查找内容
		invoke GetWindowText,hEdit,offset buffer,100
		mov @cnt,0
		xor eax,eax
		.while eax < @LineCount
			;遍历列表
			mov @cnt,eax
			invoke RtlZeroMemory,offset itembuffer,sizeof itembuffer
			;获取列表框数据
			mov Item.iSubItem,index
			mov Item.cchTextMax,100
			mov Item.pszText,offset itembuffer
			;mov ecx,@cnt
			invoke SendMessage,hListView,LVM_GETITEMTEXT,@cnt,addr Item
			;比较
			invoke lstrcmp,offset buffer,offset itembuffer
			;不匹配数据前打钩
			.if eax != 0
				mov Item.stateMask,LVIS_STATEIMAGEMASK
				mov eax,2
				shl eax,12
				mov Item.state,eax
				invoke SendMessage,hListView,LVM_SETITEMSTATE,@cnt,addr Item
			.endif
			mov eax,@cnt
			inc eax
		.endw
					
	.endif
endm

;*****************************************************************
; 宏：DeleteSelectedItem
; 功能：删除选中的列表框数据
;*****************************************************************
DeleteSelectedItem	macro
	;获取列表项数
	GetLineCount
	mov @LineCount,eax
	;遍历列表框
	xor eax,eax
	.while eax < @LineCount
		mov @cnt,eax
		;删除打钩项目
		ItemIsSelected eax
		.if eax != 0
			mov eax,@cnt
			DeleteItem eax
			mov eax,@cnt
			dec eax
			mov @cnt,eax
			dec @LineCount
		.endif
		mov eax,@cnt
	 	inc eax
	.endw
endm

;*****************************************************************
; 宏：SyncItemToEdit
; 参数：colindex - 列索引
;	index - 行索引
;	handle - 编辑框句柄
; 功能：将列表框数据同步到编辑框
;*****************************************************************
SyncItemToEdit	macro	colindex,index,handle
	invoke RtlZeroMemory,offset buffer,sizeof buffer
	;获取列表框数据
	mov Item.iSubItem,colindex
	mov Item.cchTextMax,100
	mov Item.pszText,offset buffer
	invoke SendMessage,hListView,LVM_GETITEMTEXT,index,addr Item
	;同步数据到编辑框
	invoke SetWindowText,handle,offset buffer
endm

;*****************************************************************
; 宏：GetColText
; 参数：index - 列索引
; 功能：获取列标题文本
;*****************************************************************
GetColText	macro index
	mov @Col.imask,LVCF_TEXT or LVCF_WIDTH or LVCF_FMT
	mov @Col.iSubItem,0
	mov @Col.fmt,LVCFMT_CENTER
	mov @Col.pszText,offset colbuffer
	mov @Col.cchTextMax,50
	
	invoke RtlZeroMemory,offset colbuffer,sizeof colbuffer
	invoke SendMessage,hListView,LVM_GETCOLUMN,index,addr @Col
endm

;*****************************************************************
; 宏：GetItemText
; 参数：index - 行索引
;	colindex - 列索引
; 功能：获取行标题文本
;*****************************************************************
GetItemText	macro index,colindex
	invoke RtlZeroMemory,offset itembuffer,sizeof itembuffer
	;获取列表框数据
	mov @Item.iSubItem,colindex
	mov @Item.cchTextMax,100
	mov @Item.pszText,offset itembuffer
	invoke SendMessage,hListView,LVM_GETITEMTEXT,index,addr @Item
endm

;*****************************************************************
; 宏：GetColText
; 功能：设置列属性
;*****************************************************************
SetColAttribute	macro
	mov ColInfo.pszText,offset tokenBuf
	mov ColInfo.imask,LVCF_TEXT or LVCF_WIDTH or LVCF_FMT
	mov ColInfo.iSubItem,0				
	mov ColInfo.lx,80
	mov ColInfo.fmt,LVCFMT_CENTER
	mov ColInfo.cchTextMax,100
endm
;*****************************************************************
; 宏：SetColText
; 参数：index - 列索引
; 功能：设置列标题
;*****************************************************************
SetColText	macro index
	SetColAttribute
	invoke SendMessage,hListView,LVM_SETCOLUMN,index,offset ColInfo	
endm

;*****************************************************************
; 宏：LoadColText
; 参数：index - 列索引
;	left - 左侧文本指针
;	right - 右侧文本指针
; 功能：读入文本文件中的列标题
;*****************************************************************
LoadColText	macro index,left,right
	invoke RtlZeroMemory,offset tokenBuf,sizeof tokenBuf
	;按需取出每一列数据并修改
	invoke GetMidText,offset left,offset right,offset LineBuf,offset tokenBuf
	;tokenBuf里存的是Col0的列标题
	SetColText index
	
endm

;*****************************************************************
; 宏：LoadItemText
; 参数：index - 行索引
;	colindex - 列索引
;	caption - 存放标题的字符串指针
; 功能：读入文本文件中的行标题
;*****************************************************************
LoadItemText	macro index,colindex,caption
	invoke RtlZeroMemory,offset Item,sizeof Item
	mov Item.imask,LVIF_TEXT
	mov Item.pszText,offset caption
	push index
	pop Item.iItem
	mov Item.iSubItem,0
	mov Item.iSubItem,colindex
	invoke SendMessage,hListView,LVM_SETITEM,0,addr Item
	invoke RtlZeroMemory,offset tokenBuf,sizeof tokenBuf
endm

;*****************************************************************
; 宏：LoadItemText0
; 参数：index - 行索引
;	caption - 存放标题的字符串指针
; 功能：读入文本文件中的列标题（第一列专用）
;*****************************************************************
LoadItemText0	macro index,caption
	invoke RtlZeroMemory,offset Item,sizeof Item
	mov Item.imask,LVIF_TEXT
	mov Item.pszText,offset caption
	push index
	pop Item.iItem
	mov Item.iSubItem,0
	invoke SendMessage,hListView,LVM_INSERTITEM,0,offset Item
	invoke RtlZeroMemory,offset tokenBuf,sizeof tokenBuf
endm
