/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#include "handlinggeneral.h"

bool PQHandlingGeneral::isGraphicsMagickSupportEnabled() {
#ifdef GRAPHICSMAGICK
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

    DBG << CURDATE << "PQHandlingGeneral::getFileNameFromFullPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** onlyExtraInfo = " << onlyExtraInfo << NL;

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

    DBG << CURDATE << "PQHandlingGeneral::getFilePathFromFullPath()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QFileInfo(path).absolutePath();

}

void PQHandlingGeneral::setLastLoadedImage(QString path) {

    DBG << CURDATE << "PQHandlingGeneral::setLastLoadedImage()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        out.flush();
        file.close();
    }

}

QString PQHandlingGeneral::getLastLoadedImage() {

    DBG << CURDATE << "PQHandlingGeneral::getLastLoadedImage()" << NL;

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

    DBG << CURDATE << "PQHandlingGeneral::deleteLastLoadedImage()" << NL;

    // attempts to remove stored last loaded image
    // not a big deal if this fails thus no need to error check
    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.exists())
        file.remove();

}

bool PQHandlingGeneral::isDir(QString path) {

    DBG << CURDATE << "PQHandlingGeneral::isDir()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QFileInfo(path).isDir();

}

QString PQHandlingGeneral::getFileSize(QString path) {

    DBG << CURDATE << "PQHandlingGeneral::getFileSize()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    return QString::number(QFileInfo(path).size()/1024) + " KB";

}

QString PQHandlingGeneral::getTempDir() {

    DBG << CURDATE << "PQHandlingGeneral::getTempDir()" << NL;

    return QDir::tempPath();

}

void PQHandlingGeneral::cleanUpScreenshotsTakenAtStartup() {

    DBG << CURDATE << "PQHandlingGeneral::cleanUpScreenshotsTakenAtStartup()" << NL;

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

    DBG << CURDATE << "PQHandlingGeneral::getUniqueId()" << NL;

    return QString::number(QDateTime::currentMSecsSinceEpoch());

}

QString PQHandlingGeneral::convertSecsToProperTime(int secs, int sameFormatsAsVal) {

    DBG << CURDATE << "PQHandlingGeneral::convertSecsToProperTime()" << NL
        << CURDATE << "** secs = " << secs << NL
        << CURDATE << "** sameFormatsAsVal = " << sameFormatsAsVal << NL;

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

    DBG << CURDATE << "PQHandlingGeneral::openInDefaultFileManager()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QDesktopServices::openUrl(QUrl("file://" + QFileInfo(filename).absolutePath()));

}

void PQHandlingGeneral::copyToClipboard(QString filename) {

    DBG << CURDATE << "PQHandlingGeneral::copyToClipboard()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

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

    DBG << CURDATE << "PQHandlingGeneral::copyTextToClipboard()" << NL
        << CURDATE << "** txt = " << txt.toStdString() << NL;

    QGuiApplication::clipboard()->setText(txt, QClipboard::Clipboard);

}

bool PQHandlingGeneral::checkIfConnectedToInternet() {

    DBG << CURDATE << "PQHandlingGeneral::checkIfConnectedToInternet()" << NL;

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

    DBG << CURDATE << "PQHandlingGeneral::getFileType()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    if(filename.trimmed().isEmpty() || !QFile(filename).exists())
        return "";
    return mimedb.mimeTypeForFile(filename).name();

}

QVariantList PQHandlingGeneral::convertHexToRgba(QString hex) {

    DBG << CURDATE << "PQHandlingGeneral::convertHexToRgba()" << NL
        << CURDATE << "** hex = " << hex.toStdString() << NL;

    int a = QStringRef(&hex, 1, 2).toUInt(nullptr, 16);
    int r = QStringRef(&hex, 3, 2).toUInt(nullptr, 16);
    int g = QStringRef(&hex, 5, 2).toUInt(nullptr, 16);
    int b = QStringRef(&hex, 7, 2).toUInt(nullptr, 16);

    return QVariantList() << r << g << b << a;

}

QString PQHandlingGeneral::convertRgbaToHex(QVariantList rgba) {

    DBG << CURDATE << "PQHandlingGeneral::convertRgbaToHex()" << NL;

    std::stringstream ss;
    ss << "#";
    ss << std::hex << (rgba[3].toInt() << 24 | rgba[0].toInt() << 16 | rgba[1].toInt() << 8 | rgba[2].toInt());
    return QString::fromStdString(ss.str());

}

bool PQHandlingGeneral::askForConfirmation(QString text, QString informativeText) {

    DBG << CURDATE << "PQHandlingGeneral::askForConfirmation()" << NL
        << CURDATE << "** text = " << text.toStdString() << NL
        << CURDATE << "** informativeText = " << informativeText.toStdString() << NL;

    QMessageBox msg;

    msg.setText(text);
    msg.setInformativeText(informativeText);
    msg.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    msg.setDefaultButton(QMessageBox::Yes);

    int ret = msg.exec();

    return (ret==QMessageBox::Yes);

}

void PQHandlingGeneral::setOverrideCursor(bool enabled) {

    DBG << CURDATE << "PQHandlingGeneral::setOverrideCursor()" << NL
        << CURDATE << "** enabled = " << enabled << NL;

    if(enabled)
        qApp->setOverrideCursor(Qt::BusyCursor);
    else
        qApp->restoreOverrideCursor();

}

QString PQHandlingGeneral::getVersion() {

    DBG << CURDATE << "PQHandlingGeneral::getVersion()" << NL;

    return QString::fromStdString(VERSION);

}

QString PQHandlingGeneral::getQtVersion() {

    DBG << CURDATE << "PQHandlingGeneral::getQtVersion()" << NL;

    return QString::fromStdString(QT_VERSION_STR);

}

QStringList PQHandlingGeneral::getAvailableTranslations() {

    DBG << CURDATE << "PQHandlingGeneral::getAvailableTranslations()" << NL;

    QStringList ret;

    // these are shown first
    // they are the ones with recent activity
    // this list will be updated before release
    // the other ones are shown afterwards sorted alphabetically
    ret << "en";
    ret << "de";
    ret << "pt_PT";

    QStringList tmp;

    QDirIterator it(":");
    while (it.hasNext()) {
        QString file = it.next();
        if(file.endsWith(".qm")) {
            file = file.remove(0, 10);
            file = file.remove(file.length()-3, file.length());
            if(!ret.contains(file))
                tmp.push_back(file);
        }
    }

    tmp.sort();
    ret.append(tmp);

    return ret;

}

QString PQHandlingGeneral::getIconPathFromTheme(QString binary) {

    DBG << CURDATE << "PQHandlingGeneral::getIconPathFromTheme()" << NL
        << CURDATE << "** binary = " << binary.toStdString() << NL;

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
