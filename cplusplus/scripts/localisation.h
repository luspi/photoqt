/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef PQLOCALISATION_H
#define PQLOCALISATION_H

#include <QObject>
#include <QTranslator>
#include <QApplication>
#include <QFile>

class PQLocalisation : public QObject {

    Q_OBJECT

public:
    PQLocalisation(QObject *parent = nullptr) : QObject(parent) {
        trans = new QTranslator;
    }
    ~PQLocalisation() {
        delete trans;
    }

    Q_INVOKABLE void setLanguage(QString code) {

        if(!trans->isEmpty())
            qApp->removeTranslator(trans);

        const QStringList allcodes = code.split("/");

        for(const QString &c : allcodes) {

            if(QFile(":/photoqt_" + c + ".qm").exists()) {
                trans->load(":/photoqt_" + c);
                qApp->installTranslator(trans);
                Q_EMIT languageChanged();
                return;
            }

            if(c.contains("_")) {
                const QString cc = c.split("_").at(0);
                if(QFile(":/photoqt_" + cc + ".qm").exists()) {
                    trans->load(":/photoqt_" + cc);
                    qApp->installTranslator(trans);
                    Q_EMIT languageChanged();
                    return;
                }
            } else {
                const QString cc = QString("%1_%2").arg(c, c.toUpper());
                if(QFile(":/photoqt_" + cc + ".qm").exists()) {
                    trans->load(":/photoqt_" + cc);
                    qApp->installTranslator(trans);
                    Q_EMIT languageChanged();
                    return;
                }
            }

        }

        // no translator to be added
        // signal change (to English)
        Q_EMIT languageChanged();

    }

    Q_PROPERTY(QString pty READ getPty NOTIFY languageChanged)
    QString getPty() {
        return "";
    }

private:
    QTranslator *trans;

Q_SIGNALS:
    void languageChanged();

};

#endif // PQLOCALISATION_H
