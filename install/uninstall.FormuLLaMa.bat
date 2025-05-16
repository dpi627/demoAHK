@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM 設定變數
set "SCRIPT_NAME=FormuLLaMa"
set "SHORTCUT_NAME=公式小幫手"
set "TARGET_PATH=C:\dev\ahk"
set "STARTUP_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "DESKTOP_PATH=%USERPROFILE%\Desktop"

REM 檢查並結束現有的程序
tasklist /FI "IMAGENAME eq %SCRIPT_NAME%.exe" 2>NUL | find /I /N "%SCRIPT_NAME%.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo 正在關閉 %SCRIPT_NAME% 程序...
    taskkill /F /IM "%SCRIPT_NAME%.exe"
    timeout /t 2 >NUL
)

REM 移除 exe 文件
if exist "%TARGET_PATH%\%SCRIPT_NAME%.exe" (
    echo 正在移除 %SCRIPT_NAME%.exe...
    del "%TARGET_PATH%\%SCRIPT_NAME%.exe"
)

REM 移除啟動項捷徑
if exist "%STARTUP_PATH%\%SHORTCUT_NAME%.lnk" (
    echo 正在移除啟動項捷徑...
    del "%STARTUP_PATH%\%SHORTCUT_NAME%.lnk"
)

REM 移除桌面捷徑
if exist "%DESKTOP_PATH%\%SHORTCUT_NAME%.lnk" (
    echo 正在移除桌面捷徑...
    del "%DESKTOP_PATH%\%SHORTCUT_NAME%.lnk"
)

REM 如果 TARGET_PATH 文件夾為空，則刪除它
dir /a /b "%TARGET_PATH%\*" > NUL 2>&1
if errorlevel 1 (
    echo 移除空的安裝目錄...
    rmdir "%TARGET_PATH%"
)

REM 顯示移除完成消息
echo.
echo %SCRIPT_NAME% 已成功移除。
echo.
pause