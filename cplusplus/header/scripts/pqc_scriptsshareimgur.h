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

#ifndef PQCSCRIPTSSHAREIMGUR_H
#define PQCSCRIPTSSHAREIMGUR_H

#include <QObject>
#include <QNetworkReply>
#include <QSqlDatabase>
#include <QtQmlIntegration>

class QNetworkAccessManager;

class PQCScriptsShareImgur : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:

    enum Code {
        IMGUR_NOERROR = 0,
        IMGUR_FILENAME_ERROR,
        IMGUR_FILE_OPEN_ERROR,
        IMGUR_FILE_REMOVE_ERROR,
        IMGUR_DECRYPTION_ERROR,
        IMGUR_NETWORK_TIMEOUT,
        IMGUR_NETWORK_REPLY_ERROR,
        IMGUR_ACCESS_TOKEN_ERROR,
        IMGUR_CLIENT_ID_SECRET_ERROR,
        IMGUR_DELETION_ERROR,
        IMGUR_NOT_CONNECTED_TO_INET,
        IMGUR_OTHER_ERROR};

    Q_ENUM(Code)

    static PQCScriptsShareImgur& get() {
        static PQCScriptsShareImgur instance;
        return instance;
    }
    ~PQCScriptsShareImgur();

    PQCScriptsShareImgur(PQCScriptsShareImgur const&)     = delete;
    void operator=(PQCScriptsShareImgur const&) = delete;

    Q_INVOKABLE bool checkIfConnectedToInternet();

    // three public upload function
    Q_INVOKABLE int upload(QString filename);
    Q_INVOKABLE int anonymousUpload(QString filename);
    Q_INVOKABLE int deleteImage(QString hash);

    // Authenticate with an account or forget existing authentication
    Q_INVOKABLE int authAccount();
    Q_INVOKABLE int forgetAccount();
    Q_INVOKABLE QString getAccountUsername() { return account_name; }
    Q_INVOKABLE bool isAuthenticated() { return account_name!=""; }

    Q_INVOKABLE QString getAuthDateTime();

    // The following function return the URL for obtaining a pin code
    Q_INVOKABLE QString authorizeUrlForPin();

    // The following function takes a pin and exchanges it for an access_token and refresh_token
    Q_INVOKABLE int authorizeHandlePin(QByteArray pin);

    // Abort all network operations
    Q_INVOKABLE void abort();

    Q_INVOKABLE void storeNewUpload(QString filename, QString imageUrl, QString deleteHash);
    Q_INVOKABLE QVariantList getPastUploads();
    Q_INVOKABLE QImage getPastUploadThumbnail(QString timestamp);
    Q_INVOKABLE bool deletePastEntry(QString timestamp);

    Q_INVOKABLE void closeDatabase();

private:
    PQCScriptsShareImgur();

    void setup();
    bool isSetup;

    // NetworkManager handling requests
    QNetworkAccessManager *networkManager;

    // Store the access stuff
    QString access_token;
    QString refresh_token;
    QString account_name;

    // This data is read in from the server, not stored locally!
    QString imgurClientID;
    QString imgurClientSecret;

    // Request the client id/secret from user
    int obtainClientIdSecret();

    // Location where to store local file containing access_/refresh_token
    QString imgurLocalConfigFilename;

    QSqlDatabase db;

private Q_SLOTS:
    // functions to connect to an account. the *_request function sets the whole thing in motion
    int saveAccessRefreshTokenUserName(QString filename);

    // receive feedback from the upload/connecting handler
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void uploadError(QNetworkReply::NetworkError err);
    void uploadFinished();

Q_SIGNALS:
    // signal percentage of upload completed
    void imgurUploadProgress(double perc);
    void imgurImageUrl(QString url);
    void imgurDeleteHash(QString url);
    void imgurUploadError(QNetworkReply::NetworkError err);
    void abortAllRequests();
    void finished();

};

#endif
