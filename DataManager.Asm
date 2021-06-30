		.686
		.model flat,stdcall
		option casemap:none

;*****************************************************************
; 头文件
;*****************************************************************
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		shlwapi.inc
includelib	shlwapi.lib
include		comdlg32.inc
includelib	comdlg32.lib
include		DataManager.inc.

;*****************************************************************
; 全局变量
;*****************************************************************
		.data?

hInstance	dd		?			;主窗口实例
hWinMain	dd		?			;主窗口句柄
hMenu		dd		?			;菜单句柄
hCol0Check	dd		?			;Col0选择框句柄
hCol1Check	dd		?			;Col1选择框句柄
hCol2Check	dd		?			;Col2选择框句柄
hCol3Check	dd		?			;Col3选择框句柄
hCol4Check	dd		?			;Col4选择框句柄
hCol5Check	dd		?			;Col5选择框句柄
hCol6Check	dd		?			;Col6选择框句柄
hCol7Check	dd		?			;Col7选择框句柄
hCol8Check	dd		?			;Col8选择框句柄
hCol9Check	dd		?			;Col9选择框句柄
hIndexCheck	dd		?			;索引选择框句柄
hCol0Edit	dd		?			;Col0编辑框句柄
hCol1Edit	dd		?			;Col1编辑框句柄
hCol2Edit	dd		?			;Col2编辑框句柄
hCol3Edit	dd		?			;Col3编辑框句柄
hCol4Edit	dd		?			;Col4编辑框句柄
hCol5Edit	dd		?			;Col5编辑框句柄	
hCol6Edit	dd		?			;Col6编辑框句柄
hCol7Edit	dd		?			;Col7编辑框句柄
hCol8Edit	dd		?			;Col8编辑框句柄
hCol9Edit	dd		?			;Col9编辑框句柄
hIndexEdit	dd		?			;索引编辑框句柄
hColIndexEdit	dd		?			;列索引编辑框句柄
hColTitleEdit	dd		?			;列标题编辑框句柄
hListView	dd		?			;列表框句柄
hFile		dd		?			;文件句柄
buffer		db		100	dup(?)		;通用缓冲区
itembuffer	db		100	dup(?)		;列表框行数据缓冲区
colbuffer	db		100	dup(?)		;列表框列数据缓冲区
writebuf	db		256	dup(?)		;写到文件的文本缓冲区
szFileName	db		MAX_PATH dup (?)	;文件路径
PATH		db		MAX_PATH dup(?)		;文件路径
Item		LVITEM		<?>			;列表框行数据
ColInfo		LVCOLUMN	<?>			;列表框列数据
isChanged	db		?			;当前文件是否被改变
;hHeap		dd		?			;
readbuf		db		10000h	dup(?)		;从文件读入的文本的缓冲区	
LineBuf		db		256	dup(?)		;行数据缓冲区
tokenBuf	db		100	dup(?)		;单个数据缓冲区
;tmpFileBuf	db		MAX_PATH	dup(?)	

		.code
;*****************************************************************
; 子程序：_SaveAs
; 功能：获取保存文件路径
;*****************************************************************
_SaveAs		proc
		local	@stOF:OPENFILENAME	

		;清空结构体数据
		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF	;结构体尺寸
		push	hWinMain			
		pop	@stOF.hwndOwner			;父窗口
		mov	@stOF.lpstrFilter,offset szFilter ;过滤器
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH		;最大文件路径长度
		mov	@stOF.Flags,OFN_PATHMUSTEXIST	;路径必须存在
		mov	@stOF.lpstrDefExt,offset szDefExt ;默认拓展名
		mov	@stOF.lpstrTitle,offset NULL	;默认文件名
		;打开保存文件对话框
		invoke	GetSaveFileName,addr @stOF	
		.if	eax
			invoke lstrcpy,offset PATH,@stOF.lpstrFile
			invoke CreateFile,@stOF.lpstrFile,\
				GENERIC_READ or GENERIC_WRITE,0,NULL,\
				OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			mov hFile,eax
			.if eax != INVALID_HANDLE_VALUE
				call SaveFile
				invoke CloseHandle,hFile
			.endif	
		.endif
		;保存后设置文件未被修改
		mov isChanged,FALSE
		ret

