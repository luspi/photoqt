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

#include "file.h"

GetAndDoStuffFile::GetAndDoStuffFile(QObject *parent) : QObject(parent) { }
GetAndDoStuffFile::~GetAndDoStuffFile() { }

QString GetAndDoStuffFile::getFilenameQtImage() {

    return QFileDialog::getOpenFileName(0,tr("Please select image file"),QDir::homePath());

}

QString GetAndDoStuffFile::getFilename(QString caption, QString dir, QString filter) {

    return QFileDialog::getOpenFileName(0, caption, dir, filter);

}

QByteArray GetAndDoStuffFile::toPercentEncoding(QByteArray file) {

    if(file.startsWith("image://full/"))
        return ("image://full/" + file.remove(0,13).toPercentEncoding());

    else if(file.startsWith("image://thumb/"))
        return ("image://thumb/" + file.remove(0,14).toPercentEncoding());

    else if(file.startsWith("image://icon/"))
        return ("image://icon/" + file.remove(0,13).toPercentEncoding());

    else if(file.startsWith("qrc:/"))
        return ("qrc:/" + file.remove(0,5).toPercentEncoding());

    else if(file.startsWith("file:/"))
        return ("file:/" + file.remove(0,6).toPercentEncoding());

    return file.toPercentEncoding();

}

// Search for the file path of the icons in the hicolor theme (used by contextmenu)
QString GetAndDoStuffFile::getIconPathFromTheme(QString binary) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffFile::getIconPathFromTheme() - " << binary.toStdString() << NL;

    // We go through all the themeSearchPath elements
    for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

        // Setup path (this is the most likely directory) and format (PNG)
        QString path = QIcon::themeSearchPaths().at(i) + "/hicolor/32x32/apps/" + binary.trimmed() + ".png";
        if(QFile(path).exists())
            return "file:" + path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" + path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" + path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file:" + path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file:" + path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file:" + path;
            }
        }
    }

    // Nothing found
    return "";

}

QString GetAndDoStuffFile::getSaveFilename(QString caption, QString file) {

    return QFileDialog::getSaveFileName(0, caption, file);

}

QString GetAndDoStuffFile::removePathFromFilename(QString path, bool removeSuffix) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);
    else if(path.startsWith("image://full/"))
        path = path.remove(0,13);

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.remove(0,1);
#endif

    QFileInfo info(path);

    if(info.isDir())
        return "";

    if(removeSuffix)
        return info.baseName();
    return info.fileName();

}

QString GetAndDoStuffFile::removeFilenameFromPath(QString file) {

    if(file.startsWith("file:/"))
        file = file.remove(0,6);
    else if(file.startsWith("image://full/"))
        file = file.remove(0,13);

#ifdef Q_OS_WIN
    while(file.startsWith("/"))
        file = file.remove(0,1);
#endif

    // If filename is actually a directory already, simple return full path
    QFileInfo info(file);
    if(info.isDir()) return file;

    // else return absolute path
    return info.absolutePath();

}

QString GetAndDoStuffFile::getSuffix(QString file) {

    return QFileInfo(file).suffix();

}

bool GetAndDoStuffFile::doesThisExist(QString path) {

    if(path.startsWith("file:/"))
        path = path.remove(0,6);
    else if(path.startsWith("image://full/"))
        path = path.remove(0,13);

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.remove(0,1);
#endif

    return QFileInfo(path).exists();

}

QString GetAndDoStuffFile::getMimeType(QString dir, QString file) {

    if(file.contains("::PQT1::") && file.contains("::PQT2::"))
        file = file.split("::PQT1::").at(0)+file.split("::PQT2::").at(1);

    QFileInfo info(file);
    if(!info.isAbsolute())
        info.setFile(dir+"/"+file);

    return mimedb.mimeTypeForFile(info.absoluteFilePath(), QMimeDatabase::MatchContent).name();

}

QString GetAndDoStuffFile::streamlineFilePath(QString path) {

    QFileInfo info(path);
    if(info.isAbsolute())
        return info.canonicalFilePath();
    return path;

}

QString GetAndDoStuffFile::removeSuffixFromFilename(QString file) {

    QString suffix = QFileInfo(file).suffix();
    return file.remove(file.length()-suffix.length()-1, file.length());

}
