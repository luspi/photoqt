#include "handlingfilemanagement.h"
#include <QtDebug>

bool PQHandlingFileManagement::renameFile(QString dir, QString oldName, QString newName) {

    QFile file(dir + "/" + oldName);
    return file.rename(dir + "/" + newName);

}

bool PQHandlingFileManagement::deleteFile(QString filename, bool permanent) {

    if(permanent) {

        QFile file(filename);
        return file.remove();

    } else {

        // The file to delete
        QFile file(filename);

        // Of course we only proceed if the file actually exists
        if(file.exists()) {

            // Create the meta .trashinfo file
            QString info = "[Trash Info]\n";
            info += "Path=" + QUrl(filename).toEncoded() + "\n";
            info += "DeletionDate=" + QDateTime::currentDateTime().toString("yyyy-MM-ddThh:mm:ss");

            // The base patzh for the Trah (files on external devices  use the external device for Trash)
            QString baseTrash = "";

            // If file lies in the home directory
            if(QFileInfo(filename).absoluteFilePath().startsWith(QDir::homePath())) {

                // Set the base path and make sure all the dirs exist
                baseTrash = ConfigFiles::GENERIC_DATA_DIR() + "/Trash/";

                QDir dir;
                dir.setPath(baseTrash);
                if(!dir.exists()) {
                    if(!dir.mkpath(baseTrash)) {
                        LOG << "PQHandlingFileManagement [mkdir home: baseTrash] ERROR: mkdir() failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "files");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "files")) {
                        LOG << "PQHandlingFileManagement [mkdir home: baseTrash/Trash] ERROR: mkdir() failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "info");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "info")) {
                        LOG << "PQHandlingFileManagement [mkdir home: baseTrash/info] ERROR: mkdir() failed!";
                        return false;
                    }
                }
            } else {
                // Set the base path ...
                for(QStorageInfo &storage : QStorageInfo::mountedVolumes()) {
                    if(!storage.isReadOnly() && storage.isValid() && filename.startsWith(storage.rootPath()) &&
                       baseTrash.length() < storage.rootPath().length()) {
                        baseTrash = storage.rootPath();
                    }
                }
                baseTrash += "/" + QString("/.Trash-%1/").arg(getuid());
                // ... and make sure all the dirs exist
                QDir dir;
                dir.setPath(baseTrash);
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash)) {
                        LOG << "PQHandlingFileManagement [mkdir baseTrash] ERROR: mkdir() failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "files");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "files")) {
                        LOG << "PQHandlingFileManagement [mkdir baseTrash/files] ERROR: mkdir() failed!";
                        return false;
                    }
                }
                dir.setPath(baseTrash + "info");
                if(!dir.exists()) {
                    if(!dir.mkdir(baseTrash + "info")) {
                        LOG << "PQHandlingFileManagement [mkdir baseTrash/info] ERROR: mkdir() failed!";
                        return false;
                    }
                }

            }

            // that's the new trash file
            QString trashFile = baseTrash + "files/" + QUrl::toPercentEncoding(QFileInfo(file).fileName(),""," ");
            QString backupTrashFile = trashFile;

            // If there exists already a file with that name, we simply append the next higher number (sarting at 1)
            QFile ensure(trashFile);
            int j = 1;
            while(ensure.exists()) {
                trashFile = backupTrashFile + QString(" (%1)").arg(j++);
                ensure.setFileName(trashFile);
            }

            // Copy the file to the Trash
            if(file.copy(trashFile)) {

                // And remove the old file
                if(!file.remove()) {
                    LOG << CURDATE << "PQHandlingFileManagement: ERROR: Old file couldn't be removed!" << NL;
                    return false;
                }

                // Write the .trashinfo file
                QFile i(baseTrash + "info/" + QFileInfo(trashFile).fileName() + ".trashinfo");
                if(i.open(QIODevice::WriteOnly)) {
                    QTextStream out(&i);
                    out << info;
                    i.close();
                } else {
                    LOG << CURDATE << "PQHandlingFileManagement: ERROR: *.trashinfo file couldn't be created!" << NL;
                    return false;
                }

            } else {
                LOG << CURDATE << "PQHandlingFileManagement: ERROR: File couldn't be deleted (moving file failed)" << NL;
                return false;
            }

        } else {
            LOG << CURDATE << "PQHandlingFileManagement: ERROR: File '" << filename.toStdString() << "' doesn't exist...?" << NL;
            return false;
        }

    }

    return true;

}
