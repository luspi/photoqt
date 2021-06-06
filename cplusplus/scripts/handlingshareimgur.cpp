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

#include "handlingshareimgur.h"

PQHandlingShareImgur::PQHandlingShareImgur(QObject *parent) : QObject(parent) {

    // set up network access manager, used in various locations below
    networkManager = new QNetworkAccessManager;

    // Store debug value
    this->debug = false;

    // Initialise client config to empty strings
    imgurClientID = "";
    imgurClientSecret = "";

    // Initialise user config to empty strings
    access_token = "";
    refresh_token = "";

    // Location of local file containing acces_/refresh_token
    imgurLocalConfigFilename = ConfigFiles::SHAREONLINE_IMGUR_FILE();

    // This ensures the path actually exists
    QFileInfo info(imgurLocalConfigFilename);
    QDir dir;
    dir.mkpath(info.absolutePath());

    // The cryptkey is based on the hostname of the machine. This way this value is preserved much more reliably.
    int key = 0;
    QString hostname = QSysInfo::machineHostName();
    if(hostname.length() < 4)
        key = 63871234;
    else {
        hostname = hostname.remove(5, hostname.length()+1);
        int p = 1;
        for(const auto &character : qAsConst(hostname)) {
            key += character.unicode()*p;
            p *= 10;
        }
    }
    crypt = SimpleCrypt(key);

}

PQHandlingShareImgur::~PQHandlingShareImgur() {
    delete networkManager;
}

bool PQHandlingShareImgur::checkIfConnectedToInternet() {

    DBG << CURDATE << "PQHandlingShareImgur::checkIfConnectedToInternet()" << NL;

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

// Return the web address to obtain a new pin
QString PQHandlingShareImgur::authorizeUrlForPin() {

    DBG << CURDATE << "PQHandlingShareImgur::authorizeUrlForPin()" << NL;

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR)
            return "failed to obtain URL";
    }

    // return authorisation url
    return QString("https://api.imgur.com/oauth2/authorize?client_id=%1&response_type=pin&state=requestaccess").arg(imgurClientID);

}

// Handle a new PIN passed on by the user
int PQHandlingShareImgur::authorizeHandlePin(QByteArray pin) {

    DBG << CURDATE << "PQHandlingShareImgur::authorizeHandlePin()" << NL
        << CURDATE << "** pin = " << pin.toStdString() << NL;

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR)
            return ret;
    }

    // Compose data to send as post message
    QByteArray postData;
    postData.append("client_id=");
    postData.append(imgurClientID.toUtf8());
    postData.append("&client_secret=");
    postData.append(imgurClientSecret.toUtf8());
    postData.append("&grant_type=pin&pin=");
    postData.append(pin);

    // Send network request
    QNetworkRequest req(QUrl(QString("https://api.imgur.com/oauth2/token.xml")));
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QNetworkReply *reply = networkManager->post(req, postData);
    PQReplyTimeout::set(reply, 5000);

    // Synchronous connect
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    // Read reply
    QString resp = reply->readAll();

    // Reset variables
    access_token = "";
    refresh_token = "";

    // If not successful
    if(resp.contains("success=\"0\"")) {
        if(debug) {
            QString status = resp.split("status=\"").at(1).split("\"").at(0);
            QString errorMsg = resp.split("<error>").at(1).split("</error>").at(0);
            LOG << CURDATE << "Status: " << status.toStdString() << " -  Error: " << errorMsg.toStdString() << NL;
        }
        return IMGUR_NETWORK_REPLY_ERROR;
    }

    // Read access_token
    if(resp.contains("<access_token>"))
        access_token = resp.split("<access_token>").at(1).split("</access_token>").at(0);
    else {
        if(debug)
            LOG << CURDATE << "ERROR! No access_token as part of response... Unable to proceed!" << NL;
        return IMGUR_NETWORK_REPLY_ERROR;
    }
    // Read refresh_token
    if(resp.contains("<refresh_token>"))
        refresh_token = resp.split("<refresh_token>").at(1).split("</refresh_token>").at(0);
    // Read access_token
    if(resp.contains("<account_username>"))
        account_name = resp.split("<account_username>").at(1).split("</account_username>").at(0);
    else {
        if(debug)
            LOG << CURDATE << "ERROR! No account_username as part of response... Unable to proceed!" << NL;
        return IMGUR_NETWORK_REPLY_ERROR;
    }

    // Save data to file
    return saveAccessRefreshTokenUserName(imgurLocalConfigFilename);

}

