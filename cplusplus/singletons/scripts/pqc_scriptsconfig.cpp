/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#include <qlogging.h>   // needed in this form to compile with Qt 6.2
#include <QtDebug>
#include <QFileDialog>
#include <QApplication>
#include <QImageReader>
#include <QQmlContext>
#include <QMessageBox>
#include <QDirIterator>
#include <pqc_configfiles.h>
#include <scripts/pqc_scriptsconfig.h>
#include <scripts/pqc_scriptslocalization.h>
#ifndef PQMTESTING
#include <pqc_startuphandler.h>
#endif
#include <pqc_notify_cpp.h>

#ifdef WIN32
#include <WinSock2.h>
#endif

#ifdef PQMLIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

#ifdef PQMPUGIXML
#include <pugixml.hpp>
#endif

#ifdef PQMRAW
#include <libraw/libraw.h>
#endif

#ifdef PQMPOPPLER
#include <poppler/qt6/poppler-version.h>
#endif

#if defined(PQMIMAGEMAGICK) || defined(PQMGRAPHICSMAGICK)
#include <Magick++/Include.h>
#endif

#ifdef PQMDEVIL
#include <IL/il.h>
#endif

#ifdef PQMFREEIMAGE
#include <FreeImage.h>
#endif

#ifdef PQMVIDEOMPV
#include <pqc_mpvobject.h>
#endif

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

PQCScriptsConfig::PQCScriptsConfig() {}

PQCScriptsConfig::~PQCScriptsConfig() {}

bool PQCScriptsConfig::amIOnWindows() {
#ifdef Q_OS_WIN
    return true;
#endif
    return false;
}

