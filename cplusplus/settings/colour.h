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

#ifndef COLOUR_H
#define COLOUR_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QTextStream>

#include "../logger.h"

class Colour : public QObject {

    Q_OBJECT

public:
    explicit Colour(QObject *parent = nullptr);

    Q_PROPERTY(QString bg_label MEMBER bg_label NOTIFY bg_labelChanged)

    Q_PROPERTY(QString text MEMBER text NOTIFY textChanged)
    Q_PROPERTY(QString text_inactive MEMBER text_inactive NOTIFY text_inactiveChanged)
    Q_PROPERTY(QString text_selection_color MEMBER text_selection_color NOTIFY text_selection_colorChanged)
    Q_PROPERTY(QString text_selection_color_disabled MEMBER text_selection_color_disabled NOTIFY text_selection_color_disabledChanged)
    Q_PROPERTY(QString text_selected MEMBER text_selected NOTIFY text_selectedChanged)
    Q_PROPERTY(QString text_warning MEMBER text_warning NOTIFY text_warningChanged)
    Q_PROPERTY(QString text_disabled MEMBER text_disabled NOTIFY text_disabledChanged)

    Q_PROPERTY(QString fadein_slidein_bg MEMBER fadein_slidein_bg NOTIFY fadein_slidein_bgChanged)
    Q_PROPERTY(QString fadein_slidein_block_bg MEMBER fadein_slidein_block_bg NOTIFY fadein_slidein_block_bgChanged)
    Q_PROPERTY(QString fadein_slidein_border MEMBER fadein_slidein_border NOTIFY fadein_slidein_borderChanged)

    Q_PROPERTY(QString linecolour MEMBER linecolour NOTIFY linecolourChanged)

    Q_PROPERTY(QString thumbnails_bg MEMBER thumbnails_bg NOTIFY thumbnails_bgChanged)
    Q_PROPERTY(QString thumbnails_border MEMBER thumbnails_border NOTIFY thumbnails_borderChanged)
    Q_PROPERTY(QString thumbnails_filename_bg MEMBER thumbnails_filename_bg NOTIFY thumbnails_filename_bgChanged)

    Q_PROPERTY(QString tiles_active_hovered MEMBER tiles_active_hovered NOTIFY tiles_active_hoveredChanged)
    Q_PROPERTY(QString tiles_active MEMBER tiles_active NOTIFY tiles_activeChanged)
    Q_PROPERTY(QString tiles_inactive MEMBER tiles_inactive NOTIFY tiles_inactiveChanged)
    Q_PROPERTY(QString tiles_disabled MEMBER tiles_disabled NOTIFY tiles_disabledChanged)
    Q_PROPERTY(QString tiles_text_active MEMBER tiles_text_active NOTIFY tiles_text_activeChanged)
    Q_PROPERTY(QString tiles_text_inactive MEMBER tiles_text_inactive NOTIFY tiles_text_inactiveChanged)
    Q_PROPERTY(QString tiles_indicator_col MEMBER tiles_indicator_col NOTIFY tiles_indicator_colChanged)
    Q_PROPERTY(QString tiles_indicator_bg MEMBER tiles_indicator_bg NOTIFY tiles_indicator_bgChanged)

    Q_PROPERTY(QString quickinfo_bg MEMBER quickinfo_bg NOTIFY quickinfo_bgChanged)
    Q_PROPERTY(QString quickinfo_text MEMBER quickinfo_text NOTIFY quickinfo_textChanged)
    Q_PROPERTY(QString quickinfo_text_disabled MEMBER quickinfo_text_disabled NOTIFY quickinfo_text_disabledChanged)

    Q_PROPERTY(QString menu_frame MEMBER menu_frame NOTIFY menu_frameChanged)
    Q_PROPERTY(QString menu_bg MEMBER menu_bg NOTIFY menu_bgChanged)
    Q_PROPERTY(QString menu_bg_highlight MEMBER menu_bg_highlight NOTIFY menu_bg_highlightChanged)
    Q_PROPERTY(QString menu_bg_highlight_disabled MEMBER menu_bg_highlight_disabled NOTIFY menu_bg_highlight_disabledChanged)
    Q_PROPERTY(QString menu_text MEMBER menu_text NOTIFY menu_textChanged)
    Q_PROPERTY(QString menu_text_disabled MEMBER menu_text_disabled NOTIFY menu_text_disabledChanged)

