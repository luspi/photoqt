#include <qlogging.h>   // needed in this form to compile with Qt 6.2
#include <QtDebug>
#include <QFileDialog>
#include <QImageReader>
#include <QQmlContext>
#include <pqc_configfiles.h>
#include <pqc_settings.h>
#include <pqc_shortcuts.h>
#include <pqc_validate.h>
#include <pqc_imageformats.h>
#include <scripts/pqc_scriptsconfig.h>

#ifdef WIN32
#include <WinSock2.h>
#endif

#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

#ifdef PUGIXML
#include <pugixml.hpp>
#endif

#ifdef RAW
#include <libraw/libraw.h>
#endif

#ifdef POPPLER
#include <poppler/poppler-config.h>
#endif

#if defined(IMAGEMAGICK) || defined(GRAPHICSMAGICK)
#include <Magick++/Include.h>
#endif

#ifdef DEVIL
#include <IL/il.h>
#endif

#ifdef FREEIMAGE
#include <FreeImage.h>
#endif

#ifdef VIDEOMPV
#include <pqc_mpvobject.h>
#endif

#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCScriptsConfig::PQCScriptsConfig() {
    trans = new QTranslator;
    currentTranslation = "en";
}

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

#ifdef EXIV2
    txt += QString(" - %1Exiv2%2: %3%4").arg(bold1, bold2, Exiv2::version(), nl);
#endif

#ifdef PUGIXML
    txt += QString(" - %1pugixml%2: %3%4").arg(bold1, bold2).arg((PUGIXML_VERSION)/1000.).arg(nl);
#endif

#ifdef CHROMECAST
    txt += QString(" - %1Chromecast%2%3").arg(bold1, bold2, nl);
#endif

#ifdef RAW
    txt += QString(" - %1LibRaw%2: %3%4").arg(bold1, bold2, LibRaw::version(), nl);
#endif

#ifdef POPPLER
    txt += QString(" - %1Poppler%2: %3%4").arg(bold1, bold2, POPPLER_VERSION, nl);
#endif

#ifdef QTPDF
    txt += QString(" - %1QtPDF%2%3").arg(bold1, bold2, nl);
#endif

#ifdef LIBARCHIVE
    txt += QString(" - %1LibArchive%2: %3%4").arg(bold1, bold2, ARCHIVE_VERSION_ONLY_STRING, nl);
#endif

#ifdef IMAGEMAGICK
    txt += QString(" - %1ImageMagick%2: %3%4").arg(bold1, bold2, MagickLibVersionText, nl);
#endif

#ifdef GRAPHICSMAGICK
    txt += QString(" - %1GraphicsMagick%2: %3%4").arg(bold1, bold2, MagickLibVersionText, nl);
#endif

#ifdef FREEIMAGE
    txt += QString(" - %1FreeImage%2: %3.%4%5").arg(bold1, bold2).arg(FREEIMAGE_MAJOR_VERSION).arg(FREEIMAGE_MINOR_VERSION).arg(nl);
#endif

#ifdef DEVIL
    txt += QString(" - %1DevIL%2: %3%4").arg(bold1, bold2).arg(IL_VERSION).arg(nl);
#endif

#ifdef VIDEOQT
    txt += QString(" - %1Video%2 through Qt%3").arg(bold1, bold2, nl);
#endif

#ifdef VIDEOMPV
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

    qDebug() << "args: path =" << path;

#ifdef LIBARCHIVE
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
    allfiles["CFG_SETTINGS_DB"] = PQCConfigFiles::SETTINGS_DB();
    allfiles["CFG_IMAGEFORMATS_DB"] = PQCConfigFiles::IMAGEFORMATS_DB();
    allfiles["CFG_CONTEXTMENU_DB"] = PQCConfigFiles::CONTEXTMENU_DB();
    allfiles["CFG_SHORTCUTS_DB"] = PQCConfigFiles::SHORTCUTS_DB();

    // handler to the file
    struct archive *a = archive_write_new();

    // Write a zip file with gzip compression
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
                qWarning() <<  QString("PQHandlingExternal::exportConfig(): ERROR: Unable to read config file '%1'... Skipping!").arg(iter.value());
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

