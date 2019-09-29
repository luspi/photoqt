#include "handlingwallpaper.h"
#include <QtDebug>

PQHandlingWallpaper::PQHandlingWallpaper(QObject *parent) : QObject(parent) {}

void PQHandlingWallpaper::setWallpaper(QString category, QString filename, QVariantMap options) {

    qDebug() << category;
    qDebug() << filename;
    qDebug() << options;

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
        int ret = proc.execute(QString("gsettings set org.gnome.desktop.background picture-options %1").arg(opt));
        if(ret != 0)
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: gsettings failed with exit code " << ret
                << " - are you sure Gnome/Unity is installed?" << NL;
        else
            proc.execute(QString("gsettings set org.gnome.desktop.background picture-uri file:/%1").arg(filename));


    } else if(category == "xfce") {


        QString opt = options.value("option").toString();
        QVariantList screens = options.value("screens").toList();

        QProcess proc;
        proc.setProcessChannelMode(QProcess::MergedChannels);

        proc.start("xfconf-query -c xfce4-desktop -lv");
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
            setwallpaper.execute(QString("xfconf-query -c xfce4-desktop -p %1/image-style -s \"%2\"").arg(pathToSetImageTo.at(i)).arg(opt));
            setwallpaper.execute(QString("xfconf-query -c xfce4-desktop -p %1/last-image -s \"%2\"").arg(pathToSetImageTo.at(i)).arg(filename));
        }


    } else if(category == "enlightenment") {


        QVariantList screens = options.value("screens").toList();
        QVariantList workspaces = options.value("workspaces").toList();

        // First we check if DBUS is enabled
        // (we could enable it automatically, however, the available options presented to the user might change depending on its output!)
        QProcess proc;
        proc.setProcessChannelMode(QProcess::MergedChannels);
        proc.start("enlightenment_remote -module-list");

        while(proc.waitForFinished(1000)) {}

        int ret = proc.exitCode();
        if(ret != 0) {
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: enlightenment_remote failed with return code " << ret << " - is Enlightenment installed?" << NL;
            return;
        }

        QStringList output = QString(proc.readAll()).split("\n");

        if(!output.contains("msgbus -- Enabled")) {
            LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: Enlightenment module 'msgbus' doesn't seem to be loaded! Please fix that first..." << NL;
            return;
        }

        for(int i = 0; i < screens.length(); ++i) {
            for(int j = 0; j < workspaces.length(); ++j) {
                int currentscreen = screens.at(i).toInt()-1;
                int currentworkspace = workspaces.at(j).toInt()-1;
                // >= 1e7 - This means, that there is a single COLUMN of workspaces
                if(currentworkspace >= 1e7) {
                    QProcess::execute(QString("enlightenment_remote -desktop-bg-add 0 %1 0 %2 \"%3\"")
                                      .arg(currentscreen).arg((currentworkspace/1e7)-1).arg(filename));
                // >= 1e4 - This means, that there is a single ROW of workspaces
                } else if(currentworkspace >= 1e4) {
                    QProcess::execute(QString("enlightenment_remote -desktop-bg-add 0 %1 %2 0 \"%3\"")
                                      .arg(currentscreen).arg((currentworkspace/1e4)-1).arg(filename));
                // This means, that there is a grid of workspaces, both dimensions larger than 1
                } else {
                    int row = currentworkspace/100;
                    int column = currentworkspace%100;
                    QProcess::execute(QString("enlightenment_remote -desktop-bg-add 0 %1 %2 %3 \"%3\"")
                                      .arg(currentscreen).arg(row).arg(column).arg(filename));
                }

            }
        }


    } else if(category == "other") {


        QString app = options.value("app").toString();
        QString opt = options.value("option").toString();

        if(app == "feh") {
            int ret = QProcess::execute(QString("feh %1 %2").arg(opt).arg(filename));
            if(ret != 0)
                LOG << CURDATE << "PQHandlingWallpaper::setWallpaper: ERROR: feh exited with return code " << ret
                    << " - are you sure it is installed?" << NL;
        } else {
            int ret = QProcess::execute(QString("nitrogen %1 %2").arg(opt).arg(filename));
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
    return checkCommand("which xfconf-query", out);
}

bool PQHandlingWallpaper::checkFeh() {
    QString out;
    return checkCommand("which feh", out);
}

bool PQHandlingWallpaper::checkNitrogen() {
    QString out;
    return checkCommand("which nitrogen", out);
}

bool PQHandlingWallpaper::checkGSettings() {
    QString out;
    return checkCommand("which gsettings", out);
}

bool PQHandlingWallpaper::checkEnlightenmentRemote() {
    QString out;
    return checkCommand("which enlightenment_remote", out);
}

bool PQHandlingWallpaper::checkEnlightenmentMsgbus() {
    QString out;
    checkCommand("enlightenment_remote -module-list", out);
    return (out.contains("msgbus -- Enabled") ? 0 : 1);
}

bool PQHandlingWallpaper::checkCommand(QString cmd, QString &out) {
    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);
    proc.start(cmd);
    proc.waitForFinished(1000);
    out = proc.readAll();
    int ret = proc.exitCode();
    return (ret != 0);
}

QString PQHandlingWallpaper::detectWM() {

    if(QString(getenv("KDE_FULL_SESSION")).toLower() == "true" && QString(getenv("KDE_SESSION_VERSION")).toLower() == "5")
        return "plasma";
    else if(QString(getenv("DESKTOP_SESSION")).toLower() == "gnome" || QString(getenv("XDG_CURRENT_DESKTOP")).toLower() == "unity" ||
              QString(getenv("DESKTOP_SESSION")).toLower() == "ubuntu")
        return "gnome";
    else if(QString(getenv("XDG_CURRENT_DESKTOP")).toLower() == "xfce4" || QString(getenv("XDG_CURRENT_DESKTOP")).toLower() == "xfce")
        return "xfce";
    else if(QString(getenv("DESKTOP_SESSION")).toLower() == "enlightenment")
        return "enlightenment";
    else
        return "other";

}

int PQHandlingWallpaper::getEnlightenmentWorkspaceCount() {

    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);

    proc.start("enlightenment_remote -desktops-get");
    while(proc.waitForFinished()) {}

    QString out = proc.readAll();
    int ret= proc.exitCode();

    if(ret != 0) {
        LOG << CURDATE << "PQHandlingWallpaper::getEnlightenmentWorkspaceCount: ERROR: enlightenment_remote failed with return code " << ret
            << " - is Enlightenment installed and the DBUS module activated?" << NL;
        return 1;
    }

    QStringList parts = out.trimmed().split(" ");
    if(parts.length() != 2) {
        LOG << CURDATE << "PQHandlingWallpaper::getEnlightenmentWorkspaceCount: ERROR: Failed to get proper workspace count! "
                       << "Falling back to default (1x1)" << NL;
        return 1;
    }

    return parts.at(0).toInt()*parts.at(1).toInt();

}
