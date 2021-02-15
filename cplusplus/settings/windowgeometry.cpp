/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#include "windowgeometry.h"

PQWindowGeometry::PQWindowGeometry(QObject *parent) : QObject(parent) {

    int sw = handlingExternal.getScreenSize().width();
    int sh = handlingExternal.getScreenSize().height();

    int w, h;

    m_mainWindowMaximized = false;
    w = 1280; h = 960;
    m_mainWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_fileDialogWindowMaximized = false;
    w = 1200; h = 800;
    m_fileDialogWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_mainMenuWindowMaximized = false;
    m_mainMenuWindowGeometry = QRect(sw-400, 0, 400, 700);

    m_metaDataWindowMaximized = false;
    m_metaDataWindowGeometry = QRect(0, 0, 400, 700);

    m_histogramWindowMaximized = false;
    m_histogramWindowGeometry = QRect(100, 100, 300, 200);

    m_slideshowWindowMaximized = false;
    w = 1024; h = 768;
    m_slideshowWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_slideshowControlsWindowMaximized = false;
    m_slideshowControlsWindowGeometry = QRect(0, 0, 200, 200);

    m_fileRenameWindowMaximized = false;
    w = 400; h = 300;
    m_fileRenameWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_fileDeleteWindowMaximized = false;
    w = 400; h = 300;
    m_fileDeleteWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_scaleWindowMaximized = false;
    w = 800; h = 600;
    m_scaleWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_aboutWindowMaximized = false;
    w = 600; h = 480;
    m_aboutWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_imgurWindowMaximized = false;
    w = 800; h = 600;
    m_imgurWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_wallpaperWindowMaximized = false;
    w = 800; h = 600;
    m_wallpaperWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_filterWindowMaximized = false;
    w = 600; h = 480;
    m_filterWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_settingsManagerWindowMaximized = false;
    w = 1100; h = 768;
    m_settingsManagerWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_fileSaveAsWindowMaximized = false;
    w = 800; h = 600;
    m_fileSaveAsWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    m_unavailableWindowMaximized = false;
    w = 400; h = 300;
    m_unavailableWindowGeometry = QRect((sw-w)/2.0, (sh-h)/2.0, w, h);

    settings = new QSettings(ConfigFiles::WINDOW_GEOMETRY_FILE(), QSettings::IniFormat);

    readGeometries();

}

PQWindowGeometry::~PQWindowGeometry() {
    delete settings;
}

void PQWindowGeometry::readGeometries() {

    DBG << CURDATE << "PQWindowGeometry::readGeometries()" << NL;

    if(settings->allKeys().contains("mainWindowGeometry"))
        m_mainWindowGeometry = settings->value("mainWindowGeometry").toRect();
    if(settings->allKeys().contains("mainWindowMaximized"))
        m_mainWindowMaximized = settings->value("mainWindowMaximized").toBool();

    if(settings->allKeys().contains("fileDialogWindowGeometry"))
        m_fileDialogWindowGeometry = settings->value("fileDialogWindowGeometry").toRect();
    if(settings->allKeys().contains("fileDialogWindowMaximized"))
        m_fileDialogWindowMaximized = settings->value("fileDialogWindowMaximized").toBool();

    if(settings->allKeys().contains("mainMenuWindowGeometry"))
        m_mainMenuWindowGeometry = settings->value("mainMenuWindowGeometry").toRect();
    if(settings->allKeys().contains("mainMenuWindowMaximized"))
        m_mainMenuWindowMaximized = settings->value("mainMenuWindowMaximized").toBool();

    if(settings->allKeys().contains("metaDataWindowGeometry"))
        m_metaDataWindowGeometry = settings->value("metaDataWindowGeometry").toRect();
    if(settings->allKeys().contains("metaDataWindowMaximized"))
        m_metaDataWindowMaximized = settings->value("metaDataWindowMaximized").toBool();

    if(settings->allKeys().contains("histogramWindowGeometry"))
        m_histogramWindowGeometry = settings->value("histogramWindowGeometry").toRect();
    if(settings->allKeys().contains("histogramWindowMaximized"))
        m_histogramWindowMaximized = settings->value("histogramWindowMaximized").toBool();

    if(settings->allKeys().contains("slideshowWindowGeometry"))
        m_slideshowWindowGeometry = settings->value("slideshowWindowGeometry").toRect();
    if(settings->allKeys().contains("slideshowWindowMaximized"))
        m_slideshowWindowMaximized = settings->value("slideshowWindowMaximized").toBool();

    if(settings->allKeys().contains("slideshowControlsWindowGeometry"))
        m_slideshowControlsWindowGeometry = settings->value("slideshowControlsWindowGeometry").toRect();
    if(settings->allKeys().contains("slideshowControlsWindowMaximized"))
        m_slideshowControlsWindowMaximized = settings->value("slideshowControlsWindowMaximized").toBool();

    if(settings->allKeys().contains("fileRenameWindowGeometry"))
        m_fileRenameWindowGeometry = settings->value("fileRenameWindowGeometry").toRect();
    if(settings->allKeys().contains("fileRenameWindowMaximized"))
        m_fileRenameWindowMaximized = settings->value("fileRenameWindowMaximized").toBool();

    if(settings->allKeys().contains("fileDeleteWindowGeometry"))
        m_fileDeleteWindowGeometry = settings->value("fileDeleteWindowGeometry").toRect();
    if(settings->allKeys().contains("fileDeleteWindowMaximized"))
        m_fileDeleteWindowMaximized = settings->value("fileDeleteWindowMaximized").toBool();

    if(settings->allKeys().contains("scaleWindowGeometry"))
        m_scaleWindowGeometry = settings->value("scaleWindowGeometry").toRect();
    if(settings->allKeys().contains("scaleWindowMaximized"))
        m_scaleWindowMaximized = settings->value("scaleWindowMaximized").toBool();

    if(settings->allKeys().contains("aboutWindowGeometry"))
        m_aboutWindowGeometry = settings->value("aboutWindowGeometry").toRect();
    if(settings->allKeys().contains("aboutWindowMaximized"))
        m_aboutWindowMaximized = settings->value("aboutWindowMaximized").toBool();

    if(settings->allKeys().contains("imgurWindowGeometry"))
        m_imgurWindowGeometry = settings->value("imgurWindowGeometry").toRect();
    if(settings->allKeys().contains("imgurWindowMaximized"))
        m_imgurWindowMaximized = settings->value("imgurWindowMaximized").toBool();

    if(settings->allKeys().contains("wallpaperWindowGeometry"))
        m_wallpaperWindowGeometry = settings->value("wallpaperWindowGeometry").toRect();
    if(settings->allKeys().contains("wallpaperWindowMaximized"))
        m_wallpaperWindowMaximized = settings->value("wallpaperWindowMaximized").toBool();

    if(settings->allKeys().contains("filterWindowGeometry"))
        m_filterWindowGeometry = settings->value("filterWindowGeometry").toRect();
    if(settings->allKeys().contains("filterWindowMaximized"))
        m_filterWindowMaximized = settings->value("filterWindowMaximized").toBool();

    if(settings->allKeys().contains("settingsManagerWindowGeometry"))
        m_settingsManagerWindowGeometry = settings->value("settingsManagerWindowGeometry").toRect();
    if(settings->allKeys().contains("settingsManagerWindowMaximized"))
        m_settingsManagerWindowMaximized = settings->value("settingsManagerWindowMaximized").toBool();

    if(settings->allKeys().contains("fileSaveAsWindowGeometry"))
        m_fileSaveAsWindowGeometry = settings->value("fileSaveAsWindowGeometry").toRect();
    if(settings->allKeys().contains("fileSaveAsWindowMaximized"))
        m_fileSaveAsWindowMaximized = settings->value("fileSaveAsWindowMaximized").toBool();

    if(settings->allKeys().contains("unavailableWindowGeometry"))
        m_unavailableWindowGeometry = settings->value("unavailableWindowGeometry").toRect();
    if(settings->allKeys().contains("unavailableWindowMaximized"))
        m_unavailableWindowMaximized = settings->value("unavailableWindowMaximized").toBool();

}

