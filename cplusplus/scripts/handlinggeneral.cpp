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

QString PQHandlingGeneral::getFileNameFromFullPath(QString path) {
    return QFileInfo(path).fileName();
}

QString PQHandlingGeneral::getFilePathFromFullPath(QString path) {
    return QFileInfo(path).absolutePath();
}

void PQHandlingGeneral::setLastLoadedImage(QString path) {

    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        out.flush();
        file.close();
    }

}

QString PQHandlingGeneral::getLastLoadedImage() {

    QString ret = "";

    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll();
        file.close();
    }

    return ret;

}

bool PQHandlingGeneral::isDir(QString path) {
    return QFileInfo(path).isDir();
}

QString PQHandlingGeneral::getFileSize(QString path) {
    return QString::number(QFileInfo(path).size()/1024) + " KB";
}

QString PQHandlingGeneral::getTempDir() {
    return QDir::tempPath();
}

void PQHandlingGeneral::cleanUpScreenshotsTakenAtStartup() {

    int count = 0;
    while(true) {
        QFile file(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(count));
        if(file.exists())
            file.remove();
        else
            break;
    }

}
