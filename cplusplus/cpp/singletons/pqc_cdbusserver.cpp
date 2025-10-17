#include <cpp/pqc_cdbusserver.h>
#include <cpp/pqc_cscriptslocalization.h>
#include <shared/pqc_csettings.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QtDebug>
#include <thread>

PQCCDbusServer::PQCCDbusServer() {

    const QString server_str = "org.photoqt.PhotoQtCPP";

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
    connect(m_server, &QLocalServer::newConnection, this, &PQCCDbusServer::handleConnection);

}

PQCCDbusServer::~PQCCDbusServer() {
    delete m_server;
}

void PQCCDbusServer::sendMessage(QString what, QString message) {

    QLocalSocket socket;
    socket.connectToServer("org.photoqt.PhotoQtQML");

    if(!socket.waitForConnected(1000)) {
        qCritical() << "ERROR: Timeout connecting to QML DBUS server";
        return;
    }

    socket.write(QString("%1\n%2").arg(what, message).toUtf8());
    socket.flush();

    std::this_thread::sleep_for(std::chrono::milliseconds(100));

}

void PQCCDbusServer::handleConnection() {

    QLocalSocket *socket = m_server->nextPendingConnection();
    if(socket->waitForReadyRead(2000)) {

        QString txt = socket->readAll();
        QStringList args = txt.split('\n');

        QString what = args[0];
        args.removeFirst();

        if(what == "settings" && args.length() > 0 && args[0] == "readdb") {

            PQCCSettings::get().readDB();

        } else if(what == "updateTranslation" && args.length() > 0) {

            PQCCScriptsLocalization::get().updateTranslation(args[0]);

        }

        Q_EMIT performAction(what, args);

    }

}
