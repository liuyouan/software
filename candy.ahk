/*
╔══════════════════════════════════════╗
║我常用的脚本及快捷启动                ║
║AHK版本      :1.1.33.10               ║
║版本V03      :2022.01.08              ║
║版本V02      :2020.03.22              ║
║版本V01      :2016.12.24              ║
║原始版本日期 :2014.09.10              ║
║                                      ║
║适用平台     :Windows                 ║
║作    者     :Kawvin(285781427@qq.com)║
║原 作 者     :万年书妖(aamii@qq.com)  ║
║热键说明: #=Win +=Shift ^=Ctrl !=Alt  ║
╚══════════════════════════════════════╝
*/
/*
╔══════════════════════════════════════╗
║<<<<〇程序头部>>>>                    ║
╚══════════════════════════════════════╝
*/
#NoEnv                           ;避免检查空变量是否为环境变量(推荐所有新建脚本使用)。
#NoTrayIcon                      ;隐藏托盘图标
#SingleInstance Force            ;单脚本运行
#Persistent                      ;让脚本持久运行
SetWorkingDir,%A_ScriptDir%      ;设置工作目录
#MaxThreadsPerHotkey,300         ;最大热键数量
SendMode Input
#WinActivateForce                ;强制激活窗体
#ClipboardTimeout 500            ;首次访问剪贴板失败后继续尝试访问剪贴板的持续时间
Process Priority,,High           ;线程,主,高级别
CoordMode,Mouse,Screen           ;设置鼠标相对于屏幕激活
CoordMode,Menu                   ;设置菜单相对于窗口激活
SetTitleMatchMode,2              ;设置WinWait等命令,匹配包含指定的 WinTitle 的窗口标题,精确匹配
DetectHiddenWindows On           ;不可见的窗口是否被脚本“看见”,是
AutoTrim,on                      ;自动省略首尾的空格和Tab
SetBatchLines -1                 ;让脚本无休眠地执行（换句话说，也就是让脚本全速运行）
ListLines Off
;SetCapsLockState, AlwaysOff     ;强制大写键处于关闭状态
ComObjError(0)                   ;禁用COM 错误通告
global Ky_RunWithSystem:= 1      ;定义随系统启动变量
global Ky_FoldersPasteMode:=     ;定义文件夹结构粘贴模式
global Ky_SouFolder:=            ;定义要复制的源文件夹
global Ky_DesFolder:=            ;定义要粘贴的目标文件夹
global Ky_RecentPWS:=            ;最近可用的解压密码
global Ky_ShiftIsPressed:=       ;按下Shift键，则执行第二操作
global Ky_CapsLockIsPressed:=    ;按下CapsLock键，则执行第二操作
Menu, Tray, UseErrorLevel        ;阻止显示对话框和终止线程
RegWrite, reg_sz, HKLM,Software\Microsoft\Windows\CurrentVersion\Run, Candy, %A_ScriptFullPath% ;将自己放入启动项
;挂上键盘钩子 便于查看所有按下的键
#UseHook
#InstallKeybdHook   ;安装键鼠钩子
#InstallMouseHook   ;安装鼠标钩子
#KeyHistory        ;显示历史按键
;SkSub_CreatTrayMenu()            ;创建一个自定义的托盘菜单
;我预留的函数
;SplitPath,MyTemFile,MyOutFileName,MyOutDir,MyOutExt,MyOutNameNoExt,MyOutDrive

/*
╔══════════════════════════════════════╗
║<<<<〇全局设置>>>>                    ║
╚══════════════════════════════════════╝
*/
Label_My_global_and_PreDefined_Var:
global szMenuIdx:={}             ;菜单用1
global szMenuContent:={}         ;菜单用2
global szMenuWhichFile:={}       ;菜单用3
global GeneralSettings_ini:= "ini\GeneralSettings.ini"
IniRead All_MyVar,%GeneralSettings_ini%,MyVar       ;读取我的变量，进行环境变量设置
loop,Parse,All_MyVar,`n
{
	MyVar_Key:=RegExReplace(A_LoopField,"=.*?$")     ;用户自定义变量的key
	MyVar_Val:=RegExReplace(A_LoopField,"^.*?=")     ;用户自定义变量的value
	if (MyVar_Key && MyVar_Val && not InStr(MyVar_Key," "))  ;抛弃空变量以及含空格的变量
		%MyVar_Key%=%MyVar_Val%             ;这样的写法不会传递环境变量。EnvSet,%MyVar_Key%,"%MyVar_Val%" ;另一种写法，可以传递环境变量到被他启动的应用程序
}
/*
╔══════════════════════════════════════╗
║<<<<①热键定义>>>>                     ║
╚══════════════════════════════════════╝
*/
Label_Candy_SetHotKey:         ;热键定义段，这个部分要插入到“全脚本的自动运行部分去”，可用Gosub解决。
	IniRead,Candy_Hotkey,%GeneralSettings_ini%,Candy_Hotkey           ;读取整个热键定义字段，自定义热键格式:   热键=配置文件
	loop,Parse,Candy_Hotkey,`n     ;循环读取ini里面，热键定义字段的每一行
	{
		Hotkey,% RegExReplace(A_loopfield,"=.*?$"),Label_Candy_Start,On,UseErrorLevel   ;左边是热键
		if ErrorLevel  ;热键出错
			MsgBox % "您定义的热键:      "   RegExReplace(A_loopfield,"=.*?$")   "     不可用，请检查!"
	}
return
/*
╔══════════════════════════════════════╗
║<<<<②启动，获取对象>>>>               ║
╚══════════════════════════════════════╝
*/
Label_Candy_Start:
	;     CandyStartTick :=A_TickCount  ;若要评估出menu时间，这里需打开 ,共三处，1/3
	SkSub_Clear_CandyVar()
	MouseGetPos,,,Candy_CurWin_id         ;当前鼠标下的进程ID
	WinGet, Candy_CurWin_Fullpath,ProcessPath,Ahk_ID %Candy_CurWin_id%    ;当前进程的路径
	WinGetTitle, Candy_Title,Ahk_ID %Candy_CurWin_id%    ;当前进程的标题
	Candy_Saved_ClipBoard := ClipboardAll
	Clipboard =
	Send, ^c
	ClipWait,0.5
	if ( ErrorLevel  )          ;如果没有选择到什么东西，则退出
	{
;InputBox, Clipboard, Title, Prompt, , 500, 110 ;这是会跳出一个输入框
		if ErrorLevel
		{ Clipboard := Candy_Saved_ClipBoard    ;还原粘贴板
			Candy_Saved_ClipBoard =
			return
			Clipboard:= Explorer_GetPath() . "|RightMenu"
		}
	}
	Candy_isFile := DllCall("IsClipboardFormatAvailable", "UInt", 15)   ;是否是文件类型
	Candy_isHtml := DllCall("RegisterClipboardFormat", "str", "HTML Format")  ;是否Html类型
	CandySel=%Clipboard%
	CandySel_Rich:=ClipboardAll
	Clipboard := Candy_Saved_ClipBoard  ;还原粘贴板
	Candy_Saved_ClipBoard =
	IniRead,Candy_ProFile_Ini,%GeneralSettings_ini%,Candy_Hotkey,%A_ThisHotkey%    ;本热键所调取的配置文件
	Transform,Candy_ProFile_Ini,Deref,%Candy_ProFile_Ini%                         ;ini文件路径可以使用自定义变量以及环境变量
	IfNotExist %Candy_ProFile_Ini%         ;如果配置文件不存在，则发出警告，且终止
	{
		MsgBox 对热键%A_thisHotkey% 定义的配置文件不存在! `n--------`n请检查%Candy_ProFile_Ini%
		return
	}
	SplitPath,Candy_ProFile_Ini,,Candy_Profile_Dir,,Candy_ProFile_Ini_NameNoext
/*
╔══════════════════════════════════════╗
║<<<<③选中内容的后缀定义>>>>           ║
╚══════════════════════════════════════╝
*/
	If(FileExist(CandySel) && RegExMatch(CandySel,"^(\\\\|.:\\)")) ;文件或者文件夹,不再支持相对路径的文件路径,但容许“文字模式的全路径”
	{
		Candy_isFile:=1     ;如果是“文字型”的有效路径，强制认定为文件
		SplitPath,CandySel,CandySel_FileNameWithExt,CandySel_ParentPath,CandySel_Ext,CandySel_FileNameNoExt,CandySel_Drive
		SplitPath,CandySel_ParentPath,CandySel_ParentName,,,, ;用这个提取“所在文件夹名”
		if InStr(FileExist(CandySel), "D")  ;区分是否文件夹,Attrib= D ,则是文件夹
		{
			CandySel_FileNameNoExt:=CandySel_FileNameWithExt
			CandySel_Ext:=RegExMatch(CandySel,"^.:\\$") ? "Drive":"Folder"  ;细分：盘符或者文件夹
		}
		else  if (CandySel_Ext="")       ;若不是文件夹，且无后缀，则定义为NoExt
		{
			CandySel_Ext:="NoExt"
		}
		if (CandySel_ParentName="")
			CandySel_ParentName:=RTrim(CandySel_Drive,":")
	}
