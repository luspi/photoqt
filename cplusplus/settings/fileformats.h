/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#ifndef FILEFORMATS_H
#define FILEFORMATS_H

#include <QObject>
#include <QTextStream>
#include <iostream>
#include <QDir>
#include <QFileSystemWatcher>
#include <QTimer>

#include "fileformatsavailable.h"
#include "fileformatsdefaultenabled.h"
#include "../logger.h"

class FileFormats : public QObject {

    Q_OBJECT

private:
    QFileSystemWatcher *watcher;
    QTimer *saveFileformatsTimer;

public:

    FileFormats(bool usedAtStartupOnly = false, QObject *parent = 0) : QObject(parent) {

        // This class is used during startup checks if the default formats have to be set
        // It only lives for a moment, and doesn't need many of the functions
        if(usedAtStartupOnly) {
            watcher = nullptr;
            saveFileformatsTimer = nullptr;
            return;
        }

        watcher = new QFileSystemWatcher;
        setFilesToWatcher();
        connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(loadFormats()));

        // When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds, but use a timer to save it once after all settings are set
        saveFileformatsTimer = new QTimer;
        saveFileformatsTimer->setInterval(400);
        saveFileformatsTimer->setSingleShot(true);
        connect(saveFileformatsTimer, SIGNAL(timeout()), this, SLOT(saveFormats()));

        connect(this, SIGNAL(formats_qtChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_gmChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_kdeChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_gm_ghostscriptChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_extrasChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_untestedChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_rawChanged(QStringList)), saveFileformatsTimer, SLOT(start()));
        connect(this, SIGNAL(formats_devilChanged(QStringList)), saveFileformatsTimer, SLOT(start()));

        loadFormats();

    }

    ~FileFormats() { delete watcher; if(saveFileformatsTimer != nullptr) saveFileformatsTimer->stop(); delete saveFileformatsTimer; }

    // Per default enabled image formats
    QStringList formats_qt;
    QStringList formats_kde;
    QStringList formats_gm;
    QStringList formats_gm_ghostscript;
    QStringList formats_extras;
    QStringList formats_untested;
    QStringList formats_raw;
    QStringList formats_devil;

    Q_PROPERTY(QStringList formats_qt MEMBER formats_qt NOTIFY formats_qtChanged)
    Q_PROPERTY(QStringList formats_kde MEMBER formats_kde NOTIFY formats_kdeChanged)
    Q_PROPERTY(QStringList formats_gm MEMBER formats_gm NOTIFY formats_gmChanged)
    Q_PROPERTY(QStringList formats_gm_ghostscript MEMBER formats_gm_ghostscript NOTIFY formats_gm_ghostscriptChanged)
    Q_PROPERTY(QStringList formats_extras MEMBER formats_extras NOTIFY formats_extrasChanged)
    Q_PROPERTY(QStringList formats_untested MEMBER formats_untested NOTIFY formats_untestedChanged)
    Q_PROPERTY(QStringList formats_raw MEMBER formats_raw NOTIFY formats_rawChanged)
    Q_PROPERTY(QStringList formats_devil MEMBER formats_devil NOTIFY formats_devilChanged)

    void setAvailableFormats() {

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "FileFormats::setAvailableFormats() - Setting available file formats" << NL;

        formats_qt = FileFormatsHandler::AvailableFormats::getListForQt();
        formats_kde = FileFormatsHandler::AvailableFormats::getListForKde();
        formats_gm = FileFormatsHandler::AvailableFormats::getListForGm();
        formats_gm_ghostscript = FileFormatsHandler::AvailableFormats::getListForGmGhostscript();
        formats_extras = FileFormatsHandler::AvailableFormats::getListForExtras();
        formats_untested = FileFormatsHandler::AvailableFormats::getListForUntested();
        formats_raw = FileFormatsHandler::AvailableFormats::getListForRaw();
        formats_devil = FileFormatsHandler::AvailableFormats::getListForDevIL();

    }

    void setDefaultFormats() {

        setAvailableFormats();

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "FileFormats::setAvailableFormats() - Filtering out default file formats" << NL;

        QStringList defaultEnabledQt = FileFormatsHandler::DefaultFormats::getListForQt();
        QStringList defaultEnabledKde = FileFormatsHandler::DefaultFormats::getListForKde();
        QStringList defaultEnabledGm = FileFormatsHandler::DefaultFormats::getListForGm();
        QStringList defaultEnabledRaw = FileFormatsHandler::DefaultFormats::getListForRaw();
        QStringList defaultEnabledDevIL = FileFormatsHandler::DefaultFormats::getListForDevIL();

        QStringList tmp;
        for(QString f : formats_qt)
            if(defaultEnabledQt.contains(f))
                tmp.append(f);
        formats_qt = tmp;

        tmp.clear();
        for(QString f : formats_kde)
            if(defaultEnabledKde.contains(f))
                tmp.append(f);
        formats_kde = tmp;

        tmp.clear();
        for(QString f : formats_gm)
            if(defaultEnabledGm.contains(f))
                tmp.append(f);
        formats_gm = tmp;

        tmp.clear();
        for(QString f : formats_raw)
            if(defaultEnabledRaw.contains(f))
                tmp.append(f);
        formats_raw = tmp;

        tmp.clear();
        for(QString f : formats_devil)
            if(defaultEnabledDevIL.contains(f))
                tmp.append(f);
        formats_devil = tmp;

    }

public slots:

    void setFilesToWatcher() {
        if(!QFile(ConfigFiles::FILEFORMATSQT_FILE()).exists() || !QFile(ConfigFiles::FILEFORMATSKDE_FILE()).exists() ||
           !QFile(ConfigFiles::FILEFORMATSGM_FILE()).exists() || !QFile(ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE()).exists() ||
           !QFile(ConfigFiles::FILEFORMATSEXTRAS_FILE()).exists() || !QFile(ConfigFiles::FILEFORMATSUNTESTED_FILE()).exists() ||
           !QFile(ConfigFiles::FILEFORMATSRAW_FILE()).exists() || !QFile(ConfigFiles::FILEFORMATSDEVIL_FILE()).exists())
            QTimer::singleShot(1000, this, SLOT(setFilesToWatcher()));
        else
            watcher->addPaths(QStringList() << ConfigFiles::FILEFORMATSQT_FILE()
                              << ConfigFiles::FILEFORMATSKDE_FILE()
                              << ConfigFiles::FILEFORMATSGM_FILE()
                              << ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE()
                              << ConfigFiles::FILEFORMATSEXTRAS_FILE()
                              << ConfigFiles::FILEFORMATSUNTESTED_FILE()
                              << ConfigFiles::FILEFORMATSRAW_FILE()
                              << ConfigFiles::FILEFORMATSDEVIL_FILE());
    }

    void loadFormats() {

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "FileFormats::loadFormats()" << NL;

        QFile file_qt(ConfigFiles::FILEFORMATSQT_FILE());
        QFile file_kde(ConfigFiles::FILEFORMATSKDE_FILE());
        QFile file_gm(ConfigFiles::FILEFORMATSGM_FILE());
        QFile file_gmghostscript(ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE());
        QFile file_extras(ConfigFiles::FILEFORMATSEXTRAS_FILE());
        QFile file_untested(ConfigFiles::FILEFORMATSUNTESTED_FILE());
        QFile file_raw(ConfigFiles::FILEFORMATSRAW_FILE());
        QFile file_devil(ConfigFiles::FILEFORMATSDEVIL_FILE());

        // At first startup, this file might not (yet) exist, but we can simply set the
        // default formats as they are currently in the process of being set anyways
        if(!file_qt.exists() && !file_kde.exists() && !file_gm.exists() && !file_gmghostscript.exists() && !file_extras.exists() && !file_untested.exists() && !file_raw.exists() && !file_devil.exists()) {
            setDefaultFormats();
            return;
        }

        setAvailableFormats();


        /*****************************************/
        // Qt disabled

        if(!file_qt.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load Qt disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_qt(&file_qt);
        QStringList disabled_qt = in_qt.readAll().split("\n",QString::SkipEmptyParts);
        QStringList tmp;
        for(QString f : formats_qt)
            if(!disabled_qt.contains(f))
                tmp.append(f);
        formats_qt = tmp;

        /*****************************************/
        // KDE disabled

        if(!file_kde.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load KDE disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_kde(&file_kde);
        QStringList disabled_kde = in_kde.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_kde)
            if(!disabled_kde.contains(f))
                tmp.append(f);
        formats_kde = tmp;

        /*****************************************/
        // GM disabled

        if(!file_gm.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load GM disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_gm(&file_gm);
        QStringList disabled_gm = in_gm.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_gm)
            if(!disabled_gm.contains(f))
                tmp.append(f);
        formats_gm = tmp;

        /*****************************************/
        // GM Ghostscript disabled

        if(!file_gmghostscript.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load GM Ghostscript disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_gmghostscript(&file_gmghostscript);
        QStringList disabled_gmghostscript = in_gmghostscript.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_gm_ghostscript)
            if(!disabled_gmghostscript.contains(f))
                tmp.append(f);
        formats_gm_ghostscript = tmp;

        /*****************************************/
        // Extras disabled

        if(!file_extras.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load Extras disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_extras(&file_extras);
        QStringList disabled_extras = in_extras.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_extras)
            if(!disabled_extras.contains(f))
                tmp.append(f);
        formats_extras = tmp;

        /*****************************************/
        // Untested disabled

        if(!file_untested.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load Untested disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_untested(&file_untested);
        QStringList disabled_untested = in_untested.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_untested)
            if(!disabled_untested.contains(f))
                tmp.append(f);
        formats_untested = tmp;

        /*****************************************/
        // RAW disabled

        if(!file_raw.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load RAW disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_raw(&file_raw);
        QStringList disabled_raw = in_raw.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_raw)
            if(!disabled_raw.contains(f))
                tmp.append(f);
        formats_raw = tmp;

        /*****************************************/
        // DevIL disabled

        if(!file_devil.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "FileFormats::loadFormats() - ERROR: Unable to open file to load DevIL disabled fileformats. Using default fileformats..." << NL;
            setDefaultFormats();
            return;
        }
        QTextStream in_devil(&file_devil);
        QStringList disabled_devil = in_devil.readAll().split("\n",QString::SkipEmptyParts);
        tmp.clear();
        for(QString f : formats_devil)
            if(!disabled_devil.contains(f))
                tmp.append(f);
        formats_devil = tmp;

    }

    void saveFormats() {

        if(qgetenv("PHOTOQT_DEBUG") == "yes")
            LOG << CURDATE << "FileFormats::saveFormats()" << NL;

        QStringList current_qt = formats_qt;
        QStringList current_kde = formats_kde;
        QStringList current_gm = formats_gm;
        QStringList current_gm_ghostscript = formats_gm_ghostscript;
        QStringList current_extras = formats_extras;
        QStringList current_untested = formats_untested;
        QStringList current_raw = formats_raw;
        QStringList current_devil = formats_devil;

        setAvailableFormats();

        /*******************************************/
        // Qt fileformats

        QStringList disabled_qt;
        for(QString f : formats_qt)
            if(!current_qt.contains(f))
                disabled_qt.append(f);

        QFile file_qt(ConfigFiles::FILEFORMATSQT_FILE());
        if(!file_qt.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated Qt fileformats..." << NL;
            return;
        }
        QTextStream out_qt(&file_qt);
        out_qt << disabled_qt.join("\n");
        file_qt.close();

        /*******************************************/
        // KDE fileformats

        QStringList disabled_kde;
        for(QString f : formats_kde)
            if(!current_kde.contains(f))
                disabled_kde.append(f);

        QFile file_kde(ConfigFiles::FILEFORMATSKDE_FILE());
        if(!file_kde.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated KDE fileformats..." << NL;
            return;
        }
        QTextStream out_kde(&file_kde);
        out_kde << disabled_kde.join("\n");
        file_kde.close();

        /*******************************************/
        // GM fileformats

        QStringList disabled_gm;
        for(QString f : formats_gm)
            if(!current_gm.contains(f))
                disabled_gm.append(f);

        QFile file_gm(ConfigFiles::FILEFORMATSGM_FILE());
        if(!file_gm.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated GM fileformats..." << NL;
            return;
        }
        QTextStream out_gm(&file_gm);
        out_gm << disabled_gm.join("\n");
        file_gm.close();

        /*******************************************/
        // GMGhostscript fileformats

        QStringList disabled_gmghostscript;
        for(QString f : formats_gm_ghostscript)
            if(!current_gm_ghostscript.contains(f))
                disabled_gmghostscript.append(f);

        QFile file_gmghostscript(ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE());
        if(!file_gmghostscript.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated GMGhostscript fileformats..." << NL;
            return;
        }
        QTextStream out_gmghostscript(&file_gmghostscript);
        out_gmghostscript << disabled_gmghostscript.join("\n");
        file_gmghostscript.close();

        /*******************************************/
        // Extras fileformats

        QStringList disabled_extras;
        for(QString f : formats_extras)
            if(!current_extras.contains(f))
                disabled_extras.append(f);

        QFile file_extras(ConfigFiles::FILEFORMATSEXTRAS_FILE());
        if(!file_extras.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated Extras fileformats..." << NL;
            return;
        }
        QTextStream out_extras(&file_extras);
        out_extras << disabled_extras.join("\n");
        file_extras.close();

        /*******************************************/
        // Untested fileformats

        QStringList disabled_untested;
        for(QString f : formats_untested)
            if(!current_untested.contains(f))
                disabled_untested.append(f);

        QFile file_untested(ConfigFiles::FILEFORMATSUNTESTED_FILE());
        if(!file_untested.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated Untested fileformats..." << NL;
            return;
        }
        QTextStream out_untested(&file_untested);
        out_untested << disabled_untested.join("\n");
        file_untested.close();

        /*******************************************/
        // RAW fileformats

        QStringList disabled_raw;
        for(QString f : formats_raw)
            if(!current_raw.contains(f))
                disabled_raw.append(f);

        QFile file_raw(ConfigFiles::FILEFORMATSRAW_FILE());
        if(!file_raw.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated RAW fileformats..." << NL;
            return;
        }
        QTextStream out_raw(&file_raw);
        out_raw << disabled_raw.join("\n");
        file_raw.close();

        /*******************************************/
        // DevIL fileformats

        QStringList disabled_devil;
        for(QString f : formats_devil)
            if(!current_devil.contains(f))
                disabled_devil.append(f);

        QFile file_devil(ConfigFiles::FILEFORMATSDEVIL_FILE());
        if(!file_devil.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            LOG << CURDATE << "ERROR! Unable to save updated DevIL fileformats..." << NL;
            return;
        }
        QTextStream out_devil(&file_devil);
        out_devil << disabled_devil.join("\n");
        file_devil.close();

    }

signals:
    void formats_qtChanged(QStringList val);
    void formats_kdeChanged(QStringList val);
    void formats_gmChanged(QStringList val);
    void formats_gm_ghostscriptChanged(QStringList val);
    void formats_extrasChanged(QStringList val);
    void formats_untestedChanged(QStringList val);
    void formats_rawChanged(QStringList val);
    void formats_devilChanged(QStringList val);

};

#endif
