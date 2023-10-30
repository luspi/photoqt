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
    Q_INVOKABLE QString translateShortcut(QString combo);
    Q_INVOKABLE QString translateMouseDirection(QStringList dirs);

    Q_INVOKABLE QStringList analyzeModifier(Qt::KeyboardModifiers mods);
    Q_INVOKABLE QString analyzeMouseWheel(QPoint angleDelta);
    Q_INVOKABLE QString analyzeMouseButton(Qt::MouseButton button);
    Q_INVOKABLE QString analyzeMouseDirection(QPoint prevPoint, QPoint curPoint);
    Q_INVOKABLE QString analyzeKeyPress(Qt::Key key);

private:
    PQCScriptsShortcuts();

    QString getTranslation(QString key);

    QMap<QString,QString> keyStrings;
    QMap<QString,QString> mouseStrings;

};

#endif
