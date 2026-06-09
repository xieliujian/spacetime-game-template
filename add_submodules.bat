@echo off
chcp 65001 >nul
cd /d %~dp0
if /i "%~1"=="--no-pause" set NO_PAUSE=1

set PPK_KEY=D:\xieliujian\TortoiseGit_github_private_key.ppk
set TORTOISE_BIN=D:\Program Files\TortoiseGit\bin
set "PLINK_EXE=%TORTOISE_BIN%\TortoiseGitPlink.exe"
for %%I in ("%PLINK_EXE%") do set "PLINK_EXE=%%~sI"
for %%I in ("%PPK_KEY%") do set "PPK_KEY=%%~sI"
set "PLINK_EXE=%PLINK_EXE:\=/%"
set "PPK_KEY=%PPK_KEY:\=/%"
set "GIT_SSH_COMMAND=%PLINK_EXE% -batch -i %PPK_KEY%"

echo Starting Pageant...
start "" "%TORTOISE_BIN%\pageant.exe" "D:\xieliujian\TortoiseGit_github_private_key.ppk"
ping -n 3 127.0.0.1 >nul

call :add_submodule git@github.com:xieliujian/com.spacetime.core.git client/project/Packages/com.spacetime.core
call :add_submodule git@github.com:xieliujian/com.spacetime.tool.git client/project/Packages/com.spacetime.tool
call :add_submodule git@github.com:xieliujian/com.spacetime.effect.git client/project/Packages/com.spacetime.effect

call :add_submodule git@github.com:xieliujian/com.spacetime.core.git client/art/scene/Packages/com.spacetime.core
call :add_submodule git@github.com:xieliujian/com.spacetime.tool.git client/art/scene/Packages/com.spacetime.tool
call :add_submodule git@github.com:xieliujian/com.spacetime.effect.git client/art/scene/Packages/com.spacetime.effect

call :add_submodule git@github.com:xieliujian/com.spacetime.core.git client/art/ui/Packages/com.spacetime.core
call :add_submodule git@github.com:xieliujian/com.spacetime.tool.git client/art/ui/Packages/com.spacetime.tool
call :add_submodule git@github.com:xieliujian/com.spacetime.effect.git client/art/ui/Packages/com.spacetime.effect

call :add_submodule git@github.com:xieliujian/spacetime_table.git tools/spacetime_table
call :add_submodule git@github.com:xieliujian/spacetime_localpatchserver.git tools/spacetime_localpatchserver

echo Done! All submodules added or already exist.
if not defined NO_PAUSE pause
exit /b 0

:add_submodule
if exist "%~2\.git" (
    echo [SKIP] %~2
    exit /b 0
)

echo [ADD] %~2
git submodule add %~1 %~2
if %errorlevel% neq 0 (
    echo [ERROR] Failed to add %~2
    exit /b %errorlevel%
)
exit /b 0
