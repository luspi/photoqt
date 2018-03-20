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
    QString zipFile;
    if(useThisFilename == "") {
        zipFile = QFileDialog::getSaveFileName(0, "Select Location", QDir::homePath() + "/photoqtconfig.pqt", "PhotoQt Config File (*.pqt);;All Files (*.*)");
        if(zipFile.trimmed() == "")
            return "-";
    } else
        zipFile = useThisFilename;

    // if no suffix, append the pqt suffix
    if(!zipFile.endsWith(".pqt"))
        zipFile += ".pqt";

#ifdef QUAZIP

    QStringList list;
    if(QFileInfo(ConfigFiles::SETTINGS_FILE()).exists())
        list << ConfigFiles::SETTINGS_FILE();
    if(QFileInfo(ConfigFiles::IMAGEFORMATS_FILE()).exists())
        list << ConfigFiles::IMAGEFORMATS_FILE();
    if(QFileInfo(ConfigFiles::MIMEFORMATS_FILE()).exists())
        list << ConfigFiles::MIMEFORMATS_FILE();
    if(QFileInfo(ConfigFiles::CONTEXTMENU_FILE()).exists())
        list << ConfigFiles::CONTEXTMENU_FILE();
    if(QFileInfo(ConfigFiles::SHORTCUTS_FILE()).exists())
        list << ConfigFiles::SHORTCUTS_FILE();

    if(list.length() == 0)
        return "No config files have been found for exporting... Nothing for me to do!\n";

    JlCompress::compressFiles(zipFile, list);

#else

    // All the config files to be exported
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_IMAGEFORMATS_FILE"] = ConfigFiles::IMAGEFORMATS_FILE();
    allfiles["CFG_MIMEFORMATS_FILE"] = ConfigFiles::MIMEFORMATS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();

    // Start a writer for the zip file
    ZipWriter writer(zipFile);

    // Iterate over filenames to be exported
    QHash<QString, QString>::const_iterator i = allfiles.constBegin();
    while(i != allfiles.constEnd()) {

        // Create and open file in read only mode
        QFile file(i.value());
        if(!file.exists()) {
            ++i;
            continue;
        }
        if(!file.open(QIODevice::ReadOnly)) {
            std::stringstream ss;
            ss << "ERROR: Unable to open '" << i.value().toStdString() << "' file for composing config file: " << file.errorString().trimmed().toStdString();
            LOG << CURDATE << ss.str() << NL;
            // on error, return error string
            return QString::fromStdString(ss.str());
        }

        // Add the file to the zip file
        writer.addFile(i.key(),file.readAll());

        file.close();

        ++i;
    }

    // close zip writer
    writer.close();

#endif

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
    allfiles[QFileInfo(ConfigFiles::SETTINGS_FILE()).fileName()] = ConfigFiles::SETTINGS_FILE();
    allfiles[QFileInfo(ConfigFiles::IMAGEFORMATS_FILE()).fileName()] = ConfigFiles::IMAGEFORMATS_FILE();
    allfiles[QFileInfo(ConfigFiles::MIMEFORMATS_FILE()).fileName()] = ConfigFiles::MIMEFORMATS_FILE();
    allfiles[QFileInfo(ConfigFiles::CONTEXTMENU_FILE()).fileName()] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles[QFileInfo(ConfigFiles::SHORTCUTS_FILE()).fileName()] = ConfigFiles::SHORTCUTS_FILE();

#ifdef QUAZIP

    // Handler for input file
    QFile file(filename);

    // Display and return error message if file doesn't exist
    if(!file.exists()) {
        std::stringstream ss;
        ss << "ERROR: Config file '" << filename.toStdString() << "' does not seem to exist... Abort!";
        LOG << CURDATE << ss.str() << NL;
        // on error, return error string
        return QString::fromStdString(ss.str());
    }

    // Open file for reading (aborts on error)
    if(!file.open(QIODevice::ReadOnly)) {
        std::stringstream ss;
        ss << "ERROR: Config file '" << filename.toStdString() << "' cannot be opened for reading... Abort!";
        LOG << CURDATE << ss.str() << NL;
        // on error, return error string
        return QString::fromStdString(ss.str());
    }

    // Get list of filenames in zip file
    QStringList filelist = JlCompress::getFileList(&file);

    // Loop over entries in zip file
    foreach(QString fn, filelist) {

        // If file inside zip file is a config file
        if(allfiles.contains(fn))
            // try to extract file into destination file, return empty string on error
            if(JlCompress::extractFile(&file, fn, allfiles[fn]) == "")
                LOG << CURDATE << "WARNING: unable to extract file '" << fn.toStdString() << "'... Ignoring!" << NL;

    }

#else

    // Start zip reader
    ZipReader reader(filename);

    if(!reader.exists()) {
        std::stringstream ss;
        ss << "ERROR: File '" << filename.toStdString() << "' does not exist!";
        LOG << CURDATE << ss.str() << NL;
        // on error, return error string
        return QString::fromStdString(ss.str());
    }

    // and iterate over all files in the zip file
    for(ZipReader::FileInfo item : reader.fileInfoList()) {

        if(!allfiles.keys().contains(item.filePath)) {
            LOG << CURDATE << "WARNING: Unknown key found, skipping to next file!" << NL;
            continue;
        }

        // start file with file path to be written to
        QFile file(allfiles[item.filePath]);
        if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            std::stringstream ss;
            ss << "ERROR: Unable to open '" << allfiles[item.filePath].toStdString() << "' for writing/truncating: " << file.errorString().trimmed().toStdString();
            LOG << CURDATE << ss.str() << NL;
            // on error, return error string
            return QString::fromStdString(ss.str());
        }

        // write file
        file.write(reader.fileData(item.filePath));

        file.close();

    }

    if(reader.status() == ZipReader::FileNotAZipError) {
        QString err = "ERROR: This is not a valid zip file!";
        LOG << CURDATE << err.toStdString() << NL;
        return err;
    }

    // finish reader
    reader.close();

#endif

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
