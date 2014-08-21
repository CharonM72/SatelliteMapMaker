@ECHO OFF
SETLOCAL

:: Satellite Map Maker

:: Creates a satellite imagery-like map of Dwarf Fortress worlds!

:: Written by CharonM72

:: This script is released under the GPL3 to the extent that I (CharonM72) can do so.  It incorporates code written by PeridexisErrant, Parker147 and YukiHyou.  The GPL3 licence can be found at https://www.gnu.org/licenses/gpl.html

echo Welcome to CharonM72's Dwarf Fortress Satellite Map Maker v1.3.1!
echo.
echo This program will load region map bmp's and use them to make a satellite
echo imagery-style map.
echo.
echo For all parts of this script to work, you need to export all 'd'etailed maps
echo (hotkey 'a' for all) from Legends mode.
echo.
echo They must be in the same directory as this bat file, in their original names.
echo.
echo This program will only process the latest region's maps that it finds.
echo.
echo This program also requires the SMM-data folder to be in the same directory.
echo.
pause
echo.
:: If placed as a utility in the PeridexisErrant's Lazy Newb Pack, run from the DF folder
IF NOT EXIST "%CD%\Dwarf Fortress.exe" IF EXIST "%CD%\..\..\..\Dwarf Fortress 0.34.11\Dwarf Fortress.exe" CD "..\..\..\Dwarf Fortress 0.34.11"

:find_region


:: set region ID, to use in rest of script, works for 1-99 inclusive, if site maps only sets "unknown region"
FOR /L %%G IN (999,-1,1) DO (
	IF EXIST "%~dp0\*region%%G*"  (
		set "region#=region%%G"
		goto find_gimp
		)
	)
If exist "%~dp0\site_map-*.bmp"  (
	set "region#=unknown region"
	goto find_gimp
	)

:maps_not_found


echo No region map files found, or not enough found.
echo.
echo Make sure you did not rename or relocate the files, then run this again.
echo.
timeout /t 60
goto end

:textures_not_found


echo Texture files not found.
echo.
echo Make sure the sat_trees, sat_mountains and sat_dirt BMP files are in the same directory as this BAT file.
echo.
timeout /t 60
goto end

:find_gimp

echo Processing map exports from %region#%.
:: check if the maps used by the GIMP script are present
if not exist "%~dp0\*-elw*.bmp" goto maps_not_found
if not exist "%~dp0\*-el*.bmp" goto maps_not_found
if not exist "%~dp0\*-veg*.bmp" goto maps_not_found
if not exist "%~dp0\*-vol*.bmp" goto maps_not_found
if not exist "%~dp0\*-tmp*.bmp" goto maps_not_found
if not exist "%~dp0\*-bm*.bmp" goto maps_not_found
echo Found map images.
if not exist "%~dp0\SMM_data\sat_trees.bmp" goto textures_not_found
if not exist "%~dp0\SMM_data\sat_mountains.bmp" goto textures_not_found
if not exist "%~dp0\SMM_data\sat_dirt.bmp" goto textures_not_found
echo Found texture files.

:: check for GIMP via the user folder
IF NOT EXIST "%userprofile%\.gimp-*" goto gimp_not_found
echo Searching for GIMP (this may take a minute)...
for /f "usebackq tokens=*" %%f in (`dir /s /b "%userprofile%\.gimp-*"`) do (
	SET scriptFolder="%%f"
)
:: get rid of surrounding double quotes
SET scriptFolder=%scriptFolder:~1,-1%
:: retrieve GIMP version from folder name
SET gimpVersion=%scriptFolder:*.gimp-=%

:: check for GIMP install location (calls external .cmd file)
for /f "usebackq tokens=*" %%d in (`"%~dp0\SMM_data\GetGimpInstallLocationSMM.cmd" AUTOMODE %gimpVersion%`) do (
	SET gimpLocation="%%d"
)

:: get rid of surrounding double quotes
SET gimpLocation=%gimpLocation:~1,-1%

if %gimpLocation%!==! goto :gimp_not_found

:copy_script


echo GIMP version %gimpVersion% found.
:: copy Scheme file to GIMP folder if it's not there or has been changed
if not exist "%~dp0\SMM_data\SatMapMaker.scm" (
	if not exist "%scriptFolder%\scripts\SatMapMaker.scm" goto script_not_found
	)
echo Installing script (if necessary)...
ROBOCOPY "%~dp0\SMM_data" "%scriptFolder%\scripts" "SatMapMaker.scm" /NFL /NDL /NJH /NJS /nc /ns /np
echo Done.
goto set_atmosphere

:script_not_found


echo The Satellite Map Maker script was not found either installed or in the current directory.
echo.
echo Please put a copy of the .scm file into this directory, and it will be installed automatically next time.
echo.
timeout /t 60
goto end

:gimp_not_found


echo GIMP was not found on this computer.
echo.
echo This may occur if using a version higher or lower than GIMP 2.
echo.
echo It also may occur if you've never run GIMP before
echo.
echo Please install GIMP, and run it at least once.
echo.
timeout /t 60
goto end

:set_atmosphere


echo.
echo How much atmosphere do you want to display? 
SET /P atmosphere=(0 = none, Google Earth style; 1 = some; 2 = realistic, heavy)  
if %atmosphere% equ 2 (
	goto use_SatMapMaker
	)
if %atmosphere% equ 1 (
	goto use_SatMapMaker
	)
if %atmosphere% equ 0 (
	goto use_SatMapMaker
	)
goto set_atmosphere

:use_SatMapMaker


echo Atmosphere set to %atmosphere%.
:: The following is taken from the DwarfMapMaker script, by Parker147.  It relies on the GIMP script he wrote, with modifications.  
set "mapName=SatMapMaker-%region#%.bmp"

for %%i in (*-elw*) do set water=%%~fi
for %%i in (*-el*)  do set elevation=%%~fi
for %%i in (*-veg*) do set vegetation=%%~fi
for %%i in (*-vol*) do set volcanism=%%~fi
for %%i in (*-tmp*) do set temperature=%%~fi
for %%i in (*-bm*)  do set biome=%%~fi
for %%i in (SMM_data\sat_mountains.bmp)  do set mountains=%%~fi
for %%i in (SMM_data\sat_trees.bmp)  do set trees=%%~fi
for %%i in (SMM_data\sat_dirt.bmp)  do set dirt=%%~fi

set water=%water:\=\\%
set elevation=%elevation:\=\\%
set vegetation=%vegetation:\=\\%
set volcanism=%volcanism:\=\\%
set temperature=%temperature:\=\\%
set biome=%biome:\=\\%
set trees=%trees:\=\\%
set dirt=%dirt:\=\\%
set mountains=%mountains:\=\\%
set outputFile=%outputFile:\=\\%

echo Running GIMP (should take less than a minute)...

start /wait "" %gimpLocation% -d -f -i --verbose -b "(create-save-satellite \"%water%\" \"%elevation%\" \"%vegetation%\" \"%volcanism%\" \"%temperature%\" \"%biome%\" \"%trees%\" \"%dirt%\" \"%mountains%\" %atmosphere% \"%mapName%\")"

echo Program completed.
echo.
timeout /t 30

:end
