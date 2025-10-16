#include <qml/pqc_qdbusserver.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QtDebug>
#include <QImage>
#include <thread>

PQCQDbusServer::PQCQDbusServer() : QObject() {

    const QString server_str = "org.photoqt.PhotoQtQML";

    // Connect to a Local Server (if available)
    QLocalSocket socket;
    socket.connectToServer(server_str);

    // If this is successful, then an instance is already running
    if(socket.waitForConnected(1000)) {
        m_existingServer = true;
        m_server = nullptr;
        return;
    }

    m_server = new QLocalServer;
    m_server->removeServer(server_str);
    m_server->listen(server_str);
    connect(m_server, &QLocalServer::newConnection, this, &PQCQDbusServer::handleConnection);

}

PQCQDbusServer::~PQCQDbusServer() {
    delete m_server;
}

void PQCQDbusServer::sendMessage(QString what, QString message) {

    QLocalSocket socket;
    socket.connectToServer("org.photoqt.PhotoQtCPP");

    if(!socket.waitForConnected(1000)) {
        qCritical() << "ERROR: Timeout connecting to CPP DBUS server";
        return;
    }

    socket.write(QString("%1\n%2").arg(what, message).toUtf8());
    socket.flush();

    std::this_thread::sleep_for(std::chrono::milliseconds(100));

}

void PQCQDbusServer::handleConnection() {

    // startup
    // save colorspace
    // disable colorspace support
    // show notification

    QLocalSocket *socket = m_server->nextPendingConnection();
    if(socket->waitForReadyRead(2000)) {

        QString txt = socket->readAll();
        QStringList args = txt.split('\n');

        QString what = args[0];
        args.removeFirst();

        Q_EMIT performAction(what, args);

    }

}

