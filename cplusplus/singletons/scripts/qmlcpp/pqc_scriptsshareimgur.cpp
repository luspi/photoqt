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

#include <scripts/qmlcpp/pqc_scriptsshareimgur.h>
#include <scripts/cpp/pqc_scriptscrypt.h>
#include <pqc_configfiles.h>
#include <pqc_httpreplytimeout.h>
#include <pqc_loadimage.h>

#include <QFileInfo>
#include <QDir>
#include <QNetworkInterface>
#include <QRegularExpression>
#include <QEventLoop>
#include <thread>
#include <QTimer>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QImage>
#include <QBuffer>

PQCScriptsShareImgur::PQCScriptsShareImgur() {

    isSetup = false;
    networkManager = nullptr;

}

void PQCScriptsShareImgur::setup() {

    isSetup = true;

    // set up network access manager, used in various locations below
    networkManager = new QNetworkAccessManager;

    // Initialise client config to empty strings
    imgurClientID = "";
    imgurClientSecret = "";

    // Initialise user config to empty strings
    access_token = "";
    refresh_token = "";

    // Location of local file containing acces_/refresh_token
    imgurLocalConfigFilename = PQCConfigFiles::get().SHAREONLINE_IMGUR_FILE();

    // This ensures the path actually exists
    QFileInfo info(imgurLocalConfigFilename);
    QDir dir;
    dir.mkpath(info.absolutePath());

    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "imgurhistory");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "imgurhistory");
    db.setDatabaseName(PQCConfigFiles::get().SHAREONLINE_IMGUR_HISTORY_DB());

    if(!db.open()) {
        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "History for imgur.com uploads will not be available";
    }

}

PQCScriptsShareImgur::~PQCScriptsShareImgur() {
    if(isSetup)
        delete networkManager;
}

bool PQCScriptsShareImgur::checkIfConnectedToInternet() {

    qDebug() << "";

    if(!isSetup) setup();

    // will store the return value
    bool internetConnected = false;

    // Get a list of all network interfaces
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();

    // a reg exp to validate an ip address
    static QRegularExpression ipRegExp("[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}");

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
                if(ip != "127.0.0.1" && ipRegExp.match(ip).hasMatch()) {
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
QString PQCScriptsShareImgur::authorizeUrlForPin() {

    qDebug() << "";

    if(!isSetup) setup();

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR)
            return "failed to obtain URL";
    }

    // return authorisation url
    return QString("https://api.imgur.com/oauth2/authorize?client_id=%1&response_type=pin&state=requestaccess").arg(imgurClientID);

}

// Handle a new PIN passed on by the user
int PQCScriptsShareImgur::authorizeHandlePin(QByteArray pin) {

    qDebug() << "args: pin =" << pin;

    if(!isSetup) setup();

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
    PQCHTTPReplyTimeout::set(reply, 5000);

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
    if(resp.contains("success=\"0\""))
        return IMGUR_NETWORK_REPLY_ERROR;

    // Read access_token
    if(resp.contains("<access_token>"))
        access_token = resp.split("<access_token>").at(1).split("</access_token>").at(0);
    else
        return IMGUR_NETWORK_REPLY_ERROR;

    // Read refresh_token
    if(resp.contains("<refresh_token>"))
        refresh_token = resp.split("<refresh_token>").at(1).split("</refresh_token>").at(0);
    // Read access_token
    if(resp.contains("<account_username>"))
        account_name = resp.split("<account_username>").at(1).split("</account_username>").at(0);
    else
        return IMGUR_NETWORK_REPLY_ERROR;

    // Save data to file
    return saveAccessRefreshTokenUserName(imgurLocalConfigFilename);

}

// Save access stuff to file
int PQCScriptsShareImgur::saveAccessRefreshTokenUserName(QString filename) {

    qDebug() << "args: filename =" << filename;

    if(!isSetup) setup();

    // Compose text file content
    QString txt = QString("%1\n%2\n%3\n").arg(access_token, refresh_token, account_name);

    // Initiate and open file
    QFile file(filename);
    if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return IMGUR_FILE_OPEN_ERROR;

    // Write encrypted data to file
    QTextStream out(&file);
    out << PQCScriptsCrypt::get().encryptString(txt);

    // Close file
    file.close();

    // And successfully finished
    return IMGUR_NOERROR;

}