// Save access stuff to file
int PQHandlingShareImgur::saveAccessRefreshTokenUserName(QString filename) {

    DBG << CURDATE << "PQHandlingShareImgur::saveAccessRefreshTokenUserName()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    // Compose text file content
    QString txt = QString("%1\n%2\n%3\n").arg(access_token, refresh_token, account_name);

    // Initiate and open file
    QFile file(filename);
    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if(debug)
            LOG << CURDATE << "ERROR: Unable to write access_token and refresh_token to file..." << NL;
        return IMGUR_FILE_OPEN_ERROR;
    }


    // Write encrypted data to file
    QTextStream out(&file);
    out << crypt.encryptToString(txt);

    // Close file
    file.close();

    // And successfully finished
    return IMGUR_NOERROR;

}

// Read client id and secret from server
int PQHandlingShareImgur::obtainClientIdSecret() {

    DBG << CURDATE << "PQHandlingShareImgur::obtainClientIdSecret()" << NL;

    // If we have done it already, no need to do it again
    if(imgurClientID != "" && imgurClientSecret != "")
        return IMGUR_NOERROR;

    // Request text file from server
    QNetworkRequest req(QUrl("https://photoqt.org/oauth2/imgur.php"));
    req.setRawHeader("Referer", "PhotoQt");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QNetworkReply *reply =  networkManager->get(req);
    PQReplyTimeout::set(reply, 2500);

    // Synchronous connect
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    // Read reply data
    QString dat = reply->readAll();
    reply->deleteLater();

    // If response invalid
    if(dat.trimmed() == "")
        return IMGUR_NOT_CONNECTED_TO_INET;
    else if(!dat.contains("client_id=") || !dat.contains("client_secret=")) {
        if(debug)
            LOG << CURDATE << "Network reply data: " << dat.toStdString() << NL;
        return IMGUR_NETWORK_REPLY_ERROR;
    }

    // Split client id and secret out of reply data
    imgurClientID = dat.split("client_id=").at(1).split("\n").at(0).trimmed();
    imgurClientSecret = dat.split("client_secret=").at(1).split("\n").at(0).trimmed();

    // success
    return IMGUR_NOERROR;

}

// Forget the currently connected account
int PQHandlingShareImgur::forgetAccount() {

    DBG << CURDATE << "PQHandlingShareImgur::forgetAccount()" << NL;

    // Delete file
    QFile file(imgurLocalConfigFilename);
    if(file.exists() && !file.remove()) {
        if(debug)
            LOG << CURDATE << "file.remove() error: " << file.errorString().trimmed().toStdString() << NL;
        return IMGUR_FILE_REMOVE_ERROR;
    }

    // Make sure the file is gone
    int counter = 0;
    while(file.exists() && counter < 100) {
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
        ++counter;
    }

    access_token = "";
    refresh_token = "";
    account_name = "";

    // Successfully forgot about account
    return IMGUR_NOERROR;

}

// Connect to saved account and return success
int PQHandlingShareImgur::authAccount() {

    DBG << CURDATE << "PQHandlingShareImgur::authAccount()" << NL;

    // If data is stored
    if(QFile(imgurLocalConfigFilename).exists()) {

        // reset access/refresh tokens
        access_token = "";
        refresh_token = "";

        // Initiate and open config file
        QFile file(imgurLocalConfigFilename);
        if(!file.open(QIODevice::ReadOnly)) {
            if(debug)
                LOG << CURDATE << "ERROR: Unable to read saved access_token... Requesting new one!" << NL;
            return IMGUR_FILE_OPEN_ERROR;
        }

        // Read contents of file
        QString cont = "";
        QTextStream in(&file);
        cont = crypt.decryptToString(in.readAll());

        // Check for general file format
        if(!cont.contains("\n")) {
            if(debug)
                LOG << CURDATE << "ERROR: Can't read file with access_token, invalid file format... Maybe the cryptkey has changed?" << NL;
            return IMGUR_DECRYPTION_ERROR;
        }

        // Obtain user config
        access_token = cont.split("\n").at(0);
        refresh_token = cont.split("\n").at(1);
        account_name = cont.split("\n").at(2);

        // Close file and report success
        file.close();

        // Yay!! Success!!
        return IMGUR_NOERROR;
    }

    // No stored config data found
    return IMGUR_FILENAME_ERROR;

}

