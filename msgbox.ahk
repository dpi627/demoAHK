#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; 錯誤訊息
MsgBox, 16, 錯誤, 發生了一個錯誤。

; 詢問訊息
MsgBox, 32, 問題, 你確定要繼續嗎？

; 警告訊息
MsgBox, 48, 警告, 這個操作可能有風險。

; 資訊訊息
MsgBox, 64, 資訊, 操作成功完成。