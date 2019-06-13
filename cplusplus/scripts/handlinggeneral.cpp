#include "handlinggeneral.h"

bool PQHandlingGeneral::isGraphicsMagickSupportEnabled() {
#ifdef GM
    return true;
#endif
    return false;
}

bool PQHandlingGeneral::isLibRawSupportEnabled() {
#ifdef RAW
    return true;
#endif
    return false;
}

bool PQHandlingGeneral::isDevILSupportEnabled() {
#ifdef DEVIL
    return true;
#endif
    return false;
}

bool PQHandlingGeneral::isFreeImageSupportEnabled() {
#ifdef FREEIMAGE
    return true;
#endif
    return false;
}

bool PQHandlingGeneral::isPopplerSupportEnabled() {
#ifdef POPPLER
    return true;
#endif
    return false;
}

void PQHandlingGeneral::saveWindowGeometry(int x, int y, int w, int h, bool maximized) {

    QFile geo(ConfigFiles::WINDOW_GEOMETRY_FILE());
    if(geo.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream out(&geo);
        QString txt = "[General]\n";
        txt += QString("mainWindowGeometry=@Rect(%1 %2 %3 %4)\n").arg(x).arg(y).arg(w).arg(h);
        txt += QString("mainWindowMaximized=%1\n").arg(maximized);
        out << txt;
        geo.close();
    }

}

QRect PQHandlingGeneral::getWindowGeometry() {

    QFile geo(ConfigFiles::WINDOW_GEOMETRY_FILE());
    if(geo.open(QIODevice::ReadOnly)) {
        QTextStream in(&geo);
        QString all = in.readAll();
        if(all.contains("mainWindowMaximized=1"))
            return QRect(0,0,0,0);
        if(all.contains("mainWindowGeometry=@Rect(")) {
            QStringList vars = all.split("mainWindowGeometry=@Rect(").at(1).split(")\n").at(0).split(" ");
            if(vars.length() == 4)
                return QRect(vars.at(0).toInt(),vars.at(1).toInt(),vars.at(2).toInt(),vars.at(3).toInt());
            return QRect(0,0,0,0);
        } else
            return QRect(0,0,0,0);
    } else
        return QRect(0,0,0,0);

}

QString PQHandlingGeneral::getFileNameFromFullPath(QString path) {
    return QFileInfo(path).fileName();
}

QString PQHandlingGeneral::getFilePathFromFullPath(QString path) {
    return QFileInfo(path).absolutePath();
}
