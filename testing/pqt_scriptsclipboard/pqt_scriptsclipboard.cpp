/**************************************************************************
 * *                                                                      **
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

#include <scripts/qml/pqc_scriptsclipboard.h>
#include <pqc_configfiles.h>
#include <pqc_settings.h>
#include "./pqt_scriptsclipboard.h"

int main(int argc, char **argv) {

    QApplication::setApplicationName("PhotoQt-testing");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(PQMVERSION);

    QApplication app(argc, argv);

    PQTScriptsClipboard tc;
    int ret = QTest::qExec(&tc, argc, argv);

    // we clean them up once everything is done instead of between tests
    // this avoids issues inside the code
    QDir dir(PQCConfigFiles::get().CONFIG_DIR());
    dir.removeRecursively();
    dir.setPath(PQCConfigFiles::get().CACHE_DIR());
    dir.removeRecursively();

    return ret;

}

void PQTScriptsClipboard::init() {

    // we just need to instantiate this to populate current settings to PQCSettingsCPP
    PQCSettings set;

    QDir dir;
    dir.mkpath(PQCConfigFiles::get().CONFIG_DIR());
    dir.mkpath(PQCConfigFiles::get().CACHE_DIR());
    dir.mkpath(QDir::tempPath() + "/photoqt_test");

    QFile::copy(":/imageformats.db", PQCConfigFiles::get().IMAGEFORMATS_DB());
    QFile::copy(":/defaultsettings.db", PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    QFile::copy(":/usersettings.db", PQCConfigFiles::get().USERSETTINGS_DB());
    QFile::copy(":/location.db", PQCConfigFiles::get().LOCATION_DB());
    QFile::copy(":/contextmenu.db", PQCConfigFiles::get().CONTEXTMENU_DB());
    QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB());

    QFile file(PQCConfigFiles::get().IMAGEFORMATS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().USERSETTINGS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().LOCATION_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().CONTEXTMENU_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().SHORTCUTS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

}

void PQTScriptsClipboard::cleanup() {

    QFile::remove(PQCConfigFiles::get().IMAGEFORMATS_DB());
    QFile::remove(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    QFile::remove(PQCConfigFiles::get().USERSETTINGS_DB());
    QFile::remove(PQCConfigFiles::get().LOCATION_DB());
    QFile::remove(PQCConfigFiles::get().CONTEXTMENU_DB());
    QFile::remove(PQCConfigFiles::get().SHORTCUTS_DB());

    // this needs to be cleaned up after every test to avoid artefacts from different tests interfering with each other
    QDir dir(QDir::tempPath() + "/photoqt_test");
    dir.removeRecursively();

}

/********************************************************/

void PQTScriptsClipboard::testClipboard() {

    // first copy test file to temp directory
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    PQCScriptsClipboard scr;

    // then copy the file to the clipboard
    scr.copyFilesToClipboard(QStringList() << (QDir::tempPath()+"/photoqt_test/blue.png"));

    // then check that everything worked
    QCOMPARE(scr.areFilesInClipboard(), true);
    QCOMPARE(scr.getListOfFilesInClipboard(), QStringList() << (QDir::tempPath()+"/photoqt_test/blue.png"));

}
