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

echo ============================================
echo  Update All Submodules to Latest
echo ============================================
echo.

set FAILED=0

for /f "tokens=2 delims= " %%P in ('git config --file .gitmodules --get-regexp path') do (
    call :update_one "%%P"
    if errorlevel 1 set FAILED=1
)

if "%FAILED%"=="1" (
    echo.
    echo [ERROR] One or more submodules failed to update.
    if not defined NO_PAUSE pause
    exit /b 1
)

echo.
echo All submodules updated successfully!
if not defined NO_PAUSE pause
exit /b 0

:update_one
set "SUBMODULE_PATH=%~1"
set "OLD_COMMIT="
set "NEW_COMMIT="

echo --------------------------------------------
echo [UPDATE] %SUBMODULE_PATH%

if not exist "%SUBMODULE_PATH%\.git" (
    echo [INIT] %SUBMODULE_PATH%
)

for /f "delims=" %%H in ('git -C "%SUBMODULE_PATH%" rev-parse --short HEAD 2^>nul') do set "OLD_COMMIT=%%H"
if not defined OLD_COMMIT set "OLD_COMMIT=(not initialized)"
echo [OLD] %OLD_COMMIT%

git submodule update --init --remote --merge -- "%SUBMODULE_PATH%"
if %errorlevel% neq 0 (
    echo [FAIL] %SUBMODULE_PATH%
    exit /b 1
)

for /f "delims=" %%H in ('git -C "%SUBMODULE_PATH%" rev-parse --short HEAD 2^>nul') do set "NEW_COMMIT=%%H"
if not defined NEW_COMMIT set "NEW_COMMIT=(unknown)"
echo [NEW] %NEW_COMMIT%

if "%OLD_COMMIT%"=="%NEW_COMMIT%" (
    echo [OK] No change.
) else (
    echo [OK] Updated %OLD_COMMIT% -^> %NEW_COMMIT%
)
exit /b 0
