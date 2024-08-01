#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

!f::  ; Ctrl+F 觸發腳本
InputBox, userInput, FormulaMaster-公式大師, , , 300, 100  ; 寬度300，高度100
if ErrorLevel  ; 如果用戶取消輸入
    return

param := URLEncode(userInput)
; MsgBox % param
; url := "http://localhost:5276/api/ExcelFormula?Prompt=" param
url := "http://twtpeoad002/oai/api/ExcelFormula?Prompt=" param

; Send a GET request to the API
http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
http.Open("GET", url, false)
http.Send()

; Check if the request was successful
if (http.Status = 200) {
    ; Retrieve the response string
    response := http.ResponseText

    ; Copy the response to the clipboard
    Clipboard := response

    ; Display the response
    MsgBox % "公式已複製到剪貼簿: " response
} else {
    MsgBox % "Failed to call the API. Status code: " http.Status
}

URLEncode(str) {
    VarSetCapacity(Var, StrPut(str, "UTF-8"), 0)
    StrPut(str, &Var, "UTF-8")
    f := A_FormatInteger
    SetFormat, IntegerFast, H
    While Code := NumGet(Var, A_Index - 1, "UChar")
    {
        If (Code >= 0x30 && Code <= 0x39 ; 0-9
            || Code >= 0x41 && Code <= 0x5A ; A-Z
            || Code >= 0x61 && Code <= 0x7A) ; a-z
            Res .= Chr(Code)
        Else
            Res .= "%" . SubStr(Code + 0x100, -1)
    }
    SetFormat, IntegerFast, %f%
    Return, Res
}