/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <scripts/qmlcpp/pqc_scriptswallpaper.h>

#include <QtDebug>
#include <QApplication>
#include <QProcess>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QRegularExpression>

#ifdef WIN32
#include <Windows.h>
#include <wininet.h>
#include <ShlObj.h>
#endif

PQCScriptsWallpaper::PQCScriptsWallpaper() {

}

PQCScriptsWallpaper::~PQCScriptsWallpaper() {

}

int PQCScriptsWallpaper::getScreenCount() {
    qDebug() << "";
    return QApplication::screens().count();
}

bool PQCScriptsWallpaper::checkIfCommandExists(QString cmd, QStringList args, QString &out) {

    qDebug() << "args: cmd =" << cmd;
    qDebug() << "args: args =" << args.join(",");

    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);
    proc.start(cmd, args);
    proc.waitForFinished(1000);
    out = proc.readAll();
    int ret = proc.exitCode();
    return (ret == 0);

}


bool PQCScriptsWallpaper::checkGSettings() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("gsettings", QStringList() << "--version", out);
    return (out=="");

}

bool PQCScriptsWallpaper::checkFeh() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("feh", QStringList() << "--version", out);
    return (out=="");

}

bool PQCScriptsWallpaper::checkNitrogen() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("nitrogen", QStringList() << "--version", out);
    return (out=="");

}

bool PQCScriptsWallpaper::checkXfce() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("xfconf-query", QStringList() << "--version", out);
    return (out=="");

}

bool PQCScriptsWallpaper::checkEnlightenmentMsgbus() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("enlightenment_remote", QStringList() << "-module-list", out);
    return (out.contains("msgbus -- Enabled") ? 0 : 1);

}

bool PQCScriptsWallpaper::checkEnlightenmentRemote() {

    qDebug() << "";

    QString out;
    checkIfCommandExists("enlightenment_remote", QStringList() << "-h", out);
    return (out=="");

}

QList<int> PQCScriptsWallpaper::getEnlightenmentWorkspaceCount() {

    qDebug() << "";

    QProcess proc;
    proc.setProcessChannelMode(QProcess::MergedChannels);

    proc.start("enlightenment_remote", QStringList() << "-desktops-get");
    while(proc.waitForFinished()) {}

    QString out = proc.readAll();
    int ret= proc.exitCode();

    if(ret != 0) {
        qWarning() << "ERROR: enlightenment_remote failed with return code" << ret << "- is Enlightenment installed and the DBUS module activated?";
        return {1,1};
    }

    QStringList parts = out.trimmed().split(" ");
    if(parts.length() != 2) {
        qWarning() << "ERROR: Failed to get proper workspace count! Falling back to default (1x1)";
        return {1,1};
    }

    return {parts.at(0).toInt(), parts.at(1).toInt()};

}


