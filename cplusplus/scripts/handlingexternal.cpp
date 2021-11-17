/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#include "handlingexternal.h"

void PQHandlingExternal::copyTextToClipboard(QString txt) {

    DBG << CURDATE << "PQHandlingExternal::copyTextToClipboard()" << NL
        << CURDATE << "** txt = " << txt.toStdString() << NL;

    QApplication::clipboard()->setText(txt, QClipboard::Clipboard);

}

void PQHandlingExternal::copyToClipboard(QString filename) {

    DBG << CURDATE << "PQHandlingExternal::copyToClipboard()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new PQImageProviderFull;

    // set image to clipboard
    qApp->clipboard()->setImage(imageprovider->requestImage(filename, new QSize, QSize()));

}

void PQHandlingExternal::executeExternal(QString cmd, QString currentfile) {

    DBG << CURDATE << "PQHandlingExternal::executeExternal()" << NL
        << CURDATE << "** cmd = " << cmd.toStdString() << NL
        << CURDATE << "** currentfile = " << currentfile.toStdString() << NL;

    QString executable = "";
    QStringList arguments = cmd.split(" ");
    if(!arguments.at(0).startsWith("/")) {
        executable = arguments.at(0);
        arguments.removeFirst();
    } else {

        QString path = arguments[0];
        int i;
        for(i = 1; i < arguments.length(); ++i) {
            path += " ";
            path += arguments[i];
            QFileInfo info(path);
            if(info.exists() && info.isFile()) {
                i += 1;
                break;
            }
        }
        if(i == arguments.length()) {
            LOG << CURDATE << "PQHandlingExternal::executeExternal(): Error, unable to execute: " << cmd.toStdString() << NL;
            return;
        }
        executable = path;
        arguments.erase(arguments.begin(), arguments.begin()+i);
    }

    QFileInfo info(currentfile);

    for(int i = 0; i < arguments.length(); ++i) {
        if(arguments[i].contains("%f"))
            arguments[i] = arguments[i].replace("%f", currentfile);
        if(arguments[i].contains("%u"))
            arguments[i] = arguments[i].replace("%u", info.fileName());
        if(arguments[i].contains("%d"))
            arguments[i] = arguments[i].replace("%d", info.absolutePath());
    }

    QProcess::startDetached(executable, arguments);

}

bool PQHandlingExternal::exportConfigTo(QString path) {

    DBG << CURDATE << "PQHandlingExternal::exportConfigTo()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

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
    allfiles["CFG_SETTINGS_DB"] = ConfigFiles::SETTINGS_DB();
    allfiles["CFG_IMAGEFORMATS_DB"] = ConfigFiles::IMAGEFORMATS_DB();
    allfiles["CFG_CONTEXTMENU_DB"] = ConfigFiles::CONTEXTMENU_DB();
    allfiles["CFG_SHORTCUTS_DB"] = ConfigFiles::SHORTCUTS_DB();

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
                archive_write_data(a, configtxt, config.size());

                // Clean up memory
                archive_entry_free(entry);

            } else
                LOG << CURDATE << "PQHandlingExternal::exportConfig(): ERROR: Unable to read config file '" <<
                       iter.value().toStdString() << "'... Skipping!" << NL;
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

QString PQHandlingExternal::findDropBoxFolder() {

#if defined Q_OS_UNIX || defined Q_OS_WIN

    // credit for how to find DropBox location:
    // https://stackoverflow.com/questions/12118162/how-to-determine-the-dropbox-folder-location-programmatically

#ifdef Q_OS_UNIX
    QFile f(QDir::homePath()+"/.dropbox/host.db");
#elif defined Q_OS_WIN
    QFile f(QString("%1/Dropbox/host.db").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists()) {
        f.open(QIODevice::ReadOnly);
        QTextStream in(&f);
        QStringList txt = in.readAll().split("\n");
        if(txt.length() > 1) {
            QString path = QByteArray::fromBase64(txt[1].toUtf8());
            if(path.endsWith("/"))
                return path.remove(path.length()-1,1);
            return path;
        }
    }
#endif

    return "";

}

