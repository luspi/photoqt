#include "wallpaper.h"

GetAndDoStuffWallpaper::GetAndDoStuffWallpaper(QObject *parent) : QObject(parent) { }
GetAndDoStuffWallpaper::~GetAndDoStuffWallpaper() { }

QString GetAndDoStuffWallpaper::detectWindowManager() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffWallpaper::detectWindowManager()" << NL;

    if(QString(getenv("KDE_FULL_SESSION")).toLower() == "true") {
        if(QString(getenv("KDE_SESSION_VERSION")).toLower() == "5")
            return "plasma5";
        return "kde4";
    } else if(QString(getenv("DESKTOP_SESSION")).toLower() == "gnome" || QString(getenv("XDG_CURRENT_DESKTOP")).toLower() == "unity" || QString(getenv("DESKTOP_SESSION")).toLower() == "ubuntu")
        return "gnome_unity";
    else if(QString(getenv("DESKTOP_SESSION")).toLower() == "xfce4" || QString(getenv("DESKTOP_SESSION")).toLower() == "xfce")
        return "xfce4";
    else if(QString(getenv("DESKTOP_SESSION")).toLower() == "enlightenment")
        return "enlightenment";
    else
        return "other";

}

void GetAndDoStuffWallpaper::setWallpaper(QString wm, QVariantMap options, QString file) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - " << wm.toStdString() << " / " << options.count() << " / " << file.toStdString() << NL;

    // SET GNOME/UNITY WALLPAPER
    if(wm == "gnome_unity") {

        QProcess proc;
        int ret = proc.execute(QString("gsettings set org.gnome.desktop.background picture-options %1").arg(options.value("option").toString()));
        if(ret != 0)
            LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - ERROR: gsettings failed with exit code " << ret << " - are you sure Gnome/Unity is installed?" << NL;
        else
            proc.execute(QString("gsettings set org.gnome.desktop.background picture-uri file:/%1").arg(file));

    }

    // SET XFCE4 WALLPAPER
    if(wm == "xfce4") {

        QVariantList screens = options.value("screens").toList();

        RunProcess proc;

        proc.start("xfconf-query -c xfce4-desktop -lv");
        while(proc.waitForOutput()) {}
        if(proc.gotError()) {
            LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - ERROR (code: " << proc.getErrorCode() << "): Failed to start xfconf-query! Is XFCE4 installed?" << NL;
            return;
        }

        QStringList output = proc.getOutput().split("\n");

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
                    if(line.contains(QString("-%1/workspace").arg(screens.at(i).toInt()))) {
                        ignore = false;
                        break;
                    }
                }
                if(!ignore)
                    pathToSetImageTo.append(line);
            }

        }

        QStringList xfcePicOpts;
        xfcePicOpts << "Automatic";
        xfcePicOpts << "Centered";
        xfcePicOpts << "Tiled";
        xfcePicOpts << "Stretched";
        xfcePicOpts << "Scaled";
        xfcePicOpts << "Zoomed";
        int imagestyle = xfcePicOpts.indexOf(options.value("option").toString());

        for(int i = 0; i < pathToSetImageTo.length(); ++i) {
            QProcess setwallpaper;
            setwallpaper.execute(QString("xfconf-query -c xfce4-desktop -p %1/image-style -s \"%2\"").arg(pathToSetImageTo.at(i)).arg(imagestyle));
            setwallpaper.execute(QString("xfconf-query -c xfce4-desktop -p %1/last-image -s \"%2\"").arg(pathToSetImageTo.at(i)).arg(file));
        }

    }

    if(wm == "enlightenment") {

        QVariantList screens = options.value("screens").toList();
        QVariantList workspaces = options.value("workspaces").toList();

        // First we check if DBUS is enabled (we could enable it automatically, however, the available options presented to the user might change depending on its output!)
        RunProcess proc;
        proc.start("enlightenment_remote -module-list");
        while(proc.waitForOutput()) {}
        if(proc.gotError()) {
            LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - ERROR (code: " << proc.getErrorCode() << "): Failed to start enlightenment_remote! Is Enlightenment installed?" << NL;
            return;
        }
        if(!proc.getOutput().contains("msgbus -- Enabled")) {
            LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - ERROR: Enlightenment module 'msgbus' doesn't seem to be loaded! Please check that..." << NL;
            return;
        }

        for(int i = 0; i < screens.length(); ++i) {
            for(int j = 0; j < workspaces.length(); ++j) {
                int currentscreen = screens.at(i).toInt();
                int currentworkspace = workspaces.at(j).toInt();
                // >= 1e7 - This means, that there is a single COLUMN of workspaces
                if(currentworkspace >= 1e7) {
                    QProcess::execute(QString("enlightenment_remote -desktop-bg-add 0 %1 0 %2 \"%3\"").arg(currentscreen).arg((currentworkspace/1e7)-1).arg(file));
                // >= 1e4 - This means, that there is a single ROW of workspaces
                } else if(currentworkspace >= 1e4) {
                    QProcess::execute(QString("enlightenment_remote -desktop-bg-add 0 %1 %2 0 \"%3\"").arg(currentscreen).arg((currentworkspace/1e4)-1).arg(file));
                // This means, that there is a grid of workspaces, both dimensions larger than 1
                } else {
                    int row = currentworkspace/100;
                    int column = currentworkspace%100;
                    QProcess::execute(QString("enlightenment_remote -desktop-bg-add 0 %1 %2 %3 \"%3\"").arg(currentscreen).arg(row).arg(column).arg(file));
                }

            }
        }

    }

    if(wm == "other") {

        QString app = options.value("app").toString();

        if(app == "feh") {
            int ret = QProcess::execute(QString("feh %1 %2").arg(options.value("feh_option").toString()).arg(file));
            if(ret != 0)
                LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - ERROR: feh exited with error code " << ret << " - are you sure it is installed?" << NL;
        } else {
            int ret = QProcess::execute(QString("nitrogen %1 %2").arg(options.value("nitrogen_option").toString()).arg(file));
            if(ret != 0)
                LOG << CURDATE << "GetAndDoStuffWallpaper::setWallpaper() - ERROR: nitrogen exited with error code " << ret << " - are you sure it is installed?" << NL;
        }

    }

}

int GetAndDoStuffWallpaper::getScreenCount() {
    return QGuiApplication::screens().count();
}

QList<int> GetAndDoStuffWallpaper::getEnlightenmentWorkspaceCount() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffWallpaper::getEnlightenmentWorkspaceCount()" << NL;

    QList<int> ret;

    RunProcess proc;

    proc.start("enlightenment_remote -desktops-get");
    while(proc.waitForOutput()) {}
    if(proc.gotError()) {
        LOG << CURDATE << "GetAndDoStuffWallpaper::getEnlightenmentWorkspaceCount() - ERROR (code: " << proc.getErrorCode() << "): Failed to start enlightenment_remote! Is Enlightenment installed and the DBUS module activated?" << NL;
        return QList<int>() << 1 << 1;
    }

    QStringList parts = proc.getOutput().trimmed().split(" ");
    if(parts.length() != 2) {
        if(checkWallpaperTool("enlightenment") != 2)
            LOG << CURDATE << "GetAndDoStuffWallpaper::getEnlightenmentWorkspaceCount() - ERROR: Failed to get proper workspace count! Falling back to default (1x1)" << NL;
        return QList<int>() << 1 << 1;
    }
    // Enlightenment returns columns before rows
    ret.append(parts.at(1).toInt());
    ret.append(parts.at(0).toInt());

    return ret;


}

int GetAndDoStuffWallpaper::checkWallpaperTool(QString wm) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffWallpaper::checkWallpaperTool() - " << wm.toStdString() << NL;

    if(wm == "enlightenment") {
        RunProcess proc;
        proc.start("enlightenment_remote -module-list");
        while(proc.waitForOutput()) {}
        if(proc.gotError())
            return 1;
        if(!proc.getOutput().contains("msgbus -- Enabled"))
            return 2;
        return 0;
    } else if(wm == "gnome_unity") {
        QProcess proc;
        proc.setStandardOutputFile(QProcess::nullDevice());
        proc.start("gsettings");
        while(proc.waitForFinished()) { }
        int ret = proc.exitCode();
        if(ret <= 0) return 1; // gsettings unavailable
        return 0;
    } else if(wm == "xfce4") {
        QProcess proc;
        proc.setStandardOutputFile(QProcess::nullDevice());
        proc.start("xfconf-query");
        while(proc.waitForFinished()) { }
        int ret = proc.exitCode();
        if(ret <= 0) return 1; // xfconf-query unavailable
        return 0;
    } else if(wm == "other") {
        QProcess proc;
        proc.setStandardOutputFile(QProcess::nullDevice());
        proc.start("feh");
        while(proc.waitForFinished()) { }
        int ret_feh = proc.exitCode();
        proc.start("nitrogen");
        while(proc.waitForFinished()) { }
        int ret_nit = proc.exitCode();
        if(ret_feh <= 0 && ret_nit <= 0)
            return 3;   // both nitrogen and feh not available
        else if(ret_nit <= 0)
            return 2;   // nitrogen not available
        else if(ret_feh <= 0)
            return 1;   // feh not available
        return 0;
    }
    return -1;
}