QString PQCScriptsConfig::getConfigInfo(bool formatHTML) {

    qDebug() << "args: formatHTML =" << formatHTML;

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

    txt += QString(" - Compiled with %1Qt %2%3, running with %4Qt %5%6%7").arg(bold1, QT_VERSION_STR, bold2, bold1, qVersion(), bold2, nl);

#ifdef PQMPORTABLETWEAKS
    txt += QString(" - Portable version%1").arg(nl);
#endif

#ifdef PQMEXIV2
    txt += QString(" - %1Exiv2%2: %3%4").arg(bold1, bold2, Exiv2::version(), nl);
#endif

#ifdef PQMPUGIXML
    txt += QString(" - %1pugixml%2: %3%4").arg(bold1, bold2).arg((PUGIXML_VERSION)/1000.).arg(nl);
#endif

#ifdef PQMCHROMECAST
    txt += QString(" - %1Chromecast%2%3").arg(bold1, bold2, nl);
#endif

#ifdef PQMRAW
    txt += QString(" - %1LibRaw%2: %3%4").arg(bold1, bold2, LibRaw::version(), nl);
#endif

#ifdef PQMPOPPLER
    txt += QString(" - %1Poppler%2: %3%4").arg(bold1, bold2, POPPLER_VERSION, nl);
#endif

#ifdef PQMQTPDF
    txt += QString(" - %1QtPDF%2%3").arg(bold1, bold2, nl);
#endif

#ifdef PQMLIBARCHIVE
    txt += QString(" - %1LibArchive%2: %3%4").arg(bold1, bold2, ARCHIVE_VERSION_ONLY_STRING, nl);
#endif

#ifdef PQMIMAGEMAGICK
    txt += QString(" - %1ImageMagick%2: %3%4").arg(bold1, bold2, MagickLibVersionText, nl);
#endif

#ifdef PQMGRAPHICSMAGICK
    txt += QString(" - %1GraphicsMagick%2: %3%4").arg(bold1, bold2, MagickLibVersionText, nl);
#endif

#ifdef PQMFREEIMAGE
    txt += QString(" - %1FreeImage%2: %3.%4%5").arg(bold1, bold2).arg(FREEIMAGE_MAJOR_VERSION).arg(FREEIMAGE_MINOR_VERSION).arg(nl);
#endif

#ifdef PQMDEVIL
    txt += QString(" - %1DevIL%2: %3%4").arg(bold1, bold2).arg(IL_VERSION).arg(nl);
#endif

#ifdef PQMLIBSAI
    txt += QString(" - %1LibSai%2%3").arg(bold1, bold2).arg(nl);
#endif

#ifdef PQMLOCATION
    txt += QString(" - %1Location%2%3").arg(bold1, bold2, nl);
#endif

#ifdef PQMMOTIONPHOTO
    txt += QString(" - %1Motion Photo%2%3").arg(bold1, bold2, nl);
#endif

#ifdef PQMVIDEOQT
    txt += QString(" - %1Video%2 through Qt%3").arg(bold1, bold2, nl);
#endif

#ifdef PQMLCMS2
    txt += QString(" - %1LittleCMS%2: %3%4").arg(bold1, bold2).arg(LCMS_VERSION).arg(nl);
#endif

#ifdef PQMVIDEOMPV
    mpv_handle *mpv = mpv_create();
    if(mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");
    txt += QString(" - %1libmpv%2: %3 (ffmpeg: %4)%5").arg(bold1, bold2, mpv::qt::get_property(mpv, "mpv-version").toString(), mpv::qt::get_property(mpv, "ffmpeg-version").toString(), nl);
#endif

    txt += QString(" - %1Qt%2 image formats available:%3%4").arg(bold1, bold2, nl, spacing);
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

bool PQCScriptsConfig::exportConfigTo(QString path) {

    /*********************************************************/
    // NOTE: BEFORE CALLING you HAVE TO ENSURE:
    // -> settings database is closed
    // -> shortcuts database is closed
    //
    // If called by command line, they are never opened.
    // If called through interface, they must be closed (and subsequently reopened) manually!
    /*********************************************************/

    qDebug() << "args: path =" << path;

#ifdef PQMLIBARCHIVE
    // Obtain a filename from the user or used passed on filename
    QString archiveFile;
    if(path == "") {
        archiveFile = QFileDialog::getSaveFileName(0,
                                                   "Select Location",
                                                   QDir::homePath() + "/photoqtconfig.pqt",
                                                   "PhotoQt Config File (*.pqt);;All Files (*.*)");
        if(archiveFile.trimmed() == "")
            return false;
    } else
        archiveFile = path;

    // if no suffix, append the pqt suffix
    if(!archiveFile.endsWith(".pqt"))
        archiveFile += ".pqt";

    // All the config files
    QHash<QString,QString> allfiles;
    allfiles["CFG_USERSETTINGS_DB"] = PQCConfigFiles::get().USERSETTINGS_DB();
    allfiles["CFG_IMAGEFORMATS_DB"] = PQCConfigFiles::get().IMAGEFORMATS_DB();
    allfiles["CFG_CONTEXTMENU_DB"] = PQCConfigFiles::get().CONTEXTMENU_DB();
    allfiles["CFG_SHORTCUTS_DB"] = PQCConfigFiles::get().SHORTCUTS_DB();

    // handler to the file
    struct archive *a = archive_write_new();

    // Write a zip file
    archive_write_add_filter_gzip(a);
    archive_write_set_format_zip(a);

    // open archive for writing
    archive_write_open_filename(a, archiveFile.toLatin1());

    // loop over config files
    QHash<QString, QString>::const_iterator iter = allfiles.constBegin();
    while(iter != allfiles.constEnd()) {

        QFile config(iter.value());

        // Ignore files that do not exist
        if(config.exists()) {

            if(config.open(QIODevice::ReadOnly)) {

                // Get file content
                QByteArray configtxt = config.readAll();

                // create new entry in archive
                struct archive_entry *entry = archive_entry_new();

                // Set some metadata
                archive_entry_set_pathname(entry, iter.key().toLatin1());
                archive_entry_set_size(entry, config.size());
                archive_entry_set_filetype(entry, AE_IFREG);
                archive_entry_set_perm(entry, 0644);

                // write header info
                archive_write_header(a, entry);

                // write config data to compressed file
                archive_write_data(a, configtxt, config.size());

                // Clean up memory
                archive_entry_free(entry);

            } else
                qWarning() <<  QString("ERROR: Unable to read config file '%1'... Skipping!").arg(iter.value());
        }
        ++iter;
    }

    // Clean up memory
    archive_write_close(a);
    archive_write_free(a);

    return true;

#endif
    return false;

}

bool PQCScriptsConfig::importConfigFrom(QString path) {

    /*********************************************************/
    // NOTE: BEFORE CALLING you HAVE TO ENSURE:
    // -> settings database is closed
    // -> shortcuts database is closed
    // -> image formats database is closed
    //
    // If called by command line, they are never opened.
    // If called through interface, they must be closed manually!
    /*********************************************************/

    qDebug() << "args: path =" << path;

#ifdef PQMLIBARCHIVE

    // Obtain a filename from the user or used passed on filename
    QString archiveFile;
    if(path == "") {
        archiveFile = QFileDialog::getOpenFileName(0,
                                                   "Select Location",
                                                   QDir::homePath(),
                                                   "PhotoQt Config File (*.pqt);;All Files (*.*)");
        if(archiveFile.trimmed() == "")
            return false;
    } else
        archiveFile = path;

    // All the config files to be imported
    QHash<QString,QString> allfiles;
    // the old settings file CAN be used by the new versions (but not the other way round)
    allfiles["CFG_SETTINGS_DB"] = PQCConfigFiles::get().USERSETTINGS_DB();
    allfiles["CFG_USERSETTINGS_DB"] = PQCConfigFiles::get().USERSETTINGS_DB();
    allfiles["CFG_CONTEXTMENU_DB"] = PQCConfigFiles::get().CONTEXTMENU_DB();
    allfiles["CFG_SHORTCUTS_DB"] = PQCConfigFiles::get().SHORTCUTS_DB();
    allfiles["CFG_IMAGEFORMATS_DB"] = PQCConfigFiles::get().IMAGEFORMATS_DB();

    // Create new archive handler
    struct archive *a = archive_read_new();

    // Read config file
    archive_read_support_format_all(a);
    archive_read_support_filter_all(a);

    // Read file - if something went wrong, output error message and stop here
#ifdef Q_OS_WIN
    int r = archive_read_open_filename_w(a, reinterpret_cast<const wchar_t*>(archiveFile.utf16()), 10240);
#else
    int r = archive_read_open_filename(a, archiveFile.toLocal8Bit().data(), 10240);
#endif
    if(r != ARCHIVE_OK) {
        qWarning() << "ERROR: archive_read_open_filename() returned code of" << r;
        return false;
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        if(allfiles.contains(filenameinside)) {

            // store read data in here
            const void *buff;
            size_t size;
            la_int64_t offset;

            // The output file...
            QFile file(allfiles[filenameinside]);
            // Overwrite old content
            if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                qWarning() << QString("ERROR: Unable to write new config file '%1'... Skipping file!").arg(allfiles[filenameinside]);
                continue;
            }
            QDataStream out(&file);   // we will serialize the data into the file

            // read data
            while((r = archive_read_data_block(a, &buff, &size, &offset)) == ARCHIVE_OK) {
                if(r != ARCHIVE_OK || size == 0) {
                    qWarning() << QString("ERROR: Unable to extract file '%1':").arg(allfiles[filenameinside]) << archive_error_string(a) << " " << QString("(%1)").arg(r) << " - Skipping file!";
                    break;
                }
                out.writeRawData((const char*) buff, size);
            }

            file.close();

        }

    }

    // Close archive
    r = archive_read_close(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_close() returned code of" << r;
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_free() returned code of" << r;

    return true;

#endif

    return false;

}

bool PQCScriptsConfig::isChromecastEnabled() {
#ifdef PQMCHROMECAST
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLocationSupportEnabled() {
#ifdef PQMLOCATION
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isGraphicsMagickSupportEnabled() {
#ifdef PQMGRAPHICSMAGICK
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isImageMagickSupportEnabled() {
#ifdef PQMIMAGEMAGICK
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isQtAtLeast6_5() {
#if (QT_VERSION >= QT_VERSION_CHECK(6, 5, 0))
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isPugixmlSupportEnabled() {
#ifdef PQMPUGIXML
    return true;
#endif
    return false;
}

QString PQCScriptsConfig::getLastLoadedImage() {

    qDebug() << "";

    QString ret = "";

    QFile file(PQCConfigFiles::get().LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll();
        file.close();
    }

    return ret.trimmed();

}

void PQCScriptsConfig::setLastLoadedImage(QString path) {

    qDebug() << "args: path =" << path;

    QFile file(PQCConfigFiles::get().LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        QTextStream out(&file);
        out << path;
        out.flush();
        file.close();
    }

}

void PQCScriptsConfig::deleteLastLoadedImage() {

    qDebug() << "";

    // attempts to remove stored last loaded image
    // not a big deal if this fails thus no need to error check
    QFile file(PQCConfigFiles::get().LASTOPENEDIMAGE_FILE());
    if(file.exists())
        file.remove();

}

bool PQCScriptsConfig::isMPVSupportEnabled() {
#ifdef PQMVIDEOMPV
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isVideoQtSupportEnabled() {
#ifdef PQMVIDEOQT
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLibRawSupportEnabled() {
#ifdef PQMRAW
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isDevILSupportEnabled() {
#ifdef PQMDEVIL
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isFreeImageSupportEnabled() {
#ifdef PQMFREEIMAGE
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isPDFSupportEnabled() {
#if defined PQMPOPPLER||PQMQTPDF
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLibVipsSupportEnabled() {
#ifdef PQMLIBVIPS
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLibArchiveSupportEnabled() {
#ifdef PQMLIBARCHIVE
    return true;
#endif
    return false;
}

QString PQCScriptsConfig::getVersion() {
    return PQMVERSION;
}

bool PQCScriptsConfig::isBetaVersion() {
    return QString(PQMVERSION).contains("-beta");
}

bool PQCScriptsConfig::isDebugBuild() {
#ifdef NDEBUG
    return false;
#else
    return true;
#endif
}

void PQCScriptsConfig::inform(QString title, QString txt) {

    QMessageBox msg;
    msg.setIcon(QMessageBox::Information);
    msg.setWindowFlag(Qt::WindowStaysOnTopHint);
    msg.setWindowTitle(title);
    msg.setText(txt);
    msg.setStandardButtons(QMessageBox::Ok);
    msg.exec();

}

bool PQCScriptsConfig::isMotionPhotoSupportEnabled() {
#ifdef PQMMOTIONPHOTO
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isPhotoSphereSupportEnabled() {
#ifdef PQMPHOTOSPHERE
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isZXingSupportEnabled() {
#ifdef PQMZXING
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLCMS2SupportEnabled() {
#ifdef PQMLCMS2
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isICUSupportEnabled() {
#ifdef PQMWITHOUTICU
    return false;
#endif
    return true;
}

void PQCScriptsConfig::callStartupSetupFresh() {

#ifndef PQMTESTING
    PQCStartupHandler startup(false, false);
    startup.setupFresh();
#endif

}

bool PQCScriptsConfig::askForConfirmation(QString title, QString text, QString informativeText) {
    QMessageBox msg;
    msg.setIcon(QMessageBox::Question);
    msg.setWindowFlag(Qt::WindowStaysOnTopHint);
    msg.setWindowTitle(title);
    msg.setText(text);
    msg.setInformativeText(informativeText);
    msg.setStandardButtons(QMessageBox::Yes | QMessageBox::Cancel);
    msg.setDefaultButton(QMessageBox::Yes);
    return (msg.exec() == QMessageBox::Yes);
}

bool PQCScriptsConfig::setInterfaceForNextStartup(QString variant) {
    QFile file(PQCConfigFiles::get().CACHE_DIR() + "/nextstartupvariant");
    if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        qWarning() << "Unable to toggle interface variant";
        return false;
    }
    QTextStream out(&file);
    out << variant;
    file.close();
    return true;
}

QString PQCScriptsConfig::getInterfaceForNextStartup() {
    QFile file(PQCConfigFiles::get().CACHE_DIR() + "/nextstartupvariant");
    if(!file.exists()) return "";
    if(!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Unable to read toggled interface variant";
        return "";
    }
    QTextStream in(&file);
    QString ret = in.readAll().trimmed();
    if(ret == "modern" || ret == "integrated")
        return ret;
    return "";
}
