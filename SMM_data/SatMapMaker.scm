(define (create-save-satellite waterFile elevationFile vegatationFile volcanismFile temperatureFile biomeFile treesFile dirtFile mountainsFile atmosphere outputFile)
(let * (
	(newRegion (car (satellite-map-maker waterFile elevationFile vegatationFile volcanismFile temperatureFile biomeFile treesFile dirtFile mountainsFile atmosphere)))
	)
	
	(file-bmp-save 1 newRegion (car (gimp-image-flatten newRegion)) outputFile "")
	(gimp-quit 1)
)
)

(define (create-view-satellite waterFile elevationFile vegatationFile volcanismFile temperatureFile biomeFile treesFile dirtFile mountainsFile atmosphere)
	(gimp-display-new (car (satellite-map-maker waterFile elevationFile vegatationFile volcanismFile temperatureFile biomeFile treesFile dirtFile mountainsFile atmosphere)))
)

(define (satellite-map-maker waterFile elevationFile vegatationFile volcanismFile temperatureFile biomeFile treesFile dirtFile mountainsFile atmosphere)
(let * (
	; Set image files to images within GIMP, and define variables
	(waterImage ( car (file-bmp-load 0 waterFile "")))
	(elevationImage ( car (file-bmp-load 0 elevationFile "")))
	(vegatationImage ( car (file-bmp-load 0 vegatationFile "")))
	(volcanismImage ( car (file-bmp-load 0 volcanismFile "")))
	(temperatureImage ( car (file-bmp-load 0 temperatureFile "")))
	(biomeImage (car (file-bmp-load 0 biomeFile "")))
	(treesImage (car (file-bmp-load 0 treesFile "")))
	(dirtImage (car (file-bmp-load 0 dirtFile "")))
	(mountainsImage (car (file-bmp-load 0 mountainsFile "")))
	(newRegion ( car (gimp-image-new 1 1 0))) 
	(width 0)
	(height 0)
	(center-x 0)
	(center-y 0)
	)
	; Set image dimensions based on water file
	(set! width (car (gimp-image-width waterImage)))
	(set! height (car (gimp-image-height waterImage)))
	(gimp-image-resize newRegion width height 0 0)
	(set! center-x (/ width 2))
	(set! center-y (/ height 2))
	
	(let * (
		; Create new layers from each of the loaded images (sometimes multiple layers)
		(elevation (car (gimp-layer-new-from-visible elevationImage newRegion "Elevation")))
		(mountainElevation (car (gimp-layer-new-from-visible elevationImage newRegion "Mountain Elevation")))
		(oceans (car (gimp-layer-new-from-visible waterImage newRegion "Oceans")))
		(rivers (car (gimp-layer-new-from-visible waterImage newRegion "Rivers")))
		(waterDepth (car (gimp-layer-new-from-visible elevationImage newRegion "Ocean Depth")))
		(vegatation (car (gimp-layer-new-from-visible vegatationImage newRegion "Vegatation")))
		(biome (car (gimp-layer-new-from-visible biomeImage newRegion "Biome")))
		(volcanism (car (gimp-layer-new-from-visible volcanismImage newRegion "Volcanism")))
		(temperature (car (gimp-layer-new-from-visible temperatureImage newRegion "Temperature")))
		(iceCap (car (gimp-layer-new-from-visible temperatureImage newRegion "Ice Cap")))
		; These will be based on the texture images
		(dirt (car (gimp-layer-new newRegion 10 10 0 "Dirt" 100 0)))
		(trees (car (gimp-layer-new newRegion 10 10 0 "Trees" 100 0)))
		(mountains (car (gimp-layer-new newRegion 10 10 0 "Mountains" 100 0)))
		(sky (car (gimp-layer-new newRegion 10 10 0 "sky" 100 0)))
		
		; Create a few gradients
		(elevationMap (car (gimp-gradient-new "Elevation Map")))
		(riverMap (car (gimp-gradient-new "River Map")))
		(vegatationMap (car (gimp-gradient-new "Vegatation Map")))
		(temperatureMap(car (gimp-gradient-new "Temperature Map")))
		(iceCapMap(car (gimp-gradient-new "Ice Cap Map")))
		(visible 0)
		)

		;---------------Setup Layers-----------------
		(gimp-image-resize-to-layers newRegion)
		;order layers
		(gimp-image-add-layer newRegion biome 0)
		(gimp-image-add-layer newRegion oceans 0)
		(gimp-image-add-layer newRegion waterDepth 0)
		(gimp-image-add-layer newRegion elevation 0)
		(gimp-image-add-layer newRegion mountainElevation 0)
		(gimp-image-add-layer newRegion dirt 0)
		(gimp-image-add-layer newRegion mountains 0)
		(gimp-image-add-layer newRegion vegatation 0)
		(gimp-image-add-layer newRegion rivers 0)
		(gimp-image-add-layer newRegion trees 0)
		(gimp-image-add-layer newRegion volcanism 0)
		(gimp-image-add-layer newRegion iceCap 0)
		(gimp-image-add-layer newRegion temperature 0)
		(gimp-image-add-layer newRegion sky 0)
		
		;sets dirt and mountain texture layers to the image size and transparent
		(gimp-layer-resize-to-image-size dirt)
		(gimp-layer-add-alpha dirt)
		(gimp-edit-clear dirt)
		(gimp-layer-resize-to-image-size mountains)
		(gimp-layer-add-alpha mountains)
		(gimp-edit-clear mountains)	
		(gimp-layer-resize-to-image-size sky)
		(gimp-layer-add-alpha sky)
		
		;select and remove ocean area out of layers so ocean isn't effected by other layers
		(gimp-by-color-select oceans '(0 0 75) 50 0 0 0 0 0) ;select ocean based on color
		;cut all of the textures to match land shape
		(gimp-edit-cut elevation)
		(gimp-edit-cut volcanism)
		(gimp-edit-cut temperature)
		;recolor ocean while its still selected
		(gimp-context-set-foreground '(15 86 152)) ;set FG color to ocean color
		(gimp-context-set-background '(5 33 57)) ;set BG color to darker ocean color
		;do the radial gradient
		(gimp-blend oceans 
              0 ;fg-bg-rgb mode
              0 ;normal mode
              2 ;gradient-radial
              100 ; Opacity
              0 ; Offset
              0 ; REPEAT-NONE
              FALSE ; Reverse
              TRUE ; supersampling
              3 ; recursion level for supersampling
              0.2 ; supersampling threshold 
              TRUE ;dither
              center-x ; start at center
              center-y 
              width ; end on bottom-right corner
              height)
		
		;invert selection and remove land area from ocean layers
		(gimp-selection-invert newRegion)
		(gimp-edit-cut oceans)
		(gimp-edit-cut waterDepth)
		
		;fill in land with dirt pattern
		(gimp-selection-all dirtImage) 
		(gimp-edit-copy-visible dirtImage)
		(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0)) 
		(gimp-bucket-fill dirt 2 0 100 255 0 0 0) ;fill the dirt layer with dirt pattern
		(gimp-layer-set-mode dirt 21) ;set dirt layer to grain-merge
		(gimp-levels dirt 1 0 255 1.0 25 255) ;increase minimum output level, decreasing the sharpness of dark areas
		
		;make mountains
		(gimp-selection-none newRegion)
		(gimp-by-color-select biome '(128 128 128) 0 0 0 0 0 0) ;select mountains
		(gimp-edit-cut dirt) ;remove mountain biome from layers
		(gimp-edit-cut temperature)
		;fill mountain biome with mountain pattern
		(gimp-selection-all mountainsImage)
		(gimp-edit-copy-visible mountainsImage)
		(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0)) 
		(gimp-bucket-fill mountains 2 0 75 255 0 0 0) ;fill mountain layer with mountain pattern
		(gimp-layer-set-mode mountains 19) ;set mode to softlight
		(gimp-selection-invert newRegion) ;setup another mountain biome layer for elevation
		(gimp-edit-clear mountainElevation)
		
		;setup tree layer
		(gimp-selection-none newRegion)
		(gimp-layer-resize-to-image-size trees) 
		(gimp-layer-add-alpha trees)
		(gimp-edit-clear trees)	
		
		
		;remove ice cap from tree fill
		(gimp-selection-none newRegion)
		(gimp-by-color-select iceCap '(255 255 255) 197 0 0 0 0 0)
		(gimp-edit-cut iceCap)
		(gimp-selection-none newRegion)
		
		;make water depth
		(gimp-desaturate waterDepth)
		(gimp-layer-set-opacity waterDepth 80) ;reduces opacity
		(gimp-layer-set-mode waterDepth 19) ;set mode to softlight
		(gimp-levels waterDepth 0 25 255 1.0 0 255) ;change levels so only coastlines appear
		
		;make sky
		(gimp-layer-set-opacity sky (/ atmosphere 0.05))
		(gimp-by-color-select sky '(255 255 255) 255 0 0 0 0 0)
		(gimp-context-set-foreground '(171 221 255))
		(gimp-bucket-fill sky 0 0 100 0 0 0 0)
		(gimp-selection-none newRegion)
		
		;set layer modes
		(gimp-layer-set-mode volcanism 13) ;set to color mode
		(gimp-layer-set-mode temperature 19) ;set to softlight mode
		(gimp-layer-set-mode iceCap 7) ;set to addition mode
		
		
		;---------------Apply Colors / Gradients to Layers---------------
		
		;Elevation Gradient Map
		(gimp-gradient-segment-range-split-uniform elevationMap 0 0 4) 
		(gimp-gradient-segment-set-middle-pos elevationMap 0 0.13)
		(gimp-gradient-segment-set-right-pos elevationMap 0 0.25)
		(gimp-gradient-segment-set-middle-pos elevationMap 1 0.37)
		(gimp-gradient-segment-set-right-pos elevationMap 1 0.49)
		(gimp-gradient-segment-set-middle-pos elevationMap 2 0.60)
		(gimp-gradient-segment-set-right-pos elevationMap 2 0.69)
		(gimp-gradient-segment-set-middle-pos elevationMap 3 0.88)
		(gimp-gradient-segment-set-right-pos elevationMap 3 1.0)
		(gimp-gradient-segment-set-left-color elevationMap 0 '(0 0 0) 100) ;black
		(gimp-gradient-segment-set-right-color elevationMap 0 '(0 0 0) 100) ;black
		(gimp-gradient-segment-set-left-color elevationMap 1 '(0 0 0) 100) ;black
		(gimp-gradient-segment-set-right-color elevationMap 1 '(170 154 127) 100) ;gray-brown
		(gimp-gradient-segment-set-left-color elevationMap 2 '(76 71 68) 100) ;dark gray
		(gimp-gradient-segment-set-right-color elevationMap 2 '(133 124 114) 100) ;gray
		(gimp-gradient-segment-set-left-color elevationMap 3 '(185 175 165) 100) ;light gray
		(gimp-gradient-segment-set-right-color elevationMap 3 '(255 255 255) 100) ;white
		(gimp-context-set-gradient elevationMap)
		(plug-in-gradmap 0 newRegion elevation)
		
		;Mountain Elevation Gradient Map
		;Minor changes to the elevation map so that it fills out the mountain biome completely
		(gimp-gradient-segment-set-right-pos elevationMap 1 0.45)
		(plug-in-gradmap 0 newRegion mountainElevation)
		
		 ;River Gradient Map
		(gimp-selection-none newRegion)
		(gimp-by-color-select rivers '(0 127 127) 70 0 0 0 0 0)
		(gimp-selection-invert newRegion)
		(gimp-edit-clear rivers)
		(gimp-selection-none newRegion)
		(gimp-gradient-segment-set-left-color riverMap 0 '(49 53 157) 100) ;bluish
		(gimp-gradient-segment-set-right-color riverMap 0 '(11 43 78) 100) ;dark blue 
		(gimp-context-set-gradient riverMap)
		(plug-in-gradmap 0 newRegion rivers)
		(gimp-layer-set-opacity rivers 30) ;make rivers much less visible; they're kinda ugly
		
		;Gradient Map vegatation so it is transparent in low vegatation areas
		(gimp-gradient-segment-set-middle-pos vegatationMap 0 0.33) 
		(gimp-gradient-segment-set-left-color vegatationMap 0 '(0 0 0) 0) ;black
		(gimp-gradient-segment-set-right-color vegatationMap 0 '(255 255 255) 100) ;white
		(gimp-context-set-gradient vegatationMap)
		(plug-in-gradmap 0 newRegion vegatation)
		(gimp-selection-layer-alpha vegatation) ;fill in trees from the alpha selection
		(gimp-selection-all treesImage)
		(gimp-edit-copy-visible treesImage)
		(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0)) 
		(gimp-bucket-fill trees 2 0 100 255 0 0 0) ;add the trees!

		;Gradient Map Vegatation
		(gimp-selection-none newRegion)
		(gimp-gradient-segment-range-split-midpoint vegatationMap 0 0) 
		(gimp-gradient-segment-set-middle-pos vegatationMap 0 0.379)
		(gimp-gradient-segment-set-right-pos vegatationMap 0 0.658)
		(gimp-gradient-segment-set-middle-pos vegatationMap 1 0.704)
		(gimp-gradient-segment-set-left-color vegatationMap 0 '(0 0 0) 100) ;black
		(gimp-gradient-segment-set-right-color vegatationMap 0 '(110 170 66) 100) ;light green
		(gimp-gradient-segment-set-left-color vegatationMap 1 '(85 135 63) 100) ;green
		(gimp-gradient-segment-set-right-color vegatationMap 1 '(60 108 39) 100) ;dark green
		(gimp-context-set-gradient vegatationMap)
		(plug-in-gradmap 0 newRegion vegatation)
		
		;Remove low volcanism areas so it doesn't effect the entire map (volcanism is the gray areas)
		(gimp-layer-add-alpha volcanism)
		(gimp-by-color-select volcanism '(255 255 255) 140 0 1 0 0 0) ;antialias for the nice smooth grays
		(gimp-edit-clear volcanism)
		(gimp-selection-none newRegion)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-context-set-background '(0 0 0))
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 3))
		(plug-in-gradmap 0 newRegion volcanism)
		
		;Gradient Map Temperature
		(gimp-gradient-segment-range-split-uniform temperatureMap 0 0 3)
		(gimp-gradient-segment-set-middle-pos temperatureMap 0 0.30)
		(gimp-gradient-segment-set-right-pos temperatureMap 0 0.40)
		(gimp-gradient-segment-set-right-pos temperatureMap 1 0.60)
		(gimp-gradient-segment-set-middle-pos temperatureMap 2 0.70)
		(gimp-gradient-segment-set-left-color temperatureMap 0 '(30 25 100) 100) ;bluish
		(gimp-gradient-segment-set-right-color temperatureMap 0 '(127 127 127) 100) ;gray
		(gimp-gradient-segment-set-left-color temperatureMap 1 '(127 127 127) 100) ;gray
		(gimp-gradient-segment-set-right-color temperatureMap 1 '(127 127 127) 100) ;gray
		(gimp-gradient-segment-set-left-color temperatureMap 2 '(127 127 127) 100) ;gray
		(gimp-gradient-segment-set-right-color temperatureMap 2 '(255 226 122) 100) ;orange
		(gimp-context-set-gradient temperatureMap)
		(plug-in-gradmap 0 newRegion temperature)
		(gimp-levels temperature 0 30 225 1.0 0 255) ; make temperature more visible
		
		
		;Gradient Map Ice Cap
		(gimp-gradient-segment-set-middle-pos iceCapMap 0 0.30)
		(gimp-gradient-segment-set-left-color iceCapMap 0 '(0 0 0) 100) ;black
		(gimp-gradient-segment-set-right-color iceCapMap 0 '(255 255 255) 0) ;white
		(gimp-context-set-gradient iceCapMap)
		(plug-in-gradmap 0 newRegion iceCap)
		(gimp-invert iceCap)
		(gimp-levels iceCap 0 0 200 1.0 100 255) ;make ice cap brighter
		
		
		;Change levels to make final image look nicer
		(set! visible (car (gimp-layer-new-from-visible newRegion newRegion "Levels")))
		(gimp-image-add-layer newRegion visible 0)
		(gimp-levels visible 0 5 220 1.1 0 255)
		;(plug-in-blur 0 0 visible) ;blur the map to reduce sharp edges (off)
		
		;----------------Clean up---------------------
		
		(gimp-image-remove-layer newRegion biome)
		(gimp-image-delete waterImage)
		(gimp-image-delete elevationImage)
		(gimp-image-delete vegatationImage)
		(gimp-image-delete biomeImage)
		(gimp-image-delete volcanismImage)
		(gimp-image-delete temperatureImage)
		(gimp-image-delete treesImage)
		(gimp-image-delete dirtImage)
		(gimp-image-delete mountainsImage)
		(gimp-gradient-delete elevationMap)
		(gimp-gradient-delete vegatationMap)
		(gimp-gradient-delete riverMap)
		(gimp-gradient-delete temperatureMap)
		(gimp-gradient-delete iceCapMap)
		
		(list newRegion)
	)	
)
)

;Register the script with script-fu
(script-fu-register
	"create-view-satellite"
	"Create satellite DF map..."                
	"Creates a realistic satellite map from Dwarf Fortress' exported Maps"
	"GFXiNXS, convert to GIMP by Parker147, edited by CharonM72"	;author
	""				;copyright notice
	"May 9, 2011"	;date created
	""				;
	SF-STRING	"Elevation Water File -elw-"	"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\world_graphic-elw-region1-555-5588.bmp"
	SF-STRING	"Elevation File -el-"			"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\world_graphic-el-region1-555-5588.bmp"
	SF-STRING	"Vegatation File -veg-"			"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\world_graphic-veg-region1-555-5588.bmp"
	SF-STRING	"Volcanism File -vol-"			"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\world_graphic-vol-region1-555-5588.bmp"
	SF-STRING	"Temperature File -tmp-"		"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\world_graphic-tmp-region1-555-5588.bmp"
	SF-STRING	"Biome File -bm-"				"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\world_graphic-bm-region1-555-5588.bmp"
	SF-STRING	"Trees Texture File"			"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\sat_trees.bmp"
	SF-STRING	"Dirt Texture File"				"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\sat_dirt.bmp"
	SF-STRING	"Mountains Texture File"		"C:\\Program Files (x86)\\Dwarf Fortress\\PeridexisErrant LNP r48\\Dwarf Fortress 0.34.11\\sat_mountains.bmp"
	SF-STRING	"Atmosphere level (0-2)"		"1"
)

(script-fu-menu-register "create-view-satellite" "<Image>/File/Create/Dwarf Map")