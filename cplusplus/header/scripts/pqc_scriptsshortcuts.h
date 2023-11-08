#ifndef PQCSCRIPTSSHORTCUTS_H
#define PQCSCRIPTSSHORTCUTS_H

#include <QObject>
#include <QMap>

class PQCScriptsShortcuts : public QObject {

    Q_OBJECT

public:
    static PQCScriptsShortcuts& get() {
        static PQCScriptsShortcuts instance;
        return instance;
    }
    ~PQCScriptsShortcuts();

    PQCScriptsShortcuts(PQCScriptsShortcuts const&)     = delete;
    void operator=(PQCScriptsShortcuts const&) = delete;

    Q_INVOKABLE void executeExternal(QString exe, QString args, QString currentfile);

    Q_INVOKABLE QStringList analyzeModifier(Qt::KeyboardModifiers mods);
    Q_INVOKABLE QString analyzeMouseWheel(QPoint angleDelta);
    Q_INVOKABLE QString analyzeMouseButton(Qt::MouseButton button);
    Q_INVOKABLE QString analyzeMouseDirection(QPoint prevPoint, QPoint curPoint);
    Q_INVOKABLE QString analyzeKeyPress(Qt::Key key);

private:
    PQCScriptsShortcuts();

};

#endif
