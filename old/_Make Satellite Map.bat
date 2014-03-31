@ECHO OFF
SETLOCAL

:: This program's code is largely taken from Peridexis Errant's __Process Legends Exports.bat script. It does only the fantasy map making part, with a number of modifications, and edited to make a realistic satellite-image-like map.
	
	echo Welcome to CharonM72's Dwarf Fortress Satellite Map Maker v1.2!
	echo.
	echo This program will load region map bmp's and use them to make a
	echo satellite imagery-style map.
	echo.
	echo For all parts of this script to work, you need to export all 'd'etailed maps
	echo (hotkey 'a' for all) from Legends mode.
	echo.
	echo They must be in the same directory as this bat file, in their original names.
	echo.
	echo This program will only process the first region's maps that it finds.
	echo.
	echo This program also requires the sat_trees, sat_mountains and sat_dirt BMP files
	echo to be in the same directory.
	echo.
	pause
	echo.
	FOR /L %%G IN (999,-1,1) DO (
		IF EXIST "%CD%\*region%%G*.bmp"  (
			set "region#=region%%G"
			goto got_region
			)
		)
	:maps_not_found
	
	
	echo No region map files found, or not enough found.
	echo.
	echo Make sure you did not rename or relocate the files, then run this again.
	pause
	goto end
	
	:textures_not_found
	
	
	echo Texture files not found.
	echo.
	echo Make sure the sat_trees, sat_mountains and sat_dirt BMP files are in the same directory as this BAT file.
	pause
	goto end
	
	:got_region
	
	
	:: check if the maps used by the GIMP script are present
	if not exist "%CD%\*-elw-*.bmp" goto maps_not_found
	if not exist "%CD%\*-el-*.bmp" goto maps_not_found
	if not exist "%CD%\*-veg-*.bmp" goto maps_not_found
	if not exist "%CD%\*-vol-*.bmp" goto maps_not_found
	if not exist "%CD%\*-tmp-*.bmp" goto maps_not_found
	if not exist "%CD%\*-bm-*.bmp" goto maps_not_found
	echo Found map images.
	if not exist "%CD%\sat_trees.bmp" goto textures_not_found
	if not exist "%CD%\sat_mountains.bmp" goto textures_not_found
	if not exist "%CD%\sat_dirt.bmp" goto textures_not_found
	echo Found texture files.
	
	:: check for GIMP via the user folder
	IF NOT EXIST "%userprofile%\.gimp-*" goto gimp_not_found
	echo Searching for GIMP...
	IF EXIST "%userprofile%\.gimp-*" (
		for /f "usebackq tokens=*" %%f in (`dir /s /b "%userprofile%\.gimp-*"`) do (
			SET scriptFolder="%%f"
		)
	)
	SET scriptFolder=%scriptFolder:~1,-1%
	SET gimpVersion=%scriptFolder:*.gimp-=%
	
	:: find the GIMP install directory
	IF EXIST "%programfiles%\GIMP 2\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles%\GIMP 2\bin\gimp-console-%gimpVersion%.exe"
		GOTO foundit
		)
	IF EXIST "%programfiles% (x86)\GIMP 2\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles% (x86)\GIMP 2\bin\gimp-console-%gimpVersion%.exe"
		GOTO foundit
		)
	IF EXIST "%programfiles%\GIMP-2.0\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles%\GIMP-2.0\bin\gimp-console-%gimpVersion%.exe"
		GOTO foundit
		)
	IF EXIST "%programfiles% (x86)\GIMP-2.0\bin\gimp-console-%gimpVersion%.exe" (
		SET gimpLocation="%programfiles% (x86)\GIMP-2.0\bin\gimp-console-%gimpVersion%.exe"
		GOTO foundit
		)
	goto gimp_not_found
	
	:foundit
	
	
	echo GIMP version %gimpVersion% found.
	:: copy Scheme file to GIMP folder if it's not there
	if not exist "%CD%\SatMapMaker.scm" (
		if not exist "%scriptFolder%\scripts\SatMapMaker.scm" goto script_not_found
		)
	if not exist "%scriptFolder%\scripts\SatMapMaker.scm" (
		echo Copying script...
		copy "%CD%\SatMapMaker.scm" "%scriptFolder%\scripts\SatMapMaker.scm"
		echo Done.
		goto set_atmosphere
		)
	:: check if filesizes are different; if they are then copy over the local one
	FOR %%A IN ("%scriptFolder%\scripts\SatMapMaker.scm") DO set oldfilesize=%%~zA
	FOR %%A IN ("%CD%\SatMapMaker.scm") DO set newfilesize=%%~zA
	if not %oldfilesize% equ %newfilesize% (
		echo GIMP script filesizes are different: local is %newfilesize%, installed is %oldfilesize%.
		echo Installing new script...
		copy "%CD%\SatMapMaker.scm" "%scriptFolder%\scripts\SatMapMaker.scm"
		echo Done.
		goto set_atmosphere
		)
	echo Script already installed.
	goto set_atmosphere
	
	:script_not_found
	
	
	echo The Satellite Map Maker script was not found either installed or in the current directory.
	echo.
	echo Please put a copy of the .scm file into this directory, and it will be installed automatically next time.
	pause
	goto end
	
	:gimp_not_found
	
	
	echo GIMP was not found on this computer.
	echo.
	echo This may occur if using a version higher or lower than GIMP 2.
	echo.
	echo Please install GIMP, and make sure it puts a .gimp user folder in the %userprofile% directory.
	pause
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
	
	for %%i in (*-elw-*) do set water=%%~fi
	for %%i in (*-el-*)  do set elevation=%%~fi
	for %%i in (*-veg-*) do set vegetation=%%~fi
	for %%i in (*-vol-*) do set volcanism=%%~fi
	for %%i in (*-tmp-*) do set temperature=%%~fi
	for %%i in (*-bm-*)  do set biome=%%~fi
	for %%i in (sat_mountains.bmp)  do set mountains=%%~fi
	for %%i in (sat_trees.bmp)  do set trees=%%~fi
	for %%i in (sat_dirt.bmp)  do set dirt=%%~fi
	
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
	
	echo Running GIMP...
	
	start /wait "" %gimpLocation% -d -f -i -b "(create-save-satellite \"%water%\" \"%elevation%\" \"%vegetation%\" \"%volcanism%\" \"%temperature%\" \"%biome%\" \"%trees%\" \"%dirt%\" \"%mountains%\" %atmosphere% \"%mapName%\")"
	
	echo Program completed.
	pause
	
:end
