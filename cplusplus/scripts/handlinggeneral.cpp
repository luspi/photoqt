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

void PQHandlingGeneral::deleteLastLoadedImage() {

    DBG << CURDATE << "PQHandlingGeneral::deleteLastLoadedImage()" << NL;

    // attempts to remove stored last loaded image
    // not a big deal if this fails thus no need to error check
    QFile file(ConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.exists())
        file.remove();

}

QStringList PQHandlingGeneral::getAvailableTranslations() {

    DBG << CURDATE << "PQHandlingGeneral::getAvailableTranslations()" << NL;

    QStringList ret;

    // these are shown first
    // they are the ones with recent activity
    // this list will be updated before release
    // the other ones are shown afterwards sorted alphabetically
    ret << "en";
    ret << "de_DE";
    ret << "es_ES";
    ret << "lt_LT";
    ret << "pl_PL";
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

QString PQHandlingGeneral::getQtVersion() {

    DBG << CURDATE << "PQHandlingGeneral::getQtVersion()" << NL;

    return QString::fromStdString(QT_VERSION_STR);

}

QString PQHandlingGeneral::getUniqueId() {

    DBG << CURDATE << "PQHandlingGeneral::getUniqueId()" << NL;

    return QString::number(QDateTime::currentMSecsSinceEpoch());

}

QString PQHandlingGeneral::getVersion() {

    DBG << CURDATE << "PQHandlingGeneral::getVersion()" << NL;

    return QString::fromStdString(VERSION);

}

bool PQHandlingGeneral::isDevILSupportEnabled() {
#ifdef DEVIL
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isFreeImageSupportEnabled() {
#ifdef FREEIMAGE
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isGraphicsMagickSupportEnabled() {
#ifdef GRAPHICSMAGICK
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isImageMagickSupportEnabled() {
#ifdef IMAGEMAGICK
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isLibRawSupportEnabled() {
#ifdef RAW
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isLibArchiveSupportEnabled() {
#ifdef LIBARCHIVE
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isPopplerSupportEnabled() {
#ifdef POPPLER
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isVideoSupportEnabled() {
#ifdef VIDEO
    return true;
#else
    return false;
#endif
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

void PQHandlingGeneral::setOverrideCursor(bool enabled) {

    DBG << CURDATE << "PQHandlingGeneral::setOverrideCursor()" << NL
        << CURDATE << "** enabled = " << enabled << NL;

    if(enabled)
        qApp->setOverrideCursor(Qt::BusyCursor);
    else
        qApp->restoreOverrideCursor();

}
