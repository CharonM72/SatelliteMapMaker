Satellite Map Maker v1.2


The Satellite Map Maker for Dwarf Fortress was created by CharonM72, based off of code by PeridexisErrant (batch script), Parker147 and GFXiNXS (GIMP script).

This script is released under the GPL3, or as CC-BY-SA-NC at your option.  The GPL3 licence can be found at https://www.gnu.org/licenses/gpl.html


___________INSTRUCTIONS_______________



Unzip all the files into the same directory. This can be into your Dwarf Fortress directory, or any other directory where you keep exported Legends Mode detailed maps.

This script requires the GIMP to be installed. The script will check automatically for common install locations. If it can't find it (maybe you installed to a custom directory, or have a version of GIMP this script doesn't recognize), you can manually edit the .bat file and point one of the checks toward your actual directory (also set the gimpLocation and scriptFolder variables to the correct places).

It also requires most of the exported Legends detailed maps from your Dwarf Fortress world (in BMP format). Specifically, it requires the Elevation with Water map, the Elevation map, the Vegatation map, the Volcanism map, the Temperature map, and the Biome map, but you can just export all of them to be safe.
To export detailed maps from Dwarf Fortress, have a save file with no current fortress or adventure game in progress, select Start Playing on the main menu, select Legends, and then press 'd' to see a list of maps for export. They will by default be exported into your Dwarf Fortress main directory.

This script also needs the three texture files, sat_dirt.bmp, sat_mountains.bmp, and sat_trees.bmp, to be in the same directory.

Finally, in order for GIMP to be able to run the script, the SatMapMaker.scm file must be in the same directory as the .bat file, or already installed. It will be installed into your personal GIMP scripts folder automatically if it's not there. As of v1.2 it will also automatically replace old versions.

To run the script, have the .bat, the six exported world maps, and the three texture files in the same folder (and the .scm file if it's not installed), and then just double-click the _Make Satellite Map.bat file. Follow the instructions on the command prompt. You can expect the GIMP processing to take less than a minute.
The resulting realistic world map will be saved to the directory with all the other script files for your enjoyment.

If you'd like, once the GIMP script is installed, you can run it through GIMP's UI. To do this, in GIMP click File -> Create -> Dwarf Map -> "Create realistic DF map...", then load the appropriate images. The result will be in editable layers.

If you have any problems, please mention it on the thread at the Bay 12 Forums.

___________VERSION HISTORY_______________


2014-03-18 v1.2
-Changed name of program from Realistic Map Maker to Satellite Map Maker.
-Added ability to adjust atmosphere levels.
-Overhauled batch file:
--Copy GIMP script to GIMP user folder instead of system user folder
--Automatically install script file instead of helping user manually do it (thanks PeridexisErrant)
--Automatically check if local script is different than installed and update as needed
--Expanded GIMP detection ability to find more versions of GIMP
--More useful error messages
-Updated Readme file, adding version history etc.

2014-03-13 v1.1
-Updated Readme file.

2014-03-13 v1.0
-Initial release.