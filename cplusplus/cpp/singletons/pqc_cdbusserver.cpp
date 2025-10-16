#include <cpp/pqc_cdbusserver.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QtDebug>

PQCCDbusServer::PQCCDbusServer() {

    m_server = new QLocalServer;
    m_server->listen("org.photoqt.PhotoQt.CPP");
    connect(m_server, &QLocalServer::newConnection, this, &PQCCDbusServer::handleConnection);

}

PQCCDbusServer::~PQCCDbusServer() {
    delete m_server;
}

void PQCCDbusServer::sendMessage(QString message) {

    QLocalSocket socket;
    socket.connectToServer("org.photoqt.PhotoQt.QML");

    if(!socket.waitForConnected(1000)) {
        qCritical() << "ERROR: Timeout connecting to QML DBUS server";
        return;
    }

    socket.write(message.toUtf8());
    socket.flush();

}

void PQCCDbusServer::handleConnection() {

}
