#ifndef STARTUP_H
#define STARTUP_H

#include <QtSql>
#include "../logger.h"
#include "../scripts/getanddostuff/external.h"
#include "../singleinstance/singleinstance.h"
#include "../settings/settings.h"
#include "../shortcuts/shortcuts.h"

class StartupCheck {

public:

    class ExportImport  { public: static int handleExportImport(SingleInstance *a); };
    class Migration     { public: static void migrateIfNecessary(); };
    class Screenshots   { public: static void getAndStore(); };
    class Settings      { public: static void moveToNewKeyNames(); };
    class Shortcuts     { public: static void renameShortcutsFunctions();
                                  static void setDefaultShortcutsIfShortcutFileDoesntExist();
                                  static void combineKeyMouseShortcutsSingleFile(); };
    class Thumbnails    { public: static void checkThumbnailsDatabase(int update); };
    class UpdateCheck   { public: static int checkForUpdateInstall(::Settings *settings); };

};

#endif // STARTUP_H
