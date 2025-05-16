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
        ; Call the translation API and get the result
        apiResult := CallTranslationAPI(selectedText)
        
        ; Create a GUI with an editable text area
        MyGui := Gui()
        MyGui.Title := "Translation Result"
        MyGui.Opt("+Resize +MinSize320x200")  ; Make the window resizable
        
        ; Set default GUI font to Microsoft JhengHei
        MyGui.SetFont("s10", "Microsoft JhengHei")
        
        ; Add original text label
        MyGui.Add("Text", "w400", "Original Text:")
        
        ; Add Edit control with the selected text (multi-line, can be copied, but read-only)
        MyEditOriginal := MyGui.Add("Edit", "r3 w400 vSelectedText ReadOnly", selectedText)
        
        ; Add translation result label
        MyGui.Add("Text", "w400", "Translation Result:")
        
        ; Add Edit control with the translation result - initially empty
        MyEditResult := MyGui.Add("Edit", "r7 w400 vTranslationResult ReadOnly", "Loading translation...")
        
        ; Add progress indicator
        MyProgress := MyGui.Add("Progress", "w400 h20 vProgressBar Range0-100", 0)
        MyProgress.Opt("Hidden")
        
        ; Add a dummy control that can take focus (but won't be visible)
        DummyButton := MyGui.Add("Button", "x-100 y-100 w1 h1", "")
        
        ; Make the edit controls resize with the window
        MyGui.OnEvent("Size", GuiResize)
        
        ; Show the GUI
        MyGui.Show()
        
        ; Deselect all text and remove focus
        MyEditOriginal.Focus()
        SendMessage(0xB1, -1, 0, MyEditOriginal)
        
        ; Display translation progressively if it's long
        if (StrLen(apiResult) > 500)
        {
            MyProgress.Opt("-Hidden")
            DisplayProgressiveText(MyGui, MyEditResult, apiResult, MyProgress)
        }
        else
        {
            ; For short translations, just display immediately
            MyEditResult.Value := apiResult
            MyEditResult.Focus()
            SendMessage(0xB1, -1, 0, MyEditResult)
        }
        
        ; Remove focus from all controls
        DummyButton.Focus()
    }
}

; Function to progressively display text
DisplayProgressiveText(gui, control, fullText, progressBar)
{
    textLength := StrLen(fullText)
    chunkSize := Max(20, Floor(textLength / 10))  ; Display in around 10 chunks
    
    ; Start a timer to update the text progressively
    SetTimer UpdateTextDisplay, 150
    
    ; Inner function to update the display incrementally
    UpdateTextDisplay()
    {
        static currentPos := 0
        
        ; Calculate new position
        currentPos += chunkSize
        if (currentPos >= textLength)
        {
            currentPos := textLength
            SetTimer , 0  ; Stop the timer
            progressBar.Opt("Hidden")
        }
        
        ; Extract the chunk and update the control
        displayedText := SubStr(fullText, 1, currentPos)
        control.Value := displayedText
        
        ; Update progress bar
        progressPercent := Min(100, Round((currentPos / textLength) * 100))
        progressBar.Value := progressPercent
    }
}

; Function to call the translation API
CallTranslationAPI(textToTranslate)
{
    try
    {
        ; URL encode the text
        encodedText := UrlEncode(textToTranslate)
        
        ; Create WinHttp object
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        
        ; Open a GET request to the API
        apiUrl := "http://localhost:5276/api/translate/?prompt=" encodedText
        http.Open("GET", apiUrl, false)
        
        ; Send the request
        http.Send()
        
        ; Get the response
        if (http.Status == 200)
            return http.ResponseText
        else
            return "Error: " http.Status " - Unable to get translation"
    }
    catch as e
    {
        return "Error connecting to API: " e.Message
    }
}

; URL encoding function
UrlEncode(str)
{
    result := ""
    for i in StrSplit(str)
    {
        c := Ord(i)
        if c >= 0x30 && c <= 0x39  ; 0-9
            || c >= 0x41 && c <= 0x5A  ; A-Z
            || c >= 0x61 && c <= 0x7A  ; a-z
            result .= i
        else if (i = " ")
            result .= "+"
        else
            result .= "%" . Format("{:02X}", c)
    }
    return result
}

; Function to handle window resizing
GuiResize(thisGui, minMax, width, height)
{
    if (minMax = -1)  ; The window has been minimized
        return
    
    ; Calculate heights for controls based on window height
    totalHeight := height - 20  ; Total usable height
    originalHeight := Floor(totalHeight * 0.3)  ; 30% for original text
    resultHeight := totalHeight - originalHeight - 50  ; Remaining space minus labels and progress bar
    
    ; Resize and reposition the controls
    thisGui["SelectedText"].Move(5, 20, width - 10, originalHeight)
    thisGui["TranslationResult"].Move(5, originalHeight + 40, width - 10, resultHeight)
    thisGui["ProgressBar"].Move(5, height - 30, width - 10, 20)
}