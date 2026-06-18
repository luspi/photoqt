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

    Q_INVOKABLE QSet<int> getEnabledFormats(QString category = "all") {
        return PQCImageHandler::get().getEnabledFormats(category);
    }

    Q_INVOKABLE QSet<QString> getEnabledSuffixes(QString category = "all") {
        return PQCImageHandler::get().getEnabledSuffixes(category);
    }

    Q_INVOKABLE QSet<QString> getEnabledMimetypes(QString category = "all") {
        return PQCImageHandler::get().getEnabledMimetypes(category);
    }

    Q_INVOKABLE QSet<QString> getEnabledSuffixes(QStringList categories) {
        return PQCImageHandler::get().getEnabledSuffixes(categories);
    }

    Q_INVOKABLE QSet<QString> getEnabledMimetypes(QStringList categories) {
        return PQCImageHandler::get().getEnabledMimetypes(categories);
    }

    Q_INVOKABLE QString getFormatName(int format) {
        return PQCImageHandler::get().getFormatName(format);
    }

    Q_INVOKABLE QString getFormatName(QString file) {
        return PQCImageHandler::get().getFormatName(file);
    }

    Q_INVOKABLE int getFormatIdFromName(QString name) {
        return PQCImageHandler::get().getFormatIdFromName(name);
    }

    /*****************************************************/

    Q_INVOKABLE QSet<int> getDisabledFormats(QString category = "all") {
        return PQCImageHandler::get().getDisabledFormats(category);
    }

    Q_INVOKABLE QSet<QString> getDisabledSuffixes(QString category = "all") {
        return PQCImageHandler::get().getDisabledSuffixes(category);
    }

    Q_INVOKABLE QSet<QString> getDisabledMimetypes(QString category = "all") {
        return PQCImageHandler::get().getDisabledMimetypes(category);
    }

    /*****************************************************/

    Q_INVOKABLE QStringList getPluginNames() {
        return PQCImageHandler::get().getPluginNames();
    }

    Q_INVOKABLE QStringList getPluginsForFormat(int format) {
        return PQCImageHandler::get().getPluginsForFormat(format);
    }

    Q_INVOKABLE QStringList getAllSuffixesForFormat(int format) {
        return PQCImageHandler::get().getAllSuffixesForFormat(format);
    }

    Q_INVOKABLE QString getCategoryForFormat(int format) {
        return PQCImageHandler::get().getCategoryForFormat(format);
    }

    Q_INVOKABLE bool isEnabled(QString plugin, int format) {
        return PQCImageHandler::get().isEnabled(plugin, format);
    }

    Q_INVOKABLE void setEnabled(QString pluginName, int format, bool enabled) {
               PQCImageHandler::get().setEnabled(pluginName, format, enabled);
    }

    Q_INVOKABLE void resetAllToDefaultEnabled() {
               PQCImageHandler::get().resetAllToDefaultEnabled();
    }

    /*****************************************************/

Q_SIGNALS:
    void formatsUpdated();

};
