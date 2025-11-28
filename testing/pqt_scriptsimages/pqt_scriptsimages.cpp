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

#include <scripts/pqc_scriptsimages.h>
#include <pqc_configfiles.h>
#include <pqc_settings.h>
#include <pqc_settingscpp.h>
#include "./pqt_scriptsimages.h"

int main(int argc, char **argv) {

    QApplication::setApplicationName("PhotoQt-testing");
    QApplication::setOrganizationName("");
    QApplication::setOrganizationDomain("photoqt.org");
    QApplication::setApplicationVersion(PQMVERSION);

    QApplication app(argc, argv);

    PQTScriptsImages tc;
    int ret = QTest::qExec(&tc, argc, argv);

    // we clean them up once everything is done instead of between tests
    // this avoids issues inside the code
    QDir dir(PQCConfigFiles::get().CONFIG_DIR());
    dir.removeRecursively();
    dir.setPath(PQCConfigFiles::get().CACHE_DIR());
    dir.removeRecursively();

    return ret;

}

void PQTScriptsImages::init() {

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

void PQTScriptsImages::cleanup() {

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

// TODO: FIX THESE TESTS

void PQTScriptsImages::testLoadImageAndConvertToBase64() {

    // QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    // QString base64 = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAABjGlDQ1BHSU1QIGJ1aWx0LWluIHNSR0IAACiRfZE9SMNAGIbfpooiFQeLqDhkaJ0siIo4ahWKUCHUCq06mFz6B00akhQXR8G14ODPYtXBxVlXB1dBEPwBcXRyUnSREr9LCi1iPLi7h/e+9+XuO0Col5lmdYwDmm6bqURczGRXxa5XBDGEAVqjMrOMOUlKwnd83SPA97sYz/Kv+3P0qjmLAQGReJYZpk28QTy9aRuc94nDrCirxOfEYyZdkPiR64rHb5wLLgs8M2ymU/PEYWKx0MZKG7OiqRFPEUdUTad8IeOxynmLs1ausuY9+QtDOX1lmes0R5DAIpYgQYSCKkoow0aMdp0UCyk6j/v4h12/RC6FXCUwciygAg2y6wf/g9+9tfKTE15SKA50vjjORxTo2gUaNcf5PnacxgkQfAau9Ja/UgdmPkmvtbTIEdC3DVxctzRlD7jcAQafDNmUXSlIU8jngfcz+qYs0H8L9Kx5fWue4/QBSFOvkjfAwSEwWqDsdZ93d7f37d+aZv9+AFArcpkrFo+eAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAGFJREFUaIHtzzENACAAwDDACP5VggiOhmRVsM2xz/jZ0gGvGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAuKGMBnkDB9JMAAAAASUVORK5CYII=";

    // QCOMPARE(base64, PQCScriptsImages::get().loadImageAndConvertToBase64(QDir::tempPath()+"/photoqt_test/blue.png"));
    // QCOMPARE("", PQCScriptsImages::get().loadImageAndConvertToBase64(QDir::tempPath()+"/photoqt_test/blue__.png"));

}

#ifdef PQMLIBARCHIVE
void PQTScriptsImages::testListArchiveContentZip() {

    // QFile::copy(":/testing/testarchive.zip", QDir::tempPath()+"/photoqt_test/testarchive.zip");

    // QStringList expected;
    // expected << QString("black.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());
    // expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());
    // expected << QString("green.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());
    // expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());

    // if(!PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     std::reverse(expected.begin(), expected.end());

    // QCOMPARE(expected, PQCScriptsImages::get().listArchiveContentWithoutThread(QDir::tempPath()+"/photoqt_test/testarchive.zip"));

}

void PQTScriptsImages::testListArchiveContentTarGz() {

    // QFile::copy(":/testing/testarchive.tar.gz", QDir::tempPath()+"/photoqt_test/testarchive.tar.gz");

    // QStringList expected;
    // expected << QString("black.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());
    // expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());
    // expected << QString("green.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());
    // expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());

    // if(!PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     std::reverse(expected.begin(), expected.end());

    // QCOMPARE(expected, PQCScriptsImages::get().listArchiveContentWithoutThread(QDir::tempPath()+"/photoqt_test/testarchive.tar.gz"));

}

void PQTScriptsImages::testListArchiveContent7z() {

    // QFile::copy(":/testing/testarchive.7z", QDir::tempPath()+"/photoqt_test/testarchive.7z");

    // QStringList expected;
    // expected << QString("black.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());
    // expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());
    // expected << QString("green.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());
    // expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());

    // if(!PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     std::reverse(expected.begin(), expected.end());

    // QCOMPARE(expected, PQCScriptsImages::get().listArchiveContentWithoutThread(QDir::tempPath()+"/photoqt_test/testarchive.7z"));

}

void PQTScriptsImages::testListArchiveContentRar() {

    // QFile::copy(":/testing/testarchive.rar", QDir::tempPath()+"/photoqt_test/testarchive.rar");

    // QStringList expected;
    // expected << QString("black.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());
    // expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());
    // expected << QString("green.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());
    // expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());

    // if(!PQCSettingsCPP::get().getImageviewSortImagesAscending())
    //     std::reverse(expected.begin(), expected.end());

    // QCOMPARE(expected, PQCScriptsImages::get().listArchiveContentWithoutThread(QDir::tempPath()+"/photoqt_test/testarchive.rar"));

}
#endif
