/**************************************************************************
 **                                                                      **
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
#pragma once

#include <QObject>
#include <QList>
#include <QColorSpace>
#include <QImage>
#include <QMutex>

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

/*************************************************************/
/*************************************************************/
//
// this class is used in both C++ and QML code
// thus there is a WRAPPER for QML available
//
/*************************************************************/
/*************************************************************/

class QFile;

class PQCScriptsColorProfiles : public QObject {

    Q_OBJECT

public:
    static PQCScriptsColorProfiles& get();
    virtual ~PQCScriptsColorProfiles();

    PQCScriptsColorProfiles(PQCScriptsColorProfiles const&)     = delete;
    void operator=(PQCScriptsColorProfiles const&) = delete;

    Q_INVOKABLE QStringList getImportedColorProfiles();
    Q_INVOKABLE QStringList getColorProfiles();
    Q_INVOKABLE QStringList getColorProfileDescriptions();
    Q_INVOKABLE QString getColorProfileID(int index);
    Q_INVOKABLE void setColorProfile(QString path, int index);
    Q_INVOKABLE QString getColorProfileFor(QString path);
    Q_INVOKABLE bool importColorProfile();
    Q_INVOKABLE bool removeImportedColorProfile(int index);
    Q_INVOKABLE QString detectVideoColorProfile(QString path);
    void loadColorProfileInfo();
    bool applyColorProfile(QString filename, QImage &img);

#ifdef PQMLCMS2
    int toLcmsFormat(QImage::Format fmt);
#endif

private:
    PQCScriptsColorProfiles();

    int m_lcms2CountFailedApplications;

    QList<QColorSpace::NamedColorSpace> m_integratedColorProfiles;
    QStringList m_integratedColorProfileDescriptions;
    QStringList m_externalColorProfiles;
    QStringList m_externalColorProfileDescriptions;
    QStringList m_importedColorProfiles;
    QStringList m_importedColorProfileDescriptions;

    mutable QMutex iccMmutex;
    QHash<QString, QString> m_iccColorProfiles;

    qint64 m_importedICCLastMod;

    QFile *m_colorlastlocation;

    bool _applyColorSpaceQt(QImage &img, QString filename, QColorSpace sp);
#ifdef PQMLCMS2
    bool _applyColorSpaceLCMS2(QImage &img, QString filename, cmsHPROFILE targetProfile);
#endif

};