// Upload a file to a connected account
int PQHandlingShareImgur::upload(QString filename) {

    DBG << CURDATE << "PQHandlingShareImgur::upload()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR) {
            emit abortAllRequests();
            uploadError(QNetworkReply::UnknownServerError);
            return ret;
        }
    }

    // Ensure an access token is set
    if(access_token == "") {
        if(debug)
            LOG << CURDATE << "ERROR! Unable to upload image, no access_token set... Did you connect to an account?" << NL;
        return IMGUR_ACCESS_TOKEN_ERROR;
    }

    // Ensure that filename is not empty and that the file exists
    if(filename.trimmed() == "" || !QFileInfo::exists(filename)) {
        if(debug)
            LOG << CURDATE << QString("ERROR! Filename '%1' for uploading to imgur.com is invalid").arg(filename).toStdString() << NL;
        return IMGUR_FILENAME_ERROR;
    }

    // Initiate file and open for reading
    QFile file(filename);
    if(!file.open(QIODevice::ReadOnly)) {
        if(debug)
            LOG << CURDATE << QString("ERROR! Can't open file '%1' for reading to upload to imgur.com").arg(filename).toStdString() << NL;
        return IMGUR_FILE_OPEN_ERROR;
    }

    // Read binary data of file to bytearray
    QByteArray byteArray = file.readAll();
    file.close();

    // Setup network request, use XML format
    QNetworkRequest req(QUrl("https://api.imgur.com/3/image.xml"));
    // the following is not necessary (it's the default), but avoids an error message on standard output
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    // Set access_token to prove authorisation to connect to account
    req.setRawHeader("Authorization", QByteArray("Bearer ") + access_token.toLatin1());

    // Send upload request and connect to feedback signals
    QNetworkReply *reply = networkManager->post(req, byteArray);
    connect(reply, &QNetworkReply::finished, this, &PQHandlingShareImgur::uploadFinished);
    connect(reply, &QNetworkReply::uploadProgress, this, &PQHandlingShareImgur::uploadProgress);
    // The following has to use the old syntax, as there is also a accessor member (not a signal) to access the error with the same name
#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
    connect(reply, static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), this, &PQHandlingShareImgur::uploadError);
#else
    connect(reply, &QNetworkReply::errorOccurred, this, &PQHandlingShareImgur::uploadError);
#endif
    connect(this, &PQHandlingShareImgur::abortAllRequests, reply, &QNetworkReply::abort);

    // Phew, no error occured!
    return IMGUR_NOERROR;

}

int PQHandlingShareImgur::anonymousUpload(QString filename) {

    DBG << CURDATE << "PQHandlingShareImgur::anonymousUpload()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL;

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR) {
            uploadError(QNetworkReply::NetworkSessionFailedError);
            return ret;
        }
    }

    // Ensure that filename is not empty and that the file exists
    if(filename.trimmed() == "" || !QFileInfo::exists(filename)) {
        if(debug)
            LOG << CURDATE << QString("ERROR! Filename '%1' for uploading to imgur.com is invalid").arg(filename).toStdString() << NL;
        return IMGUR_FILENAME_ERROR;
    }

    // Initiate file and open for reading
    QFile file(filename);
    if(!file.open(QIODevice::ReadOnly)) {
        if(debug)
            LOG << CURDATE << QString("ERROR! Can't open file '%1' for reading to upload to imgur.com").arg(filename).toStdString() << NL;
        return IMGUR_FILE_OPEN_ERROR;
    }

    // Read binary data of file to bytearray
    QByteArray byteArray = file.readAll();

    // Setup network request (XML format)
    QNetworkRequest request(QUrl("https://api.imgur.com/3/image.xml"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setRawHeader("Authorization", QString("Client-ID " + imgurClientID).toLatin1());

    // Send upload request and connect to feedback signals
    QNetworkReply *reply = networkManager->post(request, byteArray);
    connect(reply, &QNetworkReply::finished, this, &PQHandlingShareImgur::uploadFinished);
    connect(reply, &QNetworkReply::uploadProgress, this, &PQHandlingShareImgur::uploadProgress);
#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
    connect(reply, static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), this, &PQHandlingShareImgur::uploadError);
#else
    connect(reply, &QNetworkReply::errorOccurred, this, &PQHandlingShareImgur::uploadError);
#endif
    connect(this, &PQHandlingShareImgur::abortAllRequests, reply, &QNetworkReply::abort);

    // Phew, no error occured!
    return IMGUR_NOERROR;

}

