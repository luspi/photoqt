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

#include <pqc_extensionmethods.h>
#include <pqc_notify_cpp.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <scripts/pqc_scriptsconfig.h>
#include <pqc_extensionshandler.h>

PQCExtensionMethods::PQCExtensionMethods(QObject *parent) : QObject(parent) {

    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForAction, this, &PQCExtensionMethods::replyForAction);
    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::replyForActionWithImage, this, &PQCExtensionMethods::replyForActionWithImage);
    connect(&PQCExtensionsHandler::get(), &PQCExtensionsHandler::receivedMessage, this, &PQCExtensionMethods::receivedMessage);

    connect(this, &PQCExtensionMethods::resetGeometry, &PQCExtensionsHandler::get(), &PQCExtensionsHandler::resetGeometry);

#if __cplusplus >= 202002L
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, [=, this](int key, int modifiers) {
#else
    connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::keyPress, this, [=](int key, int modifiers) {
#endif
        QString combo = PQCScriptsShortcuts::get().analyzeModifier(static_cast<Qt::KeyboardModifiers>(modifiers)).join("+");
        if(!combo.isEmpty()) combo.append("+");
        combo += PQCScriptsShortcuts::get().analyzeKeyPress(static_cast<Qt::Key>(key));
        Q_EMIT receivedShortcut(combo);
    });

}

QVariant PQCExtensionMethods::callAction(const QString &id, QVariant additional) {
    return PQCExtensionsHandler::get().callAction(id, additional);
}

QVariant PQCExtensionMethods::callActionWithImage(const QString &id, QVariant additional) {
    return PQCExtensionsHandler::get().callActionWithImage(id, additional);
}

void PQCExtensionMethods::callActionNonBlocking(const QString &id, QVariant additional) {
    PQCExtensionsHandler::get().callActionNonBlocking(id, additional);
}

void PQCExtensionMethods::callActionWithImageNonBlocking(const QString &id, QVariant additional) {
    PQCExtensionsHandler::get().callActionWithImageNonBlocking(id, additional);
}

/**********************************/

// execute an internal command
void PQCExtensionMethods::executeInternalCommand(QString cmd) {
    Q_EMIT PQCScriptsShortcuts::get().executeInternalCommand(cmd);
}

// show a notification
void PQCExtensionMethods::showNotification(QString title, QString txt) {
    Q_EMIT PQCNotifyCPP::get().showNotificationMessage(title, txt);
}

// run another extension
void PQCExtensionMethods::runExtension(const QString &id) {
    Q_EMIT PQCNotifyCPP::get().showExtension(id);
}

void PQCExtensionMethods::showSettingsFor(const QString &id) {
    Q_EMIT PQCNotifyCPP::get().showSettingsForExtension(id);
}
