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

#include <scripts/pqc_scriptsclipboard.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <scripts/pqc_scriptsconfig.h>
#include <scripts/pqc_scriptsfiledialog.h>
#include <scripts/pqc_scriptsfilemanagement.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_configfiles.h>
#include <pqc_filefoldermodel.h>
#include "pqc_test.h"

/********************************************************/
/********************************************************/

void PQCTest::init() {

    QDir dir;
    dir.mkpath(PQCConfigFiles::get().CONFIG_DIR());
    dir.mkpath(QDir::tempPath() + "/photoqt_test");

    QFile::copy(":/imageformats.db", PQCConfigFiles::get().IMAGEFORMATS_DB());
    QFile::copy(":/settings.db", PQCConfigFiles::get().SETTINGS_DB());
    QFile::copy(":/location.db", PQCConfigFiles::get().LOCATION_DB());
    QFile::copy(":/contextmenu.db", PQCConfigFiles::get().CONTEXTMENU_DB());
    QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB());

    QFile file(PQCConfigFiles::get().IMAGEFORMATS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().SETTINGS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().LOCATION_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().CONTEXTMENU_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

    file.setFileName(PQCConfigFiles::get().SHORTCUTS_DB());
    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);


}

void PQCTest::cleanup() {

    QFile::remove(PQCConfigFiles::get().IMAGEFORMATS_DB());
    QFile::remove(PQCConfigFiles::get().SETTINGS_DB());
    QFile::remove(PQCConfigFiles::get().LOCATION_DB());
    QFile::remove(PQCConfigFiles::get().CONTEXTMENU_DB());
    QFile::remove(PQCConfigFiles::get().SHORTCUTS_DB());

    QDir dir(QDir::tempPath() + "/photoqt_test");
    dir.removeRecursively();

}

/********************************************************/
/********************************************************/

void PQCTest::cleanPath_data() {

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

void PQCTest::cleanPath() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().cleanPath(string), result);

}

/********************************************************/

void PQCTest::win_cleanPath_data() {

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

void PQCTest::win_cleanPath() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().cleanPath_windows(string), result);

}

/********************************************************/

void PQCTest::getSuffix_data() {

    QTest::addColumn<QString>("string");
    QTest::addColumn<QString>("result");

    QTest::newRow("all lower") << "/home/test/image.jpg" << "jpg";
    QTest::newRow("mixed") << "/home/test/image.jPg" << "jPg";
    QTest::newRow("all upper") << "/home/test/image.JPG" << "JPG";
    QTest::newRow("double suffix") << "/home/test/image.jpg.jpg" << "jpg.jpg";
    QTest::newRow("empty") << "" << "";

}

void PQCTest::getSuffix() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().getSuffix(string), result);

}

/********************************************************/

void PQCTest::getFoldersIn() {

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
/********************************************************/

void PQCTest::testClipboard() {

    auto clipboard = qApp->clipboard();

    // first copy test file to temp directory
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    // then copy the file to the clipboard
    PQCScriptsClipboard::get().copyFilesToClipboard(QStringList() << (QDir::tempPath()+"/photoqt_test/blue.png"));

    // then check that everything worked
    QCOMPARE(PQCScriptsClipboard::get().areFilesInClipboard(), true);
    QCOMPARE(PQCScriptsClipboard::get().getListOfFilesInClipboard(), QStringList() << (QDir::tempPath()+"/photoqt_test/blue.png"));

}

/********************************************************/
/********************************************************/

void PQCTest::testExportImport() {

    QVERIFY(PQCScriptsConfig::get().exportConfigTo(QDir::tempPath()+"/photoqt_test/export.pqt"));
    QVERIFY(PQCScriptsConfig::get().importConfigFrom(QDir::tempPath()+"/photoqt_test/export.pqt"));

    QStringList checker;
    checker << ":/settings.db" << PQCConfigFiles::get().SETTINGS_DB();
    checker << ":/contextmenu.db" << PQCConfigFiles::get().CONTEXTMENU_DB();
    checker << ":/shortcuts.db" << PQCConfigFiles::get().SHORTCUTS_DB();
    checker << ":/imageformats.db" << PQCConfigFiles::get().IMAGEFORMATS_DB();

    for(int i = 0; i < checker.length()/2; ++i) {

        QFileInfo expectedfile(checker[2*i]);
        QFileInfo file(checker[2*i +1]);

        // after unpacking with libraw the size for some reason differs by 1 byte
        QCOMPARE(qMax(5, qAbs(file.size()-expectedfile.size())), 5);

    }

}

/********************************************************/
/********************************************************/

void PQCTest::testGetSetLastLocation() {

    const QString oldloc = PQCScriptsFileDialog::get().getLastLocation();
    const QString newvalue = QDir::tempPath()+"/photoqt_test/value";

    QDir dir;
    dir.mkdir(newvalue);

    QVERIFY(PQCScriptsFileDialog::get().setLastLocation(newvalue));
    QCOMPARE(newvalue, PQCScriptsFileDialog::get().getLastLocation());
    QVERIFY(PQCScriptsFileDialog::get().setLastLocation(oldloc));

}

void PQCTest::testGetNumberFilesInFolder() {

    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue1.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue2.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue3.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue4.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue5.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue6.png");

    QCOMPARE(6, PQCScriptsFileDialog::get()._getNumberOfFilesInFolder(QDir::tempPath()+"/photoqt_test"));

}

/********************************************************/
/********************************************************/

void PQCTest::testCopyFileToHere() {

    QDir dir;
    dir.mkdir(QDir::tempPath() + "/photoqt_test/newdir");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    // normal copy
    QVERIFY(PQCScriptsFileManagement::get().copyFileToHere(QDir::tempPath()+"/photoqt_test/blue.png", QDir::tempPath()+"/photoqt_test/newdir"));
    QVERIFY(QFile::exists(QDir::tempPath()+"/photoqt_test/newdir/blue.png"));

    // copy existing
    QVERIFY(!PQCScriptsFileManagement::get().copyFileToHere(QDir::tempPath()+"/photoqt_test/blue.png", QDir::tempPath()+"/photoqt_test/"));

    // copy non-existing source
    QVERIFY(!PQCScriptsFileManagement::get().copyFileToHere(QDir::tempPath()+"/photoqt_test/blue__.png", QDir::tempPath()+"/photoqt_test/"));

    // copy non-existing destination
    QVERIFY(!PQCScriptsFileManagement::get().copyFileToHere(QDir::tempPath()+"/photoqt_test/blue.png", QDir::tempPath()+"/photoqt_test/fdfdfdf"));

}

void PQCTest::testDeletePermanentFile() {

    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    // normal delete
    QVERIFY(PQCScriptsFileManagement::get().deletePermanent(QDir::tempPath()+"/photoqt_test/blue.png"));

    // delete non-existing
    QVERIFY(!PQCScriptsFileManagement::get().deletePermanent(QDir::tempPath()+"/photoqt_test/blue__.png"));

    QVERIFY(!QFile::exists(QDir::tempPath()+"/photoqt_test/blue.png"));

}

void PQCTest::testMoveFileToTrash() {

    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    // normal delete
    QVERIFY(PQCScriptsFileManagement::get().moveFileToTrash(QDir::tempPath()+"/photoqt_test/blue.png"));

    // delete non-existing
    QVERIFY(!PQCScriptsFileManagement::get().moveFileToTrash(QDir::tempPath()+"/photoqt_test/blue__.png"));

    QVERIFY(!QFile::exists(QDir::tempPath()+"/photoqt_test/blue.png"));

}

/********************************************************/
/********************************************************/

void PQCTest::testLoadImageAndConvertToBase64() {

    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue.png");

    QString base64 = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAABjGlDQ1BHSU1QIGJ1aWx0LWluIHNSR0IAACiRfZE9SMNAGIbfpooiFQeLqDhkaJ0siIo4ahWKUCHUCq06mFz6B00akhQXR8G14ODPYtXBxVlXB1dBEPwBcXRyUnSREr9LCi1iPLi7h/e+9+XuO0Col5lmdYwDmm6bqURczGRXxa5XBDGEAVqjMrOMOUlKwnd83SPA97sYz/Kv+3P0qjmLAQGReJYZpk28QTy9aRuc94nDrCirxOfEYyZdkPiR64rHb5wLLgs8M2ymU/PEYWKx0MZKG7OiqRFPEUdUTad8IeOxynmLs1ausuY9+QtDOX1lmes0R5DAIpYgQYSCKkoow0aMdp0UCyk6j/v4h12/RC6FXCUwciygAg2y6wf/g9+9tfKTE15SKA50vjjORxTo2gUaNcf5PnacxgkQfAau9Ja/UgdmPkmvtbTIEdC3DVxctzRlD7jcAQafDNmUXSlIU8jngfcz+qYs0H8L9Kx5fWue4/QBSFOvkjfAwSEwWqDsdZ93d7f37d+aZv9+AFArcpkrFo+eAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAGFJREFUaIHtzzENACAAwDDACP5VggiOhmRVsM2xz/jZ0gGvGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAuKGMBnkDB9JMAAAAASUVORK5CYII=";

    QCOMPARE(base64, PQCScriptsImages::get().loadImageAndConvertToBase64(QDir::tempPath()+"/photoqt_test/blue.png"));
    QCOMPARE("", PQCScriptsImages::get().loadImageAndConvertToBase64(QDir::tempPath()+"/photoqt_test/blue__.png"));

}

#ifdef PQMLIBARCHIVE
void PQCTest::testListArchiveContentZip() {

    QFile::copy(":/testing/testarchive.zip", QDir::tempPath()+"/photoqt_test/testarchive.zip");

    qDebug() << "QDir::tempPath():" << QDir::tempPath();

    QStringList expected;
    expected << QString("black.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());
    expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());
    expected << QString("green.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());
    expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.zip").arg(QDir::tempPath());

    QCOMPARE(expected, PQCScriptsImages::get().listArchiveContent(QDir::tempPath()+"/photoqt_test/testarchive.zip"));

}

void PQCTest::testListArchiveContentTarGz() {

    QFile::copy(":/testing/testarchive.tar.gz", QDir::tempPath()+"/photoqt_test/testarchive.tar.gz");

    QStringList expected;
    expected << QString("black.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());
    expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());
    expected << QString("green.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());
    expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.tar.gz").arg(QDir::tempPath());

    QCOMPARE(expected, PQCScriptsImages::get().listArchiveContent(QDir::tempPath()+"/photoqt_test/testarchive.tar.gz"));

}

void PQCTest::testListArchiveContent7z() {

    QFile::copy(":/testing/testarchive.7z", QDir::tempPath()+"/photoqt_test/testarchive.7z");

    QStringList expected;
    expected << QString("black.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());
    expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());
    expected << QString("green.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());
    expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.7z").arg(QDir::tempPath());

    QCOMPARE(expected, PQCScriptsImages::get().listArchiveContent(QDir::tempPath()+"/photoqt_test/testarchive.7z"));

}

void PQCTest::testListArchiveContentRar() {

    QFile::copy(":/testing/testarchive.rar", QDir::tempPath()+"/photoqt_test/testarchive.rar");

    QStringList expected;
    expected << QString("black.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());
    expected << QString("blue.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());
    expected << QString("green.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());
    expected << QString("orange.png::ARC::%1/photoqt_test/testarchive.rar").arg(QDir::tempPath());

    QCOMPARE(expected, PQCScriptsImages::get().listArchiveContent(QDir::tempPath()+"/photoqt_test/testarchive.rar"));

}
#endif

/********************************************************/
/********************************************************/
/********************************************************/
/********************************************************/

void PQCTest::testModelFileDialog() {

    QDir dir;
    dir.mkpath(QDir::tempPath()+"/photoqt_test/subdir");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue1.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue2.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue3.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue4.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue5");

    PQCFileFolderModel::get().setFolderFileDialog(QDir::tempPath()+"/photoqt_test");

    // there is a small delay before a folder is loaded
    // much less than 200ms
    QTest::qWait(200);

    QCOMPARE(6, PQCFileFolderModel::get().getCountAllFileDialog());
    QCOMPARE(5, PQCFileFolderModel::get().getCountFilesFileDialog());
    QCOMPARE(1, PQCFileFolderModel::get().getCountFoldersFileDialog());

    QStringList expected;
    expected << QDir::tempPath() + "/photoqt_test/subdir";
    expected << QDir::tempPath() + "/photoqt_test/blue1.png";
    expected << QDir::tempPath() + "/photoqt_test/blue2.png";
    expected << QDir::tempPath() + "/photoqt_test/blue3.png";
    expected << QDir::tempPath() + "/photoqt_test/blue4.png";
    expected << QDir::tempPath() + "/photoqt_test/blue5";

    QCOMPARE(expected, PQCFileFolderModel::get().getEntriesFileDialog());

}

void PQCTest::testModelMainView() {

    QDir dir;
    dir.mkpath(QDir::tempPath()+"/photoqt_test/subdir");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue1.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue2.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue3.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue4.png");
    QFile::copy(":/testing/blue.png", QDir::tempPath()+"/photoqt_test/blue5");

    PQCFileFolderModel::get().setFileInFolderMainView(QDir::tempPath()+"/photoqt_test/blue2.png");

    // there is a small delay before a folder is loaded
    // much less than 200ms
    QTest::qWait(200);

    QCOMPARE(5, PQCFileFolderModel::get().getCountMainView());

    QStringList expected;
    expected << QDir::tempPath() + "/photoqt_test/blue1.png";
    expected << QDir::tempPath() + "/photoqt_test/blue2.png";
    expected << QDir::tempPath() + "/photoqt_test/blue3.png";
    expected << QDir::tempPath() + "/photoqt_test/blue4.png";
    expected << QDir::tempPath() + "/photoqt_test/blue5";

    QCOMPARE(expected, PQCFileFolderModel::get().getEntriesMainView());
    QCOMPARE(QDir::tempPath() + "/photoqt_test/blue2.png", PQCFileFolderModel::get().getCurrentFile());
    QCOMPARE(1, PQCFileFolderModel::get().getCurrentIndex());

}

