#include <qml/pqc_qdbusserver.h>
#include <QLocalServer>

PQCQDbusServer::PQCQDbusServer() : QObject() {

    m_server = new QLocalServer;
    m_server->listen("org.photoqt.PhotoQt.QML");
    connect(m_server, &QLocalServer::newConnection, this, &PQCQDbusServer::handleConnection);

}

PQCQDbusServer::~PQCQDbusServer() {
    delete m_server;
}

void PQCQDbusServer::handleConnection() {

}
