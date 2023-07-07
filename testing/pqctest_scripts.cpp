#include <scripts/pqc_scriptsclipboard.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <scripts/pqc_scriptsconfig.h>
#include <scripts/pqc_scriptsfiledialog.h>
#include <scripts/pqc_scriptsfilemanagement.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_configfiles.h>
#include <pqctest_scripts.h>

/********************************************************/
/********************************************************/

void PQCTESTScripts::init() {

    QDir dir;
    dir.mkpath(QDir::tempPath() + "/photoqt_test");

}

void PQCTESTScripts::cleanup() {

    QDir dir;
    dir.setPath(QDir::tempPath()+"/photoqt_test");
    dir.removeRecursively();

}

/********************************************************/
/********************************************************/

void PQCTESTScripts::cleanPath_data() {

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

void PQCTESTScripts::cleanPath() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().cleanPath(string), result);

}

/********************************************************/

void PQCTESTScripts::win_cleanPath_data() {

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

void PQCTESTScripts::win_cleanPath() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().cleanPath_windows(string), result);

}

/********************************************************/

void PQCTESTScripts::getSuffix_data() {

    QTest::addColumn<QString>("string");
    QTest::addColumn<QString>("result");

    QTest::newRow("all lower") << "/home/test/image.jpg" << "jpg";
    QTest::newRow("mixed") << "/home/test/image.jPg" << "jPg";
    QTest::newRow("all upper") << "/home/test/image.JPG" << "JPG";
    QTest::newRow("double suffix") << "/home/test/image.jpg.jpg" << "jpg";
    QTest::newRow("empty") << "" << "";

}

void PQCTESTScripts::getSuffix() {

    QFETCH(QString, string);
    QFETCH(QString, result);

    QCOMPARE(PQCScriptsFilesPaths::get().getSuffix(string), result);

}

/********************************************************/

void PQCTESTScripts::getFoldersIn() {

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
    expected << "folder1"
             << "folder2"
             << "folder3"
             << "folder10"
             << "folder11"
             << "folder12"
             << "folder20"
             << "folder30";

    QCOMPARE(PQCScriptsFilesPaths::get().getFoldersIn(QDir::tempPath() + "/photoqt_test"), expected);
    QCOMPARE(PQCScriptsFilesPaths::get().getFoldersIn(""), QStringList());

}

/********************************************************/
/********************************************************/

void PQCTESTScripts::testClipboard() {

    auto clipboard = qApp->clipboard();

    // first copy test file to temp directory
    QFile file(":/testing/blue.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue.png");

    // then copy the file to the clipboard
    PQCScriptsClipboard::get().copyFilesToClipboard(QStringList() << (QDir::tempPath()+"/photoqt_test/blue.png"));

    // then check that everything worked
    QCOMPARE(PQCScriptsClipboard::get().areFilesInClipboard(), true);
    QCOMPARE(PQCScriptsClipboard::get().getListOfFilesInClipboard(), QStringList() << (QDir::tempPath()+"/photoqt_test/blue.png"));

}

/********************************************************/
/********************************************************/

void PQCTESTScripts::testExportImport() {

    QVERIFY(PQCScriptsConfig::get().exportConfigTo(QDir::tempPath()+"/photoqt_test/export.pqt"));
    QVERIFY(PQCScriptsConfig::get().importConfigFrom(QDir::tempPath()+"/photoqt_test/export.pqt", QDir::tempPath()+"/photoqt_test"));

    QStringList checker;
    checker << "settings.db" << PQCConfigFiles::SETTINGS_DB();
    checker << "contextmenu.db" << PQCConfigFiles::CONTEXTMENU_DB();
    checker << "shortcuts.db" << PQCConfigFiles::SHORTCUTS_DB();
    checker << "imageformats.db" << PQCConfigFiles::IMAGEFORMATS_DB();

    for(int i = 0; i < checker.length()/2; ++i) {

        QFileInfo file(QString("%1/photoqt_test/%2").arg(QDir::tempPath(), checker[2*i]));
        QFileInfo expectedfile(checker[2*i +1]);

        // after unpacking with libraw the size for some reason differs by 1 byte
        QCOMPARE(file.size(), expectedfile.size()+1);

    }

}

/********************************************************/
/********************************************************/

void PQCTESTScripts::testGetSetLastLocation() {

    const QString oldloc = PQCScriptsFileDialog::get().getLastLocation();
    const QString newvalue = QDir::tempPath()+"/photoqt_test/value";

    QDir dir;
    dir.mkdir(newvalue);

    QVERIFY(PQCScriptsFileDialog::get().setLastLocation(newvalue));
    QCOMPARE(newvalue, PQCScriptsFileDialog::get().getLastLocation());
    QVERIFY(PQCScriptsFileDialog::get().setLastLocation(oldloc));

}

void PQCTESTScripts::testGetNumberFilesInFolder() {

    QFile file(":/testing/blue.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue1.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue2.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue3.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue4.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue5.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue6.png");

    QCOMPARE(6, PQCScriptsFileDialog::get()._getNumberOfFilesInFolder(QDir::tempPath()+"/photoqt_test"));

}

/********************************************************/
/********************************************************/

void PQCTESTScripts::testCopyFileToHere() {

    QDir dir;
    dir.mkdir(QDir::tempPath() + "/photoqt_test/newdir");
    QFile file(":/testing/blue.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue.png");

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

void PQCTESTScripts::testDeleteFile() {

    QFile file(":/testing/blue.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue1.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue2.png");

    // normal delete
    QVERIFY(PQCScriptsFileManagement::get().deletePermanent(QDir::tempPath()+"/photoqt_test/blue1.png"));
    QVERIFY(PQCScriptsFileManagement::get().moveFileToTrash(QDir::tempPath()+"/photoqt_test/blue2.png"));

    // delete non-existing
    QVERIFY(!PQCScriptsFileManagement::get().deletePermanent(QDir::tempPath()+"/photoqt_test/blue3.png"));
    QVERIFY(!PQCScriptsFileManagement::get().moveFileToTrash(QDir::tempPath()+"/photoqt_test/blue4.png"));

    QVERIFY(!QFile::exists(QDir::tempPath()+"/photoqt_test/blue1.png"));
    QVERIFY(!QFile::exists(QDir::tempPath()+"/photoqt_test/blue2.png"));

}

/********************************************************/
/********************************************************/

void PQCTESTScripts::testLoadImageAndConvertToBase64() {

    QFile file(":/testing/blue.png");
    file.copy(QDir::tempPath()+"/photoqt_test/blue.png");

    QString base64 = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAABjGlDQ1BHSU1QIGJ1aWx0LWluIHNSR0IAACiRfZE9SMNAGIbfpooiFQeLqDhkaJ0siIo4ahWKUCHUCq06mFz6B00akhQXR8G14ODPYtXBxVlXB1dBEPwBcXRyUnSREr9LCi1iPLi7h/e+9+XuO0Col5lmdYwDmm6bqURczGRXxa5XBDGEAVqjMrOMOUlKwnd83SPA97sYz/Kv+3P0qjmLAQGReJYZpk28QTy9aRuc94nDrCirxOfEYyZdkPiR64rHb5wLLgs8M2ymU/PEYWKx0MZKG7OiqRFPEUdUTad8IeOxynmLs1ausuY9+QtDOX1lmes0R5DAIpYgQYSCKkoow0aMdp0UCyk6j/v4h12/RC6FXCUwciygAg2y6wf/g9+9tfKTE15SKA50vjjORxTo2gUaNcf5PnacxgkQfAau9Ja/UgdmPkmvtbTIEdC3DVxctzRlD7jcAQafDNmUXSlIU8jngfcz+qYs0H8L9Kx5fWue4/QBSFOvkjfAwSEwWqDsdZ93d7f37d+aZv9+AFArcpkrFo+eAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAGFJREFUaIHtzzENACAAwDDACP5VggiOhmRVsM2xz/jZ0gGvGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAa0BrQGtAuKGMBnkDB9JMAAAAASUVORK5CYII=";

    QCOMPARE(base64, PQCScriptsImages::get().loadImageAndConvertToBase64(QDir::tempPath()+"/photoqt_test/blue.png"));
    QCOMPARE("", PQCScriptsImages::get().loadImageAndConvertToBase64(QDir::tempPath()+"/photoqt_test/blue__.png"));

}

void PQCTESTScripts::testListArchiveContent() {

    QFile fileZip(":/testing/testarchive.zip");
    fileZip.copy(QDir::tempPath()+"/photoqt_test/testarchive.zip");

    QStringList expectedZip;
    expectedZip << "black.png::ARC::/tmp/photoqt_test/testarchive.zip";
    expectedZip << "blue.png::ARC::/tmp/photoqt_test/testarchive.zip";
    expectedZip << "green.png::ARC::/tmp/photoqt_test/testarchive.zip";
    expectedZip << "orange.png::ARC::/tmp/photoqt_test/testarchive.zip";

    QCOMPARE(expectedZip, PQCScriptsImages::get().listArchiveContent(QDir::tempPath()+"/photoqt_test/testarchive.zip"));

    QFile fileTarGz(":/testing/testarchive.tar.gz");
    fileTarGz.copy(QDir::tempPath()+"/photoqt_test/testarchive.tar.gz");

    QStringList expectedTarGz;
    expectedTarGz << "black.png::ARC::/tmp/photoqt_test/testarchive.tar.gz";
    expectedTarGz << "blue.png::ARC::/tmp/photoqt_test/testarchive.tar.gz";
    expectedTarGz << "green.png::ARC::/tmp/photoqt_test/testarchive.tar.gz";
    expectedTarGz << "orange.png::ARC::/tmp/photoqt_test/testarchive.tar.gz";

    QCOMPARE(expectedTarGz, PQCScriptsImages::get().listArchiveContent(QDir::tempPath()+"/photoqt_test/testarchive.tar.gz"));

}
