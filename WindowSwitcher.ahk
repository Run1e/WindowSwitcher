﻿#SingleInstance force
#NoEnv
DetectHiddenWindows Off

; === CONFIGURATION ===
Key := "^!I"
EscapeExit := true
Width := 400
Height := 300
FontSize := 10
MaxItems := 10
LargeIcons := true
MoveUp := 120
Color := "404040"
SelColor := "44C6F6"
; === END CONFIGURATION ===

IgnoreEquals := "^(NVIDIA GeForce Overlay|Program Manager)$"

global Key, EscapeExit, Width, Height, MaxItems, Color, MoveUp, LargeIcons, FontSize, IgnoreEquals

; set up gui
Switcher := new Switcher("Window Switcher", "-Caption +Border +ToolWindow")
Switcher.Margin(0, 0)
Switcher.Color(Color, Color)
Switcher.Font("s10 cWhite")
Switcher.Edit := Switcher.Add("Edit", "w" Width " h26",, Switcher.Input.Bind(Switcher))
Switcher.LV := new Gui.ListView(Switcher, "x0 y26 w" Width " h100  -HDR -Multi +LV0x4000 -E0x200 AltSubmit -TabStop", "title|exe", Switcher.ListViewAction.Bind(Switcher))
Switcher.CLV := new LV_Colors(Switcher.LV.hwnd)
Switcher.CLV.SelectionColors("0x" SelColor, "0xFFFFFF")
Switcher.IL := new Gui.ImageList(,, LargeIcons)

Switcher.LV.SetImageList(Switcher.IL.ID)
Switcher.Icons := []

; bind hotkeys
new Hotkey(Key, Switcher.Toggle.Bind(Switcher))
new Hotkey("Enter", Switcher.Go.Bind(Switcher), Switcher.ahkid)
new Hotkey("Delete", Switcher.Stop.Bind(Switcher), Switcher.ahkid)
new Hotkey("Up", Switcher.Move.Bind(Switcher, -1), Switcher.ahkid)
new Hotkey("Down", Switcher.Move.Bind(Switcher, +1), Switcher.ahkid)
new Hotkey("^Backspace", Switcher.CtrlBackspace.Bind(Switcher), Switcher.ahkid)

if EscapeExit
	new Hotkey("Escape", Switcher.Close.Bind(Switcher), Switcher.ahkid)
return

Class Switcher extends Gui {
	
	Input(x*) {
		GuiControlGet, text,, % this.Edit
		this.LV.Delete()
		for Index, Info in Fuzzy(text, this.List, "Search") ; search over this.list with the needle text, in the attribute Title
			this.LV.Add("Icon" this.Icons[Info.Exe], Info.Title, Info.hwnd)
		this.SizeCtrl()
	}
	
	ListViewAction(x*) {
		if (x.2 = "DoubleClick")
			this.Go()
	}
	
	Go() {
		Selected := this.LV.GetNext()
		ID := this.LV.GetText(Selected, 2)
		this.Close()
		WinActivate % "ahk_id" ID
	}
	
	Stop() {
		Selected := this.LV.GetNext()
		ID := this.LV.GetText(Selected, 2)
		this.LV.Delete(Selected)
		this.SizeCtrl(Selected)
		WinClose % "ahk_id" id
	}
	
	Move(Dir) {
		Selected := this.LV.GetNext()
		Count := this.LV.GetCount()
		New := Selected + Dir
		if (New < 1) || (New > Count)
			return
		this.LV.Modify(New, "Select Vis")
		this.Control("Focus", this.Edit)
	}
	
	Open() {
		if this.IsVisible
			return
		this.List := []
		this.LV.Delete()
		WinGet windows, List
		Loop %windows%
		{
			ID := windows%A_Index%
			if !WinExist("ahk_id" ID) || (this.ahkid = "ahk_id" id)
				continue
			WinGetTitle Title, % "ahk_id" ID
			WinGet, ProcessName, ProcessName, % "ahk_id" ID
			ProcessName := StrSplit(ProcessName, ".").1
			WinGet, Exe, ProcessPath, % "ahk_id" ID
			if StrLen(Exe) && StrLen(Title) && !(Title ~= IgnoreEquals) {
				if !this.Icons.HasKey(Exe)
					Icon := this.Icons[Exe] := this.IL.Add(Exe)
				else
					Icon := this.Icons[Exe]
				if !Icon
					continue
				this.List.Push({Title:Title, Exe:Exe, hwnd:ID, Search:(Title " " ProcessName)})
				this.LV.Add("Icon" Icon, Title, ID)
			}
		} this.SizeCtrl()
		this.Animate("FADE_IN", 50)
		this.Show()
		this.Control("Focus", this.Edit)
	}
	
	SizeCtrl(Pos := 1) {
		static VERT_SCROLL, ROW_HEIGHT
		if !VERT_SCROLL
			SysGet, VERT_SCROLL, 2
		if !ROW_HEIGHT
			ROW_HEIGHT := LV_EX_GetRowHeight(this.LV.hwnd)
		this.LV.Redraw(false)
		Count := this.LV.GetCount()
		this.LV.ModifyCol(1, Width - ((Count > MaxItems) ? VERT_SCROLL : 0))
		this.Pos(A_ScreenWidth/2 - Width/2, A_ScreenHeight/2 - MoveUp,, 26 + (MaxItems > Count ? Count : MaxItems) * ROW_HEIGHT)
		this.Control("Move", this.LV.hwnd, "h" (ROW_HEIGHT * (MaxItems > Count ? Count : MaxItems)))
		this.LV.Modify((Pos>Count?Count:Pos), "Select Vis")
		this.LV.ModifyCol(2, 0)
		this.LV.Redraw(true)
	}
	
	Close() {
		if !this.IsVisible
			return
		this.SetText(this.Edit, "")
		this.Hide()
	}
	
	Toggle() {
		this[this.IsVisible ? "Close" : "Open"]()
	}
	
	CtrlBackspace() {
		this.Control("-Redraw", "Edit1")
		ControlSend, Edit1, ^+{Left}{Backspace}, % this.ahkid
		this.Control("+Redraw", "Edit1")
	}
}

pa(array, depth=5, indentLevel:="   ") { ; tidbit, this has saved my life
	try {
		for k,v in Array {
			lst.= indentLevel "[" k "]"
			if (IsObject(v) && depth>1)
				lst.="`n" pa(v, depth-1, indentLevel . "    ")
			else
				lst.=" => " v
			lst.="`n"
		} return rtrim(lst, "`r`n `t")	
	} return
}

m(x*) {
	for a, b in x
		text .= (IsObject(b)?pa(b):b) "`n"
	MsgBox, 0, msgbox, % text
}

LV_EX_GetRowHeight(HLV, Row := 1) {
	Return LV_EX_GetItemRect(HLV, Row).H
}

LV_EX_GetItemRect(HLV, Row := 1, LVIR := 0, Byref RECT := "") {
   ; LVM_GETITEMRECT = 0x100E -> http://msdn.microsoft.com/en-us/library/bb761049(v=vs.85).aspx
	VarSetCapacity(RECT, 16, 0)
	NumPut(LVIR, RECT, 0, "Int")
	SendMessage, 0x100E, % (Row - 1), % &RECT, , % "ahk_id " . HLV
	If (ErrorLevel = 0)
		Return False
	Result := {}
	Result.X := NumGet(RECT,  0, "Int")
	Result.Y := NumGet(RECT,  4, "Int")
	Result.R := NumGet(RECT,  8, "Int")
	Result.B := NumGet(RECT, 12, "Int")
	Result.W := Result.R - Result.X
	Result.H := Result.B - Result.Y
	Return Result
}

#Include lib\Class LV_Colors.ahk
#Include lib\Class GUI.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Fuzzy.ahk