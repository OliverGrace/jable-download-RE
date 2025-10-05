@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

:: 判断脚本的运行模式
:: 如果第一个参数是以 "m3u8dl://" 开头, 则进入"处理器模式"
set "ARG1=%~1"
if "%ARG1:~0,9%"=="m3u8dl://" (
    goto handle_url
) else (
    goto setup_protocol
)


:setup_protocol
    :: ===============================================================
    :: 安装模式: 当用户手动双击运行时, 会执行这里的代码
    :: ===============================================================
    echo [INFO] 开始为 N_m3u8DL-RE 配置 m3u8dl:// 协议...
    echo.

    :: 获取当前 init.bat 脚本的完整路径
    set "SCRIPT_PATH=%~f0"
    echo [INFO] 当前脚本路径: %SCRIPT_PATH%
    echo.

    :: 使用 REG 命令直接写入注册表, 将 m3u8dl:// 协议指向本脚本
    echo [STEP 1/2] 正在注册 URL Protocol...
    reg add "HKEY_CLASSES_ROOT\m3u8dl" /ve /d "URL:m3u8dl Protocol" /f > nul
    reg add "HKEY_CLASSES_ROOT\m3u8dl" /v "URL Protocol" /d "" /f > nul
    reg add "HKEY_CLASSES_ROOT\m3u8dl\shell\open\command" /ve /d "\"%SCRIPT_PATH%\" \"%%1\"" /f > nul
    
    :: 检查注册表是否写入成功
    if !errorlevel! equ 0 (
        echo [SUCCESS] URL Protocol 注册成功!
    ) else (
        echo [ERROR] 注册失败! 请尝试使用管理员权限运行此脚本。
        pause
        exit /b 1
    )
    echo.

    echo [STEP 2/2] 检查下载器主程序...
    if exist "%~dp0N_m3u8DL-RE.exe" (
        echo [SUCCESS] 下载器 N_m3u8DL-RE.exe 已找到。
    ) else (
        echo [WARNING] 未在同目录下找到 N_m3u8DL-RE.exe, 请确保本脚本和主程序在同一个文件夹内。
    )
    echo.
    
    echo [COMPLETE] 所有配置已完成! 你现在可以关闭此窗口了。
    echo.
    pause
    goto :eof


:handle_url
    :: ===============================================================
    :: 处理器模式: 当用户点击网页链接时, 系统会自动调用此脚本, 并执行这里的代码
    :: ===============================================================
    
    :: 接收完整的URL作为第一个参数, 例如: m3u8dl://Imh0dHBzOi8v...
    set "fullUrl=%~1"
    
    :: 截掉前面9个字符的协议头 "m3u8dl://"
    set "base64String=%fullUrl:~9%"
    
    :: 使用PowerShell进行Base64解码
    for /f "delims=" %%i in ('powershell -NoProfile -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(''%base64String%''))"') do (
        set "decodedArgs=%%i"
    )
    
    :: 获取当前脚本所在的目录
    set "currentDir=%~dp0"
    
    :: 组合下载器的完整路径
    set "downloaderPath=%currentDir%N_m3u8DL-RE.exe"
    
    :: 启动下载器并传递解码后的参数
    start "N_m3u8DL-RE Downloader" "%downloaderPath%" !decodedArgs!
    
    goto :eof
