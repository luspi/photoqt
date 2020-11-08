#include "handlingwallpaper.h"

PQHandlingWallpaper::PQHandlingWallpaper(QObject *parent) : QObject(parent) {}

void PQHandlingWallpaper::setWallpaper(QString category, QString filename, QVariantMap options) {

    if(category == "plasma") {

        QVariantList screens = options.value("screens").toList();

        for(int i = 0; i < screens.length(); ++i) {

            QString arg = "string: "
                          "var Desktops = desktops(); "
                          "d = Desktops[" + QString::number(screens.at(i).toInt()-1) + "]; "
                          "d.wallpaperPlugin = \"org.kde.image\"; "
                          "d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\"); "
                          "d.writeConfig(\"Image\", \"file://" + filename + "\");";

            QDBusConnection bus = QDBusConnection::sessionBus();

            QDBusInterface *interface = new QDBusInterface("org.kde.plasmashell",
                                                           "/PlasmaShell",
                                                           "org.kde.PlasmaShell",
                                                           bus,
                                                           this);

            interface->call("evaluateScript", arg);

        }


    } else if(category == "gnome") {


        QString opt = options.value("option").toString();

        QProcess proc;
        int ret = proc.execute("gsettings", QStringList() << "set" << "org.gnome.desktop.background" << "picture-options" << opt);
        if(ret != 0)
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: gsettings failed with exit code " << ret
                << " - are you sure Gnome/Unity is installed?" << NL;
        else
            proc.execute("gsettings", QStringList() << "set" << "org.gnome.desktop.background" << "picture-uri" << QString("file://%1").arg(filename));


    } else if(category == "xfce") {


        QString opt = options.value("option").toString();
        QVariantList screens = options.value("screens").toList();

        QProcess proc;
        proc.setProcessChannelMode(QProcess::MergedChannels);

        proc.start("xfconf-query", QStringList() << "-c" << "xfce4-desktop" << "-lv");
        while(proc.waitForFinished(1000)) {}

        int ret = proc.exitCode();

        if(ret != 0) {
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: xfconf-query failed with return code " << ret << " - is XFCE4 installed?" << NL;
            return;
        }

        QStringList output = QString(proc.readAll()).split("\n");

        // Filter out all the config paths that we need to adjust
        QStringList pathToSetImageTo;
        for(QString line : output) {
            // Correct line
            if(line.startsWith("/backdrop/screen0/monitor")
                        && line.contains("/image-style")) {
                line = line.split("/image-style").at(0).trimmed();
                bool ignore = true;
                // Check for screen
                for(int i = 0; i < screens.length(); ++i) {
                    if(line.contains(QString("%1/workspace").arg(screens.at(i).toInt()-1))) {
                        ignore = false;
                        break;
                    }
                }
                if(!ignore)
                    pathToSetImageTo.append(line);
            }

        }

        for(int i = 0; i < pathToSetImageTo.length(); ++i) {
            QProcess setwallpaper;
            setwallpaper.execute("xfconf-query", QStringList() << "-c" << "xfce4-desktop" << "-p" << QString("%1/image-style").arg(pathToSetImageTo.at(i)) << "-s" << opt);
            setwallpaper.execute("xfconf-query", QStringList() << "-c" << "xfce4-desktop" << "-p" << QString("%1/last-image").arg(pathToSetImageTo.at(i)) << "-s" << filename);
        }


    } else if(category == "enlightenment") {


        QVariantList screens = options.value("screens").toList();
        QVariantList workspaces = options.value("workspaces").toList();

        // First we check if DBUS is enabled
        // (we could enable it automatically, however, the available options presented to the user might change depending on its output!)
        QProcess proc;
        proc.setProcessChannelMode(QProcess::MergedChannels);
        proc.start("enlightenment_remote", QStringList() << "-module-list");

        while(proc.waitForFinished(1000)) {}

        int ret = proc.exitCode();
        if(ret != 0) {
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: enlightenment_remote failed with return code " << ret << " - is Enlightenment installed?" << NL;
            return;
        }

        QString sep = "\n";
        QStringList output = QString(proc.readAll()).split(QRegularExpression("(\\s*)"+sep+"(\\s*)"));

        if(!output.contains("msgbus -- Enabled")) {
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: Enlightenment module 'msgbus' doesn't seem to be loaded! Please fix that first..." << NL;
            return;
        }

        for(int i = 0; i < screens.length(); ++i) {
            for(int w = 0; w < workspaces.length(); ++w) {
                QString sep = "-";
                QStringList w_parts = workspaces[w].toString().split(QRegularExpression("(\\s*)"+sep+"(\\s*)"));
                int w_col = w_parts[0].toInt()-1;
                int w_row = w_parts[1].toInt()-1;
                QProcess::execute("enlightenment_remote", QStringList() << "-desktop-bg-add" << "0" << QString::number(screens.at(i).toInt()-1) << QString::number(w_row) << QString::number(w_col) << filename);
            }
        }


    } else if(category == "other") {


        QString app = options.value("app").toString();
        QString opt = options.value("option").toString();

        if(app == "feh") {
            int ret = QProcess::execute("feh", QStringList() << opt << filename);
            if(ret != 0)
                LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: feh exited with return code " << ret
                    << " - are you sure it is installed?" << NL;
        } else {
            int ret = QProcess::execute("nitrogen", QStringList() << opt << filename);
            if(ret != 0)
                LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: nitrogen exited with return code " << ret
                    << " - are you sure it is installed?" << NL;
        }


    } else
        LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: Unknown window manager: " << category.toStdString() << NL;

}

int PQHandlingWallpaper::getScreenCount() {
    return QGuiApplication::screens().count();
}

bool PQHandlingWallpaper::checkXfce() {
    QString out;
    checkIfCommandExists("xfconf-query", QStringList() << "--version", out);
    return (out=="");
}

bool PQHandlingWallpaper::checkFeh() {
    QString out;
    checkIfCommandExists("feh", QStringList() << "--version", out);
    return (out=="");
}

bool PQHandlingWallpaper::checkNitrogen() {
    QString out;
    checkIfCommandExists("nitrogen", QStringList() << "--version", out);
    return (out=="");
}

bool PQHandlingWallpaper::checkGSettings() {
    QString out;
    checkIfCommandExists("gsettings", QStringList() << "--version", out);
    return (out=="");
}

bool PQHandlingWallpaper::checkEnlightenmentRemote() {
    QString out;
    checkIfCommandExists("enlightenment_remote", QStringList() << "-h", out);
    return (out=="");
}

bool PQHandlingWallpaper::checkEnlightenmentMsgbus() {
    QString out;
    checkIfCommandExists("enlightenment_remote", QStringList() << "-module-list", out);
    return (out.contains("msgbus -- Enabled") ? 0 : 1);
}

bool PQHandlingWallpaper::checkIfCommandExists(QString cmd, QStringList args, QString &out) {
    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);
    proc.start(cmd, args);
    proc.waitForFinished(1000);
    out = proc.readAll();
    int ret = proc.exitCode();
    return (ret == 0);
}

QString PQHandlingWallpaper::detectWM() {

    if(QString(getenv("KDE_FULL_SESSION")).toLower() == "true" && QString(getenv("KDE_SESSION_VERSION")).toLower() == "5")
        return "plasma";
    else if(QString(getenv("DESKTOP_SESSION")).toLower() == "gnome" || QString(getenv("DESKTOP_SESSION")).toLower() == "unity" ||
              QString(getenv("DESKTOP_SESSION")).toLower() == "ubuntu" || QString(getenv("DESKTOP_SESSION")).toLower() == "cinnamon")
        return "gnome";
    else if(QString(getenv("XDG_CURRENT_DESKTOP")).toLower() == "xfce4" || QString(getenv("XDG_CURRENT_DESKTOP")).toLower() == "xfce")
        return "xfce";
    else if(QString(getenv("DESKTOP_SESSION")).toLower() == "enlightenment")
        return "enlightenment";
    else
        return "other";

}

QList<int> PQHandlingWallpaper::getEnlightenmentWorkspaceCount() {

    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);

    proc.start("enlightenment_remote", QStringList() << "-desktops-get");
    while(proc.waitForFinished()) {}

    QString out = proc.readAll();
    int ret= proc.exitCode();

    if(ret != 0) {
        LOG << CURDATE << "PQHandlingWallpaper::getEnlightenmentWorkspaceCount: ERROR: enlightenment_remote failed with return code " << ret
            << " - is Enlightenment installed and the DBUS module activated?" << NL;
        return {1,1};
    }

    QStringList parts = out.trimmed().split(" ");
    if(parts.length() != 2) {
        LOG << CURDATE << "PQHandlingWallpaper::getEnlightenmentWorkspaceCount: ERROR: Failed to get proper workspace count! "
                       << "Falling back to default (1x1)" << NL;
        return {1,1};
    }

    return {parts.at(0).toInt(), parts.at(1).toInt()};

}
