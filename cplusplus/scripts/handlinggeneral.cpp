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

bool PQHandlingGeneral::isVideoSupportEnabled() {
#ifdef VIDEO
    return true;
#endif
    return false;
}

QString PQHandlingGeneral::getFileNameFromFullPath(QString path, bool onlyExtraInfo) {
    QString ret = QFileInfo(path).fileName();
    if(onlyExtraInfo) {
        if(path.contains("::PQT::"))
            ret = QString("Page %1").arg(path.split("::PQT::").at(0).toInt()+1);
        if(path.contains("::ARC::"))
            ret = path.split("::ARC::").at(0);
    }
    return ret;
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

void PQHandlingGeneral::deleteLastLoadedImage() {

    // attempts to remove stored last loaded image
    // not a big deal if this fails thus no need to error check
    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.exists())
        file.remove();

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

QString PQHandlingGeneral::getUniqueId() {
    return QString::number(QDateTime::currentMSecsSinceEpoch());
}

QString PQHandlingGeneral::convertSecsToProperTime(int secs, int sameFormatsAsVal) {

    if(secs < 10 && sameFormatsAsVal < 10)
        return QString("0%1").arg(secs);

    if(secs <= 60 && sameFormatsAsVal <= 60) {
        if(secs < 10)
            return QString("0%1").arg(secs);
        return QString::number(secs);
    }

    if(secs < 3600 && sameFormatsAsVal < 3600) {
        int mins_int = secs/60;
        int secs_int = secs%60;
        QString mins_str = QString(mins_int<10 ? "0%1" : "%1").arg(mins_int);
        QString secs_str = QString(secs_int<10 ? "0%1" : "%1").arg(secs_int);
        return mins_str+":"+secs_str;
    }

    int hours_int = secs/(60*60);
    int mins_int = (secs - hours_int*60*60)/60;
    int secs_int = (secs - hours_int*60*60 - mins_int*60)/60;

    QString hours_str = QString(hours_int<10 ? "0%1" : "%1").arg(hours_int);
    QString mins_str = QString(mins_int<10 ? "0%1" : "%1").arg(mins_int);
    QString secs_str = QString(secs_int<10 ? "0%1" : "%1").arg(secs_int);

    return hours_str+":"+mins_str+":"+secs_str;

}

void PQHandlingGeneral::openInDefaultFileManager(QString filename) {
    QDesktopServices::openUrl(QUrl("file://" + QFileInfo(filename).absolutePath()));
}

void PQHandlingGeneral::copyToClipboard(QString filename) {

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new PQImageProviderFull;

    // request image
    QImage img = imageprovider->requestImage(filename, new QSize, QSize());

    // create mime data object with url and image data
    QMimeData *data = new QMimeData;
    data->setUrls(QList<QUrl>() << "file://" + filename);
    data->setImageData(img);

    // set mime data to clipboard
    qApp->clipboard()->setMimeData(data);

}

void PQHandlingGeneral::copyTextToClipboard(QString txt) {
    QGuiApplication::clipboard()->setText(txt, QClipboard::Clipboard);
}

bool PQHandlingGeneral::checkIfConnectedToInternet() {

    // will store the return value
    bool internetConnected = false;

    // Get a list of all network interfaces
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();

    // a reg exp to validate an ip address
    QRegExp ipRegExp( "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}" );
    QRegExpValidator ipRegExpValidator(ipRegExp, 0);

    // loop over all network interfaces
    for(int i = 0; i < ifaces.count(); i++) {

        // get the current network interface
        QNetworkInterface iface = ifaces.at(i);

        // if the interface is up and not a loop back interface
        if(iface.flags().testFlag(QNetworkInterface::IsUp)
             && !iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {

            // loop over all possible ip addresses
            for (int j=0; j<iface.allAddresses().count(); j++) {

                // get the ip address
                QString ip = iface.allAddresses().at(j).toString();

                // validate the ip. We have to double check 127.0.0.1 as isLoopBack above does not always work reliably
                int pos = 0;
                if(ipRegExpValidator.validate(ip, pos) == QRegExpValidator::Acceptable && ip != "127.0.0.1") {
                    internetConnected = true;
                    break;
                }
            }

        }

        // done
        if(internetConnected) break;

    }

    // return whether we're connected or not
    return internetConnected;

}

QString PQHandlingGeneral::getFileType(QString filename) {
    if(filename.trimmed().isEmpty() || !QFile(filename).exists())
        return "";
    return mimedb.mimeTypeForFile(filename).name();
}

QVariantList PQHandlingGeneral::convertHexToRgba(QString hex) {

    int a = QStringRef(&hex, 1, 2).toUInt(nullptr, 16);
    int r = QStringRef(&hex, 3, 2).toUInt(nullptr, 16);
    int g = QStringRef(&hex, 5, 2).toUInt(nullptr, 16);
    int b = QStringRef(&hex, 7, 2).toUInt(nullptr, 16);

    return QVariantList() << r << g << b << a;

}

QString PQHandlingGeneral::convertRgbaToHex(QVariantList rgba) {

    std::stringstream ss;
    ss << "#";
    ss << std::hex << (rgba[3].toInt() << 24 | rgba[0].toInt() << 16 | rgba[1].toInt() << 8 | rgba[2].toInt());
    return QString::fromStdString(ss.str());

}
