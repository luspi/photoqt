/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include <QTimer>
#include <QMimeDatabase>
#include <QSize>
#include <QFileSystemWatcher>
#include <QtDebug>
#include <QFileInfo>
#include <QDir>
#include <QCollator>
#include <QtConcurrent>
#include <pqc_filefoldermodel.h>
#include <pqc_imageformats.h>
#include <pqc_settings.h>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptsfiledialog.h>

#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

#ifdef QTPDF
#include <QtPdf/QPdfDocument>
#endif

#ifdef POPPLER
#include <poppler/qt6/poppler-qt6.h>
#endif

PQCFileFolderModel &PQCFileFolderModel::get() {
    static PQCFileFolderModel instance;
    return instance;
}

PQCFileFolderModel::PQCFileFolderModel(QObject *parent) : QObject(parent) {

    m_fileInFolderMainView = "";
    m_folderFileDialog = "";
    m_countMainView = 0;
    m_countFoldersFileDialog = 0;
    m_countFilesFileDialog = 0;

    m_readDocumentOnly = false;
    m_readArchiveOnly = false;
    m_includeFilesInSubFolders = false;

    m_entriesMainView.clear();
    m_entriesFileDialog.clear();

    m_nameFilters = QStringList();
    m_restrictToSuffixes = PQCImageFormats::get().getEnabledFormats();
    m_filenameFilters = QStringList();
    m_restrictToMimeTypes = PQCImageFormats::get().getEnabledMimeTypes();
    m_imageResolutionFilter = QSize(0,0);
    m_fileSizeFilter = 0;

    watcherMainView = new QFileSystemWatcher;
    watcherFileDialog = new QFileSystemWatcher;

    connect(watcherMainView, &QFileSystemWatcher::directoryChanged, this, &PQCFileFolderModel::loadDataMainView);
    connect(watcherFileDialog, &QFileSystemWatcher::directoryChanged, this, &PQCFileFolderModel::loadDataFileDialog);

    loadDelayMainView = new QTimer;
    loadDelayMainView->setInterval(10);
    loadDelayMainView->setSingleShot(true);
    connect(loadDelayMainView, &QTimer::timeout, this, &PQCFileFolderModel::loadDataMainView);

    loadDelayFileDialog = new QTimer;
    loadDelayFileDialog->setInterval(10);
    loadDelayFileDialog->setSingleShot(true);
    connect(loadDelayFileDialog, &QTimer::timeout, this, &PQCFileFolderModel::loadDataFileDialog);

    m_advancedSortDone = 0;

    connect(this, &PQCFileFolderModel::newDataLoadedMainView, this, &PQCFileFolderModel::handleNewDataLoadedMainView);

}

PQCFileFolderModel::~PQCFileFolderModel() {

    delete loadDelayMainView;
    delete loadDelayFileDialog;

    delete watcherMainView;
    delete watcherFileDialog;

}

/********************************************/
/********************************************/

QString PQCFileFolderModel::getFileInFolderMainView() {
    return m_fileInFolderMainView;
}
void PQCFileFolderModel::setFileInFolderMainView(QString val) {
    if(m_fileInFolderMainView == val)
        return;
    m_fileInFolderMainView = val;
    Q_EMIT fileInFolderMainViewChanged();
    loadDelayMainView->start();
}

QString PQCFileFolderModel::getFolderFileDialog() {
    return m_folderFileDialog;
}
void PQCFileFolderModel::setFolderFileDialog(QString val) {
    if(m_folderFileDialog == val)
        return;
    m_folderFileDialog = val;
    Q_EMIT folderFileDialogChanged();
    loadDelayFileDialog->start();

    if(val != "")
        PQCScriptsFileDialog::get().setLastLocation(val);

}

/********************************************/
/********************************************/

int PQCFileFolderModel::getCountMainView() {
    return m_countMainView;
}
void PQCFileFolderModel::setCountMainView(int c) {
    if(m_countMainView == c)
        return;
    m_countMainView = c;
    Q_EMIT countMainViewChanged();
}

int PQCFileFolderModel::getCountFoldersFileDialog() {
    return m_countFoldersFileDialog;
}
void PQCFileFolderModel::setCountFoldersFileDialog(int c) {
    if(m_countFoldersFileDialog == c)
        return;
    m_countFoldersFileDialog = c;
    m_countAllFileDialog = m_countFilesFileDialog+c;
    Q_EMIT countFoldersFileDialogChanged();
    Q_EMIT countAllFileDialogChanged();
}

int PQCFileFolderModel::getCountFilesFileDialog() {
    return m_countFilesFileDialog;
}
void PQCFileFolderModel::setCountFilesFileDialog(int c) {
    if(m_countFilesFileDialog == c)
        return;
    m_countFilesFileDialog = c;
    m_countAllFileDialog = m_countFoldersFileDialog+c;
    Q_EMIT countFilesFileDialogChanged();
    Q_EMIT countAllFileDialogChanged();
}