    Q_PROPERTY(QString tab_bg_color MEMBER tab_bg_color NOTIFY tab_bg_colorChanged)
    Q_PROPERTY(QString tab_color_active MEMBER tab_color_active NOTIFY tab_color_activeChanged)
    Q_PROPERTY(QString tab_color_inactive MEMBER tab_color_inactive NOTIFY tab_color_inactiveChanged)
    Q_PROPERTY(QString tab_color_selected MEMBER tab_color_selected NOTIFY tab_color_selectedChanged)
    Q_PROPERTY(QString tab_text_active MEMBER tab_text_active NOTIFY tab_text_activeChanged)
    Q_PROPERTY(QString tab_text_inactive MEMBER tab_text_inactive NOTIFY tab_text_inactiveChanged)
    Q_PROPERTY(QString tab_text_selected MEMBER tab_text_selected NOTIFY tab_text_selectedChanged)
    Q_PROPERTY(QString subtab_bg_color MEMBER subtab_bg_color NOTIFY subtab_bg_colorChanged)
    Q_PROPERTY(QString subtab_line_top MEMBER subtab_line_top NOTIFY subtab_line_topChanged)
    Q_PROPERTY(QString subtab_line_bottom MEMBER subtab_line_bottom NOTIFY subtab_line_bottomChanged)

    Q_PROPERTY(QString element_bg_color MEMBER element_bg_color NOTIFY element_bg_colorChanged)
    Q_PROPERTY(QString element_bg_color_disabled MEMBER element_bg_color_disabled NOTIFY element_bg_color_disabledChanged)
    Q_PROPERTY(QString element_border_color MEMBER element_border_color NOTIFY element_border_colorChanged)
    Q_PROPERTY(QString element_border_color_disabled MEMBER element_border_color_disabled NOTIFY element_border_color_disabledChanged)

    Q_PROPERTY(QString slider_groove_bg_color MEMBER slider_groove_bg_color NOTIFY slider_groove_bg_colorChanged)
    Q_PROPERTY(QString slider_groove_bg_color_disabled MEMBER slider_groove_bg_color_disabled NOTIFY slider_groove_bg_color_disabledChanged)
    Q_PROPERTY(QString slider_handle_color_active MEMBER slider_handle_color_active NOTIFY slider_handle_color_activeChanged)
    Q_PROPERTY(QString slider_handle_color_inactive MEMBER slider_handle_color_inactive NOTIFY slider_handle_color_inactiveChanged)
    Q_PROPERTY(QString slider_handle_color_disabled MEMBER slider_handle_color_disabled NOTIFY slider_handle_color_disabledChanged)
    Q_PROPERTY(QString slider_handle_border_color MEMBER slider_handle_border_color NOTIFY slider_handle_border_colorChanged)
    Q_PROPERTY(QString slider_handle_border_color_disabled MEMBER slider_handle_border_color_disabled
                                                                                                NOTIFY slider_handle_border_color_disabledChanged)

    Q_PROPERTY(QString radio_check_indicator_color MEMBER radio_check_indicator_color NOTIFY radio_check_indicator_colorChanged)
    Q_PROPERTY(QString radio_check_indicator_color_disabled MEMBER radio_check_indicator_color_disabled
                                                                                                NOTIFY radio_check_indicator_color_disabledChanged)
    Q_PROPERTY(QString radio_check_indicator_bg_color MEMBER radio_check_indicator_bg_color NOTIFY radio_check_indicator_bg_colorChanged)
    Q_PROPERTY(QString radio_check_indicator_bg_color_disabled MEMBER radio_check_indicator_bg_color_disabled
                                                                                                NOTIFY radio_check_indicator_bg_color_disabledChanged)

    Q_PROPERTY(QString combo_dropdown_frame MEMBER combo_dropdown_frame NOTIFY combo_dropdown_frameChanged)
    Q_PROPERTY(QString combo_dropdown_frame_border MEMBER combo_dropdown_frame_border NOTIFY combo_dropdown_frame_borderChanged)
    Q_PROPERTY(QString combo_dropdown_text MEMBER combo_dropdown_text NOTIFY combo_dropdown_textChanged)
    Q_PROPERTY(QString combo_dropdown_text_highlight MEMBER combo_dropdown_text_highlight NOTIFY combo_dropdown_text_highlightChanged)
    Q_PROPERTY(QString combo_dropdown_background MEMBER combo_dropdown_background NOTIFY combo_dropdown_backgroundChanged)
    Q_PROPERTY(QString combo_dropdown_background_highlight MEMBER combo_dropdown_background_highlight
                                                                                                NOTIFY combo_dropdown_background_highlightChanged)

