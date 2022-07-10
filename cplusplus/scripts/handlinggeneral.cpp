/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif
#ifdef PUGIXML
#include <pugixml.hpp>
#endif
#ifdef CHROMECAST
#include <Python.h>
#endif
#ifdef RAW
#include <libraw/libraw.h>
#endif
#ifdef LIBARCHIVE
#include <archive.h>
#endif
#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
#include <Magick++.h>
#endif
#ifdef FREEIMAGE
#include <FreeImagePlus.h>
#endif
#ifdef DEVIL
#include <il.h>
#endif
#ifdef VIDEOMPV
#include "../libmpv/mpvobject.h"
#endif

bool PQHandlingGeneral::amIOnWindows() {
#ifdef Q_OS_WIN
    return true;
#endif
    return false;
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

QString PQHandlingGeneral::convertBytesToHumanReadable(qint64 bytes) {

    DBG << CURDATE << "PQHandlingGeneral::convertBytesToHumanReadable()" << NL
        << CURDATE << "** bytes = " << bytes << NL;

    if(bytes <= 1024)
        return (QString::number(bytes) + " B");
    else if(bytes <= 1024*1024)
        return (QString::number(qRound(10.0*(bytes/1024.0))/10.0) + " KB");

    return (QString::number(qRound(100.0*(bytes/(1024.0*1024.0)))/100.0) + " MB");

}

QVariantList PQHandlingGeneral::convertHexToRgba(QString hex) {

    DBG << CURDATE << "PQHandlingGeneral::convertHexToRgba()" << NL
        << CURDATE << "** hex = " << hex.toStdString() << NL;

    int r,g,b,a;

    // no transparency
    if(hex.length() == 7) {

        a = 255;
        r = QStringRef(&hex, 1, 2).toUInt(nullptr, 16);
        g = QStringRef(&hex, 3, 2).toUInt(nullptr, 16);
        b = QStringRef(&hex, 5, 2).toUInt(nullptr, 16);

    } else {

        a = QStringRef(&hex, 1, 2).toUInt(nullptr, 16);
        r = QStringRef(&hex, 3, 2).toUInt(nullptr, 16);
        g = QStringRef(&hex, 5, 2).toUInt(nullptr, 16);
        b = QStringRef(&hex, 7, 2).toUInt(nullptr, 16);

    }

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

QString PQHandlingGeneral::escapeHTML(QString str) {
    return str.toHtmlEscaped();
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

QString PQHandlingGeneral::getConfigInfo(bool formatHTML) {

    QString bold1 = "";
    QString bold2 = "";
    QString nl = "\n";
    QString spacing = "    ";
    if(formatHTML) {
        bold1 = "<b>";
        bold2 = "</b>";
        nl = "<br>";
        spacing = "&nbsp;&nbsp;&nbsp;";
    }

    QString txt = "";

#ifdef EXIV2
    txt += QString("- %1Exiv2%2: %3%4").arg(bold1, bold2, Exiv2::version(), nl);
#endif

#ifdef PUGIXML
    txt += QString("- %1pugixml%2: %3%4").arg(bold1, bold2).arg((PUGIXML_VERSION)/1000.).arg(nl);
#endif

#ifdef CHROMECAST
    txt += QString("- %1Python%2: %3%4").arg(bold1, bold2, PY_VERSION, nl);
#endif

#ifdef RAW
    txt += QString("- %1LibRaw%2: %3%4").arg(bold1, bold2, LibRaw::version(), nl);
#endif

#ifdef POPPLER
    txt += QString("- %1Poppler%2%3").arg(bold1, bold2, nl);
#endif
#ifdef LIBARCHIVE
    txt += QString("- %1LibArchive%2: %3%4").arg(bold1, bold2, ARCHIVE_VERSION_ONLY_STRING, nl);
#endif
#ifdef IMAGEMAGICK
    txt += QString("- %1ImageMagick%2: %3%4").arg(bold1, bold2, MagickLibVersionText, nl);
#endif
#ifdef GRAPHICSMAGICK
    txt += QString("- %1GraphicsMagick%2: %3%4").arg(bold1, bold2, MagickLibVersionText, nl);
#endif
#ifdef FREEIMAGE
    txt += QString("- %1FreeImage%2: %3.%4%5").arg(bold1, bold2).arg(FREEIMAGE_MAJOR_VERSION).arg(FREEIMAGE_MINOR_VERSION).arg(nl);
#endif
#ifdef DEVIL
    txt += QString("- %1DevIL%2: %3%4").arg(bold1, bold2).arg(IL_VERSION).arg(nl);
#endif
#ifdef VIDEOQT
    txt += QString("- %1Video%2 through Qt%3").arg(bold1, bold2, nl);
#endif
#ifdef VIDEOMPV
    mpv_handle *mpv = mpv_create();
    if(mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");
    txt += QString("- %1libmpv%2: %3 (ffmpeg: %4)%5").arg(bold1, bold2, mpv::qt::get_property(mpv, "mpv-version").toString(), mpv::qt::get_property(mpv, "ffmpeg-version").toString(), nl);
#endif

    txt += QString("- %1Qt%2 image formats available:%3%4").arg(bold1, bold2, nl, spacing);
    QImageReader reader;
    auto formats = reader.supportedImageFormats();
    for(int i = 0; i < formats.length(); ++i) {
        if(i != 0 && i%10 == 0)
            txt += QString("%1%2").arg(nl, spacing);
        txt += QString("%1, ").arg(QString(formats[i]), 5);
    }

    txt += nl;

    return txt;

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

    return ret.trimmed();

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

bool PQHandlingGeneral::isChromecastEnabled() {
#ifdef CHROMECAST
    return true;
#else
    return false;
#endif
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

bool PQHandlingGeneral::isPugixmlSupportEnabled() {
#ifdef PUGIXML
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isVideoSupportEnabled() {
#ifdef VIDEOQT
    return true;
#else
    return false;
#endif
}

bool PQHandlingGeneral::isMPVSupportEnabled() {
#ifdef VIDEOMPV
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

void PQHandlingGeneral::storeQmlWindowMemoryAddress(QString objName) {

    DBG << CURDATE << "PQHandlingGeneral::storeQmlWindowMemoryAddress()" << NL
        << CURDATE << "** objName = " << objName.toStdString() << NL;

    PQSingleInstance *inst = reinterpret_cast<PQSingleInstance*>(PQSingleInstance::instance());
    inst->qmlWindowAddresses.push_back(inst->qmlEngine->rootObjects().at(0)->findChild<QObject*>(objName));

}

void PQHandlingGeneral::setDefaultSettings(bool ignoreLanguage) {

    PQSettings::get().setDefault(ignoreLanguage);

}
