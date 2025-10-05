@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

echo [INFO] 本脚本将从您的系统中卸载/取消注册 m3u8dl:// 协议。
echo [INFO] 这将会删除相关的注册表项。
echo.
echo [WARNING] 执行此操作后, 网页上的 m3u8dl:// 下载链接将不再起作用。
echo           按 Ctrl+C 可以取消操作, 按其他任意键则继续...
pause > nul
echo.

echo [STEP] 正在尝试删除注册表项: HKEY_CLASSES_ROOT\m3u8dl ...

:: 直接使用 REG DELETE 命令删除整个协议的根键, /f 参数表示强制删除, 无需确认
reg delete "HKEY_CLASSES_ROOT\m3u8dl" /f

:: 检查上一条命令是否执行成功
if !errorlevel! equ 0 (
    echo.
    echo [SUCCESS] m3u8dl:// 协议已成功卸载。
) else (
    echo.
    echo [ERROR] 卸载失败!
    echo [HINT]  可能是权限不足, 请尝试【以管理员身份运行】此脚本。
)

echo.
echo 按任意键退出。
pause > nul