    Q_PROPERTY(QString button_bg MEMBER button_bg NOTIFY button_bgChanged)
    Q_PROPERTY(QString button_bg_hovered MEMBER button_bg_hovered NOTIFY button_bg_hoveredChanged)
    Q_PROPERTY(QString button_bg_pressed MEMBER button_bg_pressed NOTIFY button_bg_pressedChanged)
    Q_PROPERTY(QString button_bg_disabled MEMBER button_bg_disabled NOTIFY button_bg_disabledChanged)
    Q_PROPERTY(QString button_text MEMBER button_text NOTIFY button_textChanged)
    Q_PROPERTY(QString button_text_active MEMBER button_text_active NOTIFY button_text_activeChanged)
    Q_PROPERTY(QString button_text_disabled MEMBER button_text_disabled NOTIFY button_text_disabledChanged)

    Q_PROPERTY(QString tooltip_bg MEMBER tooltip_bg NOTIFY tooltip_bgChanged)
    Q_PROPERTY(QString tooltip_text MEMBER tooltip_text NOTIFY tooltip_textChanged)
    Q_PROPERTY(QString tooltip_warning MEMBER tooltip_warning NOTIFY tooltip_warningChanged)

    Q_PROPERTY(QString shortcut_double_error MEMBER shortcut_double_error NOTIFY shortcut_double_errorChanged)


    // Text colour of labels in background (e.g., "Open File to Start" label)
    QString bg_label;

    // Standard text colour (enabled and disabled)
    QString text;
    QString text_inactive;
    QString text_selection_color;
    QString text_selection_color_disabled;
    QString text_selected;
    QString text_warning;
    QString text_disabled;

    // Fade-in/Slide-in elements colouring
    QString fadein_slidein_bg;
    QString fadein_slidein_block_bg;
    QString fadein_slidein_border;

    // Line colour used for seperating things in elements (e.g. bottom of settings)
    QString linecolour;

    // Thumbnail elements colouring
    QString thumbnails_bg;
    QString thumbnails_border;
    QString thumbnails_filename_bg;

    // Tiles in settings
    QString tiles_active_hovered;
    QString tiles_active;
    QString tiles_inactive;
    QString tiles_disabled;
    QString tiles_text_active;
    QString tiles_text_inactive;
    QString tiles_indicator_col;
    QString tiles_indicator_bg;

    // Quickinfo
    QString quickinfo_bg;
    QString quickinfo_text;
    QString quickinfo_text_disabled;

    // Rightclick menus
    QString menu_frame;
    QString menu_bg;
    QString menu_bg_highlight;
    QString menu_bg_highlight_disabled;
    QString menu_text;
    QString menu_text_disabled;

    // TabView colouring
    QString tab_bg_color;
    QString tab_color_active;
    QString tab_color_inactive;
    QString tab_color_selected;
    QString tab_text_active;
    QString tab_text_inactive;
    QString tab_text_selected;
    QString subtab_bg_color;
    QString subtab_line_top;
    QString subtab_line_bottom;

    // CustomElements background/border (ComboBox/LineEdit//Spinbox)
    QString element_bg_color;
    QString element_bg_color_disabled;
    QString element_border_color;
    QString element_border_color_disabled;

    // CustomSlider
    QString slider_groove_bg_color;
    QString slider_groove_bg_color_disabled;
    QString slider_handle_color_active;
    QString slider_handle_color_inactive;
    QString slider_handle_color_disabled;
    QString slider_handle_border_color;
    QString slider_handle_border_color_disabled;

    // CustomRadioButton and CustomCheckBox
    QString radio_check_indicator_color;
    QString radio_check_indicator_color_disabled;
    QString radio_check_indicator_bg_color;
    QString radio_check_indicator_bg_color_disabled;