// Delete an image, identified by delete_hash
int PQHandlingShareImgur::deleteImage(QString hash) {

    DBG << CURDATE << "PQHandlingShareImgur::deleteImage()" << NL
        << CURDATE << "** hash = " << hash.toStdString() << NL;

    // Set up the network request
    QNetworkRequest request(QUrl(QString("https://api.imgur.com/3/image/%1").arg(hash)));
    request.setRawHeader("Authorization", QByteArray("Bearer ") + access_token.toLatin1());

    // Send the deletion request
    QNetworkReply *reply = networkManager->deleteResource(request);
    PQReplyTimeout::set(reply, 2500);

    // Wait for it to finish
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    // Get return value
    QString ret = reply->readAll();

    // Success!
    if(ret.contains("\"success\":true"))
        return IMGUR_NOERROR;

    // Error...
    if(ret.contains("\"success\":false")) {
        if(ret.contains("\"error\":\"")) {
            if(debug) {
                QString err = ret.split("\"error\":\"").at(1).split("\"").at(0);
                LOG << CURDATE << "Deletion error: " << err.toStdString() << NL;
            }
            return IMGUR_DELETION_ERROR;
        } else
            return IMGUR_OTHER_ERROR;
    }

    // Not sure what happened
    return IMGUR_OTHER_ERROR;

}

// Handle upload progress
void PQHandlingShareImgur::uploadProgress(qint64 bytesSent, qint64 bytesTotal) {

    DBG << CURDATE << "PQHandlingShareImgur::uploadProgress()" << NL
        << CURDATE << "** bytesSent = " << bytesSent << NL
        << CURDATE << "** bytesTotal = " << bytesTotal << NL;

    // Avoid division by zero
    if(bytesTotal == 0)
        return;

    // Compute and emit progress, between 0 and 1
    double progress = (double)bytesSent/(double)bytesTotal;
    emit imgurUploadProgress(progress);

}

// An error occured
void PQHandlingShareImgur::uploadError(QNetworkReply::NetworkError err) {

    DBG << CURDATE << "PQHandlingShareImgur::uploadError()" << NL;

    // Access sender object and delete it
    QNetworkReply *reply = (QNetworkReply*)(sender());
    reply->deleteLater();

    // This is an error, but caused by the user (by calling abort())
    if(err == QNetworkReply::OperationCanceledError)
        return;

    // Compose, output, and emit error message
    if(debug)
        LOG << CURDATE << QString("ERROR! An error occured while uploading image: %1").arg(err).toStdString() << NL;
    emit imgurUploadError(err);

}

// Finished uploading an image
void PQHandlingShareImgur::uploadFinished() {

    DBG << CURDATE << "PQHandlingShareImgur::uploadFinished()" << NL;

    // The sending network reply
    QNetworkReply *reply = (QNetworkReply*)(sender());

    // The reply is not open when operation was aborted
    if(!reply->isOpen()) {
        emit imgurImageUrl("");
        emit finished();
        return;
    }

    // Read output from finished network reply
    QString resp = reply->readAll();

    // Delete sender object
    reply->deleteLater();

    // If there has been an error...
    if(resp.contains("success=\"0\"")) {
        if(debug) {
            QString errorMsg = resp.split("<error>").at(1).split("</error>").at(0);
            LOG << CURDATE << QString("ERROR! An error occured. Error message: %1").arg(errorMsg).toStdString() << NL;
        }
        emit finished();
        return;
    }

    // If data doesn't contain a valid link, something went wrong
    if(!resp.contains("<link>") || !resp.contains("<deletehash>")) {
        if(debug)
            LOG << CURDATE << QString("ERROR! Invalid return data received: %1").arg(resp).toStdString() << NL;
        emit finished();
        return;
    }

    // Read out the link
    QString imgLink = resp.split("<link>").at(1).split("</link>").at(0);
    QString delHash = resp.split("<deletehash>").at(1).split("</deletehash>").at(0);
    // and tell the user
    emit imgurImageUrl(imgLink);
    emit imgurDeleteHash(delHash);
    emit finished();

}

QString PQHandlingShareImgur::getAuthDateTime() {

    DBG << CURDATE << "PQHandlingShareImgur::getAuthDateTime()" << NL;

    QFileInfo info(ConfigFiles::SHAREONLINE_IMGUR_FILE());
    if(info.exists())
        return info.lastModified().toString("yyyy-MM-dd, hh:mm:ss");
    else
        return "???";

}

// Abort all network requests and stop
void PQHandlingShareImgur::abort() {

    DBG << CURDATE << "PQHandlingShareImgur::abort()" << NL;

    // We do it twice spaced out, in case we were just before a networkrequest to really cancel everything
    emit abortAllRequests();
    QTimer::singleShot(500, this, &PQHandlingShareImgur::abortAllRequests);

}
