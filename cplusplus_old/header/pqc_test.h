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
#pragma once

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
#ifdef PQMLIBARCHIVE
    void testListArchiveContentZip();
    void testListArchiveContentTarGz();
    void testListArchiveContentRar();
    void testListArchiveContent7z();
#endif

/********************************************************/
/********************************************************/
// file/folder model

    void testModelFileDialog();
    void testModelMainView();

};
