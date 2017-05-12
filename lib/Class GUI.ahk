Class Gui {
	static Instances := []
	
	__New(Title := "AutoHotkey Window", Options := "") {
		Gui, New, % "+hwndhwnd " Options, % Title
		this.hwnd := hwnd
		this.ahkid := "ahk_id" hwnd
		this.IsVisible := false
		Gui % this.hwnd ": -E0x10" ; disable drag-drop by default
		Gui.Instances[hwnd] := this
		this.Controls := []
		return this
	}
	
	Add(ControlType, Options := "", Params := "", Function := "") {
		Gui % this.hwnd ":Add", % ControlType, % Options " hwndControlHWND", % Params
		if Function {
			GuiControl, +g, % ControlHWND, % Function ; ty geekdude for this amazing godsent knowledge, may the darkness of labels be eternally abolished
			this.Controls.Push(ControlHWND)
		}
		return ControlHWND
	}
	
	Control(Command := "", Control := "", ControlParams := "") {
		GuiControl % this.hwnd ":" Command, % Control, % ControlParams
	}
	
	Show(Options := "", Title := "") {
		this.IsVisible := !InStr(Options, "Hide")
		Gui % this.hwnd ":Show", % Options, % Title
	}
	
	Hide(Options := "") {
		this.IsVisible := false
		Gui % this.hwnd ":Hide", % Options
	}
	
	SetDefault() {
		Gui % this.hwnd ":Default"
	}
	
	Activate() {
		WinActivate % this.ahkid
	}
	
	Tab(num) {
		Gui % this.hwnd ":Tab", % num
	}
	
	Disable() {
		Gui % this.hwnd ":+Disabled"
	}
	
	Enable() {
		Gui % this.hwnd ":-Disabled"
	}
	
	ControlGet(Command, Value := "", Control := "") {
		ControlGet, out, % Command, % (StrLen(Value) ? Value : ""), % (StrLen(Control) ? Control : ""), % this.ahkid
		return out
	}
	
	GuiControlGet(Command := "", Control := "", Param := "") {
		GuiControlGet, out, % (StrLen(Command) ? Command : ""), % (StrLen(Control) ? Control : ""), % (StrLen(Param) ? Param : "")
		return out
	}
	
	Pos(x := "", y := "", w := "", h := "") {
		this.Show(  (StrLen(x) ? "x" x : "") . " "
				. (StrLen(y) ? "y" y : "") . " "
				. (StrLen(w) ? "w" w : "") . " "
				. (StrLen(h) ? "h" h : "") . " "
				. (this.IsVisible ? "" : "Hide"))
	}
	
	SetIcon(Icon) {
		hIcon := DllCall("LoadImage", UInt,0, Str, Icon, UInt, 1, UInt, 0, UInt, 0, UInt, 0x10)
		SendMessage, 0x80, 0, hIcon ,, % this.ahkid  ; One affects Title bar and
		SendMessage, 0x80, 1, hIcon ,, % this.ahkid  ; the other the ALT+TAB menu
	}
	
	Destroy() {
		this.IsVisible := false
		Gui % this.hwnd ":Destroy"
		for Index, Control in this.Controls
			GuiControl, -g, % Control
		Gui.Instances[this.hwnd] := ""
	}
	
	Color(BackgroundColor := "", ControlColor := "") {
		Gui % this.hwnd ":Color", % BackgroundColor, % ControlColor
	}
	
	Options(Options, ext := "") {
		Gui % this.hwnd ":" Options, % ext
	}
	
	Margin(HorizontalMargin, VerticalMargin) {
		Gui % this.hwnd ":Margin", % HorizontalMargin, % VerticalMargin
	}
	
	Font(Options := "", Font := "") {
		Gui % this.hwnd ":Font", % Options, % Font
	}
	
	Submit(Hide := false, Options := "") {
		Gui % this.hwnd ":Submit", % (this.IsVisible:=!Hide ? "" : "NoHide") " " Options
	}
	
	GetText(Control) {
		ControlGetText, ControlText, % Control, % this.ahkid
		return ControlText
	}
	
	SetText(Control, Text := "") {
		this.Control(, Control, Text)
	}
	
	DropFilesToggle(Toggle) {
		this.Options((Toggle ? "+" : "-") . "E0x10")
	}
	
	Animate(Type, Duration := 80) {
		static Anims := {ROLL_LEFT_TO_RIGHT:	0x20001
					, ROLL_RIGHT_TO_LEFT:	0x20002
					, ROLL_TOP_TO_BOTTOM:	0x20004
					, ROLL_BOTTOM_TO_TOP:	0x20008
					, ROLL_DIAG_TL_TO_BR:	0x20005
					, ROLL_DIAG_TR_TO_BL:	0x20006
					, ROLL_DIAG_BL_TO_TR:	0x20009
					, ROLL_DIAG_BR_TO_TL:	0x2000a
					, SLIDE_LEFT_TO_RIGHT:	0x40001
					, SLIDE_RIGHT_TO_LEFT:	0x40002
					, SLIDE_TOP_TO_BOTTOM:	0x40004
					, SLIDE_BOTTOM_TO_TOP:	0x40008
					, SLIDE_DIAG_TL_TO_BR:	0x40005
					, SLIDE_DIAG_TR_TO_BL:	0x40006
					, SLIDE_DIAG_BL_TO_TR:	0x40009
					, SLIDE_DIAG_BR_TO_TL:	0x40010
					, ZOOM_IN:			0x16
					, ZOOM_OUT:			0x10010
					, FADE_IN:			0xa0000
					, FADE_OUT:			0x90000}
		
		return DllCall("AnimateWindow", "UInt", this.hwnd, "Int", Duration, "UInt", Anims.HasKey(Type)?Anims[Type]:Type)
	}
	
	WinSet(Command, Param := "") {
		WinSet, % Command, % Param, % this.ahkid
	}
	
	Escape() {
		this.Close()
	}
	
	Class ListView {
		__New(Parent, Options, Headers, Function := "") {
			this.Parent := Parent
			this.Function := Function
			this.hwnd := Parent.Add("ListView", Options, Headers, Function)
			return this
		}
		
		Add(Options := "", Fields*) {
			this.SetDefault()
			return LV_Add(Options, Fields*)
		}
		
		Insert(Row, Options := "", Col*) {
			this.SetDefault()
			return LV_Insert(Row, Options, Col*)
		}
		
		Delete(Row := "") {
			this.SetDefault()
			if StrLen(Row)
				return LV_Delete(Row)
			else
				return LV_Delete()
		}
		
		GetCount(Option := "") {
			this.SetDefault()
			return LV_GetCount(Option)
		}
		
		GetNext(Start := "", Option := "") {
			this.SetDefault()
			return LV_GetNext(Start, Option)
		}
		
		GetText(Row, Column := "") {
			this.SetDefault()
			LV_GetText(Text, Row, Column)
			return Text
		}
		
		Modify(Row, Options := "", NewCol*) {
			this.SetDefault()
			return LV_Modify(Row, Options, NewCol*)
		}
		
		ModifyCol(Column := "", Options := "", Title := "") {
			this.SetDefault()
			return LV_ModifyCol(Column, Options, Title)
		}
		
		Redraw(Toggle) {
			this.SetDefault()
			return this.Parent.Control((Toggle?"+":"-") "Redraw", this.hwnd)
		}
		
		SetImageList(ID, LargeIcons := false) {
			this.SetDefault()
			return LV_SetImageList(ID, !LargeIcons)
		}
		
		SetDefault() {
			this.Parent.SetDefault()
			this.Parent.Options("ListView", this.hwnd)
		}
	}
	
	Class ImageList {
		static Instances := []
		
		__New(InitialCount := 5, GrowCount := 2, LargeIcons := false) {
			this.ID := IL_Create(InitialCount, GrowCount, LargeIcons)
			Gui.ListView.ImageList.Instances[this.ID] := this
			return this
		}
		
		Destroy() {
			Gui.ListView.ImageList.Instances.Remove(this.ID)
			return IL_Destroy(this.ID)
		}
		
		Add(File) {
			return IL_Add(this.ID, File)
		}
	}
}

GuiClose(GuiHwnd) {
	(Instance := Gui.Instances[GuiHwnd]).Close.Call(Instance)
}

GuiEscape(GuiHwnd) {
	(Instance := Gui.Instances[GuiHwnd]).Escape.Call(Instance)
}

GuiSize(GuiHwnd, EventInfo, Width, Height) {
	(Instance := Gui.Instances[GuiHwnd]).Size.Call(	  Instance
					, EventInfo
					, Width
					, Height)
}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	(Instance := Gui.Instances[GuiHwnd]).DropFiles.Call(Instance, FileArray, CtrlHwnd, X, Y)
}

GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {
	(Instance := Gui.Instances[GuiHwnd]).ContextMenu.Call( Instance
						, CtrlHwnd
						, EventInfo
						, IsRightClick
						, X
						, Y)
}