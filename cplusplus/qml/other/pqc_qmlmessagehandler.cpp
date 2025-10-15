#include <pqc_qmlmessagehandler.h>
#include <QLocalServer>

PQCQMLMessageHandler::PQCQMLMessageHandler() {

    m_server = new QLocalServer;
    m_server->listen("org.photoqt.PhotoQt.QML");
    connect(m_server, &QLocalServer::newConnection, this, &PQCQMLMessageHandler::handleConnection);

}

void PQCQMLMessageHandler::handleConnection() {

}
