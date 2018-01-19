#include "other.h"
#include <QtDebug>

GetAndDoStuffOther::GetAndDoStuffOther(QObject *parent) : QObject(parent) { }
GetAndDoStuffOther::~GetAndDoStuffOther() { }

QString GetAndDoStuffOther::convertRgbaToHex(int r, int g, int b, int a) {

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

QString GetAndDoStuffOther::getVersionString() {
    return VERSION;
}

void GetAndDoStuffOther::storeGeometry(QRect rect) {

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
    if(path.startsWith("file://"))
        path = path.remove(0,7);

    return QImageReader(path).supportsAnimation();

}
