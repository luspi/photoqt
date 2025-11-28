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

#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_configfiles.h>
#include "./pqt_scriptsfilespaths.h"

int main(int argc, char **argv) {

    QApplication::setApplicationName("PhotoQt-testing");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(PQMVERSION);

    QApplication app(argc, argv);

    PQTScriptsFilesPaths tc;
    int ret = QTest::qExec(&tc, argc, argv);

    // we clean them up once everything is done instead of between tests
    // this avoids issues inside the code
    QDir dir(PQCConfigFiles::get().CONFIG_DIR());
    dir.removeRecursively();
    dir.setPath(PQCConfigFiles::get().CACHE_DIR());
    dir.removeRecursively();

    return ret;

}

void PQTScriptsFilesPaths::init() {

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

/********************************************************/

void PQTScriptsFilesPaths::cleanup() {

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

void PQTScriptsFilesPaths::cleanPath_data() {

    QTest::addColumn<QString>("string");
    QTest::addColumn<QString>("result");

    QTest::newRow("file:/") << "file://home/test/image.jpg" << "/home/test/image.jpg";
    QTest::newRow("file://") << "file:///home/test/image.jpg" << "/home/test/image.jpg";
    QTest::newRow("file:///") << "file:////home/test/image.jpg" << "/home/test/image.jpg";
    QTest::newRow("image://full/") << "image://full//home/test/image.jpg" << "/home/test/image.jpg";
    QTest::newRow("image://thumb/") << "image://thumb//home/test/image.jpg" << "/home/test/image.jpg";
    QTest::newRow("/..//test/") << "/home/test2/../test//image.jpg" << "/home/test/image.jpg";
    QTest::newRow("empty") << "" << "";

}

void PQTScriptsFilesPaths::cleanPath() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().cleanPath(string), result);

}

/********************************************************/

void PQTScriptsFilesPaths::win_cleanPath_data() {

    QTest::addColumn<QString>("string");
    QTest::addColumn<QString>("result");

    QTest::newRow("file:/") << "file:/C:/home/test/image.jpg" << "C:/home/test/image.jpg";
    QTest::newRow("file://") << "file://C:/home/test/image.jpg" << "C:/home/test/image.jpg";
    QTest::newRow("file:///") << "file:///C:/home/test/image.jpg" << "C:/home/test/image.jpg";
    QTest::newRow("image://full/") << "image://full/C:/home/test/image.jpg" << "C:/home/test/image.jpg";
    QTest::newRow("image://thumb/") << "image://thumb/C:/home/test/image.jpg" << "C:/home/test/image.jpg";
    QTest::newRow("/..//test/") << "C:/home/test2/../test//image.jpg" << "C:/home/test/image.jpg";
    QTest::newRow("//host/") << "//host/home/test2/../test//image.jpg" << "//host/home/test/image.jpg";
    QTest::newRow("empty") << "" << "";

}

void PQTScriptsFilesPaths::win_cleanPath() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().cleanPath_windows(string), result);

}

/********************************************************/

void PQTScriptsFilesPaths::getSuffix_data() {

    QTest::addColumn<QString>("string");
    QTest::addColumn<QString>("result");

    QTest::newRow("all lower") << "/home/test/image.jpg" << "jpg";
    QTest::newRow("mixed") << "/home/test/image.jPg" << "jPg";
    QTest::newRow("all upper") << "/home/test/image.JPG" << "JPG";
    QTest::newRow("double suffix") << "/home/test/image.jpg.jpg" << "jpg.jpg";
    QTest::newRow("empty") << "" << "";

}

void PQTScriptsFilesPaths::getSuffix() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().getSuffix(string), result);

}

/********************************************************/

void PQTScriptsFilesPaths::getFoldersIn() {

    QDir dir;
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder1");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder2");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder3");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder10");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder11");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder12");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder20");
    dir.mkdir(QDir::tempPath() + "/photoqt_test/folder30");

    QStringList expected;

    #ifdef PQMWITHOUTICU
    expected << "folder1"
    << "folder10"
    << "folder11"
    << "folder12"
    << "folder2"
    << "folder20"
    << "folder3"
    << "folder30";
    #else
    expected << "folder1"
    << "folder2"
    << "folder3"
    << "folder10"
    << "folder11"
    << "folder12"
    << "folder20"
    << "folder30";
    #endif

    QCOMPARE(PQCScriptsFilesPaths::get().getFoldersIn(QDir::tempPath() + "/photoqt_test"), expected);
    QCOMPARE(PQCScriptsFilesPaths::get().getFoldersIn(""), QStringList());

}

/********************************************************/
