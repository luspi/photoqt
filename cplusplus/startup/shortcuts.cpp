#include "startupcheck.h"

void StartupCheck::Shortcuts::renameShortcutsFunctions() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Shortcuts - renameShortcutsFunctions()" << NL;

    QFile allshortcuts(ConfigFiles::SHORTCUTS_FILE());

    if(!allshortcuts.exists())
        return;

    if(!allshortcuts.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "ERROR: Unable to open shortcuts file for reading!" << std::endl;
        return;
    }

    QTextStream in(&allshortcuts);
    QString all = in.readAll();

    allshortcuts.close();

    if(!all.contains("__close") && !all.contains("__hide"))
        return;

    all = all.replace("__close", "__quit");
    all = all.replace("__hide", "__close");

    if(!allshortcuts.open(QIODevice::WriteOnly|QIODevice::Truncate)) {
        LOG << CURDATE << "ERROR: Unable to open shortcuts file for writing!" << std::endl;
        return;
    }

    QTextStream out(&allshortcuts);
    out << all;

    allshortcuts.close();

}

void StartupCheck::Shortcuts::setDefaultShortcutsIfShortcutFileDoesntExist() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Shortcuts - setDefaultShortcutsIfShortcutFileDoesntExist()" << NL;

    // All shortcuts are stored in this single file
    QFileInfo allshortcuts(ConfigFiles::SHORTCUTS_FILE());

    // If file doesn't exist (i.e., on first start)
    if(!allshortcuts.exists()) {

        // Get handler to shortcuts object (the :: are needed as the current namespace is also called Shortcuts)
        ::Shortcuts sh;

        // Load and save default shortcuts
        sh.saveShortcuts(sh.loadDefaults());

    }

}

void StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Shortcuts - combineKeyMouseShortcutsSingleFile()" << NL;

    // All shortcuts are stored in this single file
    QFile allshortcuts(ConfigFiles::SHORTCUTS_FILE());

    // Potential mouse shortcuts from previous versions
    QFile mouseshortcuts(QString("%1/mouseshortcuts").arg(ConfigFiles::CONFIG_DIR()));

    // If mouse shortcuts exist in the wrong place, migrate!
    if(mouseshortcuts.exists()) {

        // Open for reading only
        if(!mouseshortcuts.open(QIODevice::ReadOnly)) {
            LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() - "
                           << "ERROR: unable to open mouseshortcuts for reading..." << NL;
            return;
        }

        // Open for appending only
        if(!allshortcuts.open(QIODevice::WriteOnly|QIODevice::Append)) {
            LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() - "
                           << "ERROR: unable to open shortcuts for writing..." << NL;
            return;
        }

        // stream to both files
        QTextStream in(&mouseshortcuts);
        QTextStream out(&allshortcuts);

        // Add a linebreak, just to be save, before adding the mouse shortcuts to allshortcuts file
        out << "\n" << in.readAll();

        // close both files
        mouseshortcuts.close();
        allshortcuts.close();

        // and remove old mouse shortcuts file (not needed anymore)
        if(!mouseshortcuts.remove())
            LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() - "
                           << "ERROR: Unable to remove redundant mouse_shortcuts file!" << NL;

    }

}
