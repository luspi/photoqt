#include "startup.h"

PQStartup::PQStartup(QObject *parent) : QObject(parent) {

}

// 0: no update
// 1: update
// 2: fresh install
int PQStartup::check() {

    QSqlDatabase db;

    // check if sqlite is available
    // this is a hard requirement now and we wont launch PhotoQt without it
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "startup");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "startup");
    else {
        LOG << CURDATE << "PQStartup::check(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQStartup::check(): PhotoQt cannot function without SQLite available." << NL;
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQStartup", "SQLite error"),
                                 QCoreApplication::translate("PQStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        std::exit(1);
    }

    // if no config files exist, then it is a fresh install
    if((!QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB())) ||
        !QFile::exists(ConfigFiles::IMAGEFORMATS_DB()) ||
        !QFile::exists(ConfigFiles::SHORTCUTS_FILE())) {
        return 2;
    }

    // 2.4 and older used a settings file
    // 2.5 and later uses a settings database
    if(QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB()))
        return 1;

    // open database
    db.setDatabaseName(ConfigFiles::SETTINGS_DB());
    if(!db.open())
        LOG << CURDATE << "PQStartup::check(): Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;

    // compare version string in database to current version string
    QSqlQuery query(db);
    if(!query.exec("SELECT `value` from `general` where `name`='Version'"))
        LOG << CURDATE << "PQStartup::check(): SQL query error: " << query.lastError().text().trimmed().toStdString() << NL;
    query.next();

    // close database
    db.close();

    // updated
    QString version = query.record().value(0).toString();
    if(version != QString(VERSION))
        return 1;

    // if we are on dev, we pretend to always update
    if(QString(VERSION) == "dev")
        return 1;

    // nothing happened
    return 0;

}

bool PQStartup::checkIfBinaryExists(QString exec) {

#ifdef Q_OS_WIN
    return false;
#endif

    QProcess p;
    p.setStandardOutputFile(QProcess::nullDevice());
    p.start("which", QStringList() << exec);
    p.waitForFinished();
    return p.exitCode() == 0;
}