QString PQHandlingExternal::findNextcloudFolder() {

#if defined Q_OS_UNIX || defined Q_OS_WIN
#if defined Q_OS_UNIX
    QFile f(QDir::homePath()+"/.config/Nextcloud/nextcloud.cfg");
#elif defined Q_OS_WIN
    QFile f(QString("%1/Nextcloud/nextcloud.cfg").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists()) {
        f.open(QIODevice::ReadOnly);
        QTextStream in(&f);
        QString txt = in.readAll();
        if(txt.contains("0\\Folders\\1\\localPath=")) {
            QString path = txt.split("0\\Folders\\1\\localPath=")[1].split("\n")[0];
            if(path.endsWith("/"))
                return path.remove(path.length()-1,1);
            return path;
        }
    }
#endif

    return "";

}

QString PQHandlingExternal::findOwnCloudFolder() {

#if defined Q_OS_UNIX || defined Q_OS_WIN
#if defined Q_OS_UNIX
    QFile f(QDir::homePath()+"/.config/ownCloud/owncloud.cfg");
#elif defined Q_OS_WIN
    QFile f(QString("%1/ownCloud/owncloud.cfg").arg(QStandardPaths::AppDataLocation));
#endif
    if(f.exists()) {
        f.open(QIODevice::ReadOnly);
        QTextStream in(&f);
        QString txt = in.readAll();
        if(txt.contains("0\\Folders\\1\\localPath=")) {
            QString path = txt.split("0\\Folders\\1\\localPath=")[1].split("\n")[0];
            if(path.endsWith("/"))
                return path.remove(path.length()-1,1);
            return path;
        }
    }
#endif

    return "";

}

QVariantList PQHandlingExternal::getContextMenuEntries() {

    DBG << CURDATE << "PQHandlingExternal::getContextMenuEntries()" << NL;

    QVariantList ret;

    { // create limited scope for database variables to allow for use of QSqlDatabase::removeDatabase()

        QSqlDatabase db;
        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            db = QSqlDatabase::addDatabase("QSQLITE3", "contextmenu");
        else
            db = QSqlDatabase::addDatabase("QSQLITE", "contextmenu");

        db.setHostName("contextmenu");
        db.setDatabaseName(ConfigFiles::CONTEXTMENU_DB());

        if(!db.open()) {
            LOG << CURDATE << "PQHandlingExternal::getContextMenuEntries(): SQL error, db.open(): " << db.lastError().text().trimmed().toStdString() << NL;
            return ret;
        }

        QSqlQuery query(db);
        query.prepare("SELECT command,desc,close FROM entries");
        if(!query.exec()) {
            LOG << CURDATE << "PQHandlingExternal::getContextMenuEntries(): SQL error, select: " << query.lastError().text().trimmed().toStdString() << NL;
            db.close();
            return ret;
        }

        while(query.next()) {

            const QString command = query.record().value(0).toString();
            const QString desc = query.record().value(1).toString();
            const QString close = query.record().value(2).toString();

            QStringList thisentry;

            thisentry << QString("_:_EX_:_%1").arg(command);
            thisentry << command.split(" ").at(0);
            thisentry << desc;
            thisentry << (close=="1" ? "close" : "donthide");

            ret << thisentry;

        }

        query.clear();
        db.close();

    }

    QSqlDatabase::removeDatabase("contextmenu");

    return ret;

}

QString PQHandlingExternal::getIconPathFromTheme(QString binary) {

    DBG << CURDATE << "PQHandlingExternal::getIconPathFromTheme()" << NL
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

bool PQHandlingExternal::importConfigFrom(QString path) {

    DBG << CURDATE << "PQHandlingExternal::importConfigFrom()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

#ifdef LIBARCHIVE

    // All the config files to be imported
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();
    allfiles["CFG_IMAGEFORMATS_FILE"] = ConfigFiles::IMAGEFORMATS_FILE();
    allfiles["CFG_SETTINGS_DB"] = ConfigFiles::SETTINGS_DB();
    allfiles["CFG_CONTEXTMENU_DB"] = ConfigFiles::CONTEXTMENU_DB();
    allfiles["CFG_SHORTCUTS_DB"] = ConfigFiles::SHORTCUTS_DB();
    allfiles["CFG_IMAGEFORMATS_DB"] = ConfigFiles::IMAGEFORMATS_DB();

    // Create new archive handler
    struct archive *a = archive_read_new();

    // We allow any type of compression and format
    archive_read_support_filter_all(a);
    archive_read_support_format_zip(a);

    // Read file
    int r = archive_read_open_filename(a, path.toLocal8Bit().data(), 10240);

    // If something went wrong, output error message and stop here
    if(r != ARCHIVE_OK) {
        std::stringstream ss;
        ss << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: archive_read_open_filename() returned code of " << r << NL;
        LOG << ss.str();
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
                LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to extract file '" <<
                       allfiles[filenameinside].toStdString() << "': " << archive_error_string(a) << " - Skipping file!" << NL;
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
                LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to write new config file '" <<
                       allfiles[filenameinside].toStdString() << "'... Skipping file!" << NL;

            delete[] buff;

        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: archive_read_free() returned code of " << r << NL;

    return true;

#endif

    return false;

}

void PQHandlingExternal::openInDefaultFileManager(QString filename) {

    DBG << CURDATE << "PQHandlingExternal::openInDefaultFileManager()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    QDesktopServices::openUrl(QUrl("file://" + QFileInfo(filename).absolutePath()));

}

void PQHandlingExternal::saveContextMenuEntries(QVariantList entries) {

    DBG << CURDATE << "PQHandlingExternal::saveContextMenuEntries()" << NL
        << CURDATE << "** entries.length() = " << entries.length() << NL;

    QString cont = "";

    { // create limited scope for database variables to allow for use of QSqlDatabase::removeDatabase()

        bool dontcontinue = false;

        QSqlDatabase db;
        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            db = QSqlDatabase::addDatabase("QSQLITE3", "contextmenu");
        else
            db = QSqlDatabase::addDatabase("QSQLITE", "contextmenu");

        db.setHostName("contextmenu");
        db.setDatabaseName(ConfigFiles::CONTEXTMENU_DB());

        if(!db.open()) {
            LOG << CURDATE << "PQHandlingExternal::saveContextMenuEntries(): SQL error, db.open(): " << db.lastError().text().trimmed().toStdString() << NL;
            dontcontinue = true;
        }

        if(!dontcontinue) {

            QSqlQuery query(db);
            query.prepare("DELETE FROM entries");
            if(!query.exec()) {
                LOG << CURDATE << "PQHandlingExternal::saveContextMenuEntries(): SQL error, truncate: " << query.lastError().text().trimmed().toStdString() << NL;
                dontcontinue = true;
            }

            for(const auto &entry : qAsConst(entries)) {

                if(dontcontinue)
                    continue;

                QVariantList entrylist = entry.toList();

                const QString close = QString::number(entrylist.at(2).toInt());
                const QString cmd = entrylist.at(1).toString();
                const QString dsc = entrylist.at(0).toString();

                if(cmd != "" && dsc != "") {

                    QSqlQuery query(db);
                    query.prepare("INSERT INTO entries (command,desc,close) VALUES(:cmd,:dsc,:cls)");
                    query.bindValue(":cmd", cmd);
                    query.bindValue(":dsc", dsc);
                    query.bindValue(":cls", close);
                    if(!query.exec())
                        LOG << CURDATE << "PQHandlingExternal::saveContextMenuEntries(): SQL error, insert: " << query.lastError().text().trimmed().toStdString() << NL;

                }

            }

        }

        db.close();

    }

    QSqlDatabase::removeDatabase("contextmenu");


}

QSize PQHandlingExternal::getScreenSize() {
    DBG << CURDATE << "PQHandlingExternal::getScreenSize()" << NL;
    return QApplication::primaryScreen()->size();
}
