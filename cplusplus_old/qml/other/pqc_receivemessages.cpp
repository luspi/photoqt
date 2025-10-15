#include <pqc_receivemessages.h>
#include <QLocalServer>
#include <QLocalSocket>
#include <QFileInfo>

PQCReceiveMessages::PQCReceiveMessages() {

    // Create server name. If this is changed, then the string in PQCSingleInstance also needs to be changed.
    QString server_str = "org.photoqt.PhotoQt";

    // Create a new local server
    m_server = new QLocalServer();
    m_server->removeServer(server_str);
    m_server->listen(server_str);
    connect(m_server, &QLocalServer::newConnection, this, &PQCReceiveMessages::newConnection);

}

void PQCReceiveMessages::newConnection() {
    QLocalSocket *socket = m_server->nextPendingConnection();
    if(socket->waitForReadyRead(2000)) {
        const QList<QByteArray> reply = socket->readAll().split('\n');
        QList<Actions> handleAll;
        for(const QByteArray &rep : reply) {
            if(rep.startsWith("_T_O_K_E_N_")) {
                qputenv("XDG_ACTIVATION_TOKEN", rep.last(rep.length()-11));
            } else if(rep.startsWith("_F_I_L_E_")) {
                m_receivedFile = rep.last(rep.length()-9);
                handleAll.append(Actions::File);
            } else if(rep.startsWith("_S_H_O_R_T_C_U_T_")) {
                m_receivedShortcut = rep.last(rep.length()-17);
                handleAll.append(Actions::Shortcut);
            } else if(rep.startsWith("_S_E_T_T_I_N_G_")) {
                const QList<QByteArray> tmp = rep.last(rep.length()-15).split(':');
                m_receivedSetting[0] = tmp[0];
                m_receivedSetting[1] = tmp[1];
                handleAll.append(Actions::Setting);
            } else {
                const QList<QByteArray> _reps = rep.split('/');
                for(const QByteArray &r : _reps) {
                    handleAll.append(static_cast<Actions>(r.toInt()));
                }
            }
        }
        handleMessage(handleAll);
    }
    socket->close();
    delete socket;
}

void PQCReceiveMessages::handleMessage(const QList<Actions> msg) {

    qDebug() << "args: msg";

    QStringList allfiles;
    QStringList allfolders;

    QFileInfo info(m_receivedFile);

    for(const Actions &m : std::as_const(msg)) {

        switch(m) {

        case Actions::File:

            // sort by files and folders
            // that way we can make sure to always load the first specified file as initial image
            if(!info.exists())
                continue;
            if(info.isFile())
                allfiles.append(m_receivedFile);
            else if(info.isDir())
                allfolders.append(m_receivedFile);
            break;

        case Actions::Open:

            Q_EMIT cmdOpen();
            break;

        case Actions::Show:

            Q_EMIT cmdShow();
            break;

        case Actions::Hide:

            Q_EMIT cmdHide();
            break;

        case Actions::Quit:

            Q_EMIT cmdQuit();
            break;

        case Actions::Toggle:

            Q_EMIT cmdToggle();
            break;

        case Actions::StartInTray:

            cmdSetStartInTray(true);
            break;

        case Actions::Tray:

            Q_EMIT cmdTray(true);
            break;

        case Actions::NoTray:

            Q_EMIT cmdTray(false);
            break;

        case Actions::Shortcut:

            Q_EMIT cmdShortcutSequence(m_receivedShortcut);
            break;

        case Actions::Debug:

            Q_EMIT cmdSetDebugMode(true);
            break;

        case Actions::NoDebug:

            Q_EMIT cmdSetDebugMode(false);
            break;

        case Actions::Setting:

            Q_EMIT cmdSettingUpdate({m_receivedSetting[0], m_receivedSetting[1]});
            break;

        default:
            qWarning() << "Unknown action received:" << static_cast<int>(m);

        }

    }

    // if we have files and/or folders that were passed on
    // if(allfiles.length() > 0 || allfolders.length() > 0) {
    //     allfiles.append(allfolders);
    //     if(allfiles.length() > 1)
    //         Q_EMIT PQCFileFolderModelCPP::get().setExtraFoldersToLoad(allfiles.mid(1));
    //     else
    //         Q_EMIT PQCFileFolderModelCPP::get().setExtraFoldersToLoad({});
    //     PQCNotifyCPP::get().setFilePath(allfiles[0]);
    // }

}
