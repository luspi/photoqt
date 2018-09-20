/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#include "external.h"

GetAndDoStuffExternal::GetAndDoStuffExternal(QObject *parent) : QObject(parent) {
     imageprovider = nullptr;
}

GetAndDoStuffExternal::~GetAndDoStuffExternal() {
    if(imageprovider != nullptr)
        delete imageprovider;
}

void GetAndDoStuffExternal::openLink(QString url) {
    QDesktopServices::openUrl(url);
}

void GetAndDoStuffExternal::executeApp(QString exec, QString fname) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffExternal::executeApp() - " << exec.toStdString() << " / " << fname.toStdString() << NL;

    fname = QByteArray::fromPercentEncoding(fname.toUtf8());

    QProcess *p = new QProcess;
    exec = exec.replace("%f", "\"" + fname + "\"");
    exec = exec.replace("%u", "\"" + QFileInfo(fname).fileName() + "\"");
    exec = exec.replace("%d", "\"" + QFileInfo(fname).absoluteDir().absolutePath() + "\"");

    p->startDetached(exec);
    if(p->error() == 5)
        p->waitForStarted(2000);

    delete p;

}

void GetAndDoStuffExternal::openInDefaultFileManager(QString file) {
    QDesktopServices::openUrl(QUrl("file://" + QFileInfo(file).absolutePath()));
}

QString GetAndDoStuffExternal::exportConfig(QString useThisFilename) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffExternal::exportConfig() - " << useThisFilename.toStdString() << NL;

    // Obtain a filename from the user or used passed on filename
    QString archiveFile;
    if(useThisFilename == "") {
        archiveFile = QFileDialog::getSaveFileName(nullptr,
                                                   "Select Location",
                                                   QDir::homePath() + "/photoqtconfig.pqt",
                                                   "PhotoQt Config File (*.pqt);;All Files (*.*)");
        if(archiveFile.trimmed() == "")
            return "-";
    } else
        archiveFile = useThisFilename;

    // if no suffix, append the pqt suffix
    if(!archiveFile.endsWith(".pqt"))
        archiveFile += ".pqt";

    // All the config files
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_IMAGEFORMATS_FILE"] = ConfigFiles::IMAGEFORMATS_FILE();
    allfiles["CFG_MIMEFORMATS_FILE"] = ConfigFiles::MIMEFORMATS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();

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
                QTextStream in(&config);
                QByteArray configtxt = in.readAll().toLatin1();

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
                archive_write_data(a, configtxt, static_cast<size_t>(config.size()));

                // Clean up memory
                archive_entry_free(entry);

            } else
                LOG << CURDATE << "GetAndDoStuffExternal::exportConfig(): ERROR: Unable to read config file '" <<
                       iter.value().toStdString() << "'... Skipping!" << NL;
        }
        ++iter;
    }

    // Clean up memory
    archive_write_close(a);
    archive_write_free(a);

    return "";

}

QString GetAndDoStuffExternal::importConfig(QString filename) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffExternal::importConfig() - " << filename.toStdString() << NL;

    // All the config files to be imported. To be backwards-compatible we use the filename keys (old way) and the real filenames (new way)
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();
    allfiles["IMAGEFORMATS_FILE"] = ConfigFiles::IMAGEFORMATS_FILE();
    allfiles["MIMEFORMATS_FILE"] = ConfigFiles::MIMEFORMATS_FILE();

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_zip(a);

    // Read file
    int r = archive_read_open_filename(a, filename.toLatin1(), 10240);

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        std::stringstream ss;
        ss << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: archive_read_open_filename() returned code of " << r << NL;
        LOG << ss.str();
        return QString::fromStdString(ss.str());
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

        if(allfiles.contains(filenameinside)) {

            // Find out the size of the data
            int64_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the data
            uchar *buff = new uchar[size+1];

            // And finally read the file into the buffer
            int64_t r = archive_read_data(a, reinterpret_cast<void*>(buff), static_cast<size_t>(size));
            if(r != size) {
                LOG << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: Unable to extract file '" <<
                       allfiles[filenameinside].toStdString() << "'... Skipping file!" << NL;
                qDebug() << "ERROR string: " << archive_error_string(a);
                continue;
            }
            // libarchive does not add a null terminating character, but Qt expects it, so we need to add it on
            buff[size] = '\0';

            // try to extract file into destination file, return empty string on error
            QByteArray dat = reinterpret_cast<char*>(&buff);

            delete[] buff;

            // The output file...
            QFile file(allfiles[filenameinside]);
            // Overwrite old content
            if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                QTextStream out(&file);
                out << dat;
                file.close();
            } else
                LOG << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: Unable to write new config file '" <<
                       allfiles[filenameinside].toStdString() << "'... Skipping file!" << NL;

        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        LOG << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: archive_read_free() returned code of " << r << NL;

    return "";

}

void GetAndDoStuffExternal::restartPhotoQt(QString loadThisFileAfter) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffExternal::restartPhotoQt() - " << loadThisFileAfter.toStdString() << NL;

    // restart PhotoQt, prepend 'RESTARTRESTARTRESTART' to file to be loader
    // -> this causes PhotoQt to load at startup to make sure this instance is first properly closed
    qApp->quit();
    QProcess::startDetached(qApp->arguments()[0], QStringList() << QString("RESTARTRESTARTRESTART%1").arg(loadThisFileAfter));
}

bool GetAndDoStuffExternal::checkIfConnectedToInternet() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffExternal::checkIfConnectedToInternet()" << NL;

    // will store the return value
    bool internetConnected = false;

    // Get a list of all network interfaces
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();

    // a reg exp to validate an ip address
    QRegExp ipRegExp( "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}" );
    QRegExpValidator ipRegExpValidator(ipRegExp, nullptr);

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

void GetAndDoStuffExternal::clipboardSetImage(QString filepath) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffExternal::clipboardSetImage() - " << filepath.toStdString() << NL;

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new ImageProviderFull;

    // remove possible prefix
    if(filepath.startsWith("file:/"))
        filepath = filepath.remove(0,6);
    if(filepath.startsWith("image://full/"))
        filepath = filepath.remove(0,13);

#ifdef Q_OS_WIN
    while(filepath.startsWith("/"))
        filepath = filepath.remove(0,1);
#endif

    // request image
    QImage img = imageprovider->requestImage(filepath, new QSize, QSize());

    // create mime data object with url and image data
    QMimeData *data = new QMimeData;
    data->setUrls(QList<QUrl>() << "file://" + filepath);
    data->setImageData(img);

    // set mime data to clipboard
    qApp->clipboard()->setMimeData(data);

}
