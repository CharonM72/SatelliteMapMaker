@ECHO OFF
SETLOCAL

rem This program's code is largely taken from Peridexis Errant's __Process Legends Exports.bat script. It does only the fantasy map making part, with a number of modifications, and edited to make a realistic map.
	echo This program will load region map bmp's and use them to make a realistic map.
	echo.
	echo For all parts of this script to work, you need to export all 'd'etailed maps (hotkey 'a' for all) from Legends mode.
	echo.
	echo They must be in the same directory as this bat file, in their original names.
	echo.
	echo This program will only process the first region's maps that it finds.
	echo.
	echo This program also requires the real_trees, real_mountains and real_dirt BMP files to be in the same directory.
	pause
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
	echo Make sure the real_trees, real_mountains and real_dirt BMP files are in the same directory as this BAT file.
	pause
	goto end
	
	:got_region
	
	
	rem check if the maps used by the GIMP script are present
	if not exist "%CD%\*-elw-*.bmp" goto maps_not_found
	if not exist "%CD%\*-el-*.bmp" goto maps_not_found
	if not exist "%CD%\*-veg-*.bmp" goto maps_not_found
	if not exist "%CD%\*-vol-*.bmp" goto maps_not_found
	if not exist "%CD%\*-tmp-*.bmp" goto maps_not_found
	if not exist "%CD%\*-bm-*.bmp" goto maps_not_found
	if not exist "%CD%\real_trees.bmp" goto textures_not_found
	if not exist "%CD%\real_mountains.bmp" goto textures_not_found
	if not exist "%CD%\real_dirt.bmp" goto textures_not_found
	
	rem check for GIMP v2.8 and v2.6 in the usual install locations
	IF EXIST "%programfiles%\GIMP 2\bin\gimp-console-2.8.exe" (
		SET gimpLocation="%programfiles%\GIMP 2\bin\gimp-console-2.8.exe"
		SET "scriptFolder=%programfiles%\GIMP 2\share\gimp\2.0\scripts\"
		GOTO foundit
		)
	IF EXIST "%programfiles% (x86)\GIMP 2\bin\gimp-console-2.8.exe" (
		SET gimpLocation="%programfiles% (x86)\GIMP 2\bin\gimp-console-2.8.exe"
		SET "scriptFolder=%programfiles% (x86)\GIMP 2\share\gimp\2.0\scripts\"
		GOTO foundit
		)
	IF EXIST "%programfiles%\GIMP-2.0\bin\gimp-console-2.8.exe" (
		SET gimpLocation="%programfiles%\GIMP-2.0\bin\gimp-console-2.8.exe"
		SET "scriptFolder=%programfiles%\GIMP-2.0\share\gimp\2.0\scripts\"
		GOTO foundit
		)
	IF EXIST "%programfiles% (x86)\GIMP-2.0\bin\gimp-console-2.8.exe" ( 
		SET gimpLocation="%programfiles% (x86)\GIMP-2.0\bin\gimp-console-2.8.exe"
		SET "scriptFolder=%programfiles% (x86)\GIMP-2.0\share\gimp\2.0\scripts\"
		GOTO foundit
		)
	IF EXIST "%programfiles%\GIMP-2.0\bin\gimp-console-2.6.exe" (
		SET gimpLocation="%programfiles%\GIMP-2.0\bin\gimp-console-2.6.exe"
		SET "scriptFolder=%programfiles%\GIMP-2.0\share\gimp\2.0\scripts\"
		GOTO foundit
		)
	IF EXIST "%programfiles% (x86)\GIMP-2.0\bin\gimp-console-2.6.exe" (
		SET gimpLocation="%programfiles% (x86)\GIMP-2.0\bin\gimp-console-2.6.exe"
		SET "scriptFolder=%programfiles% (x86)\GIMP-2.0\share\gimp\2.0\scripts\"
		GOTO foundit
		)
	
	:gimp_not_found
	
	
	echo GIMP was not found on this computer.
	echo.
	echo Please check this program's code for a list of valid directories. Alternatively, edit this program so it can see your GIMP executable.
	pause
	goto end
	
	:foundit
	
	
	IF exist "%scriptFolder%RealisticMapMaker.scm" GOTO use_RealisticMapMaker
	echo.
	ECHO You have GIMP installed, but not the Map Maker plugin.  
	echo.
	SET /P ANSWER=Do you want to install the plugin (Y/N)?

	if /i {%ANSWER%}=={y} (goto :answer_yes)
	if /i {%ANSWER%}=={yes} (goto :answer_yes)
	goto skip_gimp_script
	:answer_yes
	
	
	ECHO Copy "RealisticMapMaker.scm" into the scripts folder, which is about to open.

	%SystemRoot%\explorer.exe "%scriptFolder%"
	%SystemRoot%\explorer.exe "%CD%"

	SET /P ANSWER=Have you copied the plugin across yet (Y/N)?
	if /i {%ANSWER%}=={y} (goto :foundit)
	if /i {%ANSWER%}=={yes} (goto :foundit)

	SET /P ANSWER=Press Y to try again, N to skip the Map Maker (Y/N)?
	if /i {%ANSWER%}=={y} (goto :foundit)
	if /i {%ANSWER%}=={yes} (goto :foundit)
	goto end
	
	:use_RealisticMapMaker
	
	
	rem The following is taken from the DwarfMapMaker script, by Parker147.  It relies on the GIMP script he wrote, with modifications.  
	set "mapName=RealisticMapmaker-%region#%.bmp"
	
	for %%i in (*-elw-*) do set water=%%~fi
	for %%i in (*-el-*)  do set elevation=%%~fi
	for %%i in (*-veg-*) do set vegetation=%%~fi
	for %%i in (*-vol-*) do set volcanism=%%~fi
	for %%i in (*-tmp-*) do set temperature=%%~fi
	for %%i in (*-bm-*)  do set biome=%%~fi
	for %%i in (real_mountains.bmp)  do set mountains=%%~fi
	for %%i in (real_trees.bmp)  do set trees=%%~fi
	for %%i in (real_dirt.bmp)  do set dirt=%%~fi
	
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
	
	start /wait "" %gimpLocation% -d -f -i -b "(create-save \"%water%\" \"%elevation%\" \"%vegetation%\" \"%volcanism%\" \"%temperature%\" \"%biome%\" \"%trees%\" \"%dirt%\" \"%mountains%\" \"%mapName%\")"

	echo Program completed.
	pause
	
:end