int PQCFileFolderModel::getCountAllFileDialog() {
    return m_countAllFileDialog;
}

/********************************************/
/********************************************/

QStringList PQCFileFolderModel::getEntriesFileDialog() {
    return m_entriesFileDialog;
}

QStringList PQCFileFolderModel::getEntriesMainView() {
    return m_entriesMainView;
}

int PQCFileFolderModel::getIncludeFilesInSubFolders() {
    return m_includeFilesInSubFolders;
}
void PQCFileFolderModel::setIncludeFilesInSubFolders(int c) {
    if(m_includeFilesInSubFolders == c)
        return;
    m_includeFilesInSubFolders = c;
    Q_EMIT includeFilesInSubFoldersChanged();
    loadDelayMainView->start();
}

/********************************************/
/********************************************/

QStringList PQCFileFolderModel::getRestrictToSuffixes() {
    return m_restrictToSuffixes;
}
void PQCFileFolderModel::setRestrictToSuffixes(QStringList val) {
    if(m_restrictToSuffixes == val)
        return;
    m_restrictToSuffixes = val;
    Q_EMIT restrictToSuffixesChanged();
    loadDelayMainView->start();
    loadDelayFileDialog->start();
}

QStringList PQCFileFolderModel::getNameFilters() {
    return m_nameFilters;
}
void PQCFileFolderModel::setNameFilters(QStringList val) {
    if(m_nameFilters == val)
        return;
    m_nameFilters = val;
    Q_EMIT nameFiltersChanged();
    loadDelayMainView->start();
    loadDelayFileDialog->start();
    checkFilterActive();
}

QStringList PQCFileFolderModel::getFilenameFilters() {
    return m_filenameFilters;
}
void PQCFileFolderModel::setFilenameFilters(QStringList val) {
    if(m_filenameFilters == val)
        return;
    m_filenameFilters = val;
    Q_EMIT filenameFiltersChanged();
    loadDelayMainView->start();
    loadDelayFileDialog->start();
    checkFilterActive();
}

QStringList PQCFileFolderModel::getRestrictToMimeTypes() {
    return m_restrictToMimeTypes;
}
void PQCFileFolderModel::setRestrictToMimeTypes(QStringList val) {
    if(m_restrictToMimeTypes == val)
        return;
    m_restrictToMimeTypes = val;
    Q_EMIT restrictToMimeTypesChanged();
    loadDelayMainView->start();
    loadDelayFileDialog->start();
}

QSize PQCFileFolderModel::getImageResolutionFilter() {
    return m_imageResolutionFilter;
}
void PQCFileFolderModel::setImageResolutionFilter(QSize val) {
    if(m_imageResolutionFilter == val)
        return;
    m_imageResolutionFilter = val;
    Q_EMIT imageResolutionFilterChanged();
    loadDelayMainView->start();
    loadDelayFileDialog->start();
    checkFilterActive();
}

qint64 PQCFileFolderModel::getFileSizeFilter() {
    return m_fileSizeFilter;
}
void PQCFileFolderModel::setFileSizeFilter(qint64 val) {
    if(m_fileSizeFilter == val)
        return;
    m_fileSizeFilter = val;
    Q_EMIT fileSizeFilterChanged();
    loadDelayMainView->start();
    loadDelayFileDialog->start();
    checkFilterActive();
}

bool PQCFileFolderModel::getFilterCurrentlyActive() {
    return m_filterCurrentlyActive;
}

void PQCFileFolderModel::checkFilterActive() {

    if(m_nameFilters.length() > 0 || m_filenameFilters.length() > 0 ||
        m_imageResolutionFilter.width() > 0 || m_imageResolutionFilter.height() > 0 ||
        m_fileSizeFilter > 0) {

        if(!m_filterCurrentlyActive) {
            m_filterCurrentlyActive = true;
            filterCurrentlyActiveChanged();
        }

    } else {

        if(m_filterCurrentlyActive) {
            m_filterCurrentlyActive = false;
            filterCurrentlyActiveChanged();
        }

    }

}

/********************************************/
/********************************************/

int PQCFileFolderModel::getAdvancedSortDone() {
    return m_advancedSortDone;
}

/********************************************/