void PQStartup::setupFresh(int defaultPopout) {

    /**************************************************************/
    // make sure necessary folder exist
    QDir dir;
    dir.mkpath(ConfigFiles::CONFIG_DIR());
    dir.mkpath(ConfigFiles::GENERIC_DATA_DIR());
    dir.mkpath(ConfigFiles::GENERIC_CACHE_DIR());
    dir.mkpath(QString("%1/thumbnails/large/").arg(ConfigFiles::GENERIC_CACHE_DIR()));

    /**************************************************************/
    // create default imageformats database
    if(!QFile::copy(":/imageformats.db", ConfigFiles::IMAGEFORMATS_DB()))
        LOG << CURDATE << "PQStartup::ImageFormats: unable to create default imageformats database" << NL;
    else {
        QFile file(ConfigFiles::IMAGEFORMATS_DB());
        file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
    }

    /**************************************************************/
    // create default settings database
    if(!QFile::copy(":/settings.db", ConfigFiles::SETTINGS_DB()))
        LOG << CURDATE << "PQStartup::Settings: unable to create settings database" << NL;
    else {
        QFile file(ConfigFiles::SETTINGS_DB());
        file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
    }

    PQSettings::get().update("generalVersion", VERSION);

    // record popout selection
    // default is all integrated (defaultPopout == 0)
    if(defaultPopout == 1) { // some integrated, some individual

        PQSettings::get().update("interfacePopoutScale", true);
        PQSettings::get().update("interfacePopoutOpenFile", true);
        PQSettings::get().update("interfacePopoutSlideShowSettings", true);
        PQSettings::get().update("interfacePopoutSlideShowControls", true);
        PQSettings::get().update("interfacePopoutImgur", true);
        PQSettings::get().update("interfacePopoutWallpaper", true);
        PQSettings::get().update("interfacePopoutSettingsManager", true);

    } else if(defaultPopout == 2) { // all individual

        PQSettings::get().update("interfacePopoutMainMenu", true);
        PQSettings::get().update("interfacePopoutMetadata", true);
        PQSettings::get().update("interfacePopoutHistogram", true);
        PQSettings::get().update("interfacePopoutScale", true);
        PQSettings::get().update("interfacePopoutOpenFile", true);
        PQSettings::get().update("interfacePopoutOpenFileKeepOpen", true);
        PQSettings::get().update("interfacePopoutSlideShowSettings", true);
        PQSettings::get().update("interfacePopoutSlideShowControls", true);
        PQSettings::get().update("interfacePopoutFileRename", true);
        PQSettings::get().update("interfacePopoutFileDelete", true);
        PQSettings::get().update("interfacePopoutAbout", true);
        PQSettings::get().update("interfacePopoutImgur", true);
        PQSettings::get().update("interfacePopoutWallpaper", true);
        PQSettings::get().update("interfacePopoutFilter", true);
        PQSettings::get().update("interfacePopoutSettingsManager", true);
        PQSettings::get().update("interfacePopoutFileSaveAs", true);
        PQSettings::get().update("interfacePopoutUnavailable", true);


    }

    /**************************************************************/
    // create default shortcuts database
    if(!QFile::copy(":/shortcuts.db", ConfigFiles::SHORTCUTS_DB()))
        LOG << CURDATE << "PQStartup::Settings: unable to create shortcuts database" << NL;
    else {
        QFile file(ConfigFiles::SHORTCUTS_DB());
        file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
    }


#ifndef Q_OS_WIN

    /**************************************************************/
    // create default context menu file

    // These are the possible entries
    // There will be a ' %f' added at the end of each executable.
    QStringList m;
    //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
    m << QApplication::translate("startup", "Edit with %1").arg("Gimp") << "gimp"
         //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Edit with %1").arg("Krita") << "krita"
         //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Edit with %1").arg("KolourPaint") << "kolourpaint"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("GwenView") << "gwenview"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("showFoto") << "showfoto"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("Shotwell") << "shotwell"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("GThumb") << "gthumb"
         //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("Eye of Gnome") << "eog";

    QString cont = "";
    // Check for all entries
    for(int i = 0; i < m.size()/2; ++i)
        if(checkIfBinaryExists(m[2*i+1])) {
            cont += QString("0%1").arg(m[2*i+1]);
            cont += " %f\n";
            cont += QString("%1\n\n").arg(m[2*i]);
        }

    QFile file(ConfigFiles::CONTEXTMENU_FILE());
    if(file.open(QIODevice::WriteOnly)) {

        QTextStream out(&file);
        out << cont;
        file.close();

    }
#endif

    /**************************************************************/


}

void PQStartup::performChecksAndMigrations() {

    /**************************************************************/

    // remove version info from imageformats.db
    // the version info is managed through settings.db
    QSqlDatabase db;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "imageformatsinfo");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "imageformatsinfo");
    db.setDatabaseName(ConfigFiles::IMAGEFORMATS_DB());
    if(!db.open())
        LOG << CURDATE << "PQStartup::performChecksAndMigrations(): Error opening imageformats database: " << db.lastError().text().trimmed().toStdString() << NL;
    QSqlQuery query(db);
    if(!query.exec("DROP TABLE IF EXISTS info"))
        LOG << CURDATE << "PQStartup::performChecksAndMigrations(): SQL query error: " << query.lastError().text().trimmed().toStdString() << NL;
    query.next();
    db.close();

    // attempt to enter new format
    if(PQImageFormats::get().enterNewFormat("jxl", "image/jxl", "JPEG XL", "img", 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, "", "jxl", true))

        PQImageFormats::get().readDatabase();

    /**************************************************************/

    // migrate data
    migrateShortcutsToDb();
    migrateSettingsToDb();


}

void PQStartup::exportData(QString path) {

    if(PQHandlingExternal::exportConfigTo(path))

        LOG << CURDATE << "Configuration successfully exported... I will quit now!" << NL;

    else

        LOG << CURDATE << "Configuration was not exported... I will quit now!" << NL;

}

void PQStartup::importData(QString path) {

    if(PQHandlingExternal::importConfigFrom(path))

        LOG << CURDATE << "Configuration successfully imported... I will quit now!" << NL;

    else

        LOG << CURDATE << "Configuration was not imported... I will quit now!" << NL;

}

/**************************************************************/
/**************************************************************/
// the following migration functions are below (in this order):
// * migrateShortcutsToDb()
// * migrateSettingsToDb()

bool PQStartup::migrateShortcutsToDb() {

    QFile file(ConfigFiles::SHORTCUTS_FILE());
    QFile dbfile(ConfigFiles::SHORTCUTS_DB());

    // if the database doesn't exist, we always need to create it
    if(!dbfile.exists()) {
        if(!QFile::copy(":/shortcuts.db", ConfigFiles::SHORTCUTS_DB()))
            LOG << CURDATE << "PQStartup::migrateShortcutsToDb: unable to create shortcuts database" << NL;
        else {
            QFile file(ConfigFiles::SHORTCUTS_DB());
            file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
        }
    }

    // nothing to migrate -> we're done
    if(!file.exists())
        return true;

    QSqlDatabase db;

    // access database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "migrateshortcuts");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "migrateshortcuts");
    else
        return false;

    db.setHostName("migrateshortcuts");
    db.setDatabaseName(ConfigFiles::SHORTCUTS_DB());

    // open database
    if(!db.open()) {
        LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): Failed to open old shortcuts file" << NL;
        return false;
    }

    QTextStream in(&file);
    QString txt = file.readAll();

    // before 2.3, we used an old format
    // for 2.3 and 2.4, the format was already better
    bool oldFormat = false;
    if(txt.contains("Version=") && !txt.contains("Version=dev")) {
        double oldVersion = txt.split("Version=").at(1).split("\n").at(0).toDouble();
        if(oldVersion < 2.3)
            oldFormat = true;
    }

    // old pre-2.3 format
    if(oldFormat) {

        // first we need to collect the shortcuts set for each command
        QMap<QString, QStringList> newShortcuts;

        const QStringList parts = txt.split("\n");
        for(const QString &p : parts) {

            if(!p.contains("::"))
                continue;

            const QStringList entries = p.split("::");
            if(entries.count() > 3 || entries.at(1) == "__")
                continue;

            const QString cmd = QString("%1::%2").arg(entries.at(0), entries.at(2));
            const QString sh = entries.at(1);

            if(newShortcuts.contains(cmd))
                newShortcuts[cmd].append(sh);
            else
                newShortcuts.insert(cmd, QStringList() << sh);

        }

        db.transaction();

        // write shortcuts to database
        QMap<QString, QStringList>::const_iterator iter = newShortcuts.constBegin();
        while(iter != newShortcuts.constEnd()) {

            const QString close = iter.key().split("::").at(0);
            const QString cmd = iter.key().split("::").at(1);
            const QString sh = iter.value().join(", ");

            if(cmd.startsWith("__")) {

                QSqlQuery query(db);
                query.prepare("UPDATE builtin SET shortcuts=:sh WHERE command=:cmd");
                query.bindValue(":sh", sh);
                query.bindValue(":cmd", cmd);
                if(!query.exec())
                    LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): SQL Error [1]: " << query.lastError().text().trimmed().toStdString() << NL;

            } else {

                QSqlQuery query(db);
                query.prepare("INSERT INTO external (command,shortcuts,close) VALUES(:cmd,:sh,:cl)");
                query.bindValue(":sh", sh);
                query.bindValue(":cl", close);
                query.bindValue(":cmd", cmd);
                if(!query.exec())
                    LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): SQL Error [2]: " << query.lastError().text().trimmed().toStdString() << NL;

            }

            ++iter;

        }

        db.commit();
        db.close();

    // format of 2.3 and 2.4
    } else {

        const QStringList parts = txt.split("\n");

        db.transaction();

        for(const auto &line : parts) {

            if(line.startsWith("Version="))
                continue;

            QStringList p = line.split("::");
            if(p.length() < 3)
                continue;

            const QString close = p.at(0);
            const QString cmd = p.at(1);
            const QString sh = p.mid(2).join(", ");

            if(cmd.startsWith("__")) {

                QSqlQuery query(db);
                query.prepare("UPDATE builtin SET shortcuts=:sh WHERE command=:cmd");
                query.bindValue(":sh", sh);
                query.bindValue(":cmd", cmd);
                if(!query.exec())
                    LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): SQL Error [3]: " << query.lastError().text().trimmed().toStdString() << NL;

            } else {

                QSqlQuery query(db);
                query.prepare("INSERT INTO external (command,shortcuts,close) VALUES(:cmd,:sh,:cl)");
                query.bindValue(":sh", sh);
                query.bindValue(":cl", close);
                query.bindValue(":cmd", cmd);
                if(!query.exec())
                    LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): SQL Error [4]: " << query.lastError().text().trimmed().toStdString() << NL;

            }

        }

        db.commit();
        db.close();

    }

    if(!QFile::copy(ConfigFiles::SHORTCUTS_FILE(), QString("%1.pre-v2.5").arg(ConfigFiles::SHORTCUTS_FILE())))
        LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): Failed to copy old shortcuts file to 'shortcuts.pre-v2.5' filename" << NL;
    else {
        if(!QFile::remove(ConfigFiles::SHORTCUTS_FILE()))
            LOG << CURDATE << "PQStartup::migrateShortcutsToDb(): Failed to remove old shortcuts file" << NL;
    }

    return true;

}

bool PQStartup::migrateSettingsToDb() {

    QFile file(ConfigFiles::SETTINGS_FILE());
    QFile dbfile(ConfigFiles::SETTINGS_DB());

    // if the database doesn't exist, we always need to create it
    if(!dbfile.exists()) {
        if(!QFile::copy(":/settings.db", ConfigFiles::SETTINGS_DB()))
            LOG << CURDATE << "PQStartup::Settings: unable to create settings database" << NL;
        else {
            QFile file(ConfigFiles::SETTINGS_DB());
            file.setPermissions(QFile::WriteOwner|QFile::ReadOwner|QFile::ReadGroup|QFile::ReadOther);
        }
    }

    // nothing to migrate -> we're done
    if(!file.exists())
        return true;

    QSqlDatabase db;

    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "migratesettings");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "migratesettings");
    else
        return false;

    db.setHostName("migratesettings");
    db.setDatabaseName(ConfigFiles::SETTINGS_DB());
    if(!db.open()) {
        LOG << CURDATE << "PQStartup::Settings::migrate: Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "PQStartup::Settings::migrate: Failed to open old settings file" << NL;
        return false;
    }
    QTextStream in(&file);
    QString txt = file.readAll();

    // These are settings combined out of multiple old settings
    QString thumbnailsVisibility = "0";
    QString metadataFaceTagsVisibility = "3";

    for(auto line : txt.split("\n")) {

        if(!line.contains("="))
            continue;

        bool dontExecQuery = false;

        QSqlQuery query(db);

        QString key = line.split("=")[0].trimmed();
        QString val = line.split("=")[1].trimmed();

        /******************************************************/

        if(key == "Version") {
            query.prepare("UPDATE `general` SET value=:val WHERE name='Version'");
            val = QString(VERSION);
        } else if(key == "Language")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='Language'");
        else if(key == "WindowMode")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='WindowMode'");
        else if(key == "WindowDecoration")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='WindowDecoration'");
        else if(key == "SaveWindowGeometry")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='SaveWindowGeometry'");
        else if(key == "KeepOnTop")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='KeepWindowOnTop'");
        else if(key == "StartupLoadLastLoadedImage")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='RememberLastImage'");


        /******************************************************/
        // category: Look

        if(key == "BackgroundColorAlpha")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorAlpha'");
        else if(key == "BackgroundColorBlue")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorBlue'");
        else if(key == "BackgroundColorGreen")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorGreen'");
        else if(key == "BackgroundColorRed")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='OverlayColorRed'");
        else if(key == "BackgroundImageCenter")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageCenter'");
        else if(key == "BackgroundImagePath")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImagePath'");
        else if(key == "BackgroundImageScale")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageScale'");
        else if(key == "BackgroundImageScaleCrop")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageScaleCrop'");
        else if(key == "BackgroundImageScreenshot")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageScreenshot'");
        else if(key == "BackgroundImageStretch")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageStretch'");
        else if(key == "BackgroundImageTile")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageTile'");
        else if(key == "BackgroundImageUse")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='BackgroundImageUse'");


        /******************************************************/
        // category: Behaviour

        if(key == "AnimationDuration")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='AnimationDuration'");
        else if(key == "AnimationType")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='AnimationType'");
        else if(key == "ArchiveUseExternalUnrar")
            query.prepare("UPDATE `filetypes` SET value=:val WHERE name='ExternalUnrar'");
        else if(key == "CloseOnEmptyBackground")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='CloseOnEmptyBackground'");
        else if(key == "NavigateOnEmptyBackground")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='NavigateOnEmptyBackground'");

        else if(key == "FitInWindow")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='FitInWindow'");
        else if(key == "HotEdgeWidth")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='HotEdgeSize'");
        else if(key == "InterpolationThreshold")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='InterpolationThreshold'");
        else if(key == "InterpolationDisableForSmallImages")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='InterpolationDisableForSmallImages'");
        else if(key == "KeepZoomRotationMirror")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='RememberZoomRotationMirror'");

        else if(key == "LeftButtonMouseClickAndMove")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='LeftButtonMoveImage'");
        else if(key == "LoopThroughFolder")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='LoopThroughFolder'");
        else if(key == "MarginAroundImage")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='Margin'");
        else if(key == "MouseWheelSensitivity")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='MouseWheelSensitivity'");
        else if(key == "PdfQuality")
            query.prepare("UPDATE `filetypes` SET value=:val WHERE name='PDFQuality'");

        else if(key == "PixmapCache")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='Cache'");
        else if(key == "QuickNavigation")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='QuickNavigation'");
        else if(key == "ShowTransparencyMarkerBackground")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='TransparencyMarker'");
        else if(key == "SortImagesBy")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='SortImagesBy'");
        else if(key == "SortImagesAscending")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='SortImagesAscending'");

        else if(key == "TrayIcon")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='TrayIcon'");
        else if(key == "ZoomSpeed")
            query.prepare("UPDATE `imageview` SET value=:val WHERE name='ZoomSpeed'");


        /******************************************************/
        // category: Labels

        if(key == "LabelsWindowButtonsSize")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsWindowButtonsSize'");
        else if(key == "LabelsHideCounter")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideCounter'");
        else if(key == "LabelsHideFilepath")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideFilepath'");
        else if(key == "LabelsHideFilename")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideFilename'");
        else if(key == "LabelsWindowButtons")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsWindowButtons'");
        else if(key == "LabelsHideZoomLevel")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideZoomLevel'");
        else if(key == "LabelsHideRotationAngle")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsHideRotationAngle'");
        else if(key == "LabelsManageWindow")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='LabelsManageWindow'");


        /******************************************************/
        // category: Exclude

        if(key == "ExcludeCacheFolders") {
            QStringList result;
            QByteArray byteArray = QByteArray::fromBase64(val.toUtf8());
            QDataStream in(&byteArray, QIODevice::ReadOnly);
            in >> result;
            val = result.join(":://::");
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeFolders'");
        } else if(key == "ExcludeCacheDropBox")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeDropBox'");
        else if(key == "ExcludeCacheNextcloud")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeNextcloud'");
        else if(key == "ExcludeCacheOwnCloud")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='ExcludeOwnCloud'");


        /******************************************************/
        // category: Thumbnail

        if(key == "ThumbnailCache")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Cache'");
        else if(key == "ThumbnailCenterActive")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='CenterOnActive'");
        else if(key == "ThumbnailDisable")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Disable'");
        else if(key == "ThumbnailFilenameInstead")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='FilenameOnly'");
        else if(key == "ThumbnailFilenameInsteadFontSize")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='FilenameOnlyFontSize'");

        else if(key == "ThumbnailFontSize")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='FontSize'");
        else if(key == "ThumbnailKeepVisible") {
            dontExecQuery = true;
            if(val == "1")
                thumbnailsVisibility = "1";
        } else if(key == "ThumbnailKeepVisibleWhenNotZoomedIn") {
            dontExecQuery = true;
            if(val == "1")
                thumbnailsVisibility = "2";
        } else if(key == "ThumbnailLiftUp")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='LiftUp'");
        else if(key == "ThumbnailMaxNumberThreads")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='MaxNumberThreads'");

        else if(key == "ThumbnailPosition")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Edge'");
        else if(key == "ThumbnailSize")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Size'");
        else if(key == "ThumbnailSpacingBetween")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Spacing'");
        else if(key == "ThumbnailWriteFilename")
            query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Filename'");


        /******************************************************/
        // category: Slideshow

        if(key == "SlideShowHideLabels")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='HideLabels'");
        else if(key == "SlideShowImageTransition")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='ImageTransition'");
        else if(key == "SlideShowLoop")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='Loop'");
        else if(key == "SlideShowMusicFile")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='MusicFile'");
        else if(key == "SlideShowShuffle")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='Shuffle'");
        else if(key == "SlideShowTime")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='Time'");
        else if(key == "SlideShowTypeAnimation")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='TypeAnimation'");
        else if(key == "SlideShowIncludeSubFolders")
            query.prepare("UPDATE `slideshow` SET value=:val WHERE name='IncludeSubFolders'");


        /******************************************************/
        // category: Metadata

        if(key == "MetaApplyRotation")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='AutoRotation'");
        else if(key == "MetaCopyright")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Copyright'");
        else if(key == "MetaDimensions")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Dimensions'");
        else if(key == "MetaExposureTime")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='ExposureTime'");
        else if(key == "MetaFilename")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Filename'");

        else if(key == "MetaFileType")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FileType'");
        else if(key == "MetaFileSize")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FileSize'");
        else if(key == "MetaFlash")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Flash'");
        else if(key == "MetaFLength")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FLength'");
        else if(key == "MetaFNumber")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FNumber'");

        else if(key == "MetaGps")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Gps'");
        else if(key == "MetaGpsMapService")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='GpsMap'");
        else if(key == "MetaImageNumber")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='ImageNumber'");
        else if(key == "MetaIso")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Iso'");
        else if(key == "MetaKeywords")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Keywords'");

        else if(key == "MetaLightSource")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='LightSource'");
        else if(key == "MetaLocation")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Location'");
        else if(key == "MetaMake")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Make'");
        else if(key == "MetaModel")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Model'");
        else if(key == "MetaSceneType")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='SceneType'");

        else if(key == "MetaSoftware")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Software'");
        else if(key == "MetaTimePhotoTaken")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='Time'");


        /******************************************************/
        // category: Metadata Element

        if(key == "MetadataEnableHotEdge")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='ElementHotEdge'");
        else if(key == "MetadataOpacity")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='ElementOpacity'");
        else if(key == "MetadataWindowWidth")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='ElementWidth'");


        /******************************************************/
        // category: People Tags in Metadata

        if(key == "PeopleTagInMetaBorderAroundFace")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsBorder'");
        else if(key == "PeopleTagInMetaBorderAroundFaceColor")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsBorderColor'");
        else if(key == "PeopleTagInMetaBorderAroundFaceWidth")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsBorderWidth'");
        else if(key == "PeopleTagInMetaDisplay")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsEnabled'");
        else if(key == "PeopleTagInMetaFontSize")
            query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsFontSize'");
        else if(key == "PeopleTagInMetaAlwaysVisible") {
            dontExecQuery = true;
            if(val == "1")
                metadataFaceTagsVisibility = "1";
        } else if(key == "PeopleTagInMetaHybridMode") {
            dontExecQuery = true;
            if(val == "1")
                metadataFaceTagsVisibility = "0";
        } else if(key == "PeopleTagInMetaIndependentLabels") {
            dontExecQuery = true;
            if(val == "1")
                metadataFaceTagsVisibility = "2";
        }


        /******************************************************/
        // category: Open File

        if(key == "OpenDefaultView")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='DefaultView'");
        else if(key == "OpenKeepLastLocation")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='KeepLastLocation'");
        else if(key == "OpenPreview")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='Preview'");
        else if(key == "OpenShowHiddenFilesFolders")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='ShowHiddenFilesFolders'");
        else if(key == "OpenThumbnails")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='Thumbnails'");

        else if(key == "OpenUserPlacesStandard")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesStandard'");
        else if(key == "OpenUserPlacesUser")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesUser'");
        else if(key == "OpenUserPlacesVolumes")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesVolumes'");
        else if(key == "OpenUserPlacesWidth")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='UserPlacesWidth'");
        else if(key == "OpenZoomLevel")
            query.prepare("UPDATE `openfile` SET value=:val WHERE name='ZoomLevel'");


        /******************************************************/
        // category: Histogram

        if(key == "Histogram")
            query.prepare("UPDATE `histogram` SET value=:val WHERE name='Visibility'");
        else if(key == "HistogramPosition")
            query.prepare("UPDATE `histogram` SET value=:val WHERE name='Position'");
        else if(key == "HistogramSize")
            query.prepare("UPDATE `histogram` SET value=:val WHERE name='Size'");
        else if(key == "HistogramVersion")
            query.prepare("UPDATE `histogram` SET value=:val WHERE name='Version'");


        /******************************************************/
        // category: Main Menu Element

        if(key == "MainMenuWindowWidth")
            query.prepare("UPDATE `mainmenu` SET value=:val WHERE name='ElementWidth'");


        /******************************************************/
        // category: Video

        if(key == "VideoAutoplay")
            query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoAutoplay'");
        else if(key == "VideoLoop")
            query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoLoop'");
        else if(key == "VideoVolume")
            query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoVolume'");
        else if(key == "VideoThumbnailer")
            query.prepare("UPDATE `filetypes` SET value=:val WHERE name='VideoThumbnailer'");


        /******************************************************/
        // category:

        if(key == "MainMenuPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutMainMenu'");
        else if(key == "MetadataPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutMetadata'");
        else if(key == "HistogramPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutHistogram'");
        else if(key == "ScalePopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutScale'");
        else if(key == "OpenPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutOpenFile'");

        else if(key == "OpenPopoutElementKeepOpen")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutOpenFileKeepOpen'");
        else if(key == "SlideShowSettingsPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutSlideShowSettings'");
        else if(key == "SlideShowControlsPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutSlideShowControls'");
        else if(key == "FileRenamePopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFileRename'");
        else if(key == "FileDeletePopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFileDelete'");

        else if(key == "AboutPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutAbout'");
        else if(key == "ImgurPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutImgur'");
        else if(key == "WallpaperPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutWallpaper'");
        else if(key == "FilterPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFilter'");
        else if(key == "SettingsManagerPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutSettingsManager'");

        else if(key == "FileSaveAsPopoutElement")
            query.prepare("UPDATE `interface` SET value=:val WHERE name='PopoutFileSaveAs'");

        if(!dontExecQuery) {

            query.bindValue(":val", val);

            if(!query.exec()) {
                LOG << CURDATE << "PQStartup::Settings::migrate: Updating setting failed:  " << key.toStdString() << " / " << val.toStdString() << NL;
                LOG << CURDATE << "PQStartup::Settings::migrate: SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
            }

        }

    }

    // The following multiple old settings combine, thus they can only be updated here

    QSqlQuery query(db);
    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Visibility'");
    query.bindValue(":val", thumbnailsVisibility);
    if(!query.exec()) {
        LOG << CURDATE << "PQStartup::Settings::migrate: Updating setting failed:  thumbnailsVisibility / " << thumbnailsVisibility.toStdString() << NL;
        LOG << CURDATE << "PQStartup::Settings::migrate: SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
    }

    query.clear();
    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsVisibility'");
    query.bindValue(":val", metadataFaceTagsVisibility);
    if(!query.exec()) {
        LOG << CURDATE << "PQStartup::Settings::migrate: Updating setting failed:  metadataFaceTagsVisibility / " << metadataFaceTagsVisibility.toStdString() << NL;
        LOG << CURDATE << "PQStartup::Settings::migrate: SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
    }

    if(!QFile::copy(ConfigFiles::SETTINGS_FILE(), QString("%1.pre-v2.5").arg(ConfigFiles::SETTINGS_FILE())))
        LOG << CURDATE << "PQStartup::Settings::migrate: Failed to copy old settings file to 'settings.pre-v2.5' filename" << NL;
    else {
        if(!QFile::remove(ConfigFiles::SETTINGS_FILE()))
            LOG << CURDATE << "PQStartup::Settings::migrate: Failed to rename old settings file to 'settings.pre-v2.5'" << NL;
    }

    query.clear();
    db.close();

    return true;

}
