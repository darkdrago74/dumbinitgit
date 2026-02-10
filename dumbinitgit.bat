@echo off
setlocal EnableDelayedExpansion

REM --- CONFIGURATION ---
REM IMPORTANT: Fill these variables before the first run.
REM After the first initialization, the script will replace these values for security.
set "GITHUB_TOKEN=TOBEMODIFIED"
set "GITHUB_USERNAME=TOBEMODIFIED"
set "GITHUB_EMAIL=TOBEMODIFIED"
set "REPO_URL=https://github.com/darkdrago74/LzrCnc.git"
set "INITIALIZED=false"

REM --- SCRIPT LOGIC ---

if "%INITIALIZED%"=="false" (
    call :initialize_repo
)

:menu
cls
echo ==========================================
echo           DumbInitGit (Windows)
echo ==========================================
echo.
echo  1. Status (Check changes)
echo  2. Commit (Save local changes)
echo  3. Push (Upload to GitHub)
echo  4. Pull (Update from GitHub)
echo  5. Create Branch
echo  6. Switch Branch
echo  7. List Branches
echo  8. Manage Git LFS
echo.
echo  Q. Quit
echo.
echo ==========================================
set /p choice="Select an option: "

if /i "%choice%"=="1" goto status
if /i "%choice%"=="2" goto commit
if /i "%choice%"=="3" goto push
if /i "%choice%"=="4" goto pull
if /i "%choice%"=="5" goto create_branch
if /i "%choice%"=="6" goto switch_branch
if /i "%choice%"=="7" goto list_branches
if /i "%choice%"=="8" goto manage_lfs
if /i "%choice%"=="Q" goto end

echo Invalid choice.
pause
goto menu

:initialize_repo
echo --- Repository Initialization ---
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: git is not installed.
    pause
    exit /b 1
)

if "%GITHUB_TOKEN%"=="TOBEMODIFIED" (
    echo Warning: Credentials are not set in the script.
    set /p "prompt_choice=Do you want to enter them now? (y/n): "
    if /i "!prompt_choice!"=="y" (
        set /p "GITHUB_USERNAME=Enter your GitHub Username: "
        set /p "GITHUB_EMAIL=Enter your GitHub Email: "
        set /p "GITHUB_TOKEN=Enter your GitHub Personal Access Token: "
    ) else (
        echo Initialization aborted. Please fill in the details in the script and run again.
        pause
        exit /b 1
    )
)

if exist .git (
    echo Existing git repository detected.
) else (
    echo Initializing new git repository...
    git init
    if not exist .gitignore (
        echo dumbinitgit.bat >> .gitignore
    ) else (
        findstr /C:"dumbinitgit.bat" .gitignore >nul
        if %errorlevel% neq 0 echo dumbinitgit.bat >> .gitignore
    )
)

git config user.name "!GITHUB_USERNAME!"
git config user.email "!GITHUB_EMAIL!"

echo Configuring remote origin...
REM Remove protocol from URL to insert token
set "CLEAN_URL=!REPO_URL:https://=!"
set "REMOTE_URL=https://!GITHUB_TOKEN!@!CLEAN_URL!"

git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    git remote set-url origin "!REMOTE_URL!"
) else (
    git remote add origin "!REMOTE_URL!"
)

echo Initialization successful.

REM Initial Commit if needed (simplified check)
git rev-parse HEAD >nul 2>&1
if %errorlevel% neq 0 (
    git add .
    git commit -m "Initial commit"
)

REM Secure the script (Self-modification)
echo Securing script: removing credentials...
powershell -Command "(Get-Content '%~f0') -replace 'set \"GITHUB_TOKEN=.*\"', 'set \"GITHUB_TOKEN=AlreadyInit\"' | Set-Content '%~f0'"
powershell -Command "(Get-Content '%~f0') -replace 'set \"GITHUB_USERNAME=.*\"', 'set \"GITHUB_USERNAME=AlreadyInit\"' | Set-Content '%~f0'"
powershell -Command "(Get-Content '%~f0') -replace 'set \"GITHUB_EMAIL=.*\"', 'set \"GITHUB_EMAIL=AlreadyInit\"' | Set-Content '%~f0'"
powershell -Command "(Get-Content '%~f0') -replace 'set \"INITIALIZED=.*\"', 'set \"INITIALIZED=true\"' | Set-Content '%~f0'"

echo Script secured. Credentials have been removed.
echo ---------------------------------
pause
goto :eof

:status
echo.
git status
pause
goto menu

:commit
echo.
echo --- Commit (save) changes locally ---
echo This saves a snapshot of your current changes.
echo Important: After commit, use 'Push' to upload to GitHub.
set /p "msg=Enter your commit message: "
if "%msg%"=="" goto menu
git add .
git commit -m "%msg%"
pause
goto menu

:push
echo.
echo --- Push changes to GitHub ---
git push
if %errorlevel% neq 0 (
    echo Push failed. Trying to set upstream...
    for /f "tokens=*" %%a in ('git branch --show-current') do set current_branch=%%a
    git push --set-upstream origin !current_branch!
)
pause
goto menu

:pull
echo.
echo --- Pull (update) from GitHub ---
set /p "branch=Enter branch to pull from (default: main): "
if "%branch%"=="" set branch=main
git pull origin %branch%
pause
goto menu

:create_branch
echo.
set /p "branch=Enter new branch name: "
if "%branch%"=="" goto menu
git checkout -b %branch%
pause
goto menu

:switch_branch
echo.
git branch
echo.
set /p "branch=Enter branch name to switch to: "
if "%branch%"=="" goto menu
git checkout %branch%
pause
goto menu

:list_branches
echo.
git branch -a
pause
goto menu

:manage_lfs
echo.
echo --- Git LFS Management ---
echo 1. Track file type
echo 2. Untrack file type
echo 3. List tracked types
echo b. Back
set /p "lfs_choice=Choose: "
if "%lfs_choice%"=="1" (
    set /p "pattern=Enter pattern (e.g. *.zip): "
    git lfs track "!pattern!"
)
if "%lfs_choice%"=="2" (
    set /p "pattern=Enter pattern to untrack: "
    git lfs untrack "!pattern!"
)
if "%lfs_choice%"=="3" (
    if exist .gitattributes type .gitattributes | findstr "filter=lfs"
)
pause
goto menu

:end
endlocal
