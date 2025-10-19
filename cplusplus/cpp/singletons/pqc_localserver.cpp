#include <cpp/pqc_localserver.h>
#include <cpp/pqc_cscriptslocalization.h>
#include <cpp/pqc_imageformats.h>
#include <shared/pqc_csettings.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QtDebug>
#include <thread>
#include <QtConcurrent/QtConcurrentRun>

PQCCLocalServer::PQCCLocalServer() {

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
    connect(m_server, &QLocalServer::newConnection, this, &PQCCLocalServer::handleConnection);

}

PQCCLocalServer::~PQCCLocalServer() {
    delete m_server;
}

void PQCCLocalServer::sendStartupMessageToBoth(QString message) {

    sendMessage("startup", message);

    QFuture<void> f = QtConcurrent::run([=]() {

        QLocalSocket socket;

        socket.connectToServer("org.photoqt.PhotoQtCPP");

        socket.write(QString("%1\n%2").arg("startup", message).toUtf8());
        socket.flush();

    });

}

void PQCCLocalServer::sendMessage(QString what, QString message) {

    QFuture<void> f = QtConcurrent::run([=]() {

        QLocalSocket socket;

        int counter = 0;
        while(counter < 100) {

            socket.connectToServer("org.photoqt.PhotoQtQML");

            if(socket.waitForConnected(100))
                break;

            counter += 1;
            std::this_thread::sleep_for(std::chrono::milliseconds(10));

        }

        if(!socket.waitForConnected(1000)) {
            qWarning() << "ERROR: Timeout connecting to QML DBUS server";
            return;
        }

        socket.write(QString("%1\n%2").arg(what, message).toUtf8());
        socket.flush();

    });

}

void PQCCLocalServer::handleConnection() {

    QLocalSocket *socket = m_server->nextPendingConnection();
    if(socket->waitForReadyRead(100)) {

        QString txt = socket->readAll();
        QStringList args = txt.split('\n');

        QString what = args[0];
        args.removeFirst();

        if(what == "settings" && args.length() > 0 && args[0] == "readdb") {

            PQCCSettings::get().readDB();

        } else if(what == "updateTranslation" && args.length() > 0) {

            PQCCScriptsLocalization::get().updateTranslation(args[0]);

        } else if(what == "startup") {

            // handle token
            for(int i = 0; i < args.length(); ++i) {
                if(args[i] == ":::TOKEN:::" && i < args.length()-1)
                    qputenv("XDG_ACTIVATION_TOKEN", QString("%1").arg(args[i+1]).toUtf8());
            }

        } else {

            if(what == "imageformats")
                PQCImageFormats::get().setup();

            Q_EMIT performAction(what, args);

        }

    }

}
