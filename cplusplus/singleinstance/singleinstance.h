#ifndef SINGLEINSTANCE_H
#define SINGLEINSTANCE_H

#include "../logger.h"
#include <thread>
#include <QApplication>
#include <QLocalSocket>
#include <QLocalServer>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QDate>

// Makes sure only one instance of PhotoQt is running, and enables remote communication
class SingleInstance : public QApplication {
	Q_OBJECT
public:
	explicit SingleInstance(int&, char *[]);
	~SingleInstance();

	bool open;
	bool nothumbs;
	bool thumbs;
	bool toggle;
	bool show;
	bool hide;
	bool verbose;
	bool startintray;
	QString filename;

	// DEVELOPMENT ONLY
	bool update;
	bool install;

signals:
	// Interact with application
	void interaction(QString exec);

private slots:
	// A new application instance was started (notification to main instance)
	void newConnection();

private:
	QLocalSocket *socket;
	QLocalServer *server;

	// This one is used in main process, handling the message sent by sub-instances
	void handleResponse(QString msg);

};

#endif // SINGLEINSTANCE_H
