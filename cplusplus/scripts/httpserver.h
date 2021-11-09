#ifndef PQHTTPSERVER_H
#define PQHTTPSERVER_H

#include <QNetworkInterface>
#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include "../logger.h"

class PQHttpServer : public QObject {

    Q_OBJECT

public:
    explicit PQHttpServer(QObject *parent = 0);
    ~PQHttpServer();
    QTcpSocket *socket ;

public Q_SLOTS:
    void serve();
    int start();
    void stop();

private:
    qint64 bytesAvailable() const;
    QTcpServer *server;
};

#endif // PQHTTPSERVER_H