    // CustomComboBox
    QString combo_dropdown_frame;
    QString combo_dropdown_frame_border;
    QString combo_dropdown_text;
    QString combo_dropdown_text_highlight;
    QString combo_dropdown_background;
    QString combo_dropdown_background_highlight;

    // CustomButton
    QString button_bg;
    QString button_bg_hovered;
    QString button_bg_pressed;
    QString button_bg_disabled;
    QString button_text;
    QString button_text_active;
    QString button_text_disabled;

    // ToolTip
    QString tooltip_bg;
    QString tooltip_text;
    QString tooltip_warning;

    // Shortcuts
    QString shortcut_double_error;

public slots:

    void setDefault();
    void saveColors();
    void loadColors();

signals:
    void bg_labelChanged(QString val);
    void textChanged(QString val);
    void text_inactiveChanged(QString val);
    void text_selection_colorChanged(QString val);
    void text_selection_color_disabledChanged(QString val);
    void text_selectedChanged(QString val);
    void text_warningChanged(QString val);
    void text_disabledChanged(QString val);
    void fadein_slidein_bgChanged(QString val);
    void fadein_slidein_block_bgChanged(QString val);
    void fadein_slidein_borderChanged(QString val);
    void linecolourChanged(QString val);
    void thumbnails_bgChanged(QString val);
    void thumbnails_borderChanged(QString val);
    void thumbnails_filename_bgChanged(QString val);
    void tiles_active_hoveredChanged(QString val);
    void tiles_activeChanged(QString val);
    void tiles_inactiveChanged(QString val);
    void tiles_disabledChanged(QString val);
    void tiles_text_activeChanged(QString val);
    void tiles_text_inactiveChanged(QString val);
    void tiles_indicator_colChanged(QString val);
    void tiles_indicator_bgChanged(QString val);
    void quickinfo_bgChanged(QString val);
    void quickinfo_textChanged(QString val);
    void quickinfo_text_disabledChanged(QString val);
    void menu_frameChanged(QString val);
    void menu_bgChanged(QString val);
    void menu_bg_highlightChanged(QString val);
    void menu_bg_highlight_disabledChanged(QString val);
    void menu_textChanged(QString val);
    void menu_text_disabledChanged(QString val);
    void tab_bg_colorChanged(QString val);
    void tab_color_activeChanged(QString val);
    void tab_color_inactiveChanged(QString val);
    void tab_color_selectedChanged(QString val);
    void tab_text_activeChanged(QString val);
    void tab_text_inactiveChanged(QString val);
    void tab_text_selectedChanged(QString val);
    void subtab_bg_colorChanged(QString val);
    void subtab_line_topChanged(QString val);
    void subtab_line_bottomChanged(QString val);
    void element_bg_colorChanged(QString val);
    void element_bg_color_disabledChanged(QString val);
    void element_border_colorChanged(QString val);
    void element_border_color_disabledChanged(QString val);
    void slider_groove_bg_colorChanged(QString val);
    void slider_groove_bg_color_disabledChanged(QString val);
    void slider_handle_color_activeChanged(QString val);
    void slider_handle_color_inactiveChanged(QString val);
    void slider_handle_color_disabledChanged(QString val);
    void slider_handle_border_colorChanged(QString val);
    void slider_handle_border_color_disabledChanged(QString val);
    void radio_check_indicator_colorChanged(QString val);
    void radio_check_indicator_color_disabledChanged(QString val);
    void radio_check_indicator_bg_colorChanged(QString val);
    void radio_check_indicator_bg_color_disabledChanged(QString val);
    void combo_dropdown_frameChanged(QString val);
    void combo_dropdown_frame_borderChanged(QString val);
    void combo_dropdown_textChanged(QString val);
    void combo_dropdown_text_highlightChanged(QString val);
    void combo_dropdown_backgroundChanged(QString val);
    void combo_dropdown_background_highlightChanged(QString val);
    void button_bgChanged(QString val);
    void button_bg_hoveredChanged(QString val);
    void button_bg_pressedChanged(QString val);
    void button_bg_disabledChanged(QString val);
    void button_textChanged(QString val);
    void button_text_activeChanged(QString val);
    void button_text_disabledChanged(QString val);
    void tooltip_bgChanged(QString val);
    void tooltip_textChanged(QString val);
    void tooltip_warningChanged(QString val);
    void shortcut_double_errorChanged(QString val);

};

#endif // COLOUR_H
