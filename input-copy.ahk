#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

^f::  ; Ctrl+F 觸發腳本
InputBox, userInput, 輸入文字, 請輸入一些文字:, , 300, 100  ; 寬度300，高度100
if !ErrorLevel  ; 如果用戶沒有取消輸入
{
    Clipboard := userInput  ; 將輸入複製到剪貼簿
    MsgBox, 文字已複製到剪貼簿
}
return