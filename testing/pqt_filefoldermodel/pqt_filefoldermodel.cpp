/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_filefoldermodel.h>
#include <pqc_configfiles.h>
#include <pqc_settings.h>
#include <pqc_settingscpp.h>
#include "./pqt_filefoldermodel.h"

int main(int argc, char **argv) {

    QApplication::setApplicationName("PhotoQt-testing");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(PQMVERSION);

    QApplication app(argc, argv);

    PQTFileFolderModel tc;
    int ret = QTest::qExec(&tc, argc, argv);

    // we clean them up once everything is done instead of between tests
    // this avoids issues inside the code
    QDir dir(PQCConfigFiles::get().CONFIG_DIR());
    dir.removeRecursively();
    dir.setPath(PQCConfigFiles::get().CACHE_DIR());
    dir.removeRecursively();

    return ret;

}

void PQTFileFolderModel::init() {

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

void PQTFileFolderModel::cleanup() {

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
void PQTFileFolderModel::testModelFileDialog() {

    // QDir dir;
    // dir.mkpath(QDir::tempPath()+"/photoqt_test/subdir");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue1.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue2.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue3.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue4.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue5");

    // PQCFileFolderModel ffm;
    // ffm.setFolderFileDialog(QDir::tempPath()+"/photoqt_test");

    // // there is a small delay before a folder is loaded
    // // much less than 200ms
    // QTest::qWait(200);

    // QCOMPARE(6, ffm.getCountAllFileDialog());
    // QCOMPARE(5, ffm.getCountFilesFileDialog());
    // QCOMPARE(1, ffm.getCountFoldersFileDialog());

    // QStringList expected;
    // expected << QDir::tempPath() + "/photoqt_test/blue1.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue2.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue3.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue4.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue5";

    // if(!PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     std::reverse(expected.begin(), expected.end());

    // expected.push_front(QDir::tempPath() + "/photoqt_test/subdir");

    // QCOMPARE(expected, ffm.getEntriesFileDialog());

}

void PQTFileFolderModel::testModelMainView() {

    // QDir dir;
    // dir.mkpath(QDir::tempPath()+"/photoqt_test/subdir");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue1.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue2.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue3.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue4.png");
    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue5");

    // PQCFileFolderModel ffm;
    // ffm.setFileInFolderMainView(QDir::tempPath()+"/photoqt_test/blue2.png");

    // // there is a small delay before a folder is loaded
    // // much less than 200ms
    // QTest::qWait(200);

    // QCOMPARE(5, ffm.getCountMainView());

    // QStringList expected;
    // expected << QDir::tempPath() + "/photoqt_test/blue1.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue2.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue3.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue4.png";
    // expected << QDir::tempPath() + "/photoqt_test/blue5";

    // if(!PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     std::reverse(expected.begin(), expected.end());

    // QCOMPARE(expected, ffm.getEntriesMainView());
    // QCOMPARE(QDir::tempPath() + "/photoqt_test/blue2.png", ffm.getCurrentFile());

    // if(PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     QCOMPARE(1, ffm.getCurrentIndex());
    // else
    //     QCOMPARE(3, ffm.getCurrentIndex());

}