else if InStr(CandySel, "|RightMenu")  ;区分是否为右键菜单
{
	CandySel:=StrReplace(CandySel,"|RightMenu","")
	Candy_isFile:=1     ;如果是“文字型”的有效路径，强制认定为文件
	SplitPath,CandySel,CandySel_FileNameWithExt,CandySel_ParentPath,CandySel_Ext,CandySel_FileNameNoExt,CandySel_Drive
	SplitPath,CandySel_ParentPath,CandySel_ParentName,,,, ;用这个提取“所在文件夹名”
	CandySel_FileNameNoExt:=CandySel_FileNameWithExt
	CandySel_Ext=RightMenu
}
else if(InStr(CandySel,"`n") And  Candy_isFile=1)  ;如果包含多行，且粘贴板性质为文件，则是“多文件”
{
	CandySel_Ext:="MultiFiles" ;多文件的后缀=MultiFiles
	CandySel_FirstFile:=RegExReplace(CandySel,"(.*)\r.*","$1")  ;取第一行
	SplitPath ,CandySel_FirstFile,,CandySel_ParentPath,,  ;以第一行的父目录为“多文件的父目录”
	if RegExMatch(CandySel_ParentPath,"\:(|\\)$")  ;如果父目录是磁盘根目录,用盘符做父目录名。
		CandySel_ParentName:= RTrim(CandySel_ParentPath,":")
	else  ;否则，提取父目录名
		CandySel_ParentName:= RegExReplace(CandySel_ParentPath, ".*\\(.*)$", "$1")
}
else     ;文本类型
{
	;-----------特殊文字串辨析-------------------
	IniRead Candy_User_defined_TextType,%Candy_ProFile_Ini%,user_defined_TextType  ;是否符合用户正则定义的文本类型，有优先顺序的，排在前面的优先
	loop,Parse,Candy_User_defined_TextType,`n
	{
		If(RegExMatch(CandySel,RegExReplace(A_LoopField,"^.*?=")))     ;根据ini里面用户自定义段，逐条查看，右侧是正则规则
		{
			CandySel_Ext:=RegExReplace(A_LoopField,"=.*?$")   ;左边是“文本某类型”
			Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, "TextType", "i)(^|\|)" CandySel_Ext "($|\|)") ;获取该类型的”操作设定“
			If(Candy_Cmd!="Error")            ;如果有相应后缀组的定义，则跳出去运行。
			{
				goto Label_Candy_Read_Value
				break
			}
	}
}
IniRead,Candy_ShortText_Length,%Candy_ProFile_Ini%,Candy_Settings,ShortText_Length,80   ;没有定义，则根据所选文本的长短，设定为长文本或者短文本
CandySel_Ext:=StrLen(CandySel) < Candy_ShortText_Length ? "ShortText" : "LongText" ;区分长短文本
}
/*
╔══════════════════════════════════════╗
║<<<<④查找定义>>>>                     ║
╚══════════════════════════════════════╝
*/
Label_Candy_Read_Value:
	Candy_Type          :=Candy_isFile> 0 ? "FileType":"TextType"         ;根据Candy_isFile判断类型，在相应的INI段里面查找定义
	Candy_Type_Any   :=Candy_isFile> 0 ? "AnyFile":"AnyText"         ;根据Candy_isFile判断类型，对应的Any的名称
	Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, Candy_Type, "i)(^|\|)" CandySel_Ext "($|\|)")  ;查找后缀群定义
	If(Candy_Cmd="Error")            ;如果没有相应后缀组的定义；下面这些啰嗦的写法是为了各种容错
	{
		IfExist,%Candy_Profile_Dir%\%CandySel_Ext%.ini   ;看是否有 后缀.ini 的配置文件存在
		{
			Candy_Cmd:="Menu|" CandySel_Ext   ;同时，转化为Menu|命令行写法
		}
		else
		{
			IniRead,Candy_Cmd, %Candy_ProFile_Ini%,%Candy_Type%,%Candy_Type_Any%   ;如果没有则看看 Any在ini的定义有没有
			If(Candy_Cmd="Error")   ;没有对AnyFile（或AnyText）的定义，则看是否有 AnyFile.ini或AnyText.ini配置存在
			{
				IfExist,%Candy_Profile_Dir%\%Candy_Type%.ini   ;有，则以此为准
				{
					Candy_Cmd:="Menu|" Candy_Type   ;同时，转化为Menu|命令行写法
				}
				else
				{
					Run,%CandySel%, ,UseErrorLevel  ;层层把关都没有么，好失望的说，就直接运行吧
					return
				}
			}
	}
}
if !(RegExMatch(Candy_Cmd,"i)^Menu\|"))
{
	goto Label_Candy_RunCommand            ;如果不是Menu指令，直接运行应用程序
}
/*
╔══════════════════════════════════════╗
║<<<<⑤制作菜单>>>>                     ║
╚══════════════════════════════════════╝
*/
Label_Candy_DrawMenu:
	Menu,CandyTopLevelMenu,add
	Menu,CandyTopLevelMenu,DeleteAll
	CandyMenu_IconSize:=SkSub_IniRead(GeneralSettings_ini, "General_Settings", "MenuIconSize",16)
	CandyMenu_IconDir:=SkSub_IniRead(GeneralSettings_ini, "General_Settings", "MenuIconDir")  ;菜单图标位置

	;加第一行菜单，缩略显示选中的内容，该菜单让你拷贝其内容
	CandyMenu_FirstItem:=StrLen(CdSel_NoSpace:=Trim(CandySel)) >20 ? SubStr(CdSel_NoSpace,1,10) . "..." . SubStr(CdSel_NoSpace,-10) : CdSel_NoSpace
	Menu CandyTopLevelMenu,Add,%CandyMenu_FirstItem%,Label_Candy_CopyFullpath
	Candy_Firstline_Icon:=SkSub_Get_Firstline_Icon(CandySel_Ext,CandySel,CandyMenu_IconDir "\Extension")
	Menu CandyTopLevelMenu,icon,%CandyMenu_FirstItem%,%Candy_Firstline_Icon%,,%CandyMenu_IconSize%
	Menu CandyTopLevelMenu,Add
	
	arrCandyMenuFrom:=StrSplit( Candy_Cmd,"|")
	CandyMenu_ini:= arrCandyMenuFrom[2]="" ? Candy_ProFile_Ini_NameNoext : arrCandyMenuFrom[2]
	CandyMenu_sec:= arrCandyMenuFrom[3]="" ? "Menu" : arrCandyMenuFrom[3]
	
	szMenuIdx:={}
	szMenuContent:={}
	szMenuWhichFile:={}
	SkSub_GetMenuItem(Candy_Profile_Dir,CandyMenu_ini,CandyMenu_sec,"CandyTopLevelMenu","")
	SkSub_DeleteSubMenus("CandyTopLevelMenu")
	
	For,k,v in szMenuIdx
	{
		SkSub_CreateMenu(v,"CandyTopLevelMenu","Label_Candy_HandleMenu",CandyMenu_IconDir,CandyMenu_IconSize)
	}
	MouseGetPos,CandyMenu_X, CandyMenu_Y
	MouseMove,CandyMenu_X,CandyMenu_Y,0
	MouseMove,CandyMenu_X,CandyMenu_Y,0
	;     ToolTip,% A_TickCount-CandyStartTick,200,0     ;若要评估出menu时间，这里需打开 ,共三处，2/3
	Menu,CandyTopLevelMenu,shOW
	;     ToolTip ;若要评估出menu时间，这里需打开 ,共三处，3/3
return

;================菜单处理================================
Label_Candy_HandleMenu:
	if GetKeyState("Ctrl")          ;[按住Ctrl则是进入配置]
	{
		if GetKeyState("CapsLock", "T")
			Ky_CapsLockIsPressed:=1
		else
			Ky_CapsLockIsPressed:=0
		Candy_ctrl_ini_fullpath:=Candy_Profile_Dir . "\" . szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem] . ".ini"
		Candy_Ctrl_Regex:= "=\s*\Q" szMenuContent[ A_thisMenu "/" A_ThisMenuItem] "\E\s*$"
		SkSub_EditConfig(Candy_ctrl_ini_fullpath,Candy_Ctrl_Regex)
	}
	else if GetKeyState("Shift")      ;[按住Shift则是执行第二操作]
	{
		if GetKeyState("CapsLock", "T")
			Ky_CapsLockIsPressed:=1
		else
			Ky_CapsLockIsPressed:=0
		Ky_ShiftIsPressed:=1
		Candy_Cmd := szMenuContent[ A_thisMenu "/" A_ThisMenuItem]
		CandyError_From_Menu:=1
		goto Label_Candy_RunCommand
	}
	else
	{
		if GetKeyState("CapsLock", "T")
			Ky_CapsLockIsPressed:=1
		else
			Ky_CapsLockIsPressed:=0
		Candy_Cmd := szMenuContent[ A_thisMenu "/" A_ThisMenuItem]
		CandyError_From_Menu:=1
		goto Label_Candy_RunCommand
	}
return

Label_Candy_CopyFullpath:
	if GetKeyState("Ctrl")          ;[按住Ctrl则是进入主配置]
	{
		Candy_Ctrl_Regex:="i)(^\s*|\|)" CandySel_Ext "(\||\s*)[^=]*="
		SkSub_EditConfig(Candy_Profile_ini,Candy_Ctrl_Regex)
	}
	else
		Clipboard:=CandySel
return
/*
╔══════════════════════════════════════╗
║<<<<⑥变量替换>>>>                     ║
╚══════════════════════════════════════╝
*/
Lable_Candy_Batch_CMD_Analysis:
    Candy_Cmd:=RegExReplace(Candy_Cmd,"~\|",Chr(3))
    ; msgbox Lable_Candy_CMD_Analysis %Candy_Cmd%
    arrCandy_Cmd_Str:=StrSplit(Candy_Cmd,"|"," `t")
    Candy_Cmd_Str1:=arrCandy_Cmd_Str[1]
    Candy_Cmd_Str2:=RegExReplace(arrCandy_Cmd_Str[2],Chr(3),"|")
    Candy_Cmd_Str3:=RegExReplace(arrCandy_Cmd_Str[3],Chr(3),"|")
    If (Candy_Cmd_Str1="all")       
    {
        If (Candy_Cmd_Str2="group")
        {
            GroupPos:=A_ThisMenuItemPos
            IniRead,keylist,%Candy_ctrl_ini_fullpath%,menu            
            StringSplit, ItemListArr, keylist , `n,`r
            ; msgbox %ItemListArr0%`n %keylist%
            AbovePos:=GroupPos 
            While AbovePos >1
            {
                AbovePos--                
                Pos_Sep1:=instr(ItemListArr%AbovePos%,"-=",,1)
                if (Pos_Sep1>=1)
                    break
            }  
            BelowPos:=GroupPos 
            While BelowPos <ItemListArr0
            {
                BelowPos++
                Pos_Sep2:=instr(ItemListArr%BelowPos%,"-=",,1)
                if (Pos_Sep2>=1)
                    break
                
            }
            ; msgbox BelowPos %BelowPos% `n AbovePos %AbovePos%
            LoopCycles:=BelowPos-AbovePos+1
            While AbovePos<BelowPos
            {
              Candy_Cmd:=ItemListArr%AbovePos%
              EquaPos:=InStr(Candy_Cmd, "=")
              StringTrimLeft,Candy_Cmd,Candy_Cmd,%EquaPos%
              Candy_Cmd:=Trim(Candy_Cmd)        
              AbovePos++
              If (Candy_Cmd="all|group" or Candy_Cmd="all|section")
                Continue
              Gosub, Label_Candy_RunCommand
            }        
        }
        else If (Candy_Cmd_Str2="section")
        {
            IniRead,keylist,%Candy_ctrl_ini_fullpath%,menu            
            StringSplit, ItemListArr, keylist , `n,`r 
            loop, %ItemListArr0%
            {
                Candy_Cmd:=ItemListArr%A_Index%
                EquaPos:=InStr(Candy_Cmd, "=")
                StringTrimLeft,Candy_Cmd,Candy_Cmd,%EquaPos%
                Candy_Cmd:=Trim(Candy_Cmd)        
                If (Candy_Cmd="all|group" or Candy_Cmd="all|section")
                    Continue
                Gosub, Label_Candy_RunCommand
            }
        }
    }       
    Else
    {
        Goto  Label_Candy_RunCommand
    }
    return
    
Label_Candy_RunCommand:
	Candy_Cmd:=SkSub_EnvTrans(Candy_Cmd)  ;替换自变量以及系统变量,Ini里面用~%表示一个%,当然要用~~%，表示一个原义的~%
	Candy_Cmd=%Candy_Cmd%
	if (InStr(Candy_Cmd,"{SetClipBoard:pure}")+InStr(Candy_Cmd,"{SetClipBoard:rich}") )       ;这个开关指令会修改系统粘贴板，不会对命令行本身产生作用。所以先要从命令行替换掉。
	{
		Clipboard:=InStr(Candy_Cmd,"{SetClipBoard:pure}") ? CandySel : CandySel_Rich
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{SetClipBoard\:.*\}")
	}
	if (InStr(Candy_Cmd,"{icon:")) ;icon图标
	{
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{icon\:.*\}")
	}
	if Candy_Cmd=   ;如果只想进行以上两步操作，如果运行的指令为空，则直接退出
		return
	if InStr(Candy_Cmd,"{date:")     ; 时间参数！定义方法为:{date:yyyy_MM_dd} 冒号:后面的部分可以随意定义
	{
		Candy_Time_Mode:=RegExReplace(Candy_Cmd,"i).*\{date\:(.*?)\}.*","$1")
		FormatTime,Candy_Time_Formated,%A_nOW%,%Candy_Time_Mode%
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{date\:(.*?)\}",Candy_Time_Formated)
	}
	if InStr(Candy_Cmd,"{in:")    ; in：多文件的后缀包含
	{
		Candy_in_M:="i`am)^.*\.(" RegExReplace(Candy_Cmd,"i).*\{in\:(.*?)\}.*","$1") ")$"
		Grep(CandySel, Candy_in_M, CandySel, 1, 0, "`n")
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{in\:.*\}")
		if  (CandySel="")
			return
		else
			StringReplace,CandySel,CandySel,`n,`r`n,all
	}
	if InStr(Candy_Cmd,"{ex:")    ; ex：多文件的后缀排除
	{
		Candy_ex_M:="i`am)^.*\.(" RegExReplace(Candy_Cmd,"i).*\{ex\:(.*?)\}.*","$1") ")$\R?"    ;可用，只是多了一个”后空白问题“
		CandySel:=RegExReplace(CandySel,Candy_ex_M)
		CandySel:=RegExReplace(CandySel,"\s*$","")         ;清除后空白 CandySel:=Trim(CandySel,"`r`n")         ;清除后空白
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{ex\:.*\}")
		Clipboard:=CandySel
		if  (CandySel="")
			return
	}
	if InStr(Candy_Cmd,"{Input:")   ;特别的参数:带有prompt提示文字的Input 例：{Input:请输入延迟时间，以ms为单位},支持多个Input输入
	{    ;如果要输入密码，请写成{input:提示文字:hide}
		CdInput_P=1
		Candy_Cmd_tmp:=Candy_Cmd
		while CdInput_P :=  RegExMatch(Candy_Cmd_tmp, "i)\{Input\:(.*?)\}", CdInput_M, CdInput_P+StrLen(CdInput_M))
		{
			CdInput_Prompt:= RegExReplace(CdInput_M,"i).*\{Input\:(.*?)(:hide)?}.*","$1")
			CdInput_Hide:= RegExMatch(CdInput_M,"i)\{Input:.*?:hide}") ? "hide":""
			Gui +LastFound +OWnDialogs +AlwaysOnTop
			InputBox, CdInput_txt,Candy InputBox,`n%CdInput_Prompt% ,%CdInput_Hide%, 285, 175,,,,,
			if ErrorLevel
				return
			else
				StringReplace,Candy_Cmd,Candy_Cmd,%CdInput_M%,%CdInput_txt%
		}
	}
	if InStr(Candy_Cmd,"{box:Filebrowser}")
	{
		FileSelectFile, f_File ,,, 请选择文件
		if ErrorLevel
			return
		StringReplace,Candy_Cmd,Candy_Cmd,{box:Filebrowser},%f_File%,All
	}
	if InStr(Candy_Cmd,"{box:mFilebrowser}")
	{
		FileSelectFile, f_File ,M, , 请选择文件
		if ErrorLevel
			return
		CdMfile_suffix  := RegExReplace(Candy_Cmd,"i).*\{box:mFilebrowser:.*LastFile(.*?)\}.*","$1")
		CdMfile_prefix  := RegExReplace(Candy_Cmd,"i).*\{box:mFilebrowser:(.*?)FirstFile.*","$1")
		CdMfile_midfix := RegExReplace(Candy_Cmd,"i).*\{box:mFilebrowser:.*FirstFile(.*?)LastFile.*\}.*","$1")
		Firstline:=RegExReplace(f_File,"\n.*")
		no_Firstline:=RegExReplace(f_File,"^.*?\n","$1")
		StringReplace  ,CandySel_list,no_Firstline,`n,%CdMfile_midfix%%Firstline%/,all
		CandySel_list=%CdMfile_prefix%%Firstline%\%CandySel_list%%CdMfile_suffix%
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{.*FirstFile.*LastFile.*\}",CandySel_list)
	}
	if InStr(Candy_Cmd,"{box:folderbrowser}")
	{
		FileSelectFolder, f_Folder , , , 请选择文件夹
		if f_Folder <>
			StringReplace,Candy_Cmd,Candy_Cmd,{box:folderbrowser},%f_Folder%,All
		else
			return
	}
	Candy_Cmd:=RegExReplace(Candy_Cmd,"(?<=\s|^)\{File:fullpath\}(?=\s|$|\|)","""{File:fullpath}""")     ;强制把前后有空字符或者顶端的全路径，套上引号
	if InStr(Candy_Cmd,"{File:linktarget}")
	{
		FileGetShortcut,%CandySel%,CandySel_LinkTarget
		StringReplace,Candy_Cmd,Candy_Cmd,{File:linktarget} ,%CandySel_LinkTarget%,All                      ;lnk的目标
	}
	CandyCmd_RepStr :=Object( "{File:ext}"                ,CandySel_Ext
		,"{File:name}"            ,CandySel_FileNameNoExt
		,"{File:parentpath}"   ,CandySel_ParentPath
		,"{File:parentname}"  ,CandySel_ParentName
		,"{File:Drive}"             ,CandySel_Drive
		,"{File:Fullpath}"         ,CandySel
		,"{Text}"                     ,CandySel)
	For k, v in CandyCmd_RepStr
		StringReplace  ,Candy_Cmd,Candy_Cmd,%k%,%v%,All
	if RegExMatch(Candy_Cmd,"i)\{.*FirstFile.*LastFile.*\}")  ;如果是文件列表，需要先整理成需要的模式
	{   ;ini里面文件列表定义：   {FirstFile LastFile}   FirstFile代表非最后一个文件，LastFile代表最后一个文件。
		CdMfile_prefix  := RegExReplace(Candy_Cmd,"i).*\{(.*?)FirstFile.*\}.*","$1")
		CdMfile_suffix  := RegExReplace(Candy_Cmd,"i).*\{.*LastFile(.*?)\}.*","$1")
		CdMfile_midfix := RegExReplace(Candy_Cmd,"i).*\{.*FirstFile(.*?)LastFile.*\}.*","$1")
		StringReplace ,CandySel_list,CandySel,`r`n,%CdMfile_midfix%,all
		CandySel_list=%CdMfile_prefix%%CandySel_list%%CdMfile_suffix%
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{.*FirstFile.*LastFile.*\}",CandySel_list)
	}
	if InStr(Candy_Cmd,"{file:name:")
	{
		Candy_FileName_Coded:=
		Candy_FileName_CodeType:= RegExReplace(Candy_Cmd,"i).*\{File\:name\:(.*?)\}.*","$1")
		Candy_FileName_Coded:=SkSub_UrlEncode(CandySel_FileNameNoExt,Candy_FileName_CodeType)
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{File\:name\:(.*?)\}",Candy_FileName_Coded)
	}
	if InStr(Candy_Cmd,"{text:")  ;如果是需要格式化的文本，那先格式化再替换
	{
		Candy_Text_Coded:=
		Candy_Text_CodeType:= RegExReplace(Candy_Cmd,"i).*\{Text\:(.*?)\}.*","$1")
		Candy_Text_Coded:=SkSub_UrlEncode(CandySel,Candy_Text_CodeType)
		Candy_Cmd:=RegExReplace(Candy_Cmd,"i)\{Text\:(.*?)\}",Candy_Text_Coded)
	}
	if InStr(Candy_Cmd,"{mfile:")  ;多文件中，带有序号的文件
	{
		loop,Parse,CandySel,`n
			StringReplace,Candy_Cmd,Candy_Cmd,{mfile:%A_Index%},%A_loopfield%,All
	}
/*
╔══════════════════════════════════════╗
║<<<<⑦终极运行>>>>                     ║
╚══════════════════════════════════════╝
*/
	Candy_All_Cmd:="web|keys|cando|cango|Run|openwith|SetClipBoard|MsgBox|config|openwith|ow|Rund|Runp"
	if Not RegExMatch(Candy_Cmd,"i)^\s*(" Candy_All_Cmd ")\s*\|")
		Candy_Cmd=OpenWith|%Candy_Cmd% ;如果没有,则人为补一个OpenWith
	Candy_Cmd:=RegExReplace(Candy_Cmd,"~\|",Chr(3))
	arrCandy_Cmd_Str:=StrSplit(Candy_Cmd,"|"," `t")
	Candy_Cmd_Str1:=arrCandy_Cmd_Str[1]
	Candy_Cmd_Str2:=RegExReplace(arrCandy_Cmd_Str[2],Chr(3),"|")
	Candy_Cmd_Str3:=RegExReplace(arrCandy_Cmd_Str[3],Chr(3),"|")
	if (Candy_Cmd_Str1="web")
	{
		SkSub_WebSearch(Candy_CurWin_Fullpath,RegExReplace(Candy_Cmd,"i)^web\|(\s+|)|\s+"))
	}
	else if (Candy_Cmd_Str1="Keys")  ;如果是以keys|开头，则是发热键
	{
		Send %Candy_Cmd_Str2%
	}
	else if (Candy_Cmd_Str1="MsgBox")  ;如果是以MsgBox|开头，则是发一个提示框
	{
		Gui +LastFound +OWnDialogs +AlwaysOnTop
		MsgBox %Candy_Cmd_Str2%
	}
	else if (Candy_Cmd_Str1="Config")
	{
		for k,v in szMenuWhichfile
			Config_files .= v "`n"
		Config_files:=RemoveDuplicates(Config_files)
		loop ,Parse, Config_files,`n
			SkSub_EditConfig(Candy_Profile_Dir . "\" A_LoopField ".ini","")
		Candy_Ctrl_Regex:="i)(^\s*|\|)" CandySel_Ext "(\||\s*)[^=]*="
		SkSub_EditConfig(Candy_Profile_ini,Candy_Ctrl_Regex)
	}
	else if (Candy_Cmd_Str1="SetClipBoard")   ;之前的开关，只能把选中的内容放进粘贴板，而这个指令，则可以把后面跟随的内容放进粘贴板。（更丰富）
	{
		Clipboard := Candy_Cmd_Str2
	}
	else if (Candy_Cmd_Str1="Cando")  ;如果是以Cando|开头，则是运行一些内部程序，方便与你的其它脚本进行挂接
	{
		CandySelected:=CandySel    ;兼容以前的cando变量写法
		if IsLabel("Cando_" . Candy_Cmd_Str2)                       ;程序内置的别名
			goto % "Cando_" . Candy_Cmd_Str2
		else
			goto Label_Candy_ErrorHandle
	}
	else if (Candy_Cmd_Str1="Cango")   ;如果是以Cango|开头，则是运行一些外部ahk程序，方便与你的其它脚本进行挂接
	{
		IfExist,%Candy_Cmd_Str2%
			Run %ahk% "%Candy_Cmd_Str2%" "%Candy_Cmd_Str3%" ;外部的ahk代码段，你的ahk可以带参数
		else
			goto Label_Candy_ErrorHandle
	}
	else if (Candy_Cmd_Str1="OpenWith" or Candy_Cmd_Str1="OW")     ;OpenWith|指定用某程序打开选定的内容，这时候，应用程序后面不能带任何命令行，（严格的说是目标参数是且仅是“被选内容“，只是被省略了）
	{
		Run ,%Candy_Cmd_Str2% "%CandySel%",%Candy_Cmd_Str3%,%Candy_Cmd_Str4% UseErrorLevel             ;1:程序  2:工作目录 3:状态
		if (ErrorLevel = "Error")               ;如果运行出错的话
			goto Label_Candy_ErrorHandle
	}
	else if (Candy_Cmd_Str1="Run")     ;其后面要带命令行，即使操作对象是被选中的文件，也不能省略
	{
		Run,%Candy_Cmd_Str2% ,%Candy_Cmd_Str3%,%Candy_Cmd_Str4% UseErrorLevel             ;1:程序  2:工作目录 3:状态
		if (ErrorLevel = "Error")               ;如果运行出错的话
			goto Label_Candy_ErrorHandle
	}
	else if (Candy_Cmd_Str1="RunD")     ;格式为RunD|应用程序|应用程序的标题|x|y|等待时间
	{       ;没发现这个x，y起作用的情况，暂时放着
		Run,%Candy_Cmd_Str2%,, UseErrorLevel
		if (ErrorLevel = "Error")               ;如果运行出错的话
			goto Label_Candy_ErrorHandle
		else
		{
			Sleep,% (Candy_Cmd_Str4="") ? 1000 : arrCandy_Cmd_Str[6]
			WinWaitActive, %Candy_Cmd_Str3% ,,5
			WinActivate, %Candy_Cmd_Str3%
			Candy_RunD_x:=arrCandy_Cmd_Str[4] ? arrCandy_Cmd_Str[4] : 100
			Candy_RunD_y:=arrCandy_Cmd_Str[5] ? arrCandy_Cmd_Str[5] : 100
			PostMessage, 0x233, HDrop( CandySel,Candy_RunD_x,Candy_RunD_y), 0,, %Candy_Cmd_Str3%
		}
	}
	else if (Candy_Cmd_Str1="RunP")     ;格式为RunP|应用程序|应用程序的标题|等待时间；；
	{
		Clipboard := CandySel_Rich
		Run,%Candy_Cmd_Str2%,, UseErrorLevel
		if (ErrorLevel = "Error")               ;如果运行出错的话
			goto Label_Candy_ErrorHandle
		else
		{
			Sleep,% (Candy_Cmd_Str4="") ? 1000 : Candy_Cmd_Str4
			WinWaitActive, %Candy_Cmd_Str3% ,,5
			WinActivate, %Candy_Cmd_Str3%
			Send ^v
		}
	}
return
/*
╔══════════════════════════════════════╗
║<<<<⑧出错处理>>>>                     ║
╚══════════════════════════════════════╝
*/
Label_Candy_ErrorHandle: ;出错啦！
	if (SkSub_IniRead(Candy_ProFile_Ini,"Candy_Settings","ShowError", 0)=1 )     ;看看出错提示开关打开了没有，打开了的话，就显示出错信息
	{
		Gui +LastFound +OwnDialogs +AlwaysOnTop
		MsgBox, 4116,, 下述命令行定义出错： `n---------------------`n%Candy_Cmd%`n---------------------`n后缀名: %CandySel_Ext%`n`n立即配置相应ini？
		IfMsgBox Yes
		{
			if (CandyError_From_Menu=1)
			{
				Candy_This_ini:=szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem]
				Candy_ctrl_ini_fullpath:=Candy_Profile_Dir . "\" . szMenuWhichFile[ A_thisMenu "/" A_ThisMenuItem] . ".ini"
				Candy_Ctrl_Regex:= "=\s*\Q" szMenuContent[ A_thisMenu "/" A_ThisMenuItem] "\E\s*$"
				SkSub_EditConfig(Candy_ctrl_ini_fullpath,Candy_Ctrl_Regex)
			}
			else
			{
				Candy_Ctrl_Regex:="i)(^\s*|\|)" CandySel_Ext "(\||\s*)[^=]*="
				SkSub_EditConfig(Candy_Profile_ini,Candy_Ctrl_Regex)
			}
		}
	}
return

/*
╔══════════════════════════════════════╗
║<<<<Fuctions所用到的函数>>>>          ║
╚══════════════════════════════════════╝
*/
SkSub_GetMenuItem(IniDir,IniNameNoExt,Sec,TopRootMenuName,Parent="")   ;从一个ini的某个段获取条目，用于生成菜单。
{
	Items:=SkSub_IniRead_Section(IniDir "\" IniNameNoExt ".ini",sec)         ;本次菜单的发起地
	StringReplace,Items,Items,△,`t,all
	loop,Parse,Items,`n
	{
		Left:=RegExReplace(A_LoopField,"(?<=\/)\s+|\s+(?=\/)|^\s+|(|\s+)=[^!]*[^>]*")
		Right:=RegExReplace(A_LoopField,"^.*?\=\s*(.*)\s*$","$1")
		if (RegExMatch(left,"^/|//|/$|^$")) ;如果最右端是/，或者最左端是/，或者存在//，则是一个错误的定义，抛弃
			continue
		if RegExMatch(Left,"i)(^|/)\+$")   ;如果左边的最末端是仅仅一个"独立的" + 号
		{
			m_Parent := InStr(Left,"/") > 0 ? RegExReplace(Left,"/[^/]*$") "/" : ""  ;如果+号前面有存在上级菜单,则有上级菜单，否则没有
			Right:=RegExReplace(Right,"~\|",Chr(3))
			arrRight:=StrSplit(Right,"|"," `t")
			rr1:=arrRight[1]
			rr2:=RegExReplace(arrRight[2],Chr(3),"|")
			rr3:=RegExReplace(arrRight[3],Chr(3),"|")
			rr4:=RegExReplace(arrRight[4],Chr(3),"|")
			if (rr1="Menu")   ;如果后面是“插入（子）菜单”的命令 ，则极有可能菜单里面还有“嵌套的下级菜单”。。
			{
				m_ini:= (rr2="") ? IniNameNoExt :  rr2
				m_sec:= (rr3="") ? "Menu" : rr3
				m_Parent:=Parent "" m_Parent
				this:=SkSub_GetMenuItem(IniDir,m_ini,m_sec,TopRootMenuName,m_Parent)      ;嵌套，循环使用此函数，以便处理“其他文件里的，插入的菜单”
			}
			;             用+的方法，可以让你快速扩展自己定义的子菜单，否则直接可以写在左侧了。
		}
		else
		{
			szMenuIdx.Insert( Parent ""  Left )
			szMenuContent[ TopRootMenuName "/" Parent "" Left] := Right
			szMenuWhichFile[ TopRootMenuName "/" Parent "" Left] :=IniNameNoExt
		}
	}
}
SkSub_DeleteSubMenus(TopRootMenuName)
{
	For i,v in szMenuIdx
	{
		if InStr(v,"/")>0
		{
			Item:=RegExReplace(v, "(.*)/.*", "$1")
			Menu,%TopRootMenuName%/%Item%,add
			Menu,%TopRootMenuName%/%Item%,DeleteAll
		}
	}
}
SkSub_CreateMenu(Item,ParentMenuName,label,IconDir,IconSize)    ;条目，它所处的父菜单名，菜单处理的目标标签
{  ;送进来的Item已经经过了“去空格处理”，放心使用
	arrS:=StrSplit(Item,"/"," `t")
	_s:=arrS[1]
	if arrS.MaxIndex()= 1      ;如果里面没有 /，就是最终的”菜单项“。添加到”它的父菜单”上。
	{
		if InStr(_s,"-") = 1       ;-分割线
			Menu, %ParentMenuName%, Add
		else if InStr(_s,"*") = 1       ;* 灰菜单
		{
			_s:=LTrim(_s,"*")
			Menu, %ParentMenuName%, Add,       %_s%,%Label%
			Menu, %ParentMenuName%, Disable,  %_s%
		}
		else
		{
			y:=szMenuContent[ ParentMenuName "/" Item]
			z:=SkSub_Get_MenuItem_Icon( y ,IconDir)
			Menu, %ParentMenuName%, Add,  %_s%,%Label%
			Menu, %ParentMenuName%, icon,  %_s%,%z%,,%IconSize%
		}
	}
	else     ;如果有/，说明还不是最终的菜单项，还得一层一层分拨出来。
	{
		_Sub_ParentName=%ParentMenuName%/%_s%
		StringTrimLeft,_subItem,Item,StrLen(_s)+1
		SkSub_CreateMenu(_subItem,_Sub_ParentName,label,IconDir,IconSize)
		Menu,%ParentMenuName%,add,%_s%,:%_Sub_ParentName%
	}
}
SkSub_EnvTrans(v)
{
	v:=RegExReplace(v,"~%",Chr(3))
	Transform,v,Deref,%v% ;解决Sala的ini中支持%A_desktop%或%windir%等ahk变量或系统环境变量的解释问题，@sunwind @小古
	v:=RegExReplace(v,Chr(3),"%")
	return v
}
SkSub_Get_Firstline_Icon(ext,fullpath,iconpath)
{
	IfExist,%iconpath%\%ext%.ico             ;如果固定的文件夹里面存在该类型的图标
		x := iconpath "\" ext ".ico"
	else if ext in  bmp,gif,png,jpg,ico,icl,exe,dll
		x := fullpath
	else
		x:=AssocQueryApp(Ext)
	return %x%
}
SkSub_Get_MenuItem_Icon(item,iconpath)   ; item=需要获取图标的条目，iconpath=你定义的图标库文件夹
{
	cmd:=RegExReplace(item,"^\s+|(|\s+)\|[^!]*[^>]*")
	if InStr(item,"{icon:")     ; 有图标硬定义
	{
		Path_Icon:=RegExReplace(item,"i).*\{icon\:(.*?)\}.*","$1")
		If(FileExist(Path_Icon))         ;若有全路径的图标存在
		return Path_Icon
		If(FileExist(iconpath "\MyIcon\" Path_Icon))       ;若在MyIcon文件夹里面
		return iconpath "\MyIcon\" Path_Icon
	}
	else if FileExist(iconpath "\Command\" cmd ".ico")      ;若存在 "命令名.ico" 文件
	{
		return  iconpath "\Command\" cmd ".ico"
	}
	item:=SkSub_envtrans(item)
	if RegExMatch(item,"i)^(ow|openwith|rot|Run|roa|Runp|Rund)\|") ;运行命令类
	{
		cmd_removed:=RegExReplace(item,"^.*?\|")      ;里面纯粹的 应用程序 路径
		x:=RegExReplace(cmd_removed,"i)exe[^!]*[^>]*", "exe")
		return %x%
	}
	else if InStr(item,".exe") ;省略了指令的openwith|
	{
		x:=RegExReplace(item,"i)\.exe[^!]*[^>]*", ".exe")
		return %x%
	}
	else
	{
		t:=RegExReplace(item,"\s*\|.*?$")       ;去除运行参数，只保留第一个|最前面的部分
		x:=AssocQueryApp(t)
		return %x%
	}
}
AssocQueryApp(sExt)
{
	sExt =.%sExt%  ;ASSOCSTR_EXECUTABLE
	DllCall("shlwapi.dll\AssocQueryString", "uint", 0, "uint", 2, "uint", &sExt, "uint", 0, "uint", 0, "uint*", iLength)
	VarSetCapacity(sApp, 2*iLength, 0)
	DllCall("shlwapi.dll\AssocQueryString", "uint", 0, "uint", 2, "uint", &sExt, "uint", 0, "str", sApp, "uint*", iLength)
	return sApp
}
SkSub_Regex_IniRead(ini,sec,reg)      ;正则方式的读取，等号左侧符合正则条件
{  ;在ini的某个段内，查找符合某正则规则的字符串，并返回value值
	IniRead,keylist,%ini%,%sec%,
	loop,Parse,keylist,`n
	{
		t:=RegExReplace(A_LoopField,"=.*?$")
		If(RegExMatch(t, reg))
		{
			return % RegExReplace(A_LoopField,"^.*?=")
			break
		}
}
return "Error"
}
SkSub_IniRead(ini, sec, key="", default = "")   ;iniread的函数化
{
	IniRead, v, %ini%, %sec%, %key%, %Default%
	return, v
}
SkSub_IniRead_Section(ini,sec)
{  ;返回全部某段的内容，函数化而已
	IniRead,keylist,%ini%,%sec%              ;提取[sec]段里面所有的群组
	return %keylist%
}
grep(h, n, ByRef v, s = 1, e = 0, d = "")
{
	v =
	StringReplace, h, h, %d%, , All
	loop
		if s := RegExMatch(h, n, c, s)
			p .= d . s, s += StrLen(c), v .= d . (e ? c%e% : c)
		else return, SubStr(p, 2), v := SubStr(v, 2)
}
SkSub_UrlEncode(str, enc="UTF-8")
{
	enc:=Trim(enc)
	if enc=
		return str
	hex := "00", func := "msvcrt\" . (A_IsUnicode ? "swprintf" : "sprintf")
	VarSetCapacity(buff, size:=StrPut(str, enc)), StrPut(str, &buff, enc)
	while (code := NumGet(buff, A_Index - 1, "UChar")) && DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", code, "Cdecl")
	encoded .= hex
	return encoded
}
SkSub_WebSearch(Win_Full_Path,Http)
{
	all_browser:=SkSub_IniRead(GeneralSettings_ini, "General_Settings", "InUse_Browser")
	DefaultBrowser:=SkSub_EnvTrans(SkSub_IniRead(GeneralSettings_ini, "General_Settings", "Default_Browser"))
	;第①步，看当前当前激活窗口 是否 浏览器
	if Win_Full_Path Contains %All_Browser%
	{
		Browser:=Win_Full_Path
	}
	;第②步，看进程里面有没有浏览器，若有，看能被提取出来（防止虚拟桌面的隔离，妖自己的需求）
	else loop,Parse,All_Browser,`,   ;看所有定义的浏览器，
	{
		Useful_FullPath:=SkSub_Process_exist_and_useful(A_LoopField)
		if (  Useful_FullPath!= 0  and Useful_FullPath!= 1 )
		{
			Browser:=Useful_FullPath
			break
		}
	}
	; 第③步 ，都没有么，看ini默认浏览器是否符合条件
	if ( Browser="")  ;看ini默认浏览器，a。看进程中是否有，并且能被提取出来（防止虚拟桌面的隔离，妖自己的需求）。b。或者进程里面没有。
	{
		DefaultBrowser_去除参数:= RegExReplace(DefaultBrowser, "exe[^!]*[^>]*", "exe")
		SplitPath ,DefaultBrowser_去除参数,DefaultBrowser_name
		Useful_FullPath:=SkSub_Process_exist_and_useful(DefaultBrowser_name)
		if (  Useful_FullPath!= 0  And FileExist(DefaultBrowser_去除参数))
		{
			Browser:=DefaultBrowser
		}
	}
	; 第④部，最终运行
	if Browser ;如果取到了浏览器
	{
		SplitPath,browser,,,,browser_namenoext
		Browser_Args:=SkSub_IniRead(GeneralSettings_ini, "WebBrowser's_CommandLIne", browser_namenoext)
		if (Browser_Args!="Error")  ;有些浏览器，必须带参数,比如config或者单进程限制等待，所以在ini里面提供了一个定义的地方。
		{
			Browser := Browser " " Browser_Args
		}
		Run,% Browser . " """ . Http . """"
		IfInString Browser,firefox.exe
			WinActivate,Mozilla Firefox Ahk_Class MozillaWindowClass
		else
			WinActivate Ahk_PID %ErrorLevel%
	}
	else ;没有浏览器么
	{  ;看注册表 是否有默认的浏览器
		RegRead, RegDefaultBrowser, HKEY_CLASSES_ROOT, http\shell\open\command
		StringReplace, RegDefaultBrowser, RegDefaultBrowser,"
		SplitPath, RegDefaultBrowser,,RDB_Dir,,RDB_NameNoExt,
		Run,% RDB_Dir . "\" . RDB_NameNoExt . ".exe" . " """ . Http . """",,UseErrorLevel
		if errorlevel
		{
			Run,% "iexplore.exe " . site . """"   ;internet explorer
		}
	}
}
;============================================================================================================
SkSub_process_exist_and_useful(Process_name)        ;判断某个进程是否存在且能有效运行，如果不用desktops，这段代码可以清除掉。
{
	Process,exist,%Process_name%
	WinGet, Process_Fullpath,ProcessPath,Ahk_PID %ErrorLevel%
	if (ErrorLevel!=0 And  Process_Fullpath!="")
		return %Process_Fullpath%
	else if ErrorLevel=0
		return 1
	else
		return 0
}
HDrop(fnames,x=0,y=0)
{
	characterSize := A_IsUnicode ? 2 : 1
	fns:=RegExReplace(fnames,"\n$")
	fns:=RegExReplace(fns,"^\n")
	hDrop:=DllCall("GlobalAlloc","UInt",0x42,"UInt",20+(StrLen(fns)*characterSize)+characterSize*2)
	p:=DllCall("GlobalLock","UInt",hDrop)
	NumPut(20, p+0)  ;offset
	NumPut(x,  p+4)  ;pt.x
	NumPut(y,  p+8)  ;pt.y
	NumPut(0,  p+12) ;fNC
	NumPut(A_IsUnicode ? 1 : 0,  p+16) ;fWide
	p2:=p+20
	loop,Parse,fns,`n,`r
	{
		DllCall("RtlMoveMemory","UInt",p2,"Str",A_LoopField,"UInt",StrLen(A_LoopField)*characterSize)
		p2+=StrLen(A_LoopField)*characterSize + characterSize
	}
	DllCall("GlobalUnlock","UInt",hDrop)
	return hDrop
}
SkSub_EditConfig(inifile,regex="") ;编辑配置文件！
{
	if not FileExist(inifile)      ;动态菜单未必有ini文件存在
		return
	if (regex<>"")  ;如果送了正则表达式进来
	{
		loop
		{
			FileReadLine, L, %inifile%, %A_Index%
			if ErrorLevel
				break
			if RegExMatch(L,regex)
			{
				LineNo:=a_index
				break
			}
		}
	}
	TextEditor:=SkSub_EnvTrans(SkSub_IniRead(GeneralSettings_ini, "General_Settings", "Default_TextEditor"))  ;默认文本编辑器
	TextEditor:=FileExist(TextEditor) ? TextEditor:"notepad.exe"       ;文本编辑器
	SplitPath,TextEditor,,,,namenoext
	LineJumpArgs:=SkSub_IniRead(GeneralSettings_ini, "TextEditor's_CommandLine", namenoext)
	if  (LineJumpArgs="Error" or LineNo="" )
		cmd :=TextEditor " " inifile
	else
	{
		cmd :=TextEditor " " LineJumpArgs
		StringReplace,cmd,cmd,$(FILEPATH),%inifile%
		StringReplace,cmd,cmd,$(LINENUM),%LineNo%
	}
	Run,%cmd%,,UseErrorLevel,TextEditor_PID
	WinActivate ahk_pid %TextEditor_PID%
	return
}

SkSub_Clear_CandyVar()
{
	Global
	CandySel:=
	CandySel_LinkTarget:=
	CandySel_Ext:=
	CandySel_FileNamenoExt:=
	CandySel_ParentPath:=
	CandySel_ParentName:=
	CandySel_Drive:=
	Config_files:=
	CandyError_From_Menu:=0
}

RemoveDuplicates(Str, Delimiter="`n")
{
	Str_Sort := Str
	Sort, Str_Sort, U
	loop, Parse, Str_Sort, `n, `r
	{
		Str_m :=  "`am)^" A_LoopField "$"
		Str :=  RegExReplace(Str,Str_m,"","",-1,RegExMatch(Str,Str_m)+StrLen(A_LoopField))
	}
	return %  Trim(RegExReplace(Str,"\v+","`n"))
}
/*
╔══════════════════════════════════════╗
║<<<<托盘菜单处理部分>>>>              ║
╚══════════════════════════════════════╝
*/
SkSub_CreatTrayMenu()
{
	Menu, Tray, Icon,candy.ico
	Menu, Tray, NoStandard ; 自定义菜单放在标准菜单上面
	Menu, tray, add, 关于与提示,TrayHandle_About
	Menu, tray, add ;分隔符
	Menu, Tray, add, 编辑candy脚本, Candy_Edit
	Menu, tray, add, 编辑全局配置,TrayHandle_GeneralSettings
	Menu, tray, add, 重启脚本,TrayHandle_ReLoad
	Menu, tray, add ; 分隔符
	IniRead,Ky_RunWithSystem,ini\GeneralSettings.ini, Ky_Settings, RunWithSystem,0   ;读取Ky变量，是否随系统启动
	Menu,tray,add, 随系统启动,TrayHandle_RunWithSystem
	if (Ky_RunWithSystem)
		Menu,tray,Check ,随系统启动
	else
		Menu,tray,UnCheck, 随系统启动
	Menu, tray, add ; 分隔符
	Menu, tray, add, 退出,TrayHandle_Exit
}
/*
╔══════════════════════════════════════╗
║<<<<托盘菜单处理部分>>>>              ║
╚══════════════════════════════════════╝
*/
Candy_Edit:
	Edit
return

TrayHandle_ReLoad:
	Reload
return
TrayHandle_Exit:
	ExitApp
return

TrayHandle_GeneralSettings:
	SkSub_EditConfig(GeneralSettings_ini,"")
return

TrayHandle_RunWithSystem:
	if (Ky_RunWithSystem)
	{
		;menu,tray,unCheck ,随系统启动
		IniWrite,0,ini\GeneralSettings.ini, Ky_Settings, RunWithSystem      ;改成不随启动，0
		RegDelete,HKEY_LOCAL_MACHINE,Software\Microsoft\Windows\CurrentVersion\Run,Candy
		Reload
	} else {
		;menu,tray,Check, 随系统启动
		IniWrite,1,ini\GeneralSettings.ini, Ky_Settings, RunWithSystem      ;改成随启动，1
		RegWrite,REG_SZ,HKEY_LOCAL_MACHINE,Software\Microsoft\Windows\CurrentVersion\Run,Candy,%A_ScriptFullPath%
		Reload
	}
return

TrayHandle_About:
	MsgBox, , About Candy,
	( LTrim
		版本：Candy 2.0.0.6
		修改：Kawvin(QQ:2857814247)
		作者：万年书妖(QQ:710117768)
		邮箱：万年书妖(aamii@qq.com)
	)
return

;==================================================================================
;从资源管理器中，获取被选择的文件的路径（及文件夹）的API
/*
Explorer_GetSelected(hwnd="")   - paths of target window's selected items
Explorer_GetAll(hwnd="")        - paths of all items in the target window's folder
Explorer_GetPath(hwnd="")       - path of target window's folder

用法:
F1::
path := Explorer_GetPath()      ;打开的目录的路径
all := Explorer_GetAll()        ;打开的路径下的所有文件的路径
sel := Explorer_GetSelected()   ;打开的路径下所选择的文件的路径
MsgBox % path
MsgBox % all
MsgBox % sel
return
*/

Explorer_GetPath(hwnd="")
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
		return A_Desktop
	path := window.LocationURL
	path := RegExReplace(path, "ftp://.*@","ftp://")
	StringReplace, path, path, file:///
	StringReplace, path, path, /, \, All
	loop
		if RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
		else break
	return path
}

Explorer_GetAll(hwnd="")
{
	return Explorer_Get(hwnd)
}

Explorer_GetSelected(hwnd="")
{
	return Explorer_Get(hwnd,true)
}

Explorer_GetWindow(hwnd="")
{
	WinGet, Process, ProcessName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
	WinGetClass class, ahk_id %hwnd%

	if (Process!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW")
		return "desktop" ; desktop found
}

Explorer_Get(hwnd="",selection=false)
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
	{
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
		if !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop
		loop, Parse, files, `n, `r
		{
			path := base "\" A_LoopField
			IfExist %path% ; ignore special icons like Computer (at least for now)
				ret .= path "`n"
		}
	}
	else
	{
		if selection
			collection := window.document.SelectedItems
		else
			collection := window.document.Folder.Items
		for item in collection
			ret .= item.path "`n"
	}
	return Trim(ret,"`n")
}


/*
╔══════════════════════════════════════╗
║我常用的脚本及快捷启动                ║
║AHK版本      :1.1.33.10               ║
║版本V03      :2022.01.08              ║
║版本V02      :2020.03.22              ║
║版本V01      :2016.12.24              ║
║原始版本日期 :2014.09.10              ║
║                                      ║
║适用平台     :Windows                 ║
║作    者     :Kawvin(285781427@qq.com)║
║原 作 者     :万年书妖(aamii@qq.com)  ║
║热键说明: #=Win +=Shift ^=Ctrl !=Alt  ║
╚══════════════════════════════════════╝
*/
;以下是个人自定义的快捷键及功能
#Include %A_ScriptDir%\include\hotstring.ahk ;字符串
;#Include %A_ScriptDir%\listary.ahk ;字符串
/*
    程序: 仿Listary(By_Kawvin)
    作用: ahk实现listary中的Ctrl+G打开最近目录等功能
    作者: Kawvin，改自sunwind
    版本: 0.1
    时间: 20180301
    使用方法：Ctrl+G
    脚本说明:
        0、ahk实现listary中的Ctrl+G打开最近目录等功能
        1、获取到的当前资源管理器打开的路径
        2、获取到的当前TotalCommand打开的路径
        3、获取excel文档路径(可以扩展其它常用应用的文档路径)【未启用】
        4、用弹出菜单展示
        5、在保存/打开对话框中点击菜单项，可以更换对话框到相应路径
        5、在非保存/打开对话框中点击菜单项，可以用资源管理器打开相应路径
        6、点击菜单项中的xls文档路径，可以跳转到文档所在路径（其它类型的office文档都可实现，暂未开发）
        7、最近使用的exe,点击可以激活
        8、常用路径,点击可以打开/切换
*/
/*
#SingleInstance,Force

 ;定义主要变量内容
history=%A_ScriptDir%\history.txt
application=%A_ScriptDir%\application.txt
MostUsedDir=    ;最常用的路径
(Ltrim
    D:\Apps\
    D:\Boards\
    D:\Backup\
)

^g::    ;Ctrl+G 【Ctrl+G】运行主程序 ;{
    ;生成菜单
    ;添加菜单--目录
    HKN:=0
    HKStr:="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    Menu, MyMenu, Add  ; 添加分隔线.
    Menu, MyMenu,  DeleteAll ; 清空菜单项
    
    ;获取打开的目录，并添加到dir数组
    Menu, MyMenu, Add, 【当前打开的路径有】, MenuHandler
    Menu, MyMenu, Disable, 【当前打开的路径有】

    ;获取Explorer打开的目录，并添加到dir数组
    for oExplore in ComObjCreate("Shell.Application").Windows
    {  
        OutDir:=oExplore.LocationURL
        if (OutDir="") { ;剔除 资源管理器显示的 "库" 这种情况
            
        }else {
            fileread,AllDir,%history%
            IfNotInString,AllDir,%OutDir%
                Log(OutDir)
            HKN+=1
            HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
            MenuItem:=HKTem . OutDir
            Menu, MyMenu, Add, %MenuItem%, MenuHandler
        }
    }
    
    ;获取TC打开的目录，并添加到dir数组
    ifwinexist,ahk_class TTOTAL_CMD
    {
        ;左侧
        ;~ Postmessage, 1075, 132, 0,, ahk_class TTOTAL_CMD	;光标定位到焦点地址栏
        ;~ sleep 300
        PostMessage,1075,2029,0,,ahk_class TTOTAL_CMD ;获取路径
        sleep 100
        OutDir:=Clipboard
        If(OutDir!="ERROR"){		;错误则退出
            fileread,AllDir,%history%
            IfNotInString,AllDir,%OutDir%
                Log(OutDir)
            HKN+=1
            HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
            MenuItem:=HKTem . OutDir
            Menu, MyMenu, Add, %MenuItem%, MenuHandler
        }
        ;右侧
        ;~ Postmessage, 1075, 232, 0,, ahk_class TTOTAL_CMD	;光标定位到焦点地址栏
        ;~ sleep 300
        PostMessage,1075,2030,0,,ahk_class TTOTAL_CMD ;获取路径
        sleep 100
        OutDir:=Clipboard
        If(OutDir!="ERROR"){		;错误则退出
            fileread,AllDir,%history%
            IfNotInString,AllDir,%OutDir%
                Log(OutDir)
            HKN+=1
            HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
            MenuItem:=HKTem . OutDir
            Menu, MyMenu, Add, %MenuItem%, MenuHandler
        }
    }
    Menu, MyMenu, Add   ;添加分隔线
    

    ;~ ;获取已经打开的excel文档路径 ,这里可以扩展其它office文件的路径，并添加到dir数组
    ;~ try{
        ;~ oExcel := ComObjActive("Excel.Application")
        ;~ for Item in oExcel.workbooks
        ;~ {
            ;~ if (a_index=1){
                ;~ dir.Push("【当前打开的xls有】")
            ;~ }
            ;~ item:=oExcel.workbooks(A_index).FullName
            ;~ SplitPath,item,,OutDir ;获取Excel文件路径
            ;~ dir.Push(OutDir)
            ;~ Log(OutDir)
            ;~ oExcel.ActiveWindow.Caption :=Item
        ;~ }
    ;~ } catch e {
        
    ;~ }

    ;遍历【常用路径】
    Menu, MyMenu, Add, 【常用路径】, MenuHandler
    Menu, MyMenu, Disable, 【常用路径】
    loop,parse,MostUsedDir,"`n"
    {
        HKN+=1
        HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
        MenuItem:=HKTem .  LTrim(A_LoopField)
        Menu, MyMenu, Add, %MenuItem%, MenuHandler
    }
    Menu, MyMenu, Add   ;添加分隔线
    
    ;读取【最近使用的路径】
    Menu, MyMenu, Add, 【最近使用的路径】, MenuHandler
    Menu, MyMenu, Disable, 【最近使用的路径】
    gaopin:=getHistory(history)
    loop,parse,gaopin,"`n"
    {
        StringTrimLeft, Outdir, A_LoopField, 6 ; trim左侧6个字符
        if Outdir=
            continue
        ;~ MsgBox %Outdir%
        HKN+=1
        HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
        MenuItem:=HKTem .  Outdir
        Menu, MyMenu, Add, %MenuItem%, MenuHandler
    }
    Menu, MyMenu, Add   ;添加分隔线

    ;获取【最近使用的exe】
    _dir:=getExePath()
    Loop,parse,_dir,`n
    {
        fileread,AllApplication,%application%
        IfNotInString,AllApplication,%A_LoopField%
            Log2(A_LoopField,application)
    }
    Menu, MyMenu, Add, 【最近使用的程序】, MenuHandler
    Menu, MyMenu, Disable, 【最近使用的程序】
    Loop,Read,%application%
    {
        if (A_index>15)
            break
        if (not ( instr(A_LoopReadLine,"explorer")  OR instr(A_LoopReadLine,"CCC"))){
            if (A_LoopReadLine<>""){
                HKN+=1
                HKTem:=HKN<37?"&" . substr(HKStr,HKN,1) . ") ":""
                MenuItem:=HKTem . A_LoopReadLine
                Menu, MyMenu, Add, %MenuItem%, MenuHandler
            }
        }
    }  

    ;~ if (InStr(item,"file:///")){
        ;~ Menu, MyMenu, Add, %item%, MenuHandler
    ;~ }else if (InStr(item,"http")) {
        ;~ ;过滤掉http开头的。
    ;~ }else{
        ;~ Menu, MyMenu, Add, %item%, MenuHandler
    ;~ }

    ;显示菜单
    Menu, MyMenu, Show
return
;}

MenuHandler:    ;执行菜单项  ;{
    if (substr(A_ThisMenuItem,1,1)="&")
        T_ThisMenuItem:=substr(A_ThisMenuItem,5)
    if (instr(T_ThisMenuItem,".exe")){
        ;~ WinActivate,ahk_exe %T_ThisMenuItem%
        try {
            RunOrActivateProgram(T_ThisMenuItem)
        }catch{
            MsgBox, 16,, 本计算机上无此程序!
        }
    }else {
        WinGet, this_id,ID, A
        WinGetTitle, this_title, ahk_id %this_id%
        WinGetClass,this_class,ahk_id %this_id%
        if(this_class="#32770") { ;保存/打开对话框
            If(instr(this_title,"存") or instr(this_title,"Save") or instr(this_title,"文件")) {
                ChangePath(T_ThisMenuItem,this_id)   
            }else if(instr(this_title,"开") or instr(this_title,"Open")) {
                ChangePath(T_ThisMenuItem,this_id)   
            }
        } else  {  ;普通窗口
            try{
                OpenPath(T_ThisMenuItem)
            } catch e {
                MsgBox % "Error in " e.What ", which was called at line " e.Line  "`n" e.Message  "`n" e.Extra
            }
        }
    }
return
;}

OpenPath(_dir){ ;只是打开路径
    Run,"%_dir%"  
}

OpenAndSelect(){

}

ChangePath(_dir,this_id){
    WinActivate,ahk_id %this_id%
    ControlFocus,ReBarWindow321,ahk_id %this_id%
    ControlSend,ReBarWindow321,{f4},ahk_id %this_id%
    Loop{
        ControlFocus,Edit2,ahk_id %this_id%
        ControlGetFocus,f,ahk_id %this_id%
        if A_index>50 
            break
    }until (f="Edit2")
    ControlSetText,edit2,%_dir%,ahk_id %this_id%
    ControlSend,edit2,{Enter},ahk_id %this_id%
}

Log(debugstr){
    global
    FileAppend, %debugstr%`n, %history%
    return
}

Log2(debugstr,file){
    FileAppend, %debugstr%`n, %file%
    return
}

getHistory(history){
    ;获取最近使用的top10路径
    a := []
    b =
    Loop, read, %history%
    {
        last_line := A_LoopReadLine  ; 当循环结束时, 这里会保持最后一行的内容.
        if !a["" last_line]
            a["" last_line] := 1
        else
            a["" last_line] += 1
    }
    for c,d in a
    {
        d2 := SubStr("00000", 1, 5-strlen(d)) d
        str := d2 "_" c
        b .= b ? "`n" str : str
    }
    Sort, b, R
    e := StrSplit(b,"`n","`r")
    f =
    loop 5
        f .= f ? "`n" e[A_index] : e[A_index]
    return %f%
}

getExePath(){
    ;~ 打开当前激活窗口的exe程序所在目录
    ;~ for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
      ;~ WinGet, _ProcessPath, ProcessPath, A  
      ;~ Run,% "Explorer.exe /select, " _ProcessPath   
      ;~ return _ProcessPath
    WinGet, id, list
    Loop, %id%
    {
      this_id := id%A_Index%
      WinGet, pp, ProcessPath, ahk_id %this_id%
      out .= pp "`n"
    }
    ;~ MsgBox, % out
    return out
}

RunOrActivateProgram(Target,WinTitle=""){
    SplitPath,Target,TargetNameOnly
    Process,Exist,%TargetNameOnly%
    If ErrorLevel>0
        PID=%ErrorLevel%
    Else
        Run,%Target%,,,PID
    If WinTitle<>
    {
        SetTitleMatchMode,2
        WinWait,%WinTitle%,,3
        WinActivate,%WinTitle%
    }Else{
        WinWait,ahk_pid%PID%,,3
        WinActivate,ahk_pid%PID%
    }
    Return
}

#z::ExitApp
*/
;ThinkPad快捷键
;Fn+Esc FnLock
;Fn+4 进入睡眠模式
;Fn+Tab 启用放大镜模式
;Fn+T 更改自动冷却设置
;Fn+空格 键盘背光
;Fn+S sysrq r e i s u b
;Fn+B break
;fn+K Scroll Lock
;=======================系统+win========================
#F1:: ;记事本
	Sleep, 100
	RunWait Notepad
	;MsgBox 记事本已关闭
return

#F2:: ;计算器
	Sleep, 100
	Run, calc
return
	
#F3::  ;小画家
	Sleep, 100
	Run, mspaint
return

;同时按ctrl+del键清空回收站
;^delete:: FileRecycleEmpty 
return

!X::  ;屏幕截图
	Sleep, 100
	Run, exe\snapshot.exe
return
;=======================程序+WIN=========================
^`:: ;firefox
;	IfWinNotExist, ahk_class MozillaWindowClass
;		Run,D:\Apps\Firefox\firefox\firefox.exe
;	else
;	{
;		IfWinActive, ahk_class MozillaWindowClass
;			WinMinimize,
;		else
;			WinActivate,
;	}

;WindowSpy

IfWinNotExist,ahk_exe msedge.exe
run,C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe

	else
	{
		IfWinActive, ahk_exe msedge.exe
			WinMinimize,
		else
			WinActivate,
	}

return
#1::
	Run,C:\NuTCROOT\mksnt\sh.exe -H -c "$AGILENTICT_ROOT/bin/basic_startup.ksh"
return
;#A 打开操作中心
;Win+B Beyond Compare
#B::
	IfWinNotExist, ahk_exe BCompare.exe
		Run, D:\Apps\Beyond Compare\BCompare.exe
	else
	{
		IfWinActive, ahk_exe BCompare.exe
			WinMinimize,
		else
			WinActivate,
	}
return
#C:: ;;Chrome
	IfWinNotExist, ahk_exe chrome.exe
		Run, D:\Apps\Chrome\App\Chrome.exe
	else
	{
		IfWinActive, ahk_exe chrome.exe
			WinMinimize,
		else
			WinActivate
	}
return

;#D  ;win+D 显示桌面
;#E ;打开文件管理器（Win+ E）

#E:: ;everything
	IfWinNotExist, ahk_exe Everything.exe
		Run, D:\Apps\everything\everything.exe
	else
	{ IfWinActive,  ahk_exe Everything.exe
			WinMinimize,
		else
			WinActivate,
	}
return

#F:: ;Foxmail
	IfWinNotExist, ahk_class TFoxMainFrm.UnicodeClass
		Run, D:\Foxmail\Foxmail.exe
	else
	{IfWinActive, ahk_class TFoxMainFrm.UnicodeClass
			WinMinimize,
		else
			WinActivate,
	}
return
#G:: 
Run, D:\Apps\Candy\listary.ahk
return
;#H 听写功能 （Win+ H）
;^`::
;	Sleep 100
;	Run, D:\Apps\Candy\exe\ToggleTaskbarShowHide.exe
;return
;WinHide ahk_class Shell_TrayWnd
;WinShow ahk_class Shell_TrayWnd  ;显示任务栏

;#I 打开WIN系统设置

;#J
;#K 打开「连接」设备（Win+K）
;#L
;^!L::
;	Sleep 100
;	Run, D:\Apps\Candy\exe\KeyFreeze.exe
;return
~#L::  ; Win+L 热键关闭显示器.
	Sleep 500  ; 让用户有机会释放按键 (以防释放它们时再次唤醒显视器).
	; 关闭显示器:
	SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 为 WM_SYSCOMMAND, 0xF170 为 SC_MONITORPOWER.
	; 对上面命令的注释: 使用 -1 代替 2 来打开显示器.
	; 使用 1 代替 2 来激活显示器的节能模式.
return


; ALT+L 桌面图标文字 列表化,和Fences不兼容
!L::
Sleep 100
Run, D:\Apps\Candy\exe\desktoplistview.exe
return
ControlGet, OutputVar, Hwnd, , SysListView321, ahk_class Progman
WinSet, Style, ^0x2, ahk_id %OutputVar%

#N::
	Sleep 100
	Run, D:\Apps\npp\notepad++.exe
return

;运行窗口位置变化
;#R::
;	Run, C:\windows\system32\Rundll32.exe shell32.dll`,#61
;return

;重启资源管理器
;traytip ,重启资源管理器,按下Alt+R重启资源管理器
;!q::
;HideOrShowDesktopIcons()
;return
;
;HideOrShowDesktopIcons()
;{
;	ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
;	If class =
;		ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW
;
;	If DllCall("IsWindowVisible", UInt,class)
;		WinHide, ahk_id %class%
;	Else
;		WinShow, ahk_id %class%
;}
;return
!r::
	Process,close,explorer.exe
	Sleep 200
	Run explorer
return

#s::
	Sleep 100
	Run, D:\Apps\Listary\Listary.exe
return

#t::
	IfWinNotExist, ahk_class TTOTAL_CMD
		Run, D:\Apps\TC\Totalcmd64.exe
	else
	{
		IfWinActive, ahk_class TTOTAL_CMD
			WinMinimize,
		else
			WinActivate,
	}
return
;#u 放大镜
~#v::
	IfWinNotExist,ahk_exe v2rayN.exe
		Run, D:\Apps\v2ray\v2rayN.exe
	else
	{
		IfWinActive, ahk_exe v2rayN.exe
			WinMinimize,
		else
			WinActivate,
	}
return

#W:: ;;工作小助手
	IfWinNotExist, ahk_exe 工作小助手.exe
		Run, D:\Apps\工作小助手\工作小助手.lnk
	else
	{
		IfWinActive,ahk_exe 工作小助手.exe
			WinMinimize,
		else
			WinActivate
	}
return
;#X 系统菜单
;#Y
!m:: ;移除活动窗口的标题栏，获大更大视觉空间
	biaotyic+=1
	MouseGetPos,,, btwid,  ; 得到鼠标所在位置窗口的id及控件名称
	if biaotyic>0
	{
		WinSet, Style, -0xC00000,ahk_id %btwid%; 移除活动窗口的标题栏 (WS_CAPTION).
		biaotyic*=-1
	}
	else
	{
		WinSet, Style, +0xC00000,ahk_id %btwid%; 恢复活动窗口的标题栏 (WS_CAPTION).
	}
return

;!t::
;	MouseGetPos,,, MouseWin
;	WinGet, Transparent, Transparent, ahk_id %MouseWin%
;	;ToolTip Translucency:`t"%Transparent%"`nTransColor:`t%TransColor%
;	if Transparent!=
;		WinSet, TransColor, Off, ahk_id %MouseWin%
;	;关闭透明
;	else
;	{
;		MouseGetPos, MouseX, MouseY, MouseWin
;		PixelGetColor, MouseRGB, %MouseX%, %MouseY%, RGB
;		; 似乎有必要首先关闭任何现有的透明度:
;		WinSet, TransColor, Off, ahk_id %MouseWin%
;		WinSet, TransColor, %MouseRGB% 192, ahk_id %MouseWin%
;	}
;return

;利用CCleaner后台清理垃圾
::ccl::
	Run, D:\Apps\Dism\CCleaner64.exe /auto
	TrayTip,,Run CCleaner
return
;WIN+Z快速进入注册表
;#Z::
;	Run, regedit ; 运行注册表l
;return

;调用Candy
;F7::
;	Run, candy.ahk /ini=GeneralSettings.ini
;return
;打开系统属性
;::/sys::
;	Run, Control sysdm.cpl
;return

;強制結束explorer.exe
;!-::process, close, explorer.exe

	;显示或隐藏桌面图标
	;F1::ControlSend, SysListView321, +{F10}VD, Program Manager ahk_class Progman
	
	;=====================配合nircmd实现========================
#F9::   ;锁定+关屏+待机
	Run, D:\Apps\TC\TOOLS\NirCMD\nircmdc.exe cmdwait 1000 monitor off
	Sleep 100
	Run, D:\Apps\TC\TOOLS\NirCMD\nircmdc.exe lockws
	; Run, nircmd.exe standby
return

;截取屏幕
PrintScreen:: ;等待1秒截取当前活动窗口屏幕
Run, D:\Apps\TC\TOOLS\NirCMD\nircmdc.exe cmdwait 1000 saveScreenshotwin "D:\Backup\Temp\scr_~$currdate.yyyyMMdd$~$currtime.HHmmss$.png"
return

;两下esc关闭窗口
EscTc2:=A_TickCount
Esc_Ex=CabinetWClass,Progman,WorkerW,DV2ControlHost,Shell_TrayWnd,OpWindow
~Escape::
	EscTc:=A_TickCount
	WinGet, EscId1,ID,A

	if ( (EscTc-EscTc2)>350)
		goto Esc_end
	
	WinGetClass,Esc_class,ahk_id %EscId1%
	
	IfInString,Esc_Ex,%Esc_class%
	{        TrayTip,排除,%Esc_class%
		goto Esc_end
	}
	
	IfEqual,EscId1,%EscId2%
		WinClose,ahk_id %EscId1%
	;~ ToolTip % EscTc

Esc_end:
	EscTc2:=A_TickCount
	WinGet, EscId2,ID,A
return

^e::
clipSaved := ClipboardAll ;先把剪贴板内容放在临时文件
Clipboard =
Send, ^c
ClipWait,0.3
If ErrorLevel ;如果粘贴板里面没有内容
Run, D:\Apps\Everything\Everything.exe
else
{
If (RegExMatch(Clipboard,"^.:\\")){ 
SplitPath, Clipboard, , , , nameNoExt ; 去除路径，只取文件名
search := nameNoExt
}else
search := Clipboard
Run, D:\Apps\Everything\Everything.exe -s "%search%"
}
Clipboard := clipSaved ;还原剪贴板的内容
clipSaved = ; 在原来的剪贴板含大量内容时释放内存.
return

;按下 Ctrl+3，拷贝当前内容，然后转到 UltraEdit 里搜索
^3::
	Send ^c
	WinActivate, UltraEdit
	WinWaitActive, UltraEdit
;	Send ^f
	Send !{F3}
	WinWaitActive, 查找
	Sleep, 50
	Send ^v
	Send {Enter}
return

;新版 UltraEdit 中查找 (Alt+F3) 和快速查找 (Ctrl+F) 替换按键
#IfWinActive ahk_exe uedit32.exe
^F:: Send !{F3}
#IfWinActive
return

/*
; 前进侧键改为Home键

XButton2:: 
MouseGetPos,,,winID
IfWinNotActive, ahk_id %winID%
{
  WinActivate, ahk_id %winID%
}
SendInput, {Home}
return


; 后退侧键改为End键

XButton1:: 
MouseGetPos,,,winID
IfWinNotActive, ahk_id %winID%
{
  WinActivate, ahk_id %winID%
}
SendInput, {End}
return

; 左Win键+鼠标滚轮切换虚拟桌面

;<#WheelUp::#^Left
;<#WheelDown::#^Right

; 左Alt键+鼠标滚轮切换窗口

<!WheelUp::ShiftAltTab
<!WheelDown::AltTab
*/