bool PQCScriptsConfig::importConfigFrom(QString path, bool reloadData) {

    qDebug() << "args: path =" << path;

#ifdef LIBARCHIVE

    // All the config files to be imported
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_DB"] = PQCConfigFiles::SETTINGS_DB();
    allfiles["CFG_CONTEXTMENU_DB"] = PQCConfigFiles::CONTEXTMENU_DB();
    allfiles["CFG_SHORTCUTS_DB"] = PQCConfigFiles::SHORTCUTS_DB();
    allfiles["CFG_IMAGEFORMATS_DB"] = PQCConfigFiles::IMAGEFORMATS_DB();

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_zip(a);

    // Read file
    int r = archive_read_open_filename(a, path.toLocal8Bit().data(), 10240);

    // If something went wrong, output error message and stop here
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

            // Find out the size of the data
            size_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the data
            uchar *buff = new uchar[size+1];

            // And finally read the file into the buffer
            int r = archive_read_data(a, (void*)buff, size);
            if(r != (int)size) {
                qWarning() << QString("ERROR: Unable to extract file '%1':").arg(allfiles[filenameinside]) << archive_error_string(a) << "- Skipping file!";
                continue;
            }
            // libarchive does not add a null terminating character, but Qt expects it, so we need to add it on
            buff[size] = '\0';

            // The output file...
            QFile file(allfiles[filenameinside]);
            // Overwrite old content
            if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                file.write(reinterpret_cast<const char*>(buff), size+1);
                file.close();
            } else
                qWarning() << QString("ERROR: Unable to write new config file '%1'... Skipping file!").arg(allfiles[filenameinside]);

            delete[] buff;

        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        qWarning() << "ERROR: archive_read_free() returned code of" << r;

    // reload settings, shortcuts, and imageformats
    // we only reload when config was exported to default folders
    // we don't need to reload the contextmenu, the filewatcher takes care of that
    if(reloadData) {

        PQCSettings::get().readDB();
        PQCShortcuts::get().readDB();
        PQCImageFormats::get().readDatabase();

        PQCValidate validate;
        validate.validate();

    }

    return true;

#endif

    return false;

}

bool PQCScriptsConfig::isChromecastEnabled() {
#ifdef CHROMECAST
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLocationSupportEnabled() {
#ifdef LOCATION
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isGraphicsMagickSupportEnabled() {
#ifdef GRAPHICSMAGICK
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isImageMagickSupportEnabled() {
#ifdef IMAGEMAGICK
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isQtAtLeast6_4() {
#if (QT_VERSION >= QT_VERSION_CHECK(6, 4, 0))
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isPugixmlSupportEnabled() {
#ifdef PUGIXML
    return true;
#endif
    return false;
}

QString PQCScriptsConfig::getLastLoadedImage() {

    qDebug() << "";

    QString ret = "";

    QFile file(PQCConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        ret = in.readAll();
        file.close();
    }

    return ret.trimmed();

}

void PQCScriptsConfig::setLastLoadedImage(QString path) {

    qDebug() << "args: path =" << path;

    QFile file(PQCConfigFiles::LASTOPENEDIMAGE_FILE());
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
    QFile file(PQCConfigFiles::LASTOPENEDIMAGE_FILE());
    if(file.exists())
        file.remove();

}

bool PQCScriptsConfig::isMPVSupportEnabled() {
#ifdef VIDEOMPV
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isVideoQtSupportEnabled() {
#ifdef VIDEOQT
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isLibRawSupportEnabled() {
#ifdef RAW
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isDevILSupportEnabled() {
#ifdef DEVIL
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isFreeImageSupportEnabled() {
#ifdef FREEIMAGE
    return true;
#endif
    return false;
}

bool PQCScriptsConfig::isPopplerSupportEnabled() {
#ifdef POPPLER
    return true;
#endif
    return false;
}

QString PQCScriptsConfig::getVersion() {
    return VERSION;
}

QStringList PQCScriptsConfig::getAvailableTranslations() {

    qDebug() << "";

    QStringList ret;

    QStringList tmp;

    // the non-translated language is English
    tmp << "en";

    QDirIterator it(":/lang");
    while (it.hasNext()) {
        QString file = it.next();
        if(file.endsWith(".qm")) {
            file = file.remove(0, 15);
            file = file.remove(file.length()-3, file.length());
            if(!ret.contains(file))
                tmp.push_back(file);
        }
    }

    tmp.sort();
    ret.append(tmp);

    return ret;

}

void PQCScriptsConfig::updateTranslation() {

    QString code = PQCSettings::get()["interfaceLanguage"].toString();
    if(code == currentTranslation)
        return;

    if(!trans->isEmpty())
        qApp->removeTranslator(trans);


    const QStringList allcodes = code.split("/");

    for(const QString &c : allcodes) {

        if(QFile(":/lang/photoqt_" + c + ".qm").exists()) {

            if(trans->load(":/lang/photoqt_" + c)) {
                currentTranslation = c;
                qApp->installTranslator(trans);
            } else
                qWarning() << "Unable to install translator for language code" << c;

        } else if(c.contains("_")) {

            const QString cc = c.split("_").at(0);

            if(QFile(":/lang/photoqt_" + cc + ".qm").exists()) {

                if(trans->load(":/lang/photoqt_" + cc)) {
                    currentTranslation = cc;
                    qApp->installTranslator(trans);
                } else
                    qWarning() << "Unable to install translator for language code" << cc;

            }

        } else {

            const QString cc = QString("%1_%2").arg(c, c.toUpper());

            if(QFile(":/lang/photoqt_" + cc + ".qm").exists()) {

                if(trans->load(":/lang/photoqt_" + cc)) {
                    currentTranslation = cc;
                    qApp->installTranslator(trans);
                } else
                    qWarning() << "Unable to install translator for language code" << c;

            }
        }

    }

    QQmlEngine::contextForObject(this)->engine()->retranslate();

}

bool PQCScriptsConfig::isBetaVersion() {
    return QString(VERSION).contains("-beta");
}
