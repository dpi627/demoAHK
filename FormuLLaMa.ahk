#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include lib.log.ahk

callOut := "`n`nOAD Brian #1429`nbrian.li@sgs.com"

!f::  ; Alt+F 觸發腳本
InputBox, userInput, %A_UserName% 您好，我是公式小幫手 FormuLLaMa，請描述您的需求😄, , , 550, 100  ; 寬度300，高度100
if ErrorLevel  ; 如果用戶取消輸入
    return

param := userInput
; url := "http://localhost:5276/api/ExcelFormula"
url := "http://twtpeoad002/oai/api/ExcelFormula"
body := "{""prompt"": """ param """}"

Try
{
    ; Send a GET request to the API
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("POST", url, false)
    http.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
    http.Send(body)

    ; Check if the request was successful
    if (http.Status = 200) {
        ; Retrieve the response string
        response := http.ResponseText
        ; Copy the response to the clipboard
        Clipboard := response
        ; Display the response
        MsgBox, 64, ✨ 公式已生成, 以下公式已複製到剪貼簿，請於 Excel 公式欄位貼上 (Ctrl+V)`n`n %response%
    } else {
        errmsg := Format("{1}`n{2}", http.Status, http.ResponseText)
        Log(errmsg)
        MsgBox, 16, 🚨 服務異常, 請檢查有無特殊字元，移除再試試看`n`n如仍無法解決請聯絡 %callOut%
    }
}
Catch e
{
    Log(e.Message)
    MsgBox, 16, 🚨 系統異常, 請再次嘗試，如仍持續異常請聯絡 %callOut%
}


Return