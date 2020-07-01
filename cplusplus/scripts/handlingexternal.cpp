#include "handlingexternal.h"
#include <QtDebug>

bool PQHandlingExternal::exportConfigTo(QString path) {

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
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_IMAGEFORMATS_FILE"] = ConfigFiles::IMAGEFORMATS_FILE();
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
                archive_write_data(a, configtxt, config.size());

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

    return true;

#endif
    return false;

}

bool PQHandlingExternal::importConfigFrom(QString path) {

#ifdef LIBARCHIVE

    // All the config files to be imported. To be backwards-compatible we use the filename keys (old way) and the real filenames (new way)
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();
    allfiles["IMAGEFORMATS_FILE"] = ConfigFiles::IMAGEFORMATS_FILE();

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
        ss << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: archive_read_open_filename() returned code of " << r << NL;
        LOG << ss.str();
        return false;
    }

    // Loop over entries in archive
    struct archive_entry *entry;
    while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

        // Read the current file entry
        QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

        if(allfiles.contains(filenameinside)) {

            // Find out the size of the data
            size_t size = archive_entry_size(entry);

            // Create a uchar buffer of that size to hold the data
            uchar *buff = new uchar[size+1];

            // And finally read the file into the buffer
            int r = archive_read_data(a, (void*)buff, size);
            if(r != (int)size) {
                LOG << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: Unable to extract file '" <<
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
                LOG << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: Unable to write new config file '" <<
                       allfiles[filenameinside].toStdString() << "'... Skipping file!" << NL;

            delete[] buff;

        }

    }

    // Close archive
    r = archive_read_free(a);
    if(r != ARCHIVE_OK)
        LOG << CURDATE << "GetAndDoStuffExternal::importConfig(): ERROR: archive_read_free() returned code of " << r << NL;

    return true;

#endif

    return false;

}
