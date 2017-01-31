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

#ifndef SHAREONLINEIMGUR_H
#define SHAREONLINEIMGUR_H

#include <QObject>
#include <QFileInfo>
#include <sstream>
#include <QNetworkReply>
#include <iostream>
#include <QDesktopServices>
#include <thread>
#include <QEventLoop>
#include "../../simplecrypt/simplecrypt.h"

namespace ShareOnline {

class Imgur : public QObject {

	Q_OBJECT

public:
	explicit Imgur(QString localConfigFile, QObject *parent = 0);

	// two public upload function
	void upload(QString filename);
	void anonymousUpload(QString filename);

	bool connectAccount();
	bool forgetAccount();

	void authorizeRequestNewPin();
	bool authorizeHandlePin(QByteArray pin);

private:
	// NetworkManager handling requests
	QNetworkAccessManager *networkManager;

	// Store the access stuff
	QString access_token;
	QString refresh_token;
	int expires_in;

	// This data is read in from the server, not stored locally!
	QString imgurClientID;
	QString imgurClientSecret;

	// Request the client id/secret from user
	void requestClientIdSecretFromServer();

	// Location where to store local file containing access_/refresh_token
	QString imgurLocalConfigFilename;

	// Encrypt locally stored access_token and refresh_token
	SimpleCrypt simpleCrypt;

private slots:
	// functions to connect to an account. the *_request function sets the whole thing in motion
	bool saveAccessRefreshToken(QString filename);

	// receive feedback from the upload/connecting handler
	void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
	void uploadError(QNetworkReply::NetworkError err);
	void uploadFinished();

signals:
	// signal percentage of upload completed
	void imgurUploadProgress(double perc);
	void imgurImageUrl(QString url);
	void errorOccured(QString err);

};

}

#endif // SHAREONLINEIMGUR_H