void PQCFileFolderModel::advancedSortMainView() {

    // if nothing changed, reload folder
    QFileInfo info(m_fileInFolderMainView);
    if(info.absolutePath() == cacheAdvancedSortFolderName
        && PQCSettings::get()["imageviewAdvancedSortCriteria"].toString() == cacheAdvancedSortCriteria
        && info.lastModified().toMSecsSinceEpoch() == cacheAdvancedSortLastModified
        && PQCSettings::get()["imageviewAdvancedSortAscending"].toBool() == cacheAdvancedSortAscending) {

        m_entriesMainView = cacheAdvancedSortFolder;
        Q_EMIT newDataLoadedMainView();
        Q_EMIT advancedSortingComplete();
        return;

    }

    advancedSortKeepGoing = true;
    m_advancedSortDone = 0;
    Q_EMIT advancedSortDoneChanged();

    QtConcurrent::run([=]() {

//        PQImageProviderFull *imageprovider = new PQImageProviderFull;
//        PQLoadImage loader;

        QMap<qint64, QStringList> sortedWithKey;

        for(int i = 0; i < m_countMainView; ++i) {

//            if(!advancedSortKeepGoing) {
//                delete imageprovider;
//                return;
//            }

            // the key used for sorting
            // depending on the criteria, it is computed in different ways
            qint64 key = 0;

            if(PQCSettings::get()["imageviewAdvancedSortCriteria"].toString() == "resolution") {

//                QSize size = PQResolutionProvider::get().getResolution(m_entriesMainView[i]);
//                if(!size.isValid()) {
//                    size = loader.loadSize(m_entriesMainView[i]);
//                    if(size.isValid())
//                        PQResolutionProvider::get().saveResolution(m_entriesMainView[i], size);
//                }

//                key = size.width()+size.height();

            } else if(PQCSettings::get()["imageviewAdvancedSortCriteria"].toString() == "luminosity") {

//                QSize requestedSize = QSize(512,512);
//                if(PQSettings::get()["imageviewAdvancedSortQuality"].toString() == "medium")
//                    requestedSize = QSize(1024,1024);
//                else if(PQSettings::get()["imageviewAdvancedSortQuality"].toString() == "high")
//                    requestedSize = QSize(-1,-1);

//                QSize origSize;
//                QImage img = imageprovider->requestImage(QUrl::toPercentEncoding(m_entriesMainView[i], "", " "), &origSize, requestedSize);
//                PQResolutionProvider::get().saveResolution(m_entriesMainView[i], origSize);

//                QRgb *rgb = reinterpret_cast<QRgb*>(img.bits());

//                quint64 pixelCount = img.width() * img.height();

//                double val = 0;
//                for(int i = 0; i < img.height(); ++i) {
//                    qint64 tmpval = 0;
//                    for(int j = 0; j < img.width(); ++j) {
//                        int h,s,v;
//                        QColor col(rgb[i*img.width()+j]);
//                        col.getHsv(&h,&s,&v);
//                        tmpval += v;
//                    }
//                    val += static_cast<double>(tmpval)/static_cast<double>(pixelCount);

//                    if(!advancedSortKeepGoing) {
//                        delete imageprovider;
//                        return;
//                    }
//                }

//                key = val;

            } else if(PQCSettings::get()["imageviewAdvancedSortCriteria"].toString() == "exifdate") {

                QVariantList order = PQCSettings::get()["imageviewAdvancedSortExifDateCriteria"].toList();

                bool foundvalue = false;

                for(int j = 0; j < order.length()/2; ++j) {

                    QString item = order.at(2*j).toString();
                    int use = order.at(2*j+1).toInt();

                    if(use == 0)
                        continue;

                    if(item == "exiforiginal" || item == "exifdigital") {

#ifdef EXIV2
#if EXIV2_TEST_VERSION(0, 28, 0)
                        Exiv2::Image::UniquePtr image;
#else
                        Exiv2::Image::AutoPtr image;
#endif
                        try {
                            image  = Exiv2::ImageFactory::open(m_entriesMainView[i].toStdString());
                            image->readMetadata();
                        } catch (Exiv2::Error& e) {
                            // An error code of 11 means unknown file type
                            // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
                            if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
                            if(e.code() != 11)
#endif
                                LOG << CURDATE << "PQMetaData::updateMetadaya(): ERROR reading exiv data (caught exception): " << e.what() << NL;
                            else
                                DBG << CURDATE << "PQMetaData::updateMetadaya(): ERROR reading exiv data (caught exception): " << e.what() << NL;
                            continue;
                        }


                        /*******************
                        * Obtain EXIF data *
                        ********************/

                        Exiv2::ExifData exifData;

                        try {
                            exifData = image->exifData();
                        } catch(Exiv2::Error &e) {
                            LOG << CURDATE << "PQMetaData::updateMetaData(): ERROR: Unable to read exif metadata: " << e.what() << NL;
                            continue;
                        }


                        try {

                            Exiv2::ExifMetadata::const_iterator iter;

                            if(item == "exiforiginal")
                                iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.DateTimeOriginal"));
                            else if(item == "exifdigital")
                                iter = exifData.findKey(Exiv2::ExifKey("Exif.Photo.DateTimeDigitized"));

                            if(iter != exifData.end()) {
                                key = QDateTime::fromString(QString::fromStdString(Exiv2::toString(iter->value()))).toMSecsSinceEpoch();//, "yyyy:MM:dd hhmm:ss");
                                foundvalue = true;
                            }

                        } catch(Exiv2::Error &) {
                            // ignore exception -> most likely thrown as key does not exist
                            continue;
                        }

#endif

                    } else if(item == "filecreation") {

#if QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
                        QFileInfo info(m_entriesMainView[i]);
                        QDateTime bd = info.birthTime();
                        if(bd.isValid()) {
                            key = info.birthTime().toMSecsSinceEpoch();
                            foundvalue = true;
                        }
#endif

                    } else if(item == "filemodification") {

                        QFileInfo info(m_entriesMainView[i]);
                        key = info.lastModified().toMSecsSinceEpoch();
                        foundvalue = true;

                    } else {

                        qWarning() << "ERROR unknown item:" << item;
                        key = i;

                    }

                    if(foundvalue)
                        break;

                }

                // if no usable value was found, then we simply list them in order
                if(!foundvalue)
                    key = i;

            } else {

                QSize requestedSize = QSize(512,512);
                if(PQCSettings::get()["imageviewAdvancedSortQuality"].toString() == "medium")
                    requestedSize = QSize(1024,1024);
                else if(PQCSettings::get()["imageviewAdvancedSortQuality"].toString() == "high")
                    requestedSize = QSize(-1,-1);

                QSize origSize;
//                QImage img = imageprovider->requestImage(QUrl::toPercentEncoding(m_entriesMainView[i], "", " "), &origSize, requestedSize);
//                if(img.format() != QImage::Format_RGB32)
//                    img.convertTo(QImage::Format_RGB32);

                // Prepare the lists for the levels
                QVector<qint64> red(256);
                QVector<qint64> green(256);
                QVector<qint64> blue(256);

                // Loop over all rows of the image
//                for(int i = 0; i < img.height(); ++i) {

//                    // Get the pixel data of row i of the image
//                    QRgb *rowData = (QRgb*)img.scanLine(i);

//                    // Loop over all columns
//                    for(int j = 0; j < img.width(); ++j) {

//                        // Get pixel data of pixel at column j in row i
//                        QRgb pixelData = rowData[j];

//                        ++red[qRed(pixelData)];
//                        ++green[qGreen(pixelData)];
//                        ++blue[qBlue(pixelData)];

//                    }

//                }

                if(!advancedSortKeepGoing) {
                    //                    delete imageprovider;
                    return;
                }

                qint64 red_val = 0;
                qint64 green_val = 0;
                qint64 blue_val = 0;

                if(PQCSettings::get()["imageviewAdvancedSortCriteria"].toString() == "dominantcolor") {

                    QVector<qint64> redSteps(26);
                    QVector<qint64> greenSteps(26);
                    QVector<qint64> blueSteps(26);
                    for(int j = 0; j < 256; ++j) {
                        redSteps[j/10] += red[j];
                        greenSteps[j/10] += green[j];
                        blueSteps[j/10] += blue[j];
                    }

                    red_val = 10*redSteps.indexOf(*std::max_element(redSteps.constBegin(), redSteps.constEnd()));
                    green_val = 10*greenSteps.indexOf(*std::max_element(greenSteps.constBegin(), greenSteps.constEnd()));
                    blue_val = 10*blueSteps.indexOf(*std::max_element(blueSteps.constBegin(), blueSteps.constEnd()));

                } else {

                    // we divide before accumulating to minimize the risk of overflow
                    for(int j = 0; j < red.size(); ++j) red[j] /= static_cast<double>(red.size());
                    for(int j = 0; j < green.size(); ++j) green[j] /= static_cast<double>(green.size());
                    for(int j = 0; j < blue.size(); ++j) blue[j] /= static_cast<double>(blue.size());

                    red_val = red.indexOf(std::accumulate(red.begin(), red.end(), 0));
                    green_val = green.indexOf(std::accumulate(green.begin(), green.end(), 0));
                    blue_val = blue.indexOf(std::accumulate(blue.begin(), blue.end(), 0));

                }

                key = red_val*1000000 + green_val*1000 + blue_val;

            }

            sortedWithKey[key].push_back(m_entriesMainView[i]);

            ++m_advancedSortDone;
            Q_EMIT advancedSortDoneChanged();

        }

//        delete imageprovider;

        if(!advancedSortKeepGoing) return;

        QList<qint64> allKeys = sortedWithKey.keys();
        if(PQCSettings::get()["imageviewAdvancedSortAscending"].toBool())
            std::sort(allKeys.begin(), allKeys.end(), std::less<int>());
        else
            std::sort(allKeys.begin(), allKeys.end(), std::greater<int>());

        cacheAdvancedSortFolder.clear();
        for(auto entry : qAsConst(allKeys)) {
            QStringList curVals = sortedWithKey[entry];
            curVals.sort(Qt::CaseInsensitive);
            if(!PQCSettings::get()["imageviewAdvancedSortAscending"].toBool())
                std::reverse(curVals.begin(), curVals.end());
            for(const auto &e : qAsConst(curVals))
                cacheAdvancedSortFolder << e;
        }

        m_entriesMainView = cacheAdvancedSortFolder;
        Q_EMIT newDataLoadedMainView();
        Q_EMIT countMainViewChanged();
        Q_EMIT advancedSortingComplete();

        QFileInfo info(m_fileInFolderMainView);
        cacheAdvancedSortFolderName = info.absolutePath();
        cacheAdvancedSortLastModified = info.lastModified().toMSecsSinceEpoch();
        cacheAdvancedSortCriteria = PQCSettings::get()["imageviewAdvancedSortCriteria"].toString();
        cacheAdvancedSortAscending = PQCSettings::get()["imageviewAdvancedSortAscending"].toBool();

    });

}

void PQCFileFolderModel::advancedSortMainViewCANCEL() {
    advancedSortKeepGoing = false;
}

void PQCFileFolderModel::forceReloadMainView() {
    loadDelayMainView->stop();
    loadDataMainView();
}

void PQCFileFolderModel::forceReloadFileDialog() {
    loadDelayFileDialog->stop();
    loadDataFileDialog();
}

int PQCFileFolderModel::getIndexOfMainView(QString filepath) {
    for(int i = 0; i < m_entriesMainView.length(); ++i) {
        if(m_entriesMainView[i] == filepath)
            return i;
    }
    return -1;
}

void PQCFileFolderModel::removeEntryMainView(int index) {

    qDebug() << "args: index =" << index;

    QFileInfo info(m_fileInFolderMainView);
    if(info.absolutePath() == cacheAdvancedSortFolderName) {
        QString oldentry = m_entriesMainView[index];
        cacheAdvancedSortFolder.removeOne(oldentry);
    }

    loadDelayFileDialog->start();
    m_entriesMainView.removeAt(index);
    setCountMainView(m_countMainView-1);

    Q_EMIT newDataLoadedMainView();
    Q_EMIT newDataLoadedFileDialog();

}

void PQCFileFolderModel::resetModel() {

    delete watcherFileDialog;
    watcherFileDialog = new QFileSystemWatcher;
    delete watcherMainView;
    watcherMainView = new QFileSystemWatcher;
    setCountMainView(0);
    m_entriesMainView.clear();

    cache.resetData();

    setCurrentIndex(-1);
    setSetFileNameOnceReloaded("");

}

bool PQCFileFolderModel::setAsCurrent(QString filepath) {
    int ind = getIndexOfMainView(filepath);
    if(ind != -1) {
        setCurrentIndex(ind);
        return true;
    }
    return false;
}

/********************************************/
/********************************************/


int PQCFileFolderModel::getCurrentIndex() {
    return m_currentIndex;
}

void PQCFileFolderModel::setCurrentIndex(int val) {
    if(m_currentIndex == val)
        return;
    m_currentIndex = val;
    if(m_currentIndex == -1)
        m_currentFile = "";
    else
        m_currentFile = m_entriesMainView[m_currentIndex];

    Q_EMIT currentIndexChanged();
    Q_EMIT currentFileChanged();

    if(m_currentFile.indexOf("::PDF::")) {
        bool ispdf = m_currentFile.indexOf("::PDF::")>-1;
        if(m_isPDF != ispdf) {
            m_isPDF = ispdf;
            m_pdfName = m_currentFile.split("::PDF::")[1];
            m_pdfNum = m_currentFile.split("::PDF::")[0].toInt();
            Q_EMIT isPDFChanged();
            Q_EMIT pdfNameChanged();
            Q_EMIT pdfNumChanged();
        }
    }

    if(m_currentFile.indexOf("::ARC::")) {
        bool isarc = m_currentFile.indexOf("::ARC::")>-1;
        if(m_isARC != isarc) {
            m_isARC = isarc;
            m_arcName = m_currentFile.split("::ARC::")[1];
            m_arcFile = m_currentFile.split("::ARC::")[0];
            Q_EMIT isARCChanged();
            Q_EMIT arcNameChanged();
            Q_EMIT arcFileChanged();
        }
    }
}

QString PQCFileFolderModel::getCurrentFile() {
    return m_currentFile;
}

void PQCFileFolderModel::setSetFileNameOnceReloaded(QString val) {
    if(m_setFileNameOnceReloaded != val) {
        m_setFileNameOnceReloaded = val;
        Q_EMIT setFileNameOnceReloadedChanged();
    }
}

QString PQCFileFolderModel::getSetFileNameOnceReloaded() {
    return m_setFileNameOnceReloaded;
}

bool PQCFileFolderModel::getIsPDF() {
    return m_isPDF;
}

bool PQCFileFolderModel::getIsARC() {
    return m_isARC;
}

QString PQCFileFolderModel::getPdfName() {
    return m_pdfName;
}

int PQCFileFolderModel::getPdfNum() {
    return m_pdfNum;
}

QString PQCFileFolderModel::getArcName() {
    return m_arcName;
}

QString PQCFileFolderModel::getArcFile() {
    return m_arcFile;
}


/********************************************/
/********************************************/

void PQCFileFolderModel::loadDataMainView() {

    qDebug() << "";

    ////////////////////////
    // clear old entries

    m_entriesMainView.clear();
    m_countMainView = 0;
    delete watcherMainView;
    watcherMainView = new QFileSystemWatcher;

    ////////////////////////
    // no new directory

    if(m_fileInFolderMainView.isEmpty()) {
        Q_EMIT newDataLoadedMainView();
        Q_EMIT countMainViewChanged();
        return;
    }

    ////////////////////////
    // watch directory for changes

    watcherMainView->addPath(QFileInfo(m_fileInFolderMainView).absolutePath());
    connect(watcherMainView, &QFileSystemWatcher::directoryChanged, this, &PQCFileFolderModel::loadDataMainView);

    ////////////////////////
    // load files

    if(m_fileInFolderMainView.contains("::PDF::")) {
        m_readDocumentOnly = true;
        m_fileInFolderMainView = m_fileInFolderMainView.split("::PDF::").at(1);
    } else if(m_fileInFolderMainView.contains("::ARC::")) {
        m_readArchiveOnly = true;
        m_fileInFolderMainView = m_fileInFolderMainView.split("::ARC::").at(1);
    }

    if(m_readDocumentOnly && PQCImageFormats::get().getEnabledFormatsPoppler().contains(QFileInfo(m_fileInFolderMainView).suffix().toLower())) {

        m_entriesMainView = listPDFPages(m_fileInFolderMainView);
        m_countMainView = m_entriesMainView.length();
        m_readDocumentOnly = false;

    } else if(m_readArchiveOnly && PQCImageFormats::get().getEnabledFormatsLibArchive().contains(QFileInfo(m_fileInFolderMainView).suffix().toLower())) {

        m_entriesMainView = PQCScriptsImages::get().listArchiveContent(m_fileInFolderMainView);
        m_countMainView = m_entriesMainView.length();
        m_readArchiveOnly = false;

    } else {

        m_entriesMainView = getAllFiles(QFileInfo(m_fileInFolderMainView).absolutePath());
        m_countMainView = m_entriesMainView.length();

    }

    QFileInfo info(m_fileInFolderMainView);
    if(info.absolutePath() == cacheAdvancedSortFolderName)
        advancedSortMainView();
    else
        cacheAdvancedSortFolderName = "";

    Q_EMIT newDataLoadedMainView();
    Q_EMIT countMainViewChanged();

}

void PQCFileFolderModel::loadDataFileDialog() {

    qDebug() << "";

    ////////////////////////
    // clear old entries

    m_entriesFileDialog.clear();
    m_countFoldersFileDialog = 0;
    m_countFilesFileDialog = 0;
    m_countAllFileDialog = 0;
    delete watcherFileDialog;
    watcherFileDialog = new QFileSystemWatcher;

    ////////////////////////
    // no new directory

    if(m_folderFileDialog.isEmpty()) {
        Q_EMIT newDataLoadedFileDialog();
        Q_EMIT countFoldersFileDialogChanged();
        Q_EMIT countFilesFileDialogChanged();
        Q_EMIT countAllFileDialogChanged();
        return;
    }

    ////////////////////////
    // watch directory for changes

    watcherFileDialog->addPath(m_folderFileDialog);
    connect(watcherFileDialog, &QFileSystemWatcher::directoryChanged, this, &PQCFileFolderModel::loadDataFileDialog);

    ////////////////////////
    // load folders

    m_entriesFileDialog = getAllFolders(m_folderFileDialog);
    m_countFoldersFileDialog = m_entriesFileDialog.length();

    ////////////////////////
    // load files

    m_entriesFileDialog.append(getAllFiles(m_folderFileDialog, true));

    m_countFilesFileDialog = m_entriesFileDialog.length()-m_countFoldersFileDialog;

    m_countAllFileDialog = m_countFoldersFileDialog+m_countFilesFileDialog;

    Q_EMIT newDataLoadedFileDialog();
    Q_EMIT countFoldersFileDialogChanged();
    Q_EMIT countFilesFileDialogChanged();
    Q_EMIT countAllFileDialogChanged();

}

QStringList PQCFileFolderModel::getAllFolders(QString folder) {

    qDebug() << "args: folder =" << folder;

    QStringList ret;

    const bool sortReversed = !PQCSettings::get()["imageviewSortImagesAscending"].toBool();
    const QString sortBy = PQCSettings::get()["imageviewSortImagesBy"].toString();
    const bool showHidden = PQCSettings::get()["filedialogShowHiddenFilesFolders"].toBool();

    QDir::SortFlags sortFlags = QDir::IgnoreCase;
    if(sortReversed)
        sortFlags |= QDir::Reversed;
    if(sortBy == "name")
        sortFlags |= QDir::Name;
    else if(sortBy == "time")
        sortFlags |= QDir::Time;
    else if(sortBy == "size")
        sortFlags |= QDir::Size;
    else if(sortBy == "type")
        sortFlags |= QDir::Type;

    if(!cache.loadFoldersFromCache(folder, showHidden, sortFlags, m_restrictToSuffixes, m_nameFilters, m_filenameFilters, m_restrictToMimeTypes, m_imageResolutionFilter, m_fileSizeFilter, false, ret)) {

        QDir dir(folder);

        if(!dir.exists()) {
            qWarning() << "ERROR: Folder location does not exist:" << folder;
            return ret;
        }

        if(showHidden)
            dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
        else
            dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

        if(sortBy != "naturalname")
            dir.setSorting(sortFlags);

        const QFileInfoList lst = dir.entryInfoList();
        for(const auto &f : lst)
            ret << f.filePath();

        if(sortBy == "naturalname") {
            QCollator collator;
            collator.setNumericMode(true);
            if(sortReversed)
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
            else
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
        }

        cache.saveFoldersToCache(folder, showHidden, sortFlags, m_restrictToSuffixes, m_nameFilters, m_filenameFilters, m_restrictToMimeTypes, m_imageResolutionFilter, m_fileSizeFilter, false, ret);

    }

    return ret;

}

QStringList PQCFileFolderModel::getAllFiles(QString folder, bool ignoreFiltersExceptDefault) {

    qDebug() << "args: folder =" << folder;
    qDebug() << "args: ignoreFiltersExceptDefault =" << ignoreFiltersExceptDefault;

    QStringList ret;

    const bool sortReversed = !PQCSettings::get()["imageviewSortImagesAscending"].toBool();
    const QString sortBy = PQCSettings::get()["imageviewSortImagesBy"].toString();
    const bool showHidden = PQCSettings::get()["filedialogShowHiddenFilesFolders"].toBool();

    QDir::SortFlags sortFlags = QDir::IgnoreCase;
    if(sortReversed)
        sortFlags |= QDir::Reversed;
    if(sortBy == "name")
        sortFlags |= QDir::Name;
    else if(sortBy == "time")
        sortFlags |= QDir::Time;
    else if(sortBy == "size")
        sortFlags |= QDir::Size;
    else if(sortBy == "type")
        sortFlags |= QDir::Type;

    // In order to properly sort the resulting list (sorting by directory first and by chosen sorting criteria second (on a per-directory basis)
    // we need to consider each directory on its own before adding it to the resulting list at the end

    QStringList foldersToScan;
    foldersToScan << folder;

    if(m_includeFilesInSubFolders) {
        QDirIterator iter(folder, QDir::Dirs|QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
        int count = 0;
        while(iter.hasNext()) {
            iter.next();
            foldersToScan << iter.filePath();

            // we limit the number of subfolders to avoid getting stuck
            ++count;
            if(count > 100)
                break;
        }
    }

    for(const QString &f : qAsConst(foldersToScan)) {

        if(!cache.loadFilesFromCache(f, showHidden, sortFlags, m_restrictToSuffixes, m_nameFilters, m_filenameFilters, m_restrictToMimeTypes, m_imageResolutionFilter, m_fileSizeFilter, ignoreFiltersExceptDefault, ret)) {

            QStringList ret_cur;

            QDir dir(f);

            if(!dir.exists()) {
                qWarning() << "ERROR: Folder location does not exist:" << f;
                continue;
            }

            if(showHidden)
                dir.setFilter(QDir::Files|QDir::NoDotAndDotDot|QDir::Hidden);
            else
                dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);

            if(sortBy != "naturalname")
                dir.setSorting(sortFlags);

            if(m_nameFilters.size() == 0 && m_restrictToSuffixes.size() == 0 && m_restrictToMimeTypes.size() == 0 && m_imageResolutionFilter.isNull() && m_fileSizeFilter == 0) {
                const QFileInfoList lst = dir.entryInfoList();
                for(const auto &f: lst)
                    ret_cur << f.filePath();
            } else {

                const QFileInfoList lst = dir.entryInfoList();
                for(const auto &f : lst) {

                    if(!ignoreFiltersExceptDefault) {

                        if(m_fileSizeFilter != 0) {

                            // only show images greater than -> fails check
                            if(m_fileSizeFilter > 0 && f.size() < m_fileSizeFilter)
                                continue;

                            // only show images less than -> fails check
                            if(m_fileSizeFilter < 0 && f.size() > -m_fileSizeFilter)
                                continue;

                        }

                        if(!m_imageResolutionFilter.isNull()) {

                            const bool greater = (m_imageResolutionFilter.width()>0);
                            const int width = m_imageResolutionFilter.width();
                            const int height = m_imageResolutionFilter.height();

                            QSize origSize;
//                            PQImageProviderFull imageprovider;
//                            imageprovider.requestImage(QUrl::toPercentEncoding(f.absoluteFilePath(), "", " "), &origSize, QSize(1,1));

                            if(greater && (origSize.width() < width || origSize.height() < height))
                                continue;

                            if(!greater && (origSize.width() > -width || origSize.height() > -height))
                                continue;

                        }

                    }

                    if((m_nameFilters.size() == 0 || (!ignoreFiltersExceptDefault && m_nameFilters.contains(f.suffix().toLower()))) && (m_restrictToSuffixes.size() == 0 || m_restrictToSuffixes.contains(f.suffix().toLower()))) {
                        if(m_filenameFilters.length() == 0 || ignoreFiltersExceptDefault)
                            ret_cur << f.absoluteFilePath();
                        else {
                            for(const QString &fil : qAsConst(m_filenameFilters)) {
                                if(f.baseName().contains(fil)) {
                                    ret_cur << f.absoluteFilePath();
                                    break;
                                }
                            }
                        }
                    }
                    // if not the ending, then check the mime type
                    else if(m_nameFilters.size() == 0 && m_restrictToMimeTypes.contains(db.mimeTypeForFile(f.absoluteFilePath()).name())) {
                        if(m_filenameFilters.length() == 0 || ignoreFiltersExceptDefault)
                            ret_cur << f.absoluteFilePath();
                        else {
                            for(const QString &fil : qAsConst(m_filenameFilters)) {
                                if(f.baseName().contains(fil)) {
                                    ret_cur << f.absoluteFilePath();
                                    break;
                                }
                            }
                        }
                    }

                }

            }

            if(sortBy == "naturalname") {
                QCollator collator;
                collator.setNumericMode(true);
                if(sortReversed)
                    std::sort(ret_cur.begin(), ret_cur.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
                else
                    std::sort(ret_cur.begin(), ret_cur.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
            }

            // add current list, sorted, to global result list
            ret << ret_cur;

            cache.saveFilesToCache(f, showHidden, sortFlags, m_restrictToSuffixes, m_nameFilters, m_filenameFilters, m_restrictToMimeTypes, m_imageResolutionFilter, m_fileSizeFilter, ignoreFiltersExceptDefault, ret_cur);

        }

    }

    return ret;

}

QStringList PQCFileFolderModel::listPDFPages(QString path) {

    qDebug() << "args: path =" << path;

    QStringList ret;

#ifdef POPPLER

    std::unique_ptr<Poppler::Document> document = Poppler::Document::load(path);
    if(document && !document->isLocked()) {
        int numPages = document->numPages();
        for(int i = 0; i < numPages; ++i)
            ret.append(QString("%1::PDF::%2").arg(i).arg(path));
    }

#endif

#ifdef QTPDF
    QPdfDocument doc;
    doc.load(path);

    QPdfDocument::Status err = doc.status();
    if(err == QPdfDocument::Status::Ready) {
        const int numPages = doc.pageCount();
        for(int i = 0; i < numPages; ++i)
            ret.append(QString("%1::PDF::%2").arg(i).arg(path));
    }
#endif

    return ret;

}

void PQCFileFolderModel::handleNewDataLoadedMainView() {

    bool curset = false;

        // if a specific filename is to be loaded
    if(m_setFileNameOnceReloaded == "---") {
        if(m_countMainView > 0)
            setCurrentIndex(0);
    } else if(m_setFileNameOnceReloaded != "") {
        if(setAsCurrent(m_setFileNameOnceReloaded))
            curset = true;
        setSetFileNameOnceReloaded("");
    } else if(m_currentFile != "") {
        if(setAsCurrent(m_currentFile))
            curset = true;
    }

    if(!curset) {

        int newIndex = m_currentIndex;

        // make sure the index is valid
        if(newIndex >= m_countMainView)
            newIndex = m_countMainView-1;
        else if(newIndex == -1 && m_countMainView > 0)
            newIndex = 0;
        else if(newIndex == 0)
                newIndex = -1;

        setCurrentIndex(newIndex);

    }

}
