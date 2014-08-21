::@echo off
SETLOCAL

:: This script was mostly written by YukiHyou, with modifications by PeridexisErrant and CharonM72.
:: Run as GetGimpInstallLocationSMM.cmd [AUTOMODE] [GIMP_version]

IF %1!==AUTOMODE! GOTO :SkipUserInput
SHIFT
IF NOT %1!==! SET "gimpVersion=%1"

echo GIMP couldn't be found in the default locations. Enter the location of your
echo gimp installation or leave blank to scan for it.
echo.
set /p UserGimpLocation=GIMP Install location: 

:: Using "\..\" at the end of a path with filename will give the containing folder!
if exist "%UserGimpLocation%\..\gimp-console-*.exe" call :SubGetExeName "%UserGimpLocation%\..\"
if exist "%UserGimpLocation%\bin\gimp-console-*.exe" call :SubGetExeName "%UserGimpLocation%\bin\"
if exist "%UserGimpLocation%\gimp-console-*.exe" call :SubGetExeName "%UserGimpLocation%\"

:SkipUserInput


SHIFT
IF NOT %1!==! SET "gimpVersion=%1"
if "%UserGimpLocation%"=="" CALL :ScanForIt

if "%LNPGimpLocation%"=="" (
	echo %gimpLocation%
	goto :TheEnd
)

echo %LNPGimpLocation%!
GOTO :TheEnd

:ScanForIt


:: Scans the most common locations
IF NOT %gimpVersion%!==! (
	IF EXIST "%programfiles%\GIMP ?\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles%\GIMP 2\bin\gimp-console-%gimpVersion%.exe"
		GOTO :EOF
		)
	IF EXIST "%programfiles% (x86)\GIMP ?\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles% (x86)\GIMP 2\bin\gimp-console-%gimpVersion%.exe"
		GOTO :EOF
		)
	IF EXIST "%programfiles%\GIMP-?.?\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles%\GIMP-2.0\bin\gimp-console-%gimpVersion%.exe"
		GOTO :EOF
		)
	IF EXIST "%programfiles% (x86)\GIMP-?.?\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles% (x86)\GIMP-2.0\bin\gimp-console-%gimpVersion%.exe"
		GOTO :EOF
		)
	)
	
:BruteForce


:: echo Checking Registry ...

:: Can easily add extra registry entries in here if they are found
:: for /f "usebackq tokens=2*" %%f in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GIMP-2_is1" /v "InstallLocation"`) do call :SubGetExeName "%%g"

:: Brute force, but it works. Only tries to scan a drive if it exists.
if "%LNPGimpLocation%"=="" (
	:: echo Scanning folders manually ...
	FOR %%d in (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO (
		IF EXIST %%d:\ call :SubGetExeName "%%d:\"
	)
)

GOTO :EOF

:SubGetExeName
	:: Just a subroutine to avoid making typos on this every time.
	for /f "usebackq tokens=*" %%w in (`dir /s /b %1 ^| findstr "\gimp-console-"`) do set LNPGimpLocation=%%w
GOTO :EOF


:TheEnd