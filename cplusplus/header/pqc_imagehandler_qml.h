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
#include <QQmlEngine>
#include <QSize>
#include <pqc_imagehandler.h>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCImageHandlerQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCImageHandler)

public:
    PQCImageHandlerQML() {
        connect(&PQCImageHandler::get(), &PQCImageHandler::formatsUpdated, this, &PQCImageHandlerQML::formatsUpdated);
    }

    Q_INVOKABLE QSize getSize(QString path) {
        return PQCImageHandler::get().getSize(path);
    }

    Q_INVOKABLE bool canWrite(QString path) {
        return PQCImageHandler::get().canWrite(path);
    }

    Q_INVOKABLE int getNumFormatsEnabled() {
        return PQCImageHandler::get().getNumFormatsEnabled();
    }

    Q_INVOKABLE QSet<QString> getSuffixes(QString category = "all") {
        return PQCImageHandler::get().getSuffixes(category);
    }

    Q_INVOKABLE QSet<QString> getMimetypes(QString category = "all") {
        return PQCImageHandler::get().getMimetypes(category);
    }

    Q_INVOKABLE QSet<QString> getSuffixes(QStringList categories) {
        return PQCImageHandler::get().getSuffixes(categories);
    }

    Q_INVOKABLE QSet<QString> getMimetypes(QStringList categories) {
        return PQCImageHandler::get().getMimetypes(categories);
    }

    Q_INVOKABLE QString getDescription(QString suffix) {
        return PQCImageHandler::get().getDescription(suffix);
    }

    /*****************************************************/

    Q_INVOKABLE QStringList getPluginNames() {
        return PQCImageHandler::get().getPluginNames();
    }

    Q_INVOKABLE QStringList getAllDescriptions() {
        return PQCImageHandler::get().getAllDescriptions();
    }

    Q_INVOKABLE QStringList getPluginsForFormatByDescription(QString description) {
        return PQCImageHandler::get().getPluginsForFormatByDescription(description);
    }

    Q_INVOKABLE QStringList getAllSuffixesForFormatByDescription(QString description) {
        return PQCImageHandler::get().getAllSuffixesForFormatByDescription(description);
    }

    Q_INVOKABLE bool isEnabled(QString plugin, QString description) {
        return PQCImageHandler::get().isEnabled(plugin, description);
    }

    Q_INVOKABLE void setEnabled(QString pluginName, QString description, bool enabled) {
               PQCImageHandler::get().setEnabled(pluginName, description, enabled);
    }

    /*****************************************************/

Q_SIGNALS:
    void formatsUpdated();

};
