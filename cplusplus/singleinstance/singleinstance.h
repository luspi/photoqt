#ifndef PQSINGLEINSTANCE_H
#define PQSINGLEINSTANCE_H

#include <QGuiApplication>
#include <QLocalSocket>
#include <QLocalServer>
#include <thread>
#include "commandlineparser.h"
#include "../logger.h"

// Makes sure only one instance of PhotoQt is running, and enables remote communication
class PQSingleInstance : public QGuiApplication {

    Q_OBJECT

public:
    explicit PQSingleInstance(int&, char *[]);
    ~PQSingleInstance();

    QString exportAndQuit;
    QString importAndQuit;

signals:
    // Interact with application
    void interaction(PQCommandLineResult result, QString value);

private slots:
    // A new application instance was started (notification to main instance)
    void newConnection();

private:
    QLocalSocket *socket;
    QLocalServer *server;

    // This one is used in main process, handling the message sent by sub-instances
    void handleMessage(QString msg);

};

#endif // PQSINGLEINSTANCE_H
