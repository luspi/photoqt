#include <qml/pqc_qdbusserver.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QtDebug>

PQCQDbusServer::PQCQDbusServer() : QObject() {

    m_server = new QLocalServer;
    m_server->listen("org.photoqt.PhotoQt.QML");
    connect(m_server, &QLocalServer::newConnection, this, &PQCQDbusServer::handleConnection);

}

PQCQDbusServer::~PQCQDbusServer() {
    delete m_server;
}

void PQCQDbusServer::sendMessage(QString message) {

    QLocalSocket socket;
    socket.connectToServer("org.photoqt.PhotoQt.CPP");

    if(!socket.waitForConnected(1000)) {
        qCritical() << "ERROR: Timeout connecting to CPP DBUS server";
        return;
    }

    socket.write(message.toUtf8());
    socket.flush();

}

void PQCQDbusServer::handleConnection() {

}
