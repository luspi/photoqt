/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef GETANDDOSTUFFIMGUR_H
#define GETANDDOSTUFFIMGUR_H

#include <QObject>
#include <QFileInfo>
#include <QDir>
#include <QNetworkReply>
#include <thread>
#include <QEventLoop>
#include <QTimer>
#include <iostream>

#include "../../simplecrypt/simplecrypt.h"

namespace ShareOnline {

enum { NOERROR = 0,
       FILENAME_ERROR = 1,
       FILE_OPEN_ERROR = 2,
       FILE_REMOVE_ERROR = 3,
       DECRYPTION_ERROR = 4,
       NETWORK_TIMEOUT = 5,
       NETWORK_REPLY_ERROR = 6,
       ACCESS_TOKEN_ERROR = 7,
       CLIENT_ID_SECRET_ERROR = 8,
       DELETION_ERROR = 9,
       OTHER_ERROR = 10};

class Imgur : public QObject {

    Q_OBJECT

public:
    explicit Imgur(QString localConfigFile, bool debug = false, QObject *parent = 0);

    // three public upload function
    int upload(QString filename);
    int anonymousUpload(QString filename);
    int deleteImage(QString hash);

    // Authenticate with an account or forget existing authentication
    int authAccount();
    int forgetAccount();

    // The following function return the URL for obtaining a pin code
    QString authorizeUrlForPin();

    // The following function takes a pin and exchanges it for an access_token and refresh_token
    int authorizeHandlePin(QByteArray pin);

    // Abort all network operations
    void abort();

private:
    // NetworkManager handling requests
    QNetworkAccessManager *networkManager;

    // Store the access stuff
    QString access_token;
    QString refresh_token;

    // This data is read in from the server, not stored locally!
    QString imgurClientID;
    QString imgurClientSecret;

    // Request the client id/secret from user
    int obtainClientIdSecret();

    // Location where to store local file containing access_/refresh_token
    QString imgurLocalConfigFilename;

    // An encryption handler
    SimpleCrypt crypt;

    bool debug;

private slots:
    // functions to connect to an account. the *_request function sets the whole thing in motion
    int saveAccessRefreshToken(QString filename);

    // receive feedback from the upload/connecting handler
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void uploadError(QNetworkReply::NetworkError err);
    void uploadFinished();

signals:
    // signal percentage of upload completed
    void imgurUploadProgress(double perc);
    void imgurImageUrl(QString url);
    void imgurDeleteHash(QString url);
    void imgurUploadError(QNetworkReply::NetworkError err);
    void abortAllRequests();
    void finished();

};

}

#endif // GETANDDOSTUFFIMGUR_H
