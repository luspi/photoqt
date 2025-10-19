#include <qml/pqc_localserver.h>
#include <shared/pqc_sharedconstants.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QtDebug>
#include <QImage>
#include <QApplication>
#include <QDateTime>

PQCQLocalServer::PQCQLocalServer() : QObject() {

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

    m_startupMessage.clear();

    m_server = new QLocalServer;
    m_server->removeServer(server_str);
    m_server->listen(server_str);
    connect(m_server, &QLocalServer::newConnection, this, &PQCQLocalServer::handleConnection);

}

PQCQLocalServer::~PQCQLocalServer() {
    delete m_server;
}

void PQCQLocalServer::checkForData() {
    // this is called during startup once the QML ha sbeen set up
    // there should ALWAYS be a message at startup, even if empty
    // thus this should normally return within less than 1ms!
    if(m_server->waitForNewConnection(100))
        handleConnection();
}

void PQCQLocalServer::sendMessage(QString what, QString message) {

    QLocalSocket socket;
    socket.connectToServer("org.photoqt.PhotoQtCPP");

    if(!socket.waitForConnected(10)) {
        qCritical() << "ERROR: Timeout connecting to CPP DBUS server";
        return;
    }

    socket.write(QString("%1\n%2").arg(what, message).toUtf8());
    socket.flush();

}

void PQCQLocalServer::handleConnection() {

    // startup
    // save colorspace
    // disable colorspace support
    // show notification

    if(!m_server->hasPendingConnections()) return;

    QLocalSocket *socket = m_server->nextPendingConnection();

    if(socket->waitForReadyRead(10)) {

        QString txt = socket->readAll();
        QStringList args = txt.split('\n');

        QString what = args[0];
        args.removeFirst();

        if(what == "startup")
            m_startupMessage = args;

        Q_EMIT performAction(what, args);

    }

}

