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

#include <QObject>
#include <QMap>
#include <QColorSpace>
#include <QImage>

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

class QFile;

class PQCCScriptsColorProfiles : public QObject {

    Q_OBJECT

public:
    static PQCCScriptsColorProfiles& get() {
        static PQCCScriptsColorProfiles instance;
        return instance;
    }

    PQCCScriptsColorProfiles(PQCCScriptsColorProfiles const&) = delete;
    void operator=(PQCCScriptsColorProfiles const&) = delete;

    void loadColorProfileInfo();

    QString getColorProfileFor(QString path);
    QString applyColorProfile(QString filename, QImage &img);

#ifdef PQMLCMS2
    int toLcmsFormat(QImage::Format fmt);
#endif

private:
    PQCCScriptsColorProfiles();
    ~PQCCScriptsColorProfiles();

    QString _applyColorSpaceQt(QImage &img, QString filename, QColorSpace sp);
#ifdef PQMLCMS2
    QString _applyColorSpaceLCMS2(QImage &img, QString filename, cmsHPROFILE targetProfile);
#endif

    int m_lcms2CountFailedApplications;

    QList<QColorSpace::NamedColorSpace> m_integratedColorProfiles;
    QStringList m_integratedColorProfileDescriptions;
    QStringList m_externalColorProfiles;
    QStringList m_externalColorProfileDescriptions;
    QStringList m_importedColorProfiles;
    QStringList m_importedColorProfileDescriptions;

    QFile *m_colorlastlocation;
    qint64 m_importedICCLastMod;
    QMap<QString, QString> m_iccColorProfiles;

};
