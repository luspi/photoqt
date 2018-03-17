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

#include "other.h"

GetAndDoStuffOther::GetAndDoStuffOther(QObject *parent) : QObject(parent) { }
GetAndDoStuffOther::~GetAndDoStuffOther() { }

QString GetAndDoStuffOther::convertRgbaToHex(int r, int g, int b, int a) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOther::convertRgbaToHex() - " << r << "/" << g << "/" << b << "/" << a << NL;

    // enforce max/min limits on values
    if(r < 0) { r = 0; } if(r > 255) { r = 255; }
    if(g < 0) { g = 0; } if(g > 255) { g = 255; }
    if(b < 0) { b = 0; } if(b > 255) { b = 255; }
    if(a < 0) { a = 0; } if(a > 255) { a = 255; }

    return QString("#%1%2%3%4").arg(a, 2, 16, QLatin1Char('0'))
                               .arg(r, 2, 16, QLatin1Char('0'))
                               .arg(g, 2, 16, QLatin1Char('0'))
                               .arg(b, 2, 16, QLatin1Char('0'));

}

bool GetAndDoStuffOther::amIOnLinux() {
#ifdef Q_OS_LINUX
    return true;
#else
    return false;
#endif
}

bool GetAndDoStuffOther::amIOnWindows() {
#ifdef Q_OS_WIN
    return true;
#else
    return false;
#endif
}

int GetAndDoStuffOther::getCurrentScreen(int x, int y) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOther::getCurrentScreen() - " << x << "/" << y << NL;

    for(int i = 0; i < QGuiApplication::screens().count(); ++i)
        if(QGuiApplication::screens().at(i)->geometry().contains(x,y))
            return i;

    return 0;

}

QString GetAndDoStuffOther::getTempDir() {
    return QDir::tempPath();
}

QString GetAndDoStuffOther::getHomeDir() {
    return QDir::homePath();
}

QString GetAndDoStuffOther::getDesktopDir() {
    QStringList loc = QStandardPaths::standardLocations(QStandardPaths::DesktopLocation);
    if(loc.length() == 0)
        return "";
    return loc.first();
}

QString GetAndDoStuffOther::getPicturesDir() {
    QStringList loc = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    if(loc.length() == 0)
        return "";
    return loc.first();
}

QString GetAndDoStuffOther::getDownloadsDir() {
    QStringList loc = QStandardPaths::standardLocations(QStandardPaths::DownloadLocation);
    if(loc.length() == 0)
        return "";
    return loc.first();
}

bool GetAndDoStuffOther::isExivSupportEnabled() {
#ifdef EXIV2
    return true;
#endif
    return false;
}

bool GetAndDoStuffOther::isGraphicsMagickSupportEnabled() {
#ifdef GM
    return true;
#endif
    return false;
}

bool GetAndDoStuffOther::isLibRawSupportEnabled() {
#ifdef RAW
    return true;
#endif
    return false;
}

bool GetAndDoStuffOther::isDevILSupportEnabled() {
#ifdef DEVIL
    return true;
#endif
    return false;
}

bool GetAndDoStuffOther::isFreeImageSupportEnabled() {
#ifdef FREEIMAGE
    return true;
#endif
    return false;
}

bool GetAndDoStuffOther::isPopplerSupportEnabled() {
#ifdef POPPLER
    return true;
#endif
    return false;
}

QString GetAndDoStuffOther::getVersionString() {
    return VERSION;
}

void GetAndDoStuffOther::storeGeometry(QRect rect) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOther::storeGeometry() - " << rect.x() << "x" << rect.y() << " / " << rect.width() << "x" << rect.height() << NL;

    QFile geo(ConfigFiles::MAINWINDOW_GEOMETRY_FILE());
    if(geo.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&geo);
        QString txt = "[General]\n";
        txt += QString("mainWindowGeometry=@Rect(%1 %2 %3 %4)\n").arg(rect.x()).arg(rect.y()).arg(rect.width()).arg(rect.height());
        out << txt;
        geo.close();
    }

}

QRect GetAndDoStuffOther::getStoredGeometry() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOther::getStoredGeometry()" << NL;

    QFile geo(ConfigFiles::MAINWINDOW_GEOMETRY_FILE());
    if(geo.open(QIODevice::ReadOnly)) {
        QTextStream in(&geo);
        QString all = in.readAll();
        if(all.contains("mainWindowGeometry=@Rect(")) {
            QStringList vars = all.split("mainWindowGeometry=@Rect(").at(1).split(")\n").at(0).split(" ");
            if(vars.length() == 4)
                return QRect(vars.at(0).toInt(),vars.at(1).toInt(),vars.at(2).toInt(),vars.at(3).toInt());
            return QRect();
        } else
            return QRect();
    } else
        return QRect();
}

bool GetAndDoStuffOther::isImageAnimated(QString path) {

    if(path.startsWith("image://full/"))
        path = path.remove(0,13);
    if(path.startsWith("file:/"))
        path = path.remove(0,6);

#ifdef Q_OS_WIN
    while(path.startsWith("/"))
        path = path.remove(0,1);
#endif

    return QImageReader(path).supportsAnimation();

}

QString GetAndDoStuffOther::convertIdIntoString(QObject *object) {
    const auto context = qmlContext(object);
    return context ? context->nameForObject(object): QString("context not found");
}
