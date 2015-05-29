import QtQuick 2.3

Item {

	// Text colour of labels in background (e.g., "Open File to Start" label)
	readonly property string bg_label: "#808080"

	// Standard text colour (enabled and disabled)
	readonly property string text: "#ffffff"
	readonly property string warning: "#ff0000"
	readonly property string bordercolor: "#303030"
	readonly property string disabled: "#808080"

	// Standard mainmenu text colour (active and inactive)
	readonly property string mainmenu_active: "#ffffff"
	readonly property string mainmenu_inactive: "#cccccc"

	// Fade-in elements colouring
	readonly property string fadein_bg: "#DD000000"
	readonly property string fadein_block_bg: "#55000000"
	readonly property string fadein_border: "#55bbbbbb"

	// Slide-in elements colouring
	readonly property string slidein_bg: "#BB000000"
	readonly property string slidein_border: "#55bbbbbb"

	// Line colour used for seperating things in elements (e.g. bottom of settings)
	readonly property string linecolour: "#99999999"

	// Thumbnail elements colouring
	readonly property string thumbnails_bg: "#88000000"
	readonly property string thumbnails_border: "#BB000000"
	readonly property string thumbnails_filename_bg: "#88000000"

	// Shortcuts tiles
	readonly property string tiles_active: "#88ffffff"
	readonly property string tiles_inactive: "#44ffffff"
	readonly property string tiles_text: "#000000"

	// Language tiles
	readonly property string lang_bg_active: "#C8ffffff"
	readonly property string lang_bg_inactive: "#77ffffff"
	readonly property string lang_text: "#000000"
	readonly property string lang_indicatorCol: "#444444"
	readonly property string lang_indicatorBg: "#22000000"

	// Context setting
	readonly property string context_header_bg: "#cccccc"
	readonly property string context_header_text: "#000000"
	readonly property string context_entry_bg: "#88000000"
	readonly property string context_entry_text: "#ffffff"

	// Filetype tiles
	readonly property string filetypes_bg_active: "#B8ffffff"
	readonly property string filetypes_bg_inactive: "#67ffffff"
	readonly property string filetypes_text_active: "#000000"
	readonly property string filetypes_text_inactive: "#222222"
	readonly property string filetypes_indicator_col: "#444444"
	readonly property string filetypes_indicator_bg: "#22000000"

	// Exif tyles
	readonly property string exif_bg_active: "#B8ffffff"
	readonly property string exif_bg_inactive: "#67ffffff"
	readonly property string exif_text_active: "#000000"
	readonly property string exif_text_inactive: "#222222"
	readonly property string exif_indicator_col: "#444444"
	readonly property string exif_indicator_bg: "#22000000"

	// Quickinfo
	readonly property string quickinfo_bg: "#55000000"
	readonly property string quickinfo_text: "#ffffff"

	// Rightclick menus (NOT including main Contextmenu!!)
	readonly property string menu_frame: "#0f0f0f"
	readonly property string menu_bg: "#0F0F0F"
	readonly property string menu_bg_highlight: "#4f4f4f"
	readonly property string menu_text: "#ffffff"
	readonly property string menu_text_highlight: ""

	// Contextmenu (on main view)
	readonly property string contextmenu_text_active: "#ffffff"
	readonly property string contextmenu_text_inactive: "#cccccc"
	readonly property string contextmenu_infotext: "#bbbbbb"

	// Slideshow specialities
	readonly property string slideshow_music_enabled: "#11999999"
	readonly property string slideshow_music_disabled: "#11ffffff"

}