_SaveAs		endp


;*****************************************************************
; 子程序：_Save
; 功能：根据PATH中路径保存文件
;*****************************************************************
_Save		proc
		local	@stOF:OPENFILENAME

		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_PATHMUSTEXIST
		mov	@stOF.lpstrDefExt,offset szDefExt
		mov	@stOF.lpstrTitle,offset NULL
		;创建文件，读写方式，总是打开文件
		invoke CreateFile,offset PATH,\
			GENERIC_READ or GENERIC_WRITE,0,NULL,\
			OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov hFile,eax
		.if eax != INVALID_HANDLE_VALUE
			call SaveFile
			invoke CloseHandle,hFile
		.endif	
		mov isChanged,FALSE
		ret

_Save		endp	
	
;*****************************************************************
; 子程序：_OpenFile
; 功能：获取打开文件路径并打开文件
;*****************************************************************
_OpenFile	proc
		local	@stOF:OPENFILENAME

		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
		invoke	GetOpenFileName,addr @stOF
		.if	eax
			;将文件路径拷贝到PATH
			invoke lstrcpy,offset PATH,@stOF.lpstrFile
			;打开文件，读写方式，总是打开
			invoke CreateFile,offset szFileName,\
				GENERIC_READ or GENERIC_WRITE,0,NULL,\
				OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			;保存文件句柄
			mov hFile,eax
			.if eax != INVALID_HANDLE_VALUE
				call LoadFile
				invoke CloseHandle,hFile
			.endif	
		.endif
		ret

_OpenFile	endp


;*****************************************************************
; 子程序：GetLine
; 入口参数：pos - 起始位置
;	    lpdest - 存储结果字符串的指针
; 	    lpsource - 提供数据的字符串指针
; 功能：提取lpsource中从pos开始到第一个换行符之间的字符串，
;	存储到lpdest中
;*****************************************************************
GetLine		proc	pos,lpdest,lpsource
		;esi = lpsource + pos
		mov esi,lpsource
		add esi,pos
		;edi = lpdest
		mov edi,lpdest
		cld
		;循环读入数据
		_loop:
		lodsb
		;遇到换行符时终止
		cmp al,10
		je return
		stosb
		jmp _loop
		return:
		ret

GetLine endp

;*****************************************************************
; 子程序：lSubStr
; 入口参数：lpSubStr - 子串的指针
;	    lpStr - 字符串指针
; 出口参数：eax - 成功返回子串在字符串中下标，失败返回-1
; 功能：从字符串lpStr中查找子串lpSubStr
;*****************************************************************
lSubStr		proc	lpSubStr,lpStr
		;获取字符串长度
		mov edi,lpStr
		invoke lstrlen,edi
		mov ebx,eax
		
		;获取字串长度
		mov esi,lpSubStr
		invoke lstrlen,esi
		;字符串长度<子串长度，不匹配
		cmp ebx,eax
		jl @NoResult
		
		;ecx为子串长度
		mov ecx,eax
		cld
	;循环比较
	@LoopCmp:
		;保存寄存器数据
		push ecx
		push esi
		push edi
		;[esi]=[edi]?
		repe cmpsb
		;不相等，不匹配
		jne @F
		;相等且ecx=0，完全匹配
		jecxz @YesResult
	@@:
		;恢复寄存器数据
		pop edi
		inc edi
		;字符串长度-1
		dec ebx
		pop esi
		pop ecx
		;字符串长度>字串长度，继续比较
		cmp ebx,ecx
		jge @LoopCmp
	
	;不匹配，返回-1
	@NoResult:
		mov eax,-1
		jmp @Ret
	
	;匹配，恢复寄存器数据，返回字串位置
	@YesResult:
		pop eax
		pop esi
		pop ecx
		sub eax,lpStr
	@Ret:
	
		ret

lSubStr endp

;*****************************************************************
; 子程序：GetMidText
; 入口参数：left - 左边文本的字符窜指针
;	    right - 右边文本的字符串指针
;	    textBuffer - 欲取中间文本的字符串指针
;	    destBuffer - 存储结果的字符串指针
; 功能：从字符串textBuffer中取出被left和right所夹的
;	字符串存储到destBuffer中
;*****************************************************************
GetMidText	proc	left,right,textBuffer,destBuffer
		local   @p1
		local	@p2
		;获取left位置，存储到@p1
		invoke lSubStr,left,textBuffer
		.if eax == -1
			ret
		.endif
		mov @p1,eax
		
		;获取right位置，存储到@p2
		invoke lSubStr,right,textBuffer
		.if eax == -1
			ret
		.endif
		mov @p2,eax
		
		;获取left长度，@p1指向left后第一个字符
		invoke lstrlen,left
		add @p1,eax
		;将@p1到@p2间字符存入destBuffer
		mov ecx,@p2
		sub ecx,@p1
		mov esi,textBuffer
		add esi,@p1
		mov edi,destBuffer
		cld
		rep movsb
		ret

GetMidText endp

;*****************************************************************
; 子程序：LoadFile
; 功能：从文本文件中读入数据并加载到列表框
;*****************************************************************
LoadFile	proc
		local	@len	;文件长度
		local	@num	;写入字符数
		local	@pos	;当前位置
		local   @cnt	;计数变量
		
		;清空列表表项
		ClearList
		;一次性读入所有字符
		invoke GetFileSize,hFile,NULL
		mov @len,eax
		invoke wsprintf,offset readbuf,offset szFmt,@len
		invoke SetFilePointer,hFile,0,0,FILE_BEGIN
		invoke RtlZeroMemory,offset readbuf,sizeof readbuf
		invoke ReadFile,hFile,offset readbuf,10000H,addr @num,NULL

		;readbuf里存的是所有字符，逐字遍历
		mov @pos,0

		;按行分割
		
		;单独处理列数据
		invoke RtlZeroMemory,offset LineBuf,sizeof LineBuf
		invoke GetLine,@pos,offset LineBuf,offset readbuf
		;LineBuf里存的是第一行的列数据
		LoadColText 0,szColPart1,szColPart2
		invoke SetWindowText,hCol0Check,offset tokenBuf
		LoadColText 1,szColPart2,szColPart3
		invoke SetWindowText,hCol1Check,offset tokenBuf
		LoadColText 2,szColPart3,szColPart4
		invoke SetWindowText,hCol2Check,offset tokenBuf
		LoadColText 3,szColPart4,szColPart5
		invoke SetWindowText,hCol3Check,offset tokenBuf
		LoadColText 4,szColPart5,szColPart6
		invoke SetWindowText,hCol4Check,offset tokenBuf
		LoadColText 5,szColPart6,szColPart7
		invoke SetWindowText,hCol5Check,offset tokenBuf
		LoadColText 6,szColPart7,szColPart8
		invoke SetWindowText,hCol6Check,offset tokenBuf
		LoadColText 7,szColPart8,szColPart9
		invoke SetWindowText,hCol7Check,offset tokenBuf
		LoadColText 8,szColPart9,szColPart10
		invoke SetWindowText,hCol8Check,offset tokenBuf
		LoadColText 9,szColPart10,szColPart11Load
		invoke SetWindowText,hCol9Check,offset tokenBuf
		invoke lstrlen,offset LineBuf
		add @pos,eax
		inc @pos
		;继续处理行数据
		mov eax,@pos
		mov @cnt,0
		.while eax < @len
			invoke RtlZeroMemory,offset LineBuf,sizeof LineBuf
			invoke GetLine,@pos,offset LineBuf,offset readbuf
			;LineBuf里存的是行数据
			invoke RtlZeroMemory,offset tokenBuf,sizeof tokenBuf
			;tokenBuf里存的是每一列数据
			invoke GetMidText,offset szItemPart1,offset szItemPart2,offset LineBuf,offset tokenBuf
			LoadItemText0 @cnt,tokenBuf
			invoke GetMidText,offset szItemPart2,offset szItemPart3,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,1,tokenBuf
			invoke GetMidText,offset szItemPart3,offset szItemPart4,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,2,tokenBuf
			invoke GetMidText,offset szItemPart4,offset szItemPart5,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,3,tokenBuf
			invoke GetMidText,offset szItemPart5,offset szItemPart6,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,4,tokenBuf
			invoke GetMidText,offset szItemPart6,offset szItemPart7,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,5,tokenBuf
			invoke GetMidText,offset szItemPart7,offset szItemPart8,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,6,tokenBuf
			invoke GetMidText,offset szItemPart8,offset szItemPart9,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,7,tokenBuf
			invoke GetMidText,offset szItemPart9,offset szItemPart10,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,8,tokenBuf
			invoke GetMidText,offset szItemPart10,offset szItemPart11Load,offset LineBuf,offset tokenBuf
			LoadItemText @cnt,9,tokenBuf
			invoke lstrlen,offset LineBuf
			add @pos,eax
			inc @pos
			inc @cnt
			mov eax,@pos
		.endw
		ret

LoadFile endp

;*****************************************************************
; 子程序：SaveFile
; 功能：将列表框数据写出到文件
;*****************************************************************
SaveFile	proc
	
		local @num:DWORD	;写入字符数
		local @Col:LVCOLUMN	;列数据
		local @Item:LVITEM	;行数据
		local @LineCount:DWORD	;行数
		local @cnt:DWORD	;计数变量
		;获取行数
		GetLineCount
		mov @LineCount,eax
		GetColText 0
		invoke lstrcpy,offset writebuf,offset szColPart1
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 1
		invoke lstrcat,offset writebuf,offset szColPart2
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 2
		invoke lstrcat,offset writebuf,offset szColPart3
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 3
		invoke lstrcat,offset writebuf,offset szColPart4
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 4
		invoke lstrcat,offset writebuf,offset szColPart5
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 5
		invoke lstrcat,offset writebuf,offset szColPart6
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 6
		invoke lstrcat,offset writebuf,offset szColPart7
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 7
		invoke lstrcat,offset writebuf,offset szColPart8
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 8
		invoke lstrcat,offset writebuf,offset szColPart9
		invoke lstrcat,offset writebuf,offset colbuffer
		GetColText 9
		invoke lstrcat,offset writebuf,offset szColPart10
		invoke lstrcat,offset writebuf,offset colbuffer
		invoke lstrcat,offset writebuf,offset szColPart11
		
		;写出列标题数据到文件
		invoke lstrlen,offset writebuf
		mov @cnt,eax
		invoke WriteFile,hFile,offset writebuf,@cnt,addr @num,NULL
		
		;当前列表有多少行循环多少次
		xor eax,eax
		.while eax < @LineCount
			mov @cnt,eax
			;循环体
			invoke RtlZeroMemory,offset writebuf,sizeof writebuf
			
			GetItemText @cnt,0
			invoke lstrcpy,offset writebuf,offset szItemPart1
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,1
			invoke lstrcat,offset writebuf,offset szItemPart2
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,2
			invoke lstrcat,offset writebuf,offset szItemPart3
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,3
			invoke lstrcat,offset writebuf,offset szItemPart4
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,4
			invoke lstrcat,offset writebuf,offset szItemPart5
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,5
			invoke lstrcat,offset writebuf,offset szItemPart6
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,6
			invoke lstrcat,offset writebuf,offset szItemPart7
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,7
			invoke lstrcat,offset writebuf,offset szItemPart8
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,8
			invoke lstrcat,offset writebuf,offset szItemPart9
			invoke lstrcat,offset writebuf,offset itembuffer
			GetItemText @cnt,9
			invoke lstrcat,offset writebuf,offset szItemPart10
			invoke lstrcat,offset writebuf,offset itembuffer
			
			mov eax,@cnt
			mov ecx,@LineCount
			dec ecx
			invoke lstrcat,offset writebuf,offset szItemPart11
			;将当前行数据写到文件
			push @cnt
			invoke lstrlen,offset writebuf
			mov @cnt,eax
			invoke WriteFile,hFile,offset writebuf,@cnt,addr @num,NULL
			pop eax
			inc eax
		.endw
		
		
		ret