void PQCScriptsWallpaper::setWallpaper(QString category, QString filename, QVariantMap options) {

    qDebug() << "args: category =" << category;
    qDebug() << "args: filename =" << filename;

#ifndef Q_OS_WIN
    if(category == "plasma") {

        QVariantList screens = options.value("screens").toList();

        for(int i = 0; i < screens.length(); ++i) {

            QString arg = "string: "
                          "var allDesktops = desktops(); "
                          "for(i = 0; i < allDesktops.length; i++) {"
                          "d = allDesktops[i];"
                          "d.wallpaperPlugin = \"org.kde.image\"; "
                          "d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\"); "
                          "d.writeConfig(\"Image\", \"file:" + filename + "\");"
                                       "}";

            QDBusConnection bus = QDBusConnection::sessionBus();

            QDBusInterface *interface = new QDBusInterface("org.kde.plasmashell",
                                                           "/PlasmaShell",
                                                           "org.kde.PlasmaShell",
                                                           bus,
                                                           this);

            interface->call("evaluateScript", arg);
            interface->deleteLater();

        }


    } else if(category == "gnome") {


        QString opt = options.value("option").toString();

        QProcess proc;
        int ret = proc.execute("gsettings", QStringList() << "set" << "org.gnome.desktop.background" << "picture-options" << opt);
        if(ret != 0)
            qWarning() << "ERROR: gsettings failed with exit code" << ret << "- are you sure Gnome/Unity is installed?";
        else
            proc.execute("gsettings", QStringList() << "set" << "org.gnome.desktop.background" << "picture-uri" << QString("file:%1").arg(filename));


    } else if(category == "xfce") {


        QString opt = options.value("option").toString();
        QVariantList screens = options.value("screens").toList();

        QProcess proc;
        proc.setProcessChannelMode(QProcess::MergedChannels);

        proc.start("xfconf-query", QStringList() << "-c" << "xfce4-desktop" << "-lv");
        while(proc.waitForFinished(1000)) {}

        int ret = proc.exitCode();

        if(ret != 0) {
            qWarning() << "ERROR: xfconf-query failed with return code" << ret << "- is XFCE4 installed?";
            return;
        }

        const QStringList output = QString(proc.readAll()).split("\n");

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
            qWarning() << "ERROR: enlightenment_remote failed with return code" << ret << "- is Enlightenment installed?";
            return;
        }

        QString sep = "\n";
        QStringList output = QString(proc.readAll()).split(QRegularExpression("(\\s*)"+sep+"(\\s*)"));

        if(!output.contains("msgbus -- Enabled")) {
            qWarning() << "ERROR: Enlightenment module 'msgbus' doesn't seem to be loaded! Please fix that first...";
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
                qWarning() << "ERROR: feh exited with return code" << ret << "- are you sure it is installed?";
        } else {
            int ret = QProcess::execute("nitrogen", QStringList() << opt << filename);
            if(ret != 0)
                qWarning() << "ERROR: nitrogen exited with return code" << ret << "- are you sure it is installed?";
        }


    } else
        qWarning() << "ERROR: Unknown window manager:" << category;

#else


    // get handle to current active desktop
    IActiveDesktop *pDesk;

    // Create an instance of the Active Desktop
    HRESULT hr = CoCreateInstance(CLSID_ActiveDesktop, NULL, CLSCTX_INPROC_SERVER,
                                  IID_IActiveDesktop, (void**)&pDesk);
    if(hr != S_OK) {
        qWarning() << "CoCreateInstance() returned error:" << hr;
        return;
    }

    // Create options struct
    WALLPAPEROPT opts;
    opts.dwSize = sizeof(WALLPAPEROPT);

    const int wallpaperStyle = options.value("WallpaperStyle").toInt();
    if(wallpaperStyle == 0)
        opts.dwStyle = WPSTYLE_CENTER;
    else if(wallpaperStyle == 1)
        opts.dwStyle = WPSTYLE_TILE;
    else if(wallpaperStyle == 2)
        opts.dwStyle = WPSTYLE_STRETCH;
    else if(wallpaperStyle == 3)
        opts.dwStyle = WPSTYLE_KEEPASPECT;
    else if(wallpaperStyle == 4)
        opts.dwStyle = WPSTYLE_CROPTOFIT;
    else if(wallpaperStyle == 5)
        opts.dwStyle = WPSTYLE_SPAN;

    // set the wallpaper
    hr = pDesk->SetWallpaper(filename.toStdWString().c_str(), 0);
    if(hr != S_OK) {
        qWarning() << "IActiveDesktop::SetWallpaper() returned error:" << hr;
        return;
    }

    // set the wallpaper options
    hr = pDesk->SetWallpaperOptions(&opts, 0);
    if(hr != S_OK) {
        qWarning() << "IActiveDesktop::SetWallpaperOptions() returned error:" << hr;
        return;
    }

    // apply the above changes
    pDesk->ApplyChanges(AD_APPLY_ALL);

    // call the Release method
    pDesk->Release();


#endif

}
