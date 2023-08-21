#include <scripts/pqc_scriptsshortcuts.h>
#include <QtDebug>
#include <QFileInfo>
#include <QProcess>
#include <QDir>

PQCScriptsShortcuts::PQCScriptsShortcuts() {}

PQCScriptsShortcuts::~PQCScriptsShortcuts() {}

void PQCScriptsShortcuts::executeExternal(QString exe, QString args, QString currentfile) {

    qDebug() << "args: exe = " << exe;
    qDebug() << "args: args = " << args;
    qDebug() << "args: currentfile = " << currentfile;

    if(exe == "")
        return;

    QFileInfo info(currentfile);
    QStringList argslist;

    args = args.replace("\\space\\", "\\spa|ce\\");
    args = args.replace("\\ ", "\\space\\");

    QStringList argslist_tmp = args.split(" ");

#ifdef Q_OS_WIN
    for(auto &a : argslist_tmp) {
        if(a.contains("%f"))
            a = a.replace("%f", currentfile.replace("/","\\"));
        if(args.contains("%u"))
            a = a.replace("%u", info.fileName().replace("/","\\"));
        if(a.contains("%d"))
            a = a.replace("%d", info.absolutePath().replace("/","\\"));
        a = a.replace("\\space\\", "\\ ");
        a = a.replace("\\spa|ce\\", "\\space\\");
        argslist << a;
    }
#else
    for(auto &a : argslist_tmp) {
        if(a.contains("%f"))
            a = a.replace("%f", currentfile);
        if(args.contains("%u"))
            a = a.replace("%u", info.fileName());
        if(a.contains("%d"))
            a = a.replace("%d", info.absolutePath());
        a = a.replace("\\space\\", " ");
        a = a.replace("\\spa|ce\\", "\\space\\");
        argslist << a;
    }
#endif

    QProcess proc;
    proc.setProgram(QDir::toNativeSeparators(exe));
    proc.setArguments(argslist);

    proc.startDetached();

}
