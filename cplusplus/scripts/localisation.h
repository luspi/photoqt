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

#ifndef LOCALISATION_H
#define LOCALISATION_H

#include <QObject>
#include <QTranslator>
#include <QApplication>
#include <QFile>

class Localisation : public QObject {

    Q_OBJECT

public:
    Localisation(QObject *parent = 0) : QObject(parent) {
        trans = new QTranslator;
    }
    ~Localisation() {
        delete trans;
    }

    Q_INVOKABLE void setLanguage(QString code) {

        if(!trans->isEmpty())
            qApp->removeTranslator(trans);

        if(QFile(":/photoqt_" + code + ".qm").exists()) {
            trans->load(":/photoqt_" + code);
            qApp->installTranslator(trans);
            emit languageChanged();
            return;
        }

        if(code.contains("_")) {
            code = code.split("_").at(0);
            if(QFile(":/photoqt_" + code + ".qm").exists()) {
                trans->load(":/photoqt_" + code);
                qApp->installTranslator(trans);
                emit languageChanged();
                return;
            }
        }

        // Store translation in settings file
        trans->load(":/photoqt_en.qm");
        qApp->installTranslator(trans);
        emit languageChanged();

    }

    Q_PROPERTY(QString pty READ getPty NOTIFY languageChanged)
    QString getPty() {
        return "";
    }

private:
    QTranslator *trans;

signals:
    void languageChanged();

};

#endif // LOCALISATION_H
