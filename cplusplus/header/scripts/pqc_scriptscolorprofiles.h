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

#ifndef PQCSCRIPTSCOLORPROFILES_H
#define PQCSCRIPTSCOLORPROFILES_H

#include <QObject>
#include <QList>
#include <QColorSpace>
#include <QImage>
#include <QQmlEngine>

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

class QFile;

class PQCScriptsColorProfiles : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:
    static PQCScriptsColorProfiles& get() {
        static PQCScriptsColorProfiles instance;
        return instance;
    }
    ~PQCScriptsColorProfiles();

    PQCScriptsColorProfiles(PQCScriptsColorProfiles const&)     = delete;
    void operator=(PQCScriptsColorProfiles const&) = delete;

    QList<QColorSpace::NamedColorSpace> getIntegratedColorProfiles();
    QStringList getExternalColorProfiles();
    QStringList getExternalColorProfileDescriptions();
    Q_INVOKABLE QStringList getImportedColorProfiles();
    QStringList getImportedColorProfileDescriptions();
    Q_INVOKABLE QStringList getColorProfiles();
    Q_INVOKABLE QStringList getColorProfileDescriptions();
    Q_INVOKABLE QString getColorProfileID(int index);
    Q_INVOKABLE void setColorProfile(QString path, int index);
    Q_INVOKABLE QString getColorProfileFor(QString path);
    Q_INVOKABLE QString getDescriptionForColorSpace(QString path);
    Q_INVOKABLE int getIndexForColorProfile(QString desc);
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

    int lcms2CountFailedApplications;

    QList<QColorSpace::NamedColorSpace> integratedColorProfiles;
    QStringList integratedColorProfileDescriptions;
    QStringList externalColorProfiles;
    QStringList externalColorProfileDescriptions;
    QStringList importedColorProfiles;
    QStringList importedColorProfileDescriptions;
    QMap<QString, QString> iccColorProfiles;

    qint64 importedICCLastMod;

    QFile *colorlastlocation;

    bool applyColorSpaceQt(QImage &img, QString filename, QColorSpace sp);
#ifdef PQMLCMS2
    bool applyColorSpaceLCMS2(QImage &img, QString filename, cmsHPROFILE targetProfile);
#endif


};

#endif
