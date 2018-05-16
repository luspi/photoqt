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

#include "shortcuts.h"

Shortcuts::Shortcuts(QObject *parent) : QObject(parent) { }

QVariantList Shortcuts::load() {

    QVariantList ret;

    QFile file(ConfigFiles::SHORTCUTS_FILE());

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << " Shortcuts::load() - ERROR: Unable to open key shortcuts file for reading" << NL;
        return QVariantList();
    }

    QTextStream in(&file);
    QStringList cont = in.readAll().split("\n");

    for(QString line : cont) {

        if(line.startsWith("Version=") || line.trimmed() == "")
            continue;

        QStringList parts = line.split("::");
        if(parts.length() != 3) {
            LOG << CURDATE << " Shortcuts::load() - ERROR: Invalid shortcuts format: " << line.toStdString() << NL;
            continue;
        }

        // sh, close, cmd
        ret << parts.at(1) << parts.at(0) << parts.at(2);

    }

    file.close();

    return ret;

}

QVariantList Shortcuts::loadDefaults() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "Shortcuts::loadDefaults()" << NL;

    QVariantList ret;

    ret << "O" << "0" << "__open";
    ret << "Ctrl+O" << "0" << "__open";
    ret << "Right Button+WE" << "0" << "__open";

    ret << "Right" << "0" << "__next";
    ret << "Space" << "0" << "__next";
    ret << "Right Button+E" << "0" << "__next";
    ret << "Left" << "0" << "__prev";
    ret << "Backspace" << "0" << "__prev";
    ret << "Right Button+W" << "0" << "__prev";
    ret << "Ctrl+F" << "0" << "__filterImages";

    ret << "+" << "0" << "__zoomIn";
    ret << "=" << "0" << "__zoomIn";
    ret << "Ctrl++" << "0" << "__zoomIn";
    ret << "Ctrl+=" << "0" << "__zoomIn";
    ret << "Ctrl+Wheel Up" << "0" << "__zoomIn";
    ret << "Right Button+N" << "0" << "__zoomIn";
    ret << "-" << "0" << "__zoomOut";
    ret << "Ctrl+-" << "0" << "__zoomOut";
    ret << "Ctrl+Wheel Down" << "0" << "__zoomOut";
    ret << "Right Button+S" << "0" << "__zoomOut";
    ret << "0" << "0" << "__zoomReset";
    ret << "1" << "0" << "__zoomActual";
    ret << "Ctrl+1" << "0" << "__zoomActual";

    ret << "R" << "0" << "__rotateR";
    ret << "L" << "0" << "__rotateL";
    ret << "Ctrl+0" << "0" << "__rotate0";
    ret << "Ctrl+H" << "0" << "__flipH";
    ret << "Ctrl+V" << "0" << "__flipV";

    ret << "Ctrl+X" << "0" << "__scale";
    ret << "Ctrl+E" << "0" << "__hideMeta";
    ret << "P" << "0" << "__settings";
    ret << "I" << "0" << "__about";
    ret << "M" << "0" << "__slideshow";
    ret << "Shift+M" << "0" << "__slideshowQuick";
    ret << "W" << "0" << "__wallpaper";
    ret << "H" << "0" << "__histogram";

    ret << "F2" << "0" << "__rename";
    ret << "Ctrl+C" << "0" << "__copy";
    ret << "Ctrl+M" << "0" << "__move";
    ret << "Delete" << "0" << "__delete";

    ret << "Escape" << "0" << "__close";
    ret << "Q" << "0" << "__quit";
    ret << "Ctrl+Q" << "0" << "__quit";
    ret << "Right Button+SES" << "0" << "__close";

    ret << "Home" << "0" << "__gotoFirstThb";
    ret << "End" << "0" << "__gotoLastThb";

    return ret;

}

void Shortcuts::saveShortcuts(QVariantList data) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "Shortcuts::saveShortcuts() - # of shortcuts: " << data.length() << NL;

    QDir dir(ConfigFiles::CONFIG_DIR());
    if(!dir.exists())
        dir.mkpath(ConfigFiles::CONFIG_DIR());

    QFile file(ConfigFiles::SHORTCUTS_FILE());
    if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        LOG << CURDATE << "Shortcuts::saveShortcuts() - ERROR: unable to open shortcuts file for saving" << NL;
        return;
    }

    QTextStream out(&file);

    out << QString("Version=%1\n").arg(VERSION);

    // The -2 in the upper limit ensures that also the last entry has 3 entries available
    for(int i = 0; i < data.length()-2; i+=3) {

        QString key = data.at(i).toString();
        QString close = data.at(i+1).toString();
        QString cmd = data.at(i+2).toString();

        if(key != "" || close != "" || cmd != "")
            out << QString("%1::%2::%3\n").arg(close).arg(key).arg(cmd);

    }

    file.close();

}

QString Shortcuts::convertKeycodeToString(int code) {

    return QKeySequence(code).toString();

}
