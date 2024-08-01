@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM 設定變數
set "SCRIPT_NAME=FormuLLaMa"
set "SHORTCUT_NAME=公式小幫手"
set "SOURCE_PATH=\\twfs007\SGSSHARE\OAD\Brian\_Publish\ahk\"
set "TARGET_PATH=C:\dev\ahk"
set "STARTUP_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "DESKTOP_PATH=%USERPROFILE%\Desktop"

REM 檢查並結束現有的程序
tasklist /FI "IMAGENAME eq %SCRIPT_NAME%.exe" | find /I /N "%SCRIPT_NAME%.exe"
if "%ERRORLEVEL%"=="0" (
    taskkill /F /IM "%SCRIPT_NAME%.exe"
    timeout /t
)

REM 創建目標文件夾
if not exist "%TARGET_PATH%" mkdir "%TARGET_PATH%"

REM 複製exe文件
copy "%SOURCE_PATH%\%SCRIPT_NAME%.exe" "%TARGET_PATH%\%SCRIPT_NAME%.exe"

REM 創建啟動項捷徑
powershell -WindowStyle Hidden -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTUP_PATH%\%SHORTCUT_NAME%.lnk'); $Shortcut.TargetPath = '%TARGET_PATH%\%SCRIPT_NAME%.exe'; $Shortcut.Save()"

REM 創建桌面捷徑
powershell -WindowStyle Hidden -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP_PATH%\%SHORTCUT_NAME%.lnk'); $Shortcut.TargetPath = '%TARGET_PATH%\%SCRIPT_NAME%.exe'; $Shortcut.Save()"

REM 執行安裝的exe文件
start "" "%TARGET_PATH%\%SCRIPT_NAME%.exe"

REM 使用 VBScript 顯示安裝完成消息
mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('程序已於背執行，請使用 Alt+Z 呼叫🦙', 10, '%SCRIPT_NAME%🦙 安裝完成', 64);close();"