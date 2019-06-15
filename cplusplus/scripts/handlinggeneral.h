#ifndef PQHANDLINGGENERAL_H
#define PQHANDLINGGENERAL_H

#include <QObject>
#include <QRect>

#include "../logger.h"

class PQHandlingGeneral : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled();
    Q_INVOKABLE bool isLibRawSupportEnabled();
    Q_INVOKABLE bool isDevILSupportEnabled();
    Q_INVOKABLE bool isFreeImageSupportEnabled();
    Q_INVOKABLE bool isPopplerSupportEnabled();

    Q_INVOKABLE QString getFileNameFromFullPath(QString path);
    Q_INVOKABLE QString getFilePathFromFullPath(QString path);
    Q_INVOKABLE bool isDir(QString path);

    Q_INVOKABLE void setLastLoadedImage(QString path);
    Q_INVOKABLE QString getLastLoadedImage();

    Q_INVOKABLE QString getTempDir();
    Q_INVOKABLE void cleanUpScreenshotsTakenAtStartup();

};

#endif // PQHandlingGeneral
