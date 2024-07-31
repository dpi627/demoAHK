#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Try
{
    ; 您的腳本邏輯，可能會拋出錯誤
    MsgBox, 0, 測試, 正在執行某個操作...
    FileAppend,  ; 模擬可能拋出錯誤的操作
    MsgBox, 0, 錯誤, 此行不會執行。
}
Catch e
{
    ; 捕捉錯誤並寫入日誌
    Log(e.Message)
    MsgBox, 0, 錯誤, 發生錯誤: 未知錯誤
}

; 正常操作的結尾
MsgBox, 0, 完成, 腳本執行完畢。

Return

Log(msg)
{
    LogFile := A_ScriptDir "\" A_YYYY A_MM A_DD ".log"
    ; ErrorMessage := "錯誤發生於 " . A_Now . "`n錯誤訊息: " msg
    ErrorMessage := Format("{1}`n{2}\{3}`n{4}@{5}({6})`n{7}", A_Now, A_ScriptDir, A_ScriptName, A_UserName, A_ComputerName, A_IPAddress1, msg)
    FileAppend, %ErrorMessage%`n`n, %LogFile%
}