#include <cpp/pqc_cdbusserver.h>
#include <QLocalServer>

PQCCDbusServer::PQCCDbusServer() {

    m_server = new QLocalServer;
    m_server->listen("org.photoqt.PhotoQt.CPP");
    connect(m_server, &QLocalServer::newConnection, this, &PQCCDbusServer::handleConnection);

}

PQCCDbusServer::~PQCCDbusServer() {
    delete m_server;
}

void PQCCDbusServer::handleConnection() {

}
