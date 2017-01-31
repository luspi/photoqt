#include "imgur.h"

ShareOnline::Imgur::Imgur(QString localConfigFile, QObject *parent) : QObject(parent) {

	// set up network access manager, used in various locations below
	networkManager = new QNetworkAccessManager;

	// Initialise client config to empty
	imgurClientID = "";
	imgurClientSecret = "";

	// Location of local file containing acces_/refresh_token
	imgurLocalConfigFilename = localConfigFile;

	simpleCrypt = SimpleCrypt(QString(SIMPLECRYPTKEY).toInt());

}

// Open a webbrowser to request a new pin
void ShareOnline::Imgur::authorizeRequestNewPin() {
	requestClientIdSecretFromServer();
	QDesktopServices::openUrl(QUrl(QString("https://api.imgur.com/oauth2/authorize?client_id=%1&response_type=pin&state=requestaccess").arg(imgurClientID)));
}

// Handle a new PIN (either passed on or request via cin)
bool ShareOnline::Imgur::authorizeHandlePin(QByteArray pin) {

	// Read client id and secret from server
	requestClientIdSecretFromServer();

	// Compose data to send as post message
	QByteArray postData;
	postData.append("client_id=");
	postData.append(imgurClientID);
	postData.append("&client_secret=");
	postData.append(imgurClientSecret);
	postData.append("&grant_type=pin&pin=");
	postData.append(pin);

	// Send network request
	QNetworkRequest req(QUrl(QString("https://api.imgur.com/oauth2/token.xml")));
	req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
	QNetworkReply *reply = networkManager->post(req, postData);

	// Synchronous connect
	QEventLoop loop;
	connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
	loop.exec();

	// Read reply
	QString resp = reply->readAll();

	// Reset variables
	access_token = "";
	refresh_token = "";

	// If not successful
	if(resp.contains("success=\\\"0\\\"")) {
		QString status = resp.split("status=\\\"").at(1).split("\\\"").at(0);
		QString errorMsg = resp.split("<error>").at(1).split("</error>").at(0);
		std::stringstream ss;
		ss << "ERROR: Status: " << status.toInt() << " - Error message: " << errorMsg.toStdString();
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return false;
	}

	// Read access_token
	if(resp.contains("<access_token>"))
		access_token = resp.split("<access_token>").at(1).split("</access_token>").at(0);
	else {
		QString ret = "ERROR! No access_token as part of response... Unable to proceed!";
		std::cout << ret.toStdString() << std::endl;
		emit errorOccured(ret);
		return false;
	}
	// Read refresh_token
	if(resp.contains("<refresh_token>"))
		refresh_token = resp.split("<refresh_token>").at(1).split("</refresh_token>").at(0);

	// Save data to file
	return saveAccessRefreshToken(imgurLocalConfigFilename);

}

// Save access stuff to file
bool ShareOnline::Imgur::saveAccessRefreshToken(QString filename) {

	// Compose text file content
	QString txt = QString("access_token=%1\nrefresh_token=%2\n").arg(access_token).arg(refresh_token);

	// Initiate and open file
	QFile file(filename);
	if(!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
		QString ret = "ERROR: Unable to write access_token and refresh_token to file...";
		std::cout << ret.toStdString() << std::endl;
		emit errorOccured(ret);
		return false;
	}

	// Write data to file
	QTextStream out(&file);
	out << simpleCrypt.encryptToString(txt);

	// Close file
	file.close();

	// And successfully finished
	return true;

}

// Read client id and secret from server
void ShareOnline::Imgur::requestClientIdSecretFromServer() {

	// If we have done it already, no need to do it again
	if(imgurClientID != "" && imgurClientSecret != "")
		return;

	// Request text file from server
	QNetworkRequest req(QUrl("http://photoqt.org/oauth2/imgur.php"));
	req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
	QNetworkReply *reply = networkManager->get(req);

	// Synchronous connect
	QEventLoop loop;
	connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
	loop.exec();

	// Read reply data
	QString dat = reply->readAll();

	// If response invalid
	if(!dat.contains("client_id=") || !dat.contains("client_secret=")) {
		std::stringstream ss;
		ss << "ERROR: Unable to obtain client_id/client_secret from server! Reply data invalid: " << dat.toStdString();
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return;
	}

	// Split client id and secret out of reply data
	imgurClientID = dat.split("client_id=").at(1).split("\n").at(0).trimmed();
	imgurClientSecret = dat.split("client_secret=").at(1).split("\n").at(0).trimmed();

}

// Forget the currently connected account
bool ShareOnline::Imgur::forgetAccount() {

	// Delete file
	QFile file(imgurLocalConfigFilename);
	if(file.exists() && !file.remove()) {
		std::stringstream ss;
		ss << "ERROR: Can't forget previous account. File deletion failed with error message: " << file.errorString().trimmed().toStdString();
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return false;
	}

	// Make sure the file is gone
	int counter = 0;
	while(file.exists() && counter < 100) {
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
		++counter;
	}

	return true;

}