SaveFile endp


;*****************************************************************
; 子程序：WinProc
; 功能：主窗口消息处理函数
;*****************************************************************
WinProc	proc	uses ebx edi esi,hWnd,uMsg,wParam,lParam
		local	@dwStyle:DWORD		;窗口风格
		local	@index:SDWORD		;索引
		local	@LineCount:DWORD	;总行数
		local	@cnt:DWORD		;计数变量
		local	@notfound:DWORD		;未找到数据
		local   @iSelected:SDWORD	;当前数据被选中
		mov	eax,uMsg
		;处理菜单和按钮点击事件
		.if	eax ==	WM_COMMAND
			mov eax,wParam
			movzx eax,ax
			;插入按钮
			.if eax == IDB_INSERT
				;当前文件被修改
				mov isChanged,TRUE
				;获取索引值
				GetNum hIndexEdit
				mov @index,eax
				;索引错误需要输出提示
				.if @index < 0
					invoke MessageBox,hWnd,offset szIndexError,offset szError,MB_OK
				.endif
				;获取当前（行，列）的数据，写入到相应位置
				InsertItem hCol0Edit,Item,@index,buffer
				SetItem	hCol1Edit,Item,@index,1,buffer
				SetItem	hCol2Edit,Item,@index,2,buffer
				SetItem	hCol3Edit,Item,@index,3,buffer
				SetItem	hCol4Edit,Item,@index,4,buffer
				SetItem	hCol5Edit,Item,@index,5,buffer
				SetItem	hCol6Edit,Item,@index,6,buffer
				SetItem	hCol7Edit,Item,@index,7,buffer
				SetItem	hCol8Edit,Item,@index,8,buffer
				SetItem	hCol9Edit,Item,@index,9,buffer
			;修改按钮
			.elseif	eax == IDB_MODIFY
				;当前文件被修改
				mov isChanged,TRUE
				;获取索引值
				GetNum hIndexEdit
				mov @index,eax
				;索引错误需要输出提示
				.if @index < 0
					invoke MessageBox,hWnd,offset szIndexError,offset szError,MB_OK
				.endif
				;获取当前（行，列）的数据，写入到相应位置
				SetItem hCol0Edit,Item,@index,0,buffer
				SetItem	hCol1Edit,Item,@index,1,buffer
				SetItem	hCol2Edit,Item,@index,2,buffer
				SetItem	hCol3Edit,Item,@index,3,buffer
				SetItem	hCol4Edit,Item,@index,4,buffer
				SetItem	hCol5Edit,Item,@index,5,buffer
				SetItem	hCol6Edit,Item,@index,6,buffer
				SetItem	hCol7Edit,Item,@index,7,buffer
				SetItem	hCol8Edit,Item,@index,8,buffer
				SetItem	hCol9Edit,Item,@index,9,buffer
			;清空按钮
			.elseif	eax == IDB_CLEAR
				;当前文件被修改
				mov isChanged,TRUE
				;清空列表
				ClearList
			;删除表项按钮
			.elseif eax == IDB_DELETE
				;当前文件被修改
				mov isChanged,TRUE
				;删除打钩数据
				DeleteSelectedItem
			;查找按钮
			.elseif	eax == IDB_FIND
				;当前文件被修改
				mov isChanged,TRUE
				;默认未找到数据
				mov @notfound,1
				;获取行数
				GetLineCount
				mov @LineCount,eax
				;索引查找
				FindByIndex
				;按列查找
				GetLineCount
				mov @LineCount,eax
				FindByCol hCol0Check,hCol0Edit,0
				FindByCol hCol1Check,hCol1Edit,1
				FindByCol hCol2Check,hCol2Edit,2
				FindByCol hCol3Check,hCol3Edit,3
				FindByCol hCol4Check,hCol4Edit,4
				FindByCol hCol5Check,hCol5Edit,5
				FindByCol hCol6Check,hCol6Edit,6
				FindByCol hCol7Check,hCol7Edit,7
				FindByCol hCol8Check,hCol8Edit,8
				FindByCol hCol9Check,hCol9Edit,9
				;检查是否找到数据（没打勾的行即为存储查找数据的行）
				xor eax,eax
				.while eax < @LineCount
					mov @cnt,eax
					ItemIsSelected eax
					;哪一行没打勾
					.if eax == 0
						mov @notfound,0
						.break
					.endif
					mov eax,@cnt
					inc eax
				.endw
				;如果没有找到数据，提示用户，并取消每一列的选中状态
				.if @notfound == 1
					invoke MessageBox,hWnd,offset szNotFoundText,offset szNotFound,MB_OK
					xor eax,eax
					.while eax < @LineCount
						mov @cnt,eax
						mov Item.stateMask,LVIS_STATEIMAGEMASK
						mov eax,1
						shl eax,12
						mov Item.state,eax
						invoke SendMessage,hListView,LVM_SETITEMSTATE,@cnt,addr Item
						mov eax,@cnt
						inc eax
					.endw
				.else
					;找到数据，删除不符合条件的行
					DeleteSelectedItem
				.endif
			;修改列标题
			.elseif	eax == IDB_COLMODIFY
				;当前文件被修改
				mov isChanged,TRUE
				invoke RtlZeroMemory,offset buffer,sizeof buffer
				invoke RtlZeroMemory,addr ColInfo,sizeof LVCOLUMN
				;获取索引值
				GetNum hColIndexEdit
				push ecx
				push eax
				;获取列标题
				invoke GetWindowText,hColTitleEdit,offset buffer,100
				mov ColInfo.pszText,offset buffer
				mov ColInfo.imask,LVCF_TEXT or LVCF_WIDTH or LVCF_FMT
				mov ColInfo.iSubItem,0
				mov ColInfo.lx,80
				mov ColInfo.fmt,LVCFMT_CENTER
				mov ColInfo.cchTextMax,100
				pop ecx
				;修改列标题
				invoke SendMessage,hListView,LVM_SETCOLUMN,ecx,addr ColInfo
				pop ecx
				;同步选择框标题
				ResetCheckBox
			;退出菜单
			.elseif eax == IDM_EXIT
				;跳到WM_CLOSE消息处理

				invoke SendMessage,hWinMain,WM_CLOSE,0,0
			;另存为菜单
			.elseif eax == IDM_SAVEAS
				call _SaveAs
			;保存菜单
			.elseif	eax == IDM_SAVE
				;当前是否打开文件（PATH中有数据）？
				invoke lstrcmp,offset PATH,offset szNull
				;未打开文件，另存为
				.if eax == 0
					call _SaveAs
				;打开文件，用PATH中路径保存
				.else
					call _Save
				.endif
			;打开菜单
			.elseif	eax == IDM_OPEN
				;获取文件名
				call _OpenFile	
				;当前文件被修改
				mov isChanged,TRUE
			;新建菜单
			.elseif eax == IDM_NEW
				;如果当前文件被修改
				.if isChanged
					;询问是否保存
					invoke MessageBox,hWinMain,offset szSaveText,offset szSaveTitle,MB_YESNOCANCEL
					;是
					.if eax == IDYES
						;保存并清空列表框
						call _SaveAs
						ClearList
						;当前文件未被修改
						mov isChanged,FALSE
					;否
					.elseif eax == IDNO
						;清空列表框
						ClearList
						;当前文件未被修改
						mov isChanged,FALSE
					;取消
					.else	
						;当前文件被修改
						mov isChanged,TRUE
					.endif
				.endif
			;关于菜单
			.elseif eax == IDM_ABOUT
				;显示关于对话框
				invoke CreateDialogParam,hInstance,IDD_ABOUTBOX,hWinMain,NULL,NULL
			.endif
		;处理列表框表项被选中消息
		.elseif eax ==  WM_NOTIFY
			mov ecx,lParam
			mov eax,[ecx+8]
			;列表框左键被单击
			.if eax == NM_CLICK
				mov @iSelected,0
				;获取被选中数据索引
				invoke SendMessage,hListView,LVM_GETNEXTITEM,-1,LVNI_SELECTED
				mov @iSelected,eax
				;同步列表框数据到编辑框
				.if @iSelected != -1
					SyncItemToEdit 0,@iSelected,hCol0Edit
					SyncItemToEdit 1,@iSelected,hCol1Edit
					SyncItemToEdit 2,@iSelected,hCol2Edit
					SyncItemToEdit 3,@iSelected,hCol3Edit
					SyncItemToEdit 4,@iSelected,hCol4Edit
					SyncItemToEdit 5,@iSelected,hCol5Edit
					SyncItemToEdit 6,@iSelected,hCol6Edit
					SyncItemToEdit 7,@iSelected,hCol7Edit
					SyncItemToEdit 8,@iSelected,hCol8Edit
					SyncItemToEdit 9,@iSelected,hCol9Edit
					;同步索引
					invoke RtlZeroMemory,offset buffer,sizeof buffer
					invoke wsprintf,offset buffer,offset szFmt,@iSelected
					invoke SetWindowText,hIndexEdit,offset buffer
				.endif
				
			.endif 
		;创建组件
		.elseif	eax ==	WM_CREATE
			;列表框
			invoke	CreateWindowEx,NULL,\
				offset szListView,NULL,\
				WS_CHILD or WS_VISIBLE or WS_BORDER or LVS_REPORT or LVS_SINGLESEL,\
				0,0,810,656,\
				hWnd,IDC_LISTVIEW,hInstance,NULL
			mov hListView,eax
			;设置风格
			;获取拓展属性信息
			invoke SendMessage,hListView,LVM_GETEXTENDEDLISTVIEWSTYLE,0,0
			mov @dwStyle,eax
			;整行选择、一次选一行、显示选择框
			or @dwStyle,LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or LVS_EX_CHECKBOXES
			;设置拓展属性
			invoke SendMessage,hListView,LVM_SETEXTENDEDLISTVIEWSTYLE,0,@dwStyle
			;插入列
			
			InsertColumn ColInfo,0,szCol0
			InsertColumn ColInfo,1,szCol1
			InsertColumn ColInfo,2,szCol2
			InsertColumn ColInfo,3,szCol3
			InsertColumn ColInfo,4,szCol4
			InsertColumn ColInfo,5,szCol5
			InsertColumn ColInfo,6,szCol6
			InsertColumn ColInfo,7,szCol7
			InsertColumn ColInfo,8,szCol8
			InsertColumn ColInfo,9,szCol9

			
			;按钮
			;插入
			CreateButton szInsert,832,400,IDB_INSERT
			;修改
			CreateButton szModify,952,400,IDB_MODIFY
			;删除
			CreateButton szDelete,832,437,IDB_DELETE
			;清空
			CreateButton szClear,952,437,IDB_CLEAR
			;查找
			CreateButton szFind,832,474,IDB_FIND
			;修改列标题
			CreateButton szModify,960,595,IDB_COLMODIFY
			
			;选择框
			;Col0
			CreateCheckBox szCol0,16,IDCB_COL0,hCol0Check
			;Col1
			CreateCheckBox szCol1,52,IDCB_COL1,hCol1Check
			;Col2
			CreateCheckBox szCol2,86,IDCB_COL2,hCol2Check
			;Col3
			CreateCheckBox szCol3,122,IDCB_COL3,hCol3Check
			;Col4
			CreateCheckBox szCol4,158,IDCB_COL4,hCol4Check
			;Col5
			CreateCheckBox szCol5,194,IDCB_COL5,hCol5Check
			;Col6
			CreateCheckBox szCol6,228,IDCB_COL6,hCol6Check
			;Col7
			CreateCheckBox szCol7,264,IDCB_COL7,hCol7Check
			;Col8
			CreateCheckBox szCol8,296,IDCB_COL8,hCol8Check
			;Col9
			CreateCheckBox szCol9,332,IDCB_COL9,hCol9Check
			;索引
			CreateCheckBox szIndex,368,IDCB_INDEX,hIndexCheck
			
			;标签
			;列索引
			CreateLabel szColIndex,523,IDC_COLINDEX
			;列标题
			CreateLabel szColTitle,558,IDC_COLTITLE
			
			;编辑框
			;Col0
			CreateEdit 16,IDE_COL0,hCol0Edit
			;Col1
			CreateEdit 52,IDE_COL1,hCol1Edit
			;Col2
			CreateEdit 86,IDE_COL2,hCol2Edit
			;Col3
			CreateEdit 122,IDE_COL3,hCol3Edit
			;Col4
			CreateEdit 158,IDE_COL4,hCol4Edit
			;Col5
			CreateEdit 194,IDE_COL5,hCol5Edit
			;Col6
			CreateEdit 228,IDE_COL6,hCol6Edit
			;Col7
			CreateEdit 264,IDE_COL7,hCol7Edit
			;Col8
			CreateEdit 296,IDE_COL8,hCol8Edit
			;Col9
			CreateEdit 332,IDE_COL9,hCol9Edit
			;索引
			CreateEdit 368,IDE_INDEX,hIndexEdit
			;列索引
			CreateEdit 523,IDE_COLINDEX,hColIndexEdit
			;列标题
			CreateEdit 558,IDE_COLTITLE,hColTitleEdit
		;退出程序
		.elseif	eax ==	WM_CLOSE
			
			.if isChanged
			invoke MessageBox,hWinMain,offset szSaveText,offset szSaveTitle ,MB_YESNOCANCEL
				.if eax == IDYES
					call _SaveAs
					invoke DestroyWindow,hWinMain
					invoke	PostQuitMessage,NULL

				.elseif eax == IDNO
					invoke DestroyWindow,hWinMain
					invoke	PostQuitMessage,NULL
				.else 
					nop
				.endif
			.else
				invoke DestroyWindow,hWinMain
				invoke	PostQuitMessage,NULL
			.endif
			
		.else
			invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif

		xor	eax,eax
		ret

WinProc	endp

;*****************************************************************
; 子程序：_WinMain
; 功能：创建主窗口
;*****************************************************************
_WinMain	proc
		local	@stWndClass:WNDCLASSEX	;窗口类
		local	@stMsg:MSG		;消息
		;获取应用程序句柄
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		;填充窗口类
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		;装载菜单
		invoke	LoadMenu,hInstance,IDM_MAIN
		mov hMenu,eax
		;装载鼠标光标
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		;装载图标
		invoke LoadIcon,hInstance,ICO_MAIN
		mov	@stWndClass.hIcon,eax
		mov	@stWndClass.hIconSm,eax
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset WinProc
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset szClassName
		;注册窗口类
		invoke	RegisterClassEx,addr @stWndClass
		;创建窗口
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,offset szCaptionMain,\
			WS_OVERLAPPEDWINDOW,\
			0,0,1077,725,\
			NULL,hMenu,hInstance,NULL
		mov	hWinMain,eax
		;显示窗口
		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		;刷新客户区
		invoke	UpdateWindow,hWinMain
		;消息循环
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endw
		ret

_WinMain	endp

start:
		call	_WinMain
		invoke	ExitProcess,NULL

		end	start
