import QtQuick 2.3

Item {

	// Text colour of labels in background (e.g., "Open File to Start" label)
	readonly property string bg_label: "#808080"

	// Standard border color
	readonly property string bordercolor: "#303030"

	// Standard text colour (enabled and disabled)
	readonly property string text: "#ffffff"
	readonly property string text_inactive: "#cccccc"
	readonly property string text_selection_color: "#ffffff"
	readonly property string text_selection_color_disabled: "#cccccc"
	readonly property string text_selected: "#000000"
	readonly property string warning: "#ff0000"
	readonly property string disabled: "#808080"

	// Fade-in/Slide-in elements colouring
	readonly property string fadein_slidein_bg: "#DD000000"
	readonly property string fadein_slidein_block_bg: "#55000000"
	readonly property string fadein_slidein_border: "#55bbbbbb"

	// Line colour used for seperating things in elements (e.g. bottom of settings)
	readonly property string linecolour: "#99999999"

	// Thumbnail elements colouring
	readonly property string thumbnails_bg: "#88000000"
	readonly property string thumbnails_border: "#BB000000"
	readonly property string thumbnails_filename_bg: "#88000000"

	// Tiles in settings
	readonly property string tiles_active: "#C8ffffff"
	readonly property string tiles_inactive: "#77ffffff"
	readonly property string tiles_disabled: "#33ffffff"
	readonly property string tiles_text_active: "#000000"
	readonly property string tiles_text_inactive: "#000000"
	readonly property string tiles_indicator_col: "#444444"
	readonly property string tiles_indicator_bg: "#22000000"

	// Context setting
	readonly property string context_header_bg: "#cccccc"
	readonly property string context_header_text: "#000000"

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

	// TabView colouring
	readonly property string tab_bg_color: "#33000000"
	readonly property string tab_color_active: "#96444444"
	readonly property string tab_color_inactive: "#96212121"
	readonly property string tab_color_selected: "#96676767"
	readonly property string tab_text_active: "#cccccc"
	readonly property string tab_text_inactive: "#969696"
	readonly property string tab_text_selected: "#ffffff"
	readonly property string subtab_bg_color: "#00000000"
	readonly property string subtab_line_top: "#969696"
	readonly property string subtab_line_bottom: "#969696"

	// CustomElements background/border (SpinBox)
	readonly property string element_bg_color: "#88000000"
	readonly property string element_bg_color_disabled: "#55000000"
	readonly property string element_border_color: "#99969696"
	readonly property string element_border_color_disabled: "#44969696"

	// CustomSlider
	readonly property string slider_groove_bg_color: "#ffffff"
	readonly property string slider_groove_bg_color_disabled: "#777777"
	readonly property string slider_handle_color_active: "#444444"
	readonly property string slider_handle_color_inactive: "#111111"
	readonly property string slider_handle_color_disabled: "#080808"
	readonly property string slider_handle_border_color: "#666666"
	readonly property string slider_handle_border_color_disabled: "#333333"

	// CustomRadioButton and CustomCheckBox
	readonly property string radio_check_indicator_color: "#ffffff"
	readonly property string radio_check_indicator_color_disabled: "#555555"
	readonly property string radio_check_indicator_bg_color: "#22FFFFFF"
	readonly property string radio_check_indicator_bg_color_disabled: "#22888888"

	// CustomComboBox
	readonly property string combo_dropdown_frame: "#bb000000"
	readonly property string combo_dropdown_frame_border: "#404040"
	readonly property string combo_dropdown_text: "#ffffff"
	readonly property string combo_dropdown_text_highlight: "#000000"
	readonly property string combo_dropdown_background: "#000000"
	readonly property string combo_dropdown_background_highlight: "#ffffff"

	// CustomButton
	readonly property string button_bg: "#22DDDDDD"
	readonly property string button_bg_hovered: "#44DDDDDD"
	readonly property string button_bg_pressed: "#66DDDDDD"
	readonly property string button_bg_disabled: "#11777777"
	readonly property string button_text: "#aacccccc"
	readonly property string button_text_active: "#aacccccc"
	readonly property string button_text_disabled: "#55cccccc"

}
