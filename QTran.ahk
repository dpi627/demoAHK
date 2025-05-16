#Requires AutoHotkey v2.0
#SingleInstance Force

!q::
{
    ; Get the selected text
    ClipSaved := A_Clipboard
    A_Clipboard := ""
    Send "^c"
    ClipWait(1)
    selectedText := A_Clipboard
    A_Clipboard := ClipSaved
    
    ; Check if there is selected text
    if (selectedText != "")
    {
        ; Create a GUI with an editable text area
        MyGui := Gui()
        MyGui.Title := "Selected Text"
        MyGui.Opt("+Resize +MinSize320x200")  ; Make the window resizable
        
        ; Set default GUI font to Microsoft JhengHei
        MyGui.SetFont("s10", "Microsoft JhengHei")
        
        ; Add Edit control with the selected text (multi-line, can be copied, but read-only)
        MyEdit := MyGui.Add("Edit", "r10 w400 vSelectedText ReadOnly", selectedText)
        
        ; Add a dummy control that can take focus (but won't be visible)
        DummyButton := MyGui.Add("Button", "x-100 y-100 w1 h1", "")
        
        ; Make the edit control resize with the window
        MyGui.OnEvent("Size", GuiResize)
        
        ; Show the GUI
        MyGui.Show()
        
        ; Deselect all text first
        MyEdit.Focus()
        SendMessage(0xB1, -1, 0, MyEdit)
        
        ; Move focus away from the edit control
        DummyButton.Focus()
    }
}

; Function to handle window resizing
GuiResize(thisGui, minMax, width, height)
{
    if (minMax = -1)  ; The window has been minimized
        return
    
    ; Resize the edit control to match the window size (with smaller margins)
    thisGui["SelectedText"].Move(5, 5, width - 10, height - 10)
}