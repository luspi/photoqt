#ifndef PQCTESTSCRIPTSFILESPATHS_H
#define PQCTESTSCRIPTSFILESPATHS_H

#include <QTest>

class PQCTest : public QObject {

    Q_OBJECT

private Q_SLOTS:

    void init();
    void cleanup();

/********************************************************/
/********************************************************/
// scripts

/********************************************************/
    // files and paths

    void cleanPath_data();
    void cleanPath();

    void win_cleanPath_data();
    void win_cleanPath();

    void getSuffix_data();
    void getSuffix();

    void getFoldersIn();

/********************************************************/
    // clipboard
    
    void testClipboard();

/********************************************************/
    // config

    void testExportImport();

/********************************************************/
    // filedialog

    void testGetNumberFilesInFolder();
    void testGetSetLastLocation();

/********************************************************/
    // file management

    void testCopyFileToHere();
    void testDeletePermanentFile();
    void testMoveFileToTrash();

/********************************************************/
    // images

    void testLoadImageAndConvertToBase64();
    void testListArchiveContentZip();
    void testListArchiveContentTarGz();
    void testListArchiveContentRar();
    void testListArchiveContent7z();

/********************************************************/
/********************************************************/
// file/folder model

    void testModelFileDialog();
    void testModelMainView();

};

#endif // PQCTESTSCRIPTSFILESPATHS_H
