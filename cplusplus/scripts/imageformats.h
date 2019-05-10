#ifndef PQIMAGEFORMATS_H
#define PQIMAGEFORMATS_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QMap>
#include <QImageReader>
#include <QFileInfo>

#include "../logger.h"
#include "../configfiles.h"

class PQImageFormats : public QObject {

    Q_OBJECT

public:
    explicit PQImageFormats(QObject *parent = nullptr);

    void setEnabledFileformats(QString cat, QStringList val, bool withSaving = true);

    // All possibly available file formats for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsQt() {
        return availableFileformats[categories.indexOf("qt")];
    }

    // All possibly available file formats INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionQt() {
        return availableFileformatsWithDescription[categories.indexOf("qt")];
    }

    // All possibly available file formats for the various categories
    Q_INVOKABLE QStringList getDefaultEnabledEndingsQt() {
        return defaultEnabledFileformats[categories.indexOf("qt")];
    }

    // All currently enabled file formats for ...
    // ... Qt
    Q_PROPERTY(QStringList enabledFileformatsQt
               READ getEnabledFileformatsQt
               WRITE setEnabledFileformatsQt
               NOTIFY enabledFileformatsQtChanged)
    QStringList getEnabledFileformatsQt() { return enabledFileformats[categories.indexOf("qt")]; }
    void setEnabledFileformatsQt(QStringList val) { enabledFileformats[categories.indexOf("qt")] = val;
                                                    emit enabledFileformatsQtChanged(val); }
    void setEnabledFileformatsQtWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("qt")] = val; }

    Q_INVOKABLE void setDefaultFormatsQt() {
        setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
    }

    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultFileformats() {
        setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
    }

    Q_INVOKABLE QStringList getAllEnabledFileformats() {

        QStringList allFormats;

        // Qt
        foreach(QVariant entry, enabledFileformats[categories.indexOf("qt")])
            allFormats.append(entry.toString());

        return allFormats;
    }

signals:
    void enabledFileformatsQtChanged(QStringList val);
    void enabledFileformatsChanged();
    void enabledFileformatsSaved();

    /****************************************************************************************/
    /****************************************************************************************/
    /****** Anything below here is agnostic to how many and what categories there are *******/
    /*********** As long as everything above is adjusted properly, that is enough ***********/
    /****************************************************************************************/
    /****************************************************************************************/

private:
    // Watch for changes to the imageformats file
    QFileSystemWatcher *watcher;
    QTimer *watcherTimer;

    // This is only used for entering which file endings are available, the name of the image and whether it is enabled by default
    QMap<QString, QStringList> *setupAvailable;

    QStringList categories;

    // These are accessible from QML and hold the set info about the file endings
    QVariantList *availableFileformats;
    QVariantList *availableFileformatsWithDescription;
    QStringList *enabledFileformats;

    // Not publicly accessible. They are used when, e.g., the respective disabled fileformats file doesn't exist or when the settings are reset.
    QStringList *defaultEnabledFileformats;

    QTimer *saveTimer;

    // Called at setup, these do not change during runtime
    void composeAvailableFormats();

private slots:

    // Save Qt file formats
    void saveEnabledFormats();

    // Read the currently disabled file formats from file (and thus compose the list of currently enabled formats)
    void composeEnabledFormats(bool withSaving = true);

};


#endif // PQIMAGEFORMATS_H
