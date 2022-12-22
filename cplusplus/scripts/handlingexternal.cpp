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

#include "handlingexternal.h"

PQHandlingExternal::PQHandlingExternal(QObject *parent) : QObject(parent) {
    imageprovider = nullptr;
}

void PQHandlingExternal::copyTextToClipboard(QString txt, bool removeHTML) {

    DBG << CURDATE << "PQHandlingExternal::copyTextToClipboard()" << NL
        << CURDATE << "** txt = " << txt.toStdString() << NL;

    if(removeHTML)
        txt = QTextDocumentFragment::fromHtml(txt).toPlainText();

    QApplication::clipboard()->setText(txt, QClipboard::Clipboard);

}

void PQHandlingExternal::copyToClipboard(QString filename) {

    DBG << CURDATE << "PQHandlingExternal::copyToClipboard()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    if(filename == "")
        return;

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new PQImageProviderFull;

    // set image to clipboard
    QImage img = imageprovider->requestImage(filename, new QSize, QSize());
    qApp->clipboard()->setImage(img);

}

void PQHandlingExternal::executeExternal(QString exe, QString args, QString currentfile) {

    DBG << CURDATE << "PQHandlingExternal::executeExternal()" << NL
        << CURDATE << "** exe = " << exe.toStdString() << NL
        << CURDATE << "** args = " << args.toStdString() << NL
        << CURDATE << "** currentfile = " << currentfile.toStdString() << NL;

    if(exe == "")
        return;

    QFileInfo info(currentfile);

    QStringList argslist;
    QStringList argslist_tmp = args.split(" ");

    for(auto &a : argslist_tmp) {
        if(a.contains("%f"))
            a = a.replace("%f", currentfile);
        if(args.contains("%u"))
            a = a.replace("%u", info.fileName());
        if(a.contains("%d"))
            a = a.replace("%d", info.absolutePath());
        argslist << a;
    }

    QProcess proc;
    proc.setProgram(exe);
    proc.setArguments(argslist);

    proc.startDetached();

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

    QSqlDatabase db = QSqlDatabase::database("contextmenu");

    if(!db.open()) {
        LOG << CURDATE << "PQHandlingExternal::getContextMenuEntries(): SQL error, db.open(): " << db.lastError().text().trimmed().toStdString() << NL;
        return ret;
    }

    QSqlQuery query(db);
    query.prepare("SELECT command,arguments,icon,desc,close FROM entries");
    if(!query.exec()) {
        LOG << CURDATE << "PQHandlingExternal::getContextMenuEntries(): SQL error, select: " << query.lastError().text().trimmed().toStdString() << NL;
        return ret;
    }

    while(query.next()) {

        const QString command = query.record().value(0).toString();
        const QString arguments = query.record().value(1).toString();
        const QString icon = query.record().value(2).toString();
        const QString desc = query.record().value(3).toString();
        const QString close = query.record().value(4).toString();

        QStringList thisentry;

        thisentry << icon;      // icon (if specified)
        thisentry << command;   // executable
        thisentry << desc;      // name
        thisentry << close;     // close
        thisentry << arguments; // command line arguments

        ret << thisentry;

    }

    query.clear();

    return ret;

}

void PQHandlingExternal::replaceContextMenuEntriesWithAvailable() {

    // These are the possible entries
    // There will be a ' %f' added at the end of each executable.
    QStringList m;
    //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
    m << QApplication::translate("startup", "Edit with %1").arg("Gimp") << "gimp"
         //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Edit with %1").arg("Krita") << "krita"
         //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Edit with %1").arg("KolourPaint") << "kolourpaint"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("GwenView") << "gwenview"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("showFoto") << "showfoto"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("Shotwell") << "shotwell"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("GThumb") << "gthumb"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("Eye of Gnome") << "eog";

    {
        QSqlDatabase db = QSqlDatabase::database("contextmenu");
        if(!db.open())
            LOG << CURDATE << "PQStartup::setupFresh(): Error opening contextmenu database: " << db.lastError().text().trimmed().toStdString() << NL;

        QSqlQuery query(db);
        query.exec("DELETE FROM entries");
        query.clear();

        // Check for all entries
        for(int i = 0; i < m.size()/2; ++i) {
            if(checkIfBinaryExists(m[2*i+1])) {

                QSqlQuery query(db);
                query.prepare("INSERT INTO entries (command,arguments,desc,close) VALUES(:cmd,:arg,:dsc,:cls)");
                query.bindValue(":cmd", m[2*i+1]);
                query.bindValue(":arg", "%f");
                query.bindValue(":dsc", m[2*i]);
                query.bindValue(":cls", "0");
                if(!query.exec())
                    LOG << CURDATE << "PQStartup::setupFresh(): SQL error, contextmenu insert: " << query.lastError().text().trimmed().toStdString() << NL;

            }
        }

    }

}

bool PQHandlingExternal::checkIfBinaryExists(QString exec) {

#ifdef Q_OS_WIN
    return false;
#endif

    QProcess p;
    p.setStandardOutputFile(QProcess::nullDevice());
    p.start("which", QStringList() << exec);
    p.waitForFinished();
    return p.exitCode() == 0;
}

QString PQHandlingExternal::getIconPathFromTheme(QString binary) {

    DBG << CURDATE << "PQHandlingExternal::getIconPathFromTheme()" << NL
        << CURDATE << "** binary = " << binary.toStdString() << NL;

    // We go through all the themeSearchPath elements
    for(int i = 0; i < QIcon::themeSearchPaths().length(); ++i) {

        // Setup path (this is the most likely directory) and format (PNG)
        QString path = QIcon::themeSearchPaths().at(i) + "/hicolor/32x32/apps/" + binary.trimmed() + ".png";
        if(QFile(path).exists())
            return "file://" + path;
        else {
            // Also check a smaller version
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file://" + path;
            else {
                // And check 24x24, if not in the two before, it most likely is in here (e.g., shotwell on my system)
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file://" + path;
            }
        }

        // Do the same checks as above for SVG

        path = path.replace("22x22","32x32").replace(".png",".svg");
        if(QFile(path).exists())
            return "file://" + path;
        else {
            path = path.replace("32x32","22x22");
            if(QFile(path).exists())
                return "file://" + path;
            else {
                path = path.replace("22x22","24x24");
                if(QFile(path).exists())
                    return "file://" + path;
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
    QHash<QString,QString> oldfiles;
    oldfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    oldfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    oldfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();
    QHash<QString,QString> allfiles;
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

    PQStartup startup;

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        // We use the '_w' variant here, as otherwise on Windows this call causes a segfault when a file in an archive contains non-latin characters
        QString filenameinside = QString::fromWCharArray(archive_entry_pathname_w(entry));

        if(allfiles.contains(filenameinside) || oldfiles.contains(filenameinside)) {

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

            // export in new database-based format
            if(allfiles.contains(filenameinside)) {

                // The output file...
                QFile file(allfiles[filenameinside]);
                // Overwrite old content
                if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                    file.write(reinterpret_cast<const char*>(buff), size+1);
                    file.close();
                } else
                    LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to write new config file '" <<
                           allfiles[filenameinside].toStdString() << "'... Skipping file!" << NL;

            // export in old text-based format
            } else {

                QFile file(oldfiles[filenameinside]);
                // Overwrite old content
                if(file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
                    file.write(reinterpret_cast<const char*>(buff), size+1);
                    file.close();

                    if(filenameinside == "CFG_CONTEXTMENU_FILE") {
                        QFile::remove(ConfigFiles::CONTEXTMENU_DB());
                        if(!startup.migrateContextmenuToDb())
                            LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to migrate imported contextmenu" << NL;
                    } else if(filenameinside == "CFG_SHORTCUTS_FILE") {
                        QFile::remove(ConfigFiles::SHORTCUTS_DB());
                        if(!startup.migrateShortcutsToDb())
                            LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to migrate imported shortcuts" << NL;
                    } else if(filenameinside == "CFG_SETTINGS_FILE") {
                        QFile::remove(ConfigFiles::SETTINGS_DB());
                        if(!startup.migrateSettingsToDb())
                            LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to migrate imported settings" << NL;
                    }

                } else
                    LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: Unable to write new temporary config file '" <<
                           oldfiles[filenameinside].toStdString() << "'... Skipping file!" << NL;

            }

            delete[] buff;

        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        LOG << CURDATE << "PQHandlingExternal::importConfigFrom(): ERROR: archive_read_free() returned code of " << r << NL;

    // reload settings, shortcuts, and imageformats
    // we don't need to reload the contextmenu, the filewatcher takes care of that
    PQSettings::get().readDB();
    PQShortcuts::get().readDB();
    PQImageFormats::get().readDatabase();

    return true;

#endif

    return false;

}

void PQHandlingExternal::openInDefaultFileManager(QString filename) {

    DBG << CURDATE << "PQHandlingExternal::openInDefaultFileManager()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

#ifdef Q_OS_WIN
    QProcess::startDetached("explorer.exe", {"/select,", QDir::toNativeSeparators(filename)});
#else
    QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(filename).absolutePath()));
#endif

}

void PQHandlingExternal::saveContextMenuEntries(QVariantList entries) {

    DBG << CURDATE << "PQHandlingExternal::saveContextMenuEntries()" << NL
        << CURDATE << "** entries.length() = " << entries.length() << NL;

    QString cont = "";

    bool dontcontinue = false;

    QSqlDatabase db = QSqlDatabase::database("contextmenu");

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

            const QString cmd = entrylist.at(1).toString();
            const QString args = entrylist.at(4).toString();
            const QString icn = entrylist.at(0).toString();
            const QString dsc = entrylist.at(2).toString();
            const QString close = entrylist.at(3).toString();

            if(cmd != "" && dsc != "") {

                QSqlQuery query(db);
                query.prepare("INSERT INTO entries (icon,command,arguments,desc,close) VALUES(:icn,:cmd,:arg,:dsc,:cls)");
                query.bindValue(":cmd", cmd);
                query.bindValue(":arg", args);
                query.bindValue(":icn", icn);
                query.bindValue(":dsc", dsc);
                query.bindValue(":cls", close);
                if(!query.exec())
                    LOG << CURDATE << "PQHandlingExternal::saveContextMenuEntries(): SQL error, insert: " << query.lastError().text().trimmed().toStdString() << NL;

            }

        }

    }

}

QSize PQHandlingExternal::getScreenSize() {
    DBG << CURDATE << "PQHandlingExternal::getScreenSize()" << NL;
    return QApplication::primaryScreen()->size();
}

QString PQHandlingExternal::loadImageAndConvertToBase64(QString filename) {

    PQHandlingFileDir filedir;
    filename = filedir.cleanPath(filename);

    QPixmap pix;
    pix.load(filename);
    if(pix.width() > 64 || pix.height() > 64)
        pix = pix.scaled(64,64,Qt::KeepAspectRatio);
    QByteArray bytes;
    QBuffer buffer(&bytes);
    buffer.open(QIODevice::WriteOnly);
    pix.save(&buffer, "PNG");
    return bytes.toBase64();

}
