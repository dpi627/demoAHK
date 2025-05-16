#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Log(msg)
{
    LogFile := A_ScriptDir "\" A_YYYY A_MM A_DD ".log"
    ErrorMessage := Format("{1}`n{2}\{3}`n{4}@{5}({6})`n==========`n{7}`n`n", A_Now, A_ScriptDir, A_ScriptName, A_UserName, A_ComputerName, A_IPAddress1, msg)
    FileAppend, %ErrorMessage%, %LogFile%
}