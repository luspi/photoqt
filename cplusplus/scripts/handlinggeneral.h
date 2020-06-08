#ifndef PQHANDLINGGENERAL_H
#define PQHANDLINGGENERAL_H

#include <QObject>
#include <QRect>
#include <QDesktopServices>
#include <QUrl>
#include <QNetworkInterface>
#include <QMimeDatabase>
#include <QStringRef>
#include "../imageprovider/imageproviderfull.h"
#include "../logger.h"

class PQHandlingGeneral : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool isGraphicsMagickSupportEnabled();
    Q_INVOKABLE bool isLibRawSupportEnabled();
    Q_INVOKABLE bool isDevILSupportEnabled();
    Q_INVOKABLE bool isFreeImageSupportEnabled();
    Q_INVOKABLE bool isPopplerSupportEnabled();

    Q_INVOKABLE QString getFileNameFromFullPath(QString path, bool onlyExtraInfo = false);
    Q_INVOKABLE QString getFilePathFromFullPath(QString path);
    Q_INVOKABLE bool isDir(QString path);
    Q_INVOKABLE QString getFileSize(QString path);

    Q_INVOKABLE void setLastLoadedImage(QString path);
    Q_INVOKABLE QString getLastLoadedImage();
    Q_INVOKABLE void deleteLastLoadedImage();

    Q_INVOKABLE QString getTempDir();
    Q_INVOKABLE void cleanUpScreenshotsTakenAtStartup();

    Q_INVOKABLE QString getUniqueId();

    Q_INVOKABLE QString convertSecsToProperTime(int secs, int sameFormatsAsVal);

    Q_INVOKABLE void openInDefaultFileManager(QString filename);
    Q_INVOKABLE void copyToClipboard(QString filename);
    Q_INVOKABLE void copyTextToClipboard(QString txt);

    Q_INVOKABLE bool checkIfConnectedToInternet();

    Q_INVOKABLE QString getFileType(QString filename);

    Q_INVOKABLE QVariantList convertHexToRgba(QString hex);

private:
    PQImageProviderFull *imageprovider;
    QMimeDatabase mimedb;

};

#endif // PQHandlingGeneral