// Connect to saved account and return success
bool ShareOnline::Imgur::connectAccount() {

	// If data is stored
	if(QFile(imgurLocalConfigFilename).exists()) {

		// reset access/refresh tokens
		access_token = "";
		refresh_token = "";

		// Initiate and open config file
		QFile file(imgurLocalConfigFilename);
		if(!file.open(QIODevice::ReadOnly)) {
			QString ret = "ERROR: Unable to read saved access_token... Requesting new one!";
			std::cout << ret.toStdString() << std::endl;
			emit errorOccured(ret);
			return false;
		}

		// Read contents of file
		QString cont = "";
		QTextStream in(&file);
		cont = simpleCrypt.decryptToString(in.readAll());

		// Obtain access_token
		if(!cont.contains("access_token=")) {
			QString ret = "ERROR: access_token missing from file.";
			std::cout << ret.toStdString() << std::endl;
			emit errorOccured(ret);
			return false;
		}
		access_token = cont.split("access_token=").at(1).split("\n").at(0);

		// Obtain refresh_token
		if(!cont.contains("refresh_token=")) {
			QString ret = "ERROR: refresh_token missing from file.";
			std::cout << ret.toStdString() << std::endl;
			emit errorOccured(ret);
			return false;
		}
		refresh_token = cont.split("refresh_token=").at(1).split("\n").at(0);

		// Close file and report success
		file.close();
		return true;
	}

	// No stored config data found
	return false;

}

// Upload a file to a connected account
void ShareOnline::Imgur::upload(QString filename) {

	// Ensure that filename is not empty and that the file exists
	if(filename.trimmed() == "" || !QFileInfo(filename).exists()) {
		std::stringstream ss;
		ss << "ERROR! Filename '" << filename.toStdString() << "' for uploading to imgur.com is invalid";
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return;
	}

	// Initiate file and open for reading
	QFile file(filename);
	if(!file.open(QIODevice::ReadOnly)) {
		std::stringstream ss;
		ss << "ERROR! Can't open file '" << filename.toStdString() << "' for reading to upload to imgur.com";
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return;
	}

	// Read binary data of file to bytearray
	QByteArray byteArray = file.readAll();
	file.close();

	// Setup network request, use XML format
	QNetworkRequest req(QUrl("https://api.imgur.com/3/image.xml"));
	// the following is not necessary (it's the default), but avoids an error message on std::cout
	req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
	// Set access_token to prove authorisation to connect to account
	req.setRawHeader("Authorization", QByteArray("Bearer ") + access_token.toLatin1());

	// Send upload request and connect to feedback signals
	QNetworkReply *reply = networkManager->post(req, byteArray);
	connect(reply, SIGNAL(finished()), this, SLOT(uploadFinished()));
	connect(reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
	connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(uploadError(QNetworkReply::NetworkError)));

	// Phew, no error occured!

}

void ShareOnline::Imgur::anonymousUpload(QString filename) {

	// Ensure that filename is not empty and that the file exists
	if(filename.trimmed() == "" || !QFileInfo(filename).exists()) {
		std::stringstream ss;
		ss << "ERROR! Filename '" << filename.toStdString() << "' for uploading to imgur.com is invalid";
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return;
	}

	// Initiate file and open for reading
	QFile file(filename);
	if(!file.open(QIODevice::ReadOnly)) {
		std::stringstream ss;
		ss << "ERROR! Can't open file '" << filename.toStdString() << "' for reading to upload to imgur.com";
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return;
	}

	// Read binary data of file to bytearray
	QByteArray byteArray = file.readAll();

	// Read client id and secret from server
	requestClientIdSecretFromServer();

	// Setup network request (XML format)
	QNetworkRequest request(QUrl("https://api.imgur.com/3/image.xml"));
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
	request.setRawHeader("Authorization", QString("Client-ID " + imgurClientID).toLatin1());

	// Send upload request and connect to feedback signals
	QNetworkReply *reply = networkManager->post(request, byteArray);
	connect(reply, SIGNAL(finished()), this, SLOT(uploadFinished()));
	connect(reply, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(uploadProgress(qint64,qint64)));
	connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(uploadError(QNetworkReply::NetworkError)));

	// Phew, no error occured!

}

void ShareOnline::Imgur::uploadProgress(qint64 bytesSent, qint64 bytesTotal) {

	if(bytesTotal == 0)
		return;

	double progress = (double)bytesSent/(double)bytesTotal;
	emit imgurUploadProgress(progress);

}

void ShareOnline::Imgur::uploadError(QNetworkReply::NetworkError err) {

	std::stringstream ss;
	ss << "ERROR! An error occured while uploading image: " << err;
	std::cout << ss.str() << std::endl;
	emit errorOccured(QString::fromStdString(ss.str()));

}

void ShareOnline::Imgur::uploadFinished() {

	QNetworkReply *reply = (QNetworkReply*)(sender());

	QString resp = reply->readAll();

	if(resp.contains("success=\\\"0\\\"")) {
		QString errorMsg = resp.split("<error>").at(1).split("</error>").at(0);
		std::stringstream ss;
		ss << "ERROR! An error occured. Error message: " << errorMsg.toStdString();
		std::cout << ss.str() << std::endl;
		emit errorOccured(QString::fromStdString(ss.str()));
		return;
	}

	QString link = resp.split("<link>").at(1).split("</link>").at(0);

	emit imgurImageUrl(link);

}