// Read client id and secret from server
int PQCScriptsShareImgur::obtainClientIdSecret() {

    qDebug() << "";

    if(!isSetup) setup();

    // If we have done it already, no need to do it again
    if(imgurClientID != "" && imgurClientSecret != "")
        return IMGUR_NOERROR;

    // Request text file from server
    QNetworkRequest req(QUrl("https://photoqt.org/appaccess/oauth2imgur.php"));
    req.setRawHeader("Referer", "PhotoQt");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QNetworkReply *reply =  networkManager->get(req);
    PQCHTTPReplyTimeout::set(reply, 2500);

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
    else if(!dat.contains("client_id=") || !dat.contains("client_secret="))
        return IMGUR_NETWORK_REPLY_ERROR;

    // Split client id and secret out of reply data
    imgurClientID = dat.split("client_id=").at(1).split("\n").at(0).trimmed();
    imgurClientSecret = dat.split("client_secret=").at(1).split("\n").at(0).trimmed();

    // success
    return IMGUR_NOERROR;

}

// Forget the currently connected account
int PQCScriptsShareImgur::forgetAccount() {

    qDebug() << "";

    if(!isSetup) setup();

    // Delete file
    QFile file(imgurLocalConfigFilename);
    if(file.exists() && !file.remove())
        return IMGUR_FILE_REMOVE_ERROR;

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
int PQCScriptsShareImgur::authAccount() {

    qDebug() << "";

    if(!isSetup) setup();

    // If data is stored
    if(QFile(imgurLocalConfigFilename).exists()) {

        // reset access/refresh tokens
        access_token = "";
        refresh_token = "";

        // Initiate and open config file
        QFile file(imgurLocalConfigFilename);
        if(!file.open(QIODevice::ReadOnly))
            return IMGUR_FILE_OPEN_ERROR;

        // Read contents of file
        QString cont = "";
        QTextStream in(&file);
        cont = PQCScriptsCrypt::get().decryptString(in.readAll());

        // Check for general file format
        if(!cont.contains("\n"))
            return IMGUR_DECRYPTION_ERROR;

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
int PQCScriptsShareImgur::upload(QString filename) {

    qDebug() << "args: filename =" << filename;

    if(!isSetup) setup();

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR) {
            Q_EMIT abortAllRequests();
            uploadError(QNetworkReply::UnknownServerError);
            return ret;
        }
    }

    // Ensure an access token is set
    if(access_token == "")
        return IMGUR_ACCESS_TOKEN_ERROR;

    // Ensure that filename is not empty and that the file exists
    if(filename.trimmed() == "" || !QFileInfo::exists(filename))
        return IMGUR_FILENAME_ERROR;

    // Initiate file and open for reading
    QFile *file = new QFile(filename);
    if(!file->open(QIODevice::ReadOnly))
        return IMGUR_FILE_OPEN_ERROR;

    // Setup network request, use XML format
    QNetworkRequest req(QUrl("https://api.imgur.com/3/image.xml"));
    // the following is not necessary (it's the default), but avoids an error message on standard output
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    // Set access_token to prove authorisation to connect to account
    req.setRawHeader("Authorization", QByteArray("Bearer ") + access_token.toLatin1());

    // Send upload request and connect to feedback signals
    QNetworkReply *reply = networkManager->post(req, file);
    file->setParent(reply);
    connect(reply, &QNetworkReply::finished, this, &PQCScriptsShareImgur::uploadFinished);
    connect(reply, &QNetworkReply::uploadProgress, this, &PQCScriptsShareImgur::uploadProgress);
    // The following has to use the old syntax, as there is also a accessor member (not a signal) to access the error with the same name
    connect(reply, &QNetworkReply::errorOccurred, this, &PQCScriptsShareImgur::uploadError);
    connect(this, &PQCScriptsShareImgur::abortAllRequests, reply, &QNetworkReply::abort);

    // Phew, no error occurred!
    return IMGUR_NOERROR;

}

int PQCScriptsShareImgur::anonymousUpload(QString filename) {

    qDebug() << "args: filename =" << filename;

    if(!isSetup) setup();

    if(imgurClientID == "" || imgurClientSecret == "") {
        int ret = obtainClientIdSecret();
        if(ret != IMGUR_NOERROR) {
            uploadError(QNetworkReply::NetworkSessionFailedError);
            return ret;
        }
    }

    // Ensure that filename is not empty and that the file exists
    if(filename.trimmed() == "" || !QFileInfo::exists(filename))
        return IMGUR_FILENAME_ERROR;

    // Initiate file and open for reading
    QFile *file = new QFile(filename);
    if(!file->open(QIODevice::ReadOnly))
        return IMGUR_FILE_OPEN_ERROR;

    // Setup network request (XML format)
    QNetworkRequest request(QUrl("https://api.imgur.com/3/image.xml"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/application/x-www-form-urlencoded");
    request.setRawHeader("Authorization", QString("Client-ID " + imgurClientID).toLatin1());

    // Send upload request and connect to feedback signals
    QNetworkReply *reply = networkManager->post(request, file);
    connect(reply, &QNetworkReply::finished, this, &PQCScriptsShareImgur::uploadFinished);
    connect(reply, &QNetworkReply::uploadProgress, this, &PQCScriptsShareImgur::uploadProgress);
    connect(reply, &QNetworkReply::errorOccurred, this, &PQCScriptsShareImgur::uploadError);
    connect(this, &PQCScriptsShareImgur::abortAllRequests, reply, &QNetworkReply::abort);

    // Phew, no error occurred!
    return IMGUR_NOERROR;

}

// Delete an image, identified by delete_hash
int PQCScriptsShareImgur::deleteImage(QString hash) {

    qDebug() << "args: hash =" << hash;

    if(!isSetup) setup();

    // Set up the network request
    QNetworkRequest request(QUrl(QString("https://api.imgur.com/3/image/%1").arg(hash)));
    request.setRawHeader("Authorization", QByteArray("Bearer ") + access_token.toLatin1());

    // Send the deletion request
    QNetworkReply *reply = networkManager->deleteResource(request);
    PQCHTTPReplyTimeout::set(reply, 2500);

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
        if(ret.contains("\"error\":\""))
            return IMGUR_DELETION_ERROR;
        return IMGUR_OTHER_ERROR;
    }

    // Not sure what happened
    return IMGUR_OTHER_ERROR;

}

// Handle upload progress
void PQCScriptsShareImgur::uploadProgress(qint64 bytesSent, qint64 bytesTotal) {

    qDebug() << "args: bytesSent =" << bytesSent;
    qDebug() << "args: bytesTotal =" << bytesTotal;

    if(!isSetup) setup();

    // Avoid division by zero
    if(bytesTotal == 0)
        return;

    // Compute and emit progress, between 0 and 1
    double progress = (double)bytesSent/(double)bytesTotal;
    Q_EMIT imgurUploadProgress(progress);

}

// An error occurred
void PQCScriptsShareImgur::uploadError(QNetworkReply::NetworkError err) {

    qDebug() << "args: err =" << err;

    if(!isSetup) setup();

    // Access sender object and delete it
    QNetworkReply *reply = (QNetworkReply*)(sender());
    reply->deleteLater();

    // This is an error, but caused by the user (by calling abort())
    if(err == QNetworkReply::OperationCanceledError)
        return;

    // Compose, output, and emit error message
    Q_EMIT imgurUploadError(err);

}

// Finished uploading an image
void PQCScriptsShareImgur::uploadFinished() {

    qDebug() << "";

    if(!isSetup) setup();

    // The sending network reply
    QNetworkReply *reply = (QNetworkReply*)(sender());

    // The reply is not open when operation was aborted
    if(!reply->isOpen()) {
        Q_EMIT imgurImageUrl("");
        Q_EMIT finished();
        return;
    }

    // Read output from finished network reply
    QString resp = reply->readAll();

    // Delete sender object
    reply->deleteLater();

    // If there has been an error...
    if(resp.contains("success=\"0\"")) {
        Q_EMIT finished();
        return;
    }

    // If data doesn't contain a valid link, something went wrong
    if(!resp.contains("<link>") || !resp.contains("<deletehash>")) {
        Q_EMIT finished();
        return;
    }

    // Read out the link
    QString imgLink = resp.split("<link>").at(1).split("</link>").at(0);
    QString delHash = resp.split("<deletehash>").at(1).split("</deletehash>").at(0);
    // and tell the user
    Q_EMIT imgurImageUrl(imgLink);
    Q_EMIT imgurDeleteHash(delHash);
    Q_EMIT finished();

}

QString PQCScriptsShareImgur::getAuthDateTime() {

    qDebug() << "";

    if(!isSetup) setup();

    QFileInfo info(PQCConfigFiles::get().SHAREONLINE_IMGUR_FILE());
    if(info.exists())
        return info.lastModified().toString("yyyy-MM-dd, hh:mm:ss");
    else
        return "???";

}

// Abort all network requests and stop
void PQCScriptsShareImgur::abort() {

    qDebug() << "";

    if(!isSetup) setup();

    // We do it twice spaced out, in case we were just before a networkrequest to really cancel everything
    Q_EMIT abortAllRequests();
    QTimer::singleShot(500, this, &PQCScriptsShareImgur::abortAllRequests);

}

void PQCScriptsShareImgur::storeNewUpload(QString filename, QString imageUrl, QString deleteHash) {

    if(!db.isOpen())
        return;

    QImage thumb;
    QSize orig;
    PQCLoadImage::get().load(filename, QSize(128,128), orig, thumb);

    QByteArray thumb_data;
    QBuffer thumb_buffer(&thumb_data);
    thumb_buffer.open(QIODevice::WriteOnly);
    thumb.save(&thumb_buffer, "PNG");

    QSqlQuery query(db);
    query.prepare("INSERT INTO `history` (`timestamp`, `thumbnail`, `imageurl`, `deletehash`) VALUES (:timestamp, :thumbnail, :imageurl, :deletehash)");
    query.bindValue(":timestamp", QDateTime::currentMSecsSinceEpoch());
    query.bindValue(":thumbnail", thumb_data);
    query.bindValue(":imageurl", imageUrl);
    query.bindValue(":deletehash", deleteHash);

    if(!query.exec())
        qWarning() << "SQL error caching imgur.com upload:" << query.lastError().text();

    query.clear();

}

QVariantList PQCScriptsShareImgur::getPastUploads() {

    QVariantList ret;

    if(!db.isOpen())
        return ret;

    QSqlQuery query(db);
    if(!query.exec("SELECT `timestamp`,`imageurl`,`deletehash` FROM `history` ORDER BY `timestamp` DESC")) {
        qWarning() << "SQL error:" << db.lastError().text();
        return ret;
    }

    while(query.next()) {

        qint64 ms = query.value(0).toLongLong();

        QDateTime dt;
        dt.setMSecsSinceEpoch(ms);

        QVariantList entry;
        entry << ms;
        entry << QLocale::system().toString(dt);
        entry << query.value(1);
        entry << query.value(2);

        ret.push_back(entry);

    }

    query.clear();

    return ret;
}

QImage PQCScriptsShareImgur::getPastUploadThumbnail(QString timestamp) {

    if(!db.isOpen())
        return QImage();

    QSqlQuery query(db);
    query.prepare("SELECT `thumbnail` FROM `history` WHERE `timestamp`=:timestamp");
    query.bindValue(":timestamp", timestamp);
    if(!query.exec()) {
        qWarning() << "SQL error:" << db.lastError().text();
        return QImage();
    }

    if(query.next())
        return QImage::fromData(query.value(0).toByteArray());

    return QImage();
}

bool PQCScriptsShareImgur::deletePastEntry(QString timestamp) {

    if(!db.isOpen())
        return false;

    // delete all
    if(timestamp == "xxx") {

        QSqlQuery query(db);
        query.prepare("DELETE FROM `history`");
        if(!query.exec()) {
            qWarning() << "SQL error:" << db.lastError().text();
            return false;
        }

    } else {

        QSqlQuery query(db);
        query.prepare("DELETE FROM `history` WHERE `timestamp`=:timestamp");
        query.bindValue(":timestamp", timestamp);
        if(!query.exec()) {
            qWarning() << "SQL error:" << db.lastError().text();
            return false;
        }

    }

    return true;

}

void PQCScriptsShareImgur::closeDatabase() {

    qDebug() << "";

    db.close();

}
