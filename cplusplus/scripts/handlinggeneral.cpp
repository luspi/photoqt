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
