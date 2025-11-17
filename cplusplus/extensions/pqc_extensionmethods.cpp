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

#include <pqc_extensionmethods.h>

PQCExtensionMethods::PQCExtensionMethods(QObject *parent) : QObject(parent) {

    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForAction, this, &PQCExtensionMethods::replyForAction);
    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForActionWithImage, this, &PQCExtensionMethods::replyForActionWithImage);
    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::receivedMessage, this, &PQCExtensionMethods::receivedMessage);

    connect(this, &PQCExtensionMethods::requestResetGeometry, &PQCExtensionsHandler::get(), &PQCExtensionsHandler::requestResetGeometry);

    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, [=](int key, int modifiers) {
        QString combo = PQCScriptsShortcuts::get().analyzeModifier(static_cast<Qt::KeyboardModifiers>(modifiers)).join("+");
        if(combo != "") combo += "+";
        combo += PQCScriptsShortcuts::get().analyzeKeyPress(static_cast<Qt::Key>(key));
        Q_EMIT receivedShortcut(combo);
    });

}

void PQCExtensionMethods::requestCallActionWithImage(const QString &id, QVariant additional, bool async) {
    PQCExtensionsHandler::get().requestCallActionWithImage(id, additional, async);
}

void PQCExtensionMethods::requestCallAction(const QString &id, QVariant additional, bool async) {
    PQCExtensionsHandler::get().requestCallAction(id, additional, async);
}

/**********************************/

// execute an internal command
void PQCExtensionMethods::executeInternalCommand(QString cmd) {
    PQCScriptsShortcuts::get().executeInternalCommand(cmd);
}

// show a notification
void PQCExtensionMethods::showNotification(QString title, QString txt) {
    PQCNotifyCPP::get().showNotificationMessage(title, txt);
}

// check if we are operating on Windows
bool PQCExtensionMethods::amIOnWindows() {
    return PQCScriptsConfig::get().amIOnWindows();
}

// run another extension
void PQCExtensionMethods::runExtension(const QString &id) {
    PQCNotifyCPP::get().showExtension(id);
}
