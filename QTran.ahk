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
        
        ; Create a GUI with a simple layout like the error window
        MyGui := Gui("+AlwaysOnTop -MinimizeBox")
        MyGui.Title := "QTran.ahk"
        MyGui.BackColor := "FFFFFF"  ; White background like the error window
        MyGui.SetFont("s9", "Segoe UI")  ; Font similar to error window
        
        ; Add the original text with label
        MyGui.Add("Text", "w600", "Original Text:")
        MyGui.Add("Text", "xm y+5 w600 r3", selectedText)
        
        ; Add a horizontal line
        MyGui.Add("Text", "xm y+10 w600 h1 0x10")  ; 0x10 creates a horizontal line
        
        ; Add the translation result with label
        MyGui.Add("Text", "xm y+10 w600", "Translation Result:")
        TranslationText := MyGui.Add("Text", "xm y+5 w600 r7", "Loading translation...")
        
        ; Add progress indicator at the bottom
        MyProgress := MyGui.Add("Progress", "xm y+10 w600 h20 vProgressBar Range0-100", 0)
        MyProgress.Opt("Hidden")
        
        ; Add bottom buttons like the error dialog
        MyGui.Add("Button", "x" (600-320) " y+15 w80", "Help").OnEvent("Click", (*) => ShowHelp())
        MyGui.Add("Button", "x+5 w80", "Copy").OnEvent("Click", (*) => CopyText(selectedText, apiResult))
        MyGui.Add("Button", "x+5 w80", "Close").OnEvent("Click", (*) => MyGui.Destroy())
        
        ; Show the GUI
        MyGui.Show()
        
        ; Display translation progressively if it's long
        if (StrLen(apiResult) > 500)
        {
            MyProgress.Opt("-Hidden")
            DisplayProgressiveTextLabel(MyGui, TranslationText, apiResult, MyProgress)
        }
        else
        {
            ; For short translations, just display immediately
            TranslationText.Value := apiResult
        }
    }
}

; Function to progressively display text in a Text control
DisplayProgressiveTextLabel(gui, control, fullText, progressBar)
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
            currentPos := 0  ; Reset for next time
        }
        
        ; Extract the chunk and update the control
        displayedText := SubStr(fullText, 1, currentPos)
        control.Text := displayedText
        
        ; Update progress bar
        progressPercent := Min(100, Round((currentPos / textLength) * 100))
        progressBar.Value := progressPercent
    }
}

; Function to handle copy button
CopyText(originalText, translatedText)
{
    A_Clipboard := "Original Text:`r`n" originalText "`r`n`r`nTranslation:`r`n" translatedText
}

; Function to show help
ShowHelp()
{
    MsgBox("QTran Help`n`nThis tool translates selected text.`n`n" 
         . "1. Select text in any application`n"
         . "2. Press Alt+Q`n"
         . "3. View the translation result", "Help")
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