/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include "colour.h"

Colour::Colour(QObject *parent) : QObject(parent) {

    loadColors();

}

void Colour::setDefault() {

    // Text colour of labels in background (e.g., "Open File to Start" label)
    bg_label = "#808080";

    // Standard text colour (enabled and disabled)
    text = "#ffffff";
    text_inactive = "#cccccc";
    text_selection_color = "#ffffff";
    text_selection_color_disabled = "#cccccc";
    text_selected = "#000000";
    text_warning = "#ff0000";
    text_disabled = "#66707070";

    // Fade-in/Slide-in elements colouring
    fadein_slidein_bg = "#cc000000";
    fadein_slidein_block_bg = "#88000000";
    fadein_slidein_border = "#55bbbbbb";

    // Line colour used for seperating things in elements (e.g. bottom of settings)
    linecolour = "#99999999";

    // Thumbnail elements colouring
    thumbnails_bg = "#88000000";
    thumbnails_border = "#bb000000";
    thumbnails_filename_bg = "#88000000";

    // Tiles in settings
    tiles_active_hovered = "#99cccccc";
    tiles_active = "#77cccccc";
    tiles_inactive = "#55cccccc";
    tiles_disabled = "#44cccccc";
    tiles_text_active = "#bbffffff";
    tiles_text_inactive = "#bbffffff";
    tiles_indicator_col = "#dddddd";
    tiles_indicator_bg = "#22000000";

    // Quickinfo
    quickinfo_bg = "#55000000";
    quickinfo_text = "#ffffff";
    quickinfo_text_disabled = "#66707070";

    // Rightclick menus
    menu_frame = "#0f0f0f";
    menu_bg = "#0f0f0f";
    menu_bg_highlight = "#4f4f4f";
    menu_bg_highlight_disabled = "#2f2f2f";
    menu_text = "#ffffff";
    menu_text_disabled = "#88808080";

    // TabView colouring
    tab_bg_color = "#33000000";
    tab_color_active = "#96444444";
    tab_color_inactive = "#96212121";
    tab_color_selected = "#96676767";
    tab_text_active = "#cccccc";
    tab_text_inactive = "#969696";
    tab_text_selected = "#ffffff";
    subtab_bg_color = "#00000000";
    subtab_line_top = "#969696";
    subtab_line_bottom = "#969696";

    // CustomElements background/border (ComboBox/LineEdit//Spinbox)
    element_bg_color = "#aa000000";
    element_bg_color_disabled = "#66000000";
    element_border_color = "#99969696";
    element_border_color_disabled = "#44969696";

    // CustomSlider
    slider_groove_bg_color = "#ffffff";
    slider_groove_bg_color_disabled = "#777777";
    slider_handle_color_active = "#444444";
    slider_handle_color_inactive = "#111111";
    slider_handle_color_disabled = "#080808";
    slider_handle_border_color = "#666666";
    slider_handle_border_color_disabled = "#333333";

    // CustomRadioButton and CustomCheckBox
    radio_check_indicator_color = "#ffffff";
    radio_check_indicator_color_disabled = "#88555555";
    radio_check_indicator_bg_color = "#22ffffff";
    radio_check_indicator_bg_color_disabled = "#11808080";

    // CustomComboBox
    combo_dropdown_frame = "#bb000000";
    combo_dropdown_frame_border = "#404040";
    combo_dropdown_text = "#ffffff";
    combo_dropdown_text_highlight = "#000000";
    combo_dropdown_background = "#000000";
    combo_dropdown_background_highlight = "#ffffff";

    // CustomButton
    button_bg = "#99333333";
    button_bg_hovered = "#aa333333";
    button_bg_pressed = "#bb333333";
    button_bg_disabled = "#05777777";
    button_text = "#aacccccc";
    button_text_active = "#aacccccc";
    button_text_disabled = "#66707070";

    // ToolTip
    tooltip_bg = "#dd222222";
    tooltip_text = "#dddddddd";
    tooltip_warning = "#ddff0000";

    // Shortcuts
    shortcut_double_error = "#ff2200";
}

void Colour::saveColors() {

    QFile file(ConfigFiles::COLOR_FILE());

    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        LOG << CURDATE << "ERROR! Unable to open 'colors' file for saving: " << file.errorString().trimmed().toStdString() << NL;
        return;
    }

    QString txt = "";

    txt += QString("bg_label=%1\n\n").arg(bg_label);

    txt += QString("text=%1\n").arg(text);
    txt += QString("text_inactive=%1\n").arg(text_inactive);
    txt += QString("text_selection_color=%1\n").arg(text_selection_color);
    txt += QString("text_selection_color_disabled=%1\n").arg(text_selection_color_disabled);
    txt += QString("text_selected=%1\n").arg(text_selected);
    txt += QString("text_warning=%1\n").arg(text_warning);
    txt += QString("text_disabled=%1\n\n").arg(text_disabled);

    txt += QString("fadein_slidein_bg=%1\n").arg(fadein_slidein_bg);
    txt += QString("fadein_slidein_block_bg=%1\n").arg(fadein_slidein_block_bg);
    txt += QString("fadein_slidein_border=%1\n\n").arg(fadein_slidein_border);

    txt += QString("linecolour=%1\n\n").arg(linecolour);

    txt += QString("thumbnails_bg=%1\n").arg(thumbnails_bg);
    txt += QString("thumbnails_border=%1\n").arg(thumbnails_border);
    txt += QString("thumbnails_filename_bg=%1\n\n").arg(thumbnails_filename_bg);

    txt += QString("tiles_active_hovered=%1\n").arg(tiles_active_hovered);
    txt += QString("tiles_active=%1\n").arg(tiles_active);
    txt += QString("tiles_inactive=%1\n").arg(tiles_inactive);
    txt += QString("tiles_disabled=%1\n").arg(tiles_disabled);
    txt += QString("tiles_text_active=%1\n").arg(tiles_text_active);
    txt += QString("tiles_text_inactive=%1\n").arg(tiles_text_inactive);
    txt += QString("tiles_indicator_col=%1\n").arg(tiles_indicator_col);
    txt += QString("tiles_indicator_bg=%1\n\n").arg(tiles_indicator_bg);

    txt += QString("quickinfo_bg=%1\n").arg(quickinfo_bg);
    txt += QString("quickinfo_text=%1\n\n").arg(quickinfo_text);
    txt += QString("quickinfo_text_disabled=%1\n\n").arg(quickinfo_text_disabled);

    txt += QString("menu_frame=%1\n").arg(menu_frame);
    txt += QString("menu_bg=%1\n").arg(menu_bg);
    txt += QString("menu_bg_highlight=%1\n").arg(menu_bg_highlight);
    txt += QString("menu_bg_highlight_disabled=%1\n").arg(menu_bg_highlight_disabled);
    txt += QString("menu_text=%1\n").arg(menu_text);
    txt += QString("menu_text_disabled=%1\n\n").arg(menu_text_disabled);

    txt += QString("tab_bg_color=%1\n").arg(tab_bg_color);
    txt += QString("tab_color_active=%1\n").arg(tab_color_active);
    txt += QString("tab_color_inactive=%1\n").arg(tab_color_inactive);
    txt += QString("tab_color_selected=%1\n").arg(tab_color_selected);
    txt += QString("tab_text_active=%1\n").arg(tab_text_active);
    txt += QString("tab_text_inactive=%1\n").arg(tab_text_inactive);
    txt += QString("tab_text_selected=%1\n").arg(tab_text_selected);
    txt += QString("subtab_bg_color=%1\n").arg(subtab_bg_color);
    txt += QString("subtab_line_top=%1\n").arg(subtab_line_top);
    txt += QString("subtab_line_bottom=%1\n\n").arg(subtab_line_bottom);

    txt += QString("element_bg_color=%1\n").arg(element_bg_color);
    txt += QString("element_bg_color_disabled=%1\n").arg(element_bg_color_disabled);
    txt += QString("element_border_color=%1\n").arg(element_border_color);
    txt += QString("element_border_color_disabled=%1\n\n").arg(element_border_color_disabled);

    txt += QString("slider_groove_bg_color=%1\n").arg(slider_groove_bg_color);
    txt += QString("slider_groove_bg_color_disabled=%1\n").arg(slider_groove_bg_color_disabled);
    txt += QString("slider_handle_color_active=%1\n").arg(slider_handle_color_active);
    txt += QString("slider_handle_color_inactive=%1\n").arg(slider_handle_color_inactive);
    txt += QString("slider_handle_color_disabled=%1\n").arg(slider_handle_color_disabled);
    txt += QString("slider_handle_border_color=%1\n").arg(slider_handle_border_color);
    txt += QString("slider_handle_border_color_disabled=%1\n\n").arg(slider_handle_border_color_disabled);

    txt += QString("radio_check_indicator_color=%1\n").arg(radio_check_indicator_color);
    txt += QString("radio_check_indicator_color_disabled=%1\n").arg(radio_check_indicator_color_disabled);
    txt += QString("radio_check_indicator_bg_color=%1\n").arg(radio_check_indicator_bg_color);
    txt += QString("radio_check_indicator_bg_color_disabled=%1\n\n").arg(radio_check_indicator_bg_color_disabled);

    txt += QString("combo_dropdown_frame=%1\n").arg(combo_dropdown_frame);
    txt += QString("combo_dropdown_frame_border=%1\n").arg(combo_dropdown_frame_border);
    txt += QString("combo_dropdown_text=%1\n").arg(combo_dropdown_text);
    txt += QString("combo_dropdown_text_highlight=%1\n").arg(combo_dropdown_text_highlight);
    txt += QString("combo_dropdown_background=%1\n").arg(combo_dropdown_background);
    txt += QString("combo_dropdown_background_highlight=%1\n\n").arg(combo_dropdown_background_highlight);

    txt += QString("button_bg=%1\n").arg(button_bg);
    txt += QString("button_bg_hovered=%1\n").arg(button_bg_hovered);
    txt += QString("button_bg_pressed=%1\n").arg(button_bg_pressed);
    txt += QString("button_bg_disabled=%1\n").arg(button_bg_disabled);
    txt += QString("button_text=%1\n").arg(button_text);
    txt += QString("button_text_active=%1\n").arg(button_text_active);
    txt += QString("button_text_disabled=%1\n\n").arg(button_text_disabled);

    txt += QString("tooltip_bg=%1\n").arg(tooltip_bg);
    txt += QString("tooltip_text=%1\n\n").arg(tooltip_text);
    txt += QString("tooltip_warning=%1\n\n").arg(tooltip_warning);

    txt += QString("shortcut_double_error=%1\n").arg(shortcut_double_error);

    QTextStream out(&file);
    out << txt;
    file.close();

}

void Colour::loadColors() {

    setDefault();

    QFile file(ConfigFiles::COLOR_FILE());

    if(!file.exists())
        return;

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "ERROR! Unable to open and load colors from file: " << file.errorString().trimmed().toStdString() << NL;
        return;
    }

    QTextStream in(&file);
    QString line;
    do {

        line = in.readLine();

        if(line.contains("=") && !line.startsWith("#")) {

            QStringList parts = line.split("=");
            QString color = parts.at(1).trimmed();
            QString property = parts.at(0).trimmed();

            if(property == "bg_label")
                bg_label = color;

            else if(property == "text")
                text = color;
            else if(property == "text_inactive")
                text_inactive = color;
            else if(property == "text_selection_color")
                text_selection_color = color;
            else if(property == "text_selection_color_disabled")
                text_selection_color_disabled = color;
            else if(property == "text_selected")
                text_selected = color;
            else if(property == "text_warning")
                text_warning = color;
            else if(property == "text_disabled")
                text_disabled = color;

            else if(property == "fadein_slidein_bg")
                fadein_slidein_bg = color;
            else if(property == "fadein_slidein_block_bg")
                fadein_slidein_block_bg = color;
            else if(property == "fadein_slidein_border")
                fadein_slidein_border = color;

            else if(property == "linecolour")
                linecolour = color;

            else if(property == "thumbnails_bg")
                thumbnails_bg = color;
            else if(property == "thumbnails_border")
                thumbnails_border = color;
            else if(property == "thumbnails_filename_bg")
                thumbnails_filename_bg = color;

            else if(property == "tiles_active_hovered")
                tiles_active_hovered = color;
            else if(property == "tiles_active")
                tiles_active = color;
            else if(property == "tiles_inactive")
                tiles_inactive = color;
            else if(property == "tiles_disabled")
                tiles_disabled = color;
            else if(property == "tiles_text_active")
                tiles_text_active = color;
            else if(property == "tiles_text_inactive")
                tiles_text_inactive = color;
            else if(property == "tiles_indicator_col")
                tiles_indicator_col = color;
            else if(property == "tiles_indicator_bg")
                tiles_indicator_bg = color;

            else if(property == "quickinfo_bg")
                quickinfo_bg = color;
            else if(property == "quickinfo_text")
                quickinfo_text = color;
            else if(property == "quickinfo_text_disabled")
                quickinfo_text_disabled = color;

            else if(property == "menu_frame")
                menu_frame = color;
            else if(property == "menu_bg")
                menu_bg = color;
            else if(property == "menu_bg_highlight")
                menu_bg_highlight = color;
            else if(property == "menu_bg_highlight_disabled")
                menu_bg_highlight_disabled = color;
            else if(property == "menu_text")
                menu_text = color;
            else if(property == "menu_text_disabled")
                menu_text_disabled = color;

            else if(property == "tab_bg_color")
                tab_bg_color = color;
            else if(property == "tab_color_active")
                tab_color_active = color;
            else if(property == "tab_color_inactive")
                tab_color_inactive = color;
            else if(property == "tab_color_selected")
                tab_color_selected = color;
            else if(property == "tab_text_active")
                tab_text_active = color;
            else if(property == "tab_text_inactive")
                tab_text_inactive = color;
            else if(property == "tab_text_selected")
                tab_text_selected = color;
            else if(property == "subtab_bg_color")
                subtab_bg_color = color;
            else if(property == "subtab_line_top")
                subtab_line_top = color;
            else if(property == "subtab_line_bottom")
                subtab_line_bottom = color;

            else if(property == "element_bg_color")
                element_bg_color = color;
            else if(property == "element_bg_color_disabled")
                element_bg_color_disabled = color;
            else if(property == "element_border_color")
                element_border_color = color;
            else if(property == "element_border_color_disabled")
                element_border_color_disabled = color;

            else if(property == "slider_groove_bg_color")
                slider_groove_bg_color = color;
            else if(property == "slider_groove_bg_color_disabled")
                slider_groove_bg_color_disabled = color;
            else if(property == "slider_handle_color_active")
                slider_handle_color_active = color;
            else if(property == "slider_handle_color_inactive")
                slider_handle_color_inactive = color;
            else if(property == "slider_handle_color_disabled")
                slider_handle_color_disabled = color;
            else if(property == "slider_handle_border_color")
                slider_handle_border_color = color;
            else if(property == "slider_handle_border_color_disabled")
                slider_handle_border_color_disabled = color;

            else if(property == "radio_check_indicator_color")
                radio_check_indicator_color = color;
            else if(property == "radio_check_indicator_color_disabled")
                radio_check_indicator_color_disabled = color;
            else if(property == "radio_check_indicator_bg_color")
                radio_check_indicator_bg_color = color;
            else if(property == "radio_check_indicator_bg_color_disabled")
                radio_check_indicator_bg_color_disabled = color;

            else if(property == "combo_dropdown_frame")
                combo_dropdown_frame = color;
            else if(property == "combo_dropdown_frame_border")
                combo_dropdown_frame_border = color;
            else if(property == "combo_dropdown_text")
                combo_dropdown_text = color;
            else if(property == "combo_dropdown_text_highlight")
                combo_dropdown_text_highlight = color;
            else if(property == "combo_dropdown_background")
                combo_dropdown_background = color;
            else if(property == "combo_dropdown_background_highlight")
                combo_dropdown_background_highlight = color;

            else if(property == "button_bg")
                button_bg = color;
            else if(property == "button_bg_hovered")
                button_bg_hovered = color;
            else if(property == "button_bg_pressed")
                button_bg_pressed = color;
            else if(property == "button_bg_disabled")
                button_bg_disabled = color;
            else if(property == "button_text")
                button_text = color;
            else if(property == "button_text_active")
                button_text_active = color;
            else if(property == "button_text_disabled")
                button_text_disabled = color;

            else if(property == "tooltip_bg")
                tooltip_bg = color;
            else if(property == "tooltip_text")
                tooltip_text = color;
            else if(property == "tooltip_warning")
                tooltip_warning = color;

            else if(property == "shortcut_double_error")
                shortcut_double_error = color;

        }

    } while(!line.isNull());

}
