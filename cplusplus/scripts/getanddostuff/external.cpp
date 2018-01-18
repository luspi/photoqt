#include "external.h"

GetAndDoStuffExternal::GetAndDoStuffExternal(QObject *parent) : QObject(parent) { }
GetAndDoStuffExternal::~GetAndDoStuffExternal() { }

void GetAndDoStuffExternal::openLink(QString url) {
    QDesktopServices::openUrl(url);
}

void GetAndDoStuffExternal::executeApp(QString exec, QString fname) {

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

    // Obtain a filename from the user or used passed on filename
    QString zipFile;
    if(useThisFilename == "") {
        zipFile = QFileDialog::getSaveFileName(0, "Select Location", QDir::homePath() + "/photoqtconfig.pqt", "PhotoQt Config File (*.pqt);;All Files (*.*)");
        if(zipFile.trimmed() == "")
            return "-";
    } else
        zipFile = useThisFilename;

    // if no suffix, append the pqt suffix
    if(QFileInfo(zipFile).suffix() == "")
        zipFile += ".pqt";

    // All the config files to be exported
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_FILEFORMATS_FILE"] = ConfigFiles::FILEFORMATS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();

    // Start a writer for the zip file
    ZipWriter writer(zipFile);

    // Iterate over filenames to be exported
    QHash<QString, QString>::const_iterator i = allfiles.constBegin();
    while(i != allfiles.constEnd()) {

        // Create and open file in read only mode
        QFile file(i.value());
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

    return "";

}

QString GetAndDoStuffExternal::importConfig(QString filename) {

    // All the config files to be imported
    QHash<QString,QString> allfiles;
    allfiles["CFG_SETTINGS_FILE"] = ConfigFiles::SETTINGS_FILE();
    allfiles["CFG_FILEFORMATS_FILE"] = ConfigFiles::FILEFORMATS_FILE();
    allfiles["CFG_CONTEXTMENU_FILE"] = ConfigFiles::CONTEXTMENU_FILE();
    allfiles["CFG_SHORTCUTS_FILE"] = ConfigFiles::SHORTCUTS_FILE();

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
            QString err = "ERROR: Not a valid PhotoQt config file!";
            LOG << CURDATE << err.toStdString() << NL;
            return err;
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

    return "";

}

void GetAndDoStuffExternal::restartPhotoQt(QString loadThisFileAfter) {
    // restart PhotoQt, prepend 'RESTARTRESTARTRESTART' to file to be loader
    // -> this causes PhotoQt to load at startup to make sure this instance is first properly closed
    qApp->quit();
    QProcess::startDetached(qApp->arguments()[0], QStringList() << QString("RESTARTRESTARTRESTART%1").arg(loadThisFileAfter));
}

bool GetAndDoStuffExternal::checkIfConnectedToInternet() {

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