void PQWindowGeometry::saveGeometries() {

    DBG << CURDATE << "PQWindowGeometry::saveGeometries()" << NL;

    settings->setValue("mainWindowGeometry", m_mainWindowGeometry);
    settings->setValue("mainWindowMaximized", m_mainWindowMaximized);

    settings->setValue("fileDialogWindowGeometry", m_fileDialogWindowGeometry);;
    settings->setValue("fileDialogWindowMaximized", m_fileDialogWindowMaximized);

    settings->setValue("mainMenuWindowGeometry", m_mainMenuWindowGeometry);;
    settings->setValue("mainMenuWindowMaximized", m_mainMenuWindowMaximized);

    settings->setValue("metaDataWindowGeometry", m_metaDataWindowGeometry);;
    settings->setValue("metaDataWindowMaximized", m_metaDataWindowMaximized);

    settings->setValue("histogramWindowGeometry", m_histogramWindowGeometry);;
    settings->setValue("histogramWindowMaximized", m_histogramWindowMaximized);

    settings->setValue("slideshowWindowGeometry", m_slideshowWindowGeometry);;
    settings->setValue("slideshowWindowMaximized", m_slideshowWindowMaximized);

    settings->setValue("slideshowControlsWindowGeometry", m_slideshowControlsWindowGeometry);
    settings->setValue("slideshowControlsWindowMaximized", m_slideshowControlsWindowMaximized);

    settings->setValue("fileRenameWindowGeometry", m_fileRenameWindowGeometry);
    settings->setValue("fileRenameWindowMaximized", m_fileRenameWindowMaximized);

    settings->setValue("fileDeleteWindowGeometry", m_fileDeleteWindowGeometry);
    settings->setValue("fileDeleteWindowMaximized", m_fileDeleteWindowMaximized);

    settings->setValue("scaleWindowGeometry", m_scaleWindowGeometry);
    settings->setValue("scaleWindowMaximized", m_scaleWindowMaximized);

    settings->setValue("aboutWindowGeometry", m_aboutWindowGeometry);
    settings->setValue("aboutWindowMaximized", m_aboutWindowMaximized);

    settings->setValue("imgurWindowGeometry", m_imgurWindowGeometry);
    settings->setValue("imgurWindowMaximized", m_imgurWindowMaximized);

    settings->setValue("wallpaperWindowGeometry", m_wallpaperWindowGeometry);
    settings->setValue("wallpaperWindowMaximized", m_wallpaperWindowMaximized);

    settings->setValue("filterWindowGeometry", m_filterWindowGeometry);
    settings->setValue("filterWindowMaximized", m_filterWindowMaximized);

    settings->setValue("settingsManagerWindowGeometry", m_settingsManagerWindowGeometry);
    settings->setValue("settingsManagerWindowMaximized", m_settingsManagerWindowMaximized);

    settings->setValue("fileSaveAsWindowGeometry", m_fileSaveAsWindowGeometry);
    settings->setValue("fileSaveAsWindowMaximized", m_fileSaveAsWindowMaximized);

    settings->setValue("unavailableWindowGeometry", m_unavailableWindowGeometry);
    settings->setValue("unavailableWindowMaximized", m_unavailableWindowMaximized);

}
