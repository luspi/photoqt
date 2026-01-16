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

#include <QWizard>
#include <QLabel>

#include <ui_pqc_wizard.h>

class PQCWizard : public QWizard {

    Q_OBJECT

public:
    PQCWizard(bool freshInstall, QWidget *parent = 0);
    ~PQCWizard();

private:

    Ui::Wizard *m_ui;

    QStringList m_allAvailableLanguages;
    QString m_selectedLanguage;

    bool m_freshInstall;

private Q_SLOTS:
    void storeCurrentInterface(QString variant);
    void applyCurrentLanguage(int index);

};
