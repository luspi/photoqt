#ifndef MIMETYPES_H
#define MIMETYPES_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QFile>
#include <QTimer>
#include <QFileSystemWatcher>
#include <QImageReader>

#include "../configfiles.h"
#include "../logger.h"

class MimeTypes : public QObject {

    Q_OBJECT

public:
    explicit MimeTypes(QObject *parent = 0);

    // All possibly available mime types for the various categories
    Q_INVOKABLE QVariantList getAvailableMimeTypesQt() { return availableMimeTypes[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesXCFTools() { return availableMimeTypes[categories.indexOf("xcftools")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesPoppler() { return availableMimeTypes[categories.indexOf("poppler")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesGm() { return availableMimeTypes[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesGmGhostscript() { return availableMimeTypes[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesRAW() { return availableMimeTypes[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesDevIL() { return availableMimeTypes[categories.indexOf("devil")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesFreeImage() { return availableMimeTypes[categories.indexOf("freeimage")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesQuaZIP() { return availableMimeTypes[categories.indexOf("quazip")]; }

    // All possibly available mime types INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionQt() { return availableMimeTypesWithDescription[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionXCFTools() { return availableMimeTypesWithDescription[categories.indexOf("xcftools")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionPoppler() { return availableMimeTypesWithDescription[categories.indexOf("poppler")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionGm() { return availableMimeTypesWithDescription[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionGmGhostscript() { return availableMimeTypesWithDescription[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionRAW() { return availableMimeTypesWithDescription[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionDevIL() { return availableMimeTypesWithDescription[categories.indexOf("devil")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionFreeImage() { return availableMimeTypesWithDescription[categories.indexOf("freeimage")]; }
    Q_INVOKABLE QVariantList getAvailableMimeTypesWithDescriptionQuaZIP() { return availableMimeTypesWithDescription[categories.indexOf("quazip")]; }

    // All possibly available mime types for the various categories
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesQt() { return defaultEnabledMimeTypes[categories.indexOf("qt")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesXCFTools() { return defaultEnabledMimeTypes[categories.indexOf("xcftools")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesPoppler() { return defaultEnabledMimeTypes[categories.indexOf("poppler")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesGm() { return defaultEnabledMimeTypes[categories.indexOf("gm")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesGmGhostscript() { return defaultEnabledMimeTypes[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesRAW() { return defaultEnabledMimeTypes[categories.indexOf("raw")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesDevIL() { return defaultEnabledMimeTypes[categories.indexOf("devil")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesFreeImage() { return defaultEnabledMimeTypes[categories.indexOf("freeimage")]; }
    Q_INVOKABLE QStringList getDefaultEnabledMimeTypesQuaZIP() { return defaultEnabledMimeTypes[categories.indexOf("quazip")]; }

    // All currently enabled mime types for ...
    // ... Qt
    Q_PROPERTY(QStringList enabledMimeTypesQt READ getEnabledMimeTypesQt WRITE setEnabledMimeTypesQt NOTIFY enabledMimeTypesQtChanged)
    QStringList getEnabledMimeTypesQt() { return enabledMimeTypes[categories.indexOf("qt")]; }
    void setEnabledMimeTypesQt(QStringList val) { enabledMimeTypes[categories.indexOf("qt")] = val; enabledMimeTypesQtChanged(val); }
    void setEnabledMimeTypesQtWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("qt")] = val; }
    // ... XCF
    Q_PROPERTY(QStringList enabledMimeTypesXCFTools READ getEnabledMimeTypesXCFTools WRITE setEnabledMimeTypesXCFTools NOTIFY enabledMimeTypesXCFToolsChanged)
    QStringList getEnabledMimeTypesXCFTools() { return enabledMimeTypes[categories.indexOf("xcftools")]; }
    void setEnabledMimeTypesXCFTools(QStringList val) { enabledMimeTypes[categories.indexOf("xcftools")] = val; emit enabledMimeTypesXCFToolsChanged(val); }
    void setEnabledMimeTypesXCFToolsWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("xcftools")] = val;}
    // ... Poppler
    Q_PROPERTY(QStringList enabledMimeTypesPoppler READ getEnabledMimeTypesPoppler WRITE setEnabledMimeTypesPoppler NOTIFY enabledMimeTypesPopplerChanged)
    QStringList getEnabledMimeTypesPoppler() { return enabledMimeTypes[categories.indexOf("poppler")]; }
    void setEnabledMimeTypesPoppler(QStringList val) { enabledMimeTypes[categories.indexOf("poppler")] = val; emit enabledMimeTypesPopplerChanged(val); }
    void setEnabledMimeTypesPopplerWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("poppler")] = val; }
    // ... GraphicsMagick
    Q_PROPERTY(QStringList enabledMimeTypesGm READ getEnabledMimeTypesGm WRITE setEnabledMimeTypesGm NOTIFY enabledMimeTypesGmChanged)
    QStringList getEnabledMimeTypesGm() { return enabledMimeTypes[categories.indexOf("gm")]; }
    void setEnabledMimeTypesGm(QStringList val) { enabledMimeTypes[categories.indexOf("gm")] = val; emit enabledMimeTypesGmChanged(val); }
    void setEnabledMimeTypesGmWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("gm")] = val; }
    // ... GraphicsMagick w/ Ghostscript
    Q_PROPERTY(QStringList enabledMimeTypesGmGhostscript READ getEnabledMimeTypesGmGhostscript WRITE setEnabledMimeTypesGmGhostscript NOTIFY enabledMimeTypesGmGhostscriptChanged)
    QStringList getEnabledMimeTypesGmGhostscript() { return enabledMimeTypes[categories.indexOf("gmghostscript")]; }
    void setEnabledMimeTypesGmGhostscript(QStringList val) { enabledMimeTypes[categories.indexOf("gmghostscript")] = val; emit enabledMimeTypesGmGhostscriptChanged(val); }
    void setEnabledMimeTypesGmGhostscriptWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("gmghostscript")] = val; }
    // ... RAW
    Q_PROPERTY(QStringList enabledMimeTypesRAW READ getEnabledMimeTypesRAW WRITE setEnabledMimeTypesRAW NOTIFY enabledMimeTypesRAWChanged)
    QStringList getEnabledMimeTypesRAW() { return enabledMimeTypes[categories.indexOf("raw")]; }
    void setEnabledMimeTypesRAW(QStringList val) { enabledMimeTypes[categories.indexOf("raw")] = val; emit enabledMimeTypesRAWChanged(val); }
    void setEnabledMimeTypesRAWWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("raw")] = val; }
    // ... DevIL
    Q_PROPERTY(QStringList enabledMimeTypesDevIL READ getEnabledMimeTypesDevIL WRITE setEnabledMimeTypesDevIL NOTIFY enabledMimeTypesDevILChanged)
    QStringList getEnabledMimeTypesDevIL() { return enabledMimeTypes[categories.indexOf("devil")]; }
    void setEnabledMimeTypesDevIL(QStringList val) { enabledMimeTypes[categories.indexOf("devil")] = val; emit enabledMimeTypesDevILChanged(val); }
    void setEnabledMimeTypesDevILWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("devil")] = val; }
    // ... FreeImage
    Q_PROPERTY(QStringList enabledMimeTypesFreeImage READ getEnabledMimeTypesFreeImage WRITE setEnabledMimeTypesFreeImage NOTIFY enabledMimeTypesFreeImageChanged)
    QStringList getEnabledMimeTypesFreeImage() { return enabledMimeTypes[categories.indexOf("freeimage")]; }
    void setEnabledMimeTypesFreeImage(QStringList val) { enabledMimeTypes[categories.indexOf("freeimage")] = val; emit enabledMimeTypesFreeImageChanged(val); }
    void setEnabledMimeTypesFreeImageWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("freeimage")] = val; }
    // ... QuaZIP
    Q_PROPERTY(QStringList enabledMimeTypesQuaZIP READ getEnabledMimeTypesQuaZIP WRITE setEnabledMimeTypesQuaZIP NOTIFY enabledMimeTypesQuaZIPChanged)
    QStringList getEnabledMimeTypesQuaZIP() { return enabledMimeTypes[categories.indexOf("quazip")]; }
    void setEnabledMimeTypesQuaZIP(QStringList val) { enabledMimeTypes[categories.indexOf("quazip")] = val; emit enabledMimeTypesQuaZIPChanged(val); }
    void setEnabledMimeTypesQuaZIPWithoutSaving(QStringList val) { enabledMimeTypes[categories.indexOf("quazip")] = val; }

    Q_INVOKABLE void setDefaultMimeTypesQt() { setEnabledMimeTypesQt(defaultEnabledMimeTypes[categories.indexOf("qt")]); }
    Q_INVOKABLE void setDefaultMimeTypesXCFTools() { setEnabledMimeTypesXCFTools(defaultEnabledMimeTypes[categories.indexOf("xcftools")]); }
    Q_INVOKABLE void setDefaultMimeTypesPoppler() { setEnabledMimeTypesPoppler(defaultEnabledMimeTypes[categories.indexOf("poppler")]); }
    Q_INVOKABLE void setDefaultMimeTypesGm() { setEnabledMimeTypesGm(defaultEnabledMimeTypes[categories.indexOf("gm")]); }
    Q_INVOKABLE void setDefaultMimeTypesGmGhostscript() { setEnabledMimeTypesGmGhostscript(defaultEnabledMimeTypes[categories.indexOf("gmghostscript")]); }
    Q_INVOKABLE void setDefaultMimeTypesRAW() { setEnabledMimeTypesRAW(defaultEnabledMimeTypes[categories.indexOf("raw")]); }
    Q_INVOKABLE void setDefaultMimeTypesDevIL() { setEnabledMimeTypesDevIL(defaultEnabledMimeTypes[categories.indexOf("devil")]); }
    Q_INVOKABLE void setDefaultMimeTypesFreeImage() { setEnabledMimeTypesFreeImage(defaultEnabledMimeTypes[categories.indexOf("freeimage")]); }
    Q_INVOKABLE void setDefaultMimeTypesQuaZIP() { setEnabledMimeTypesQuaZIP(defaultEnabledMimeTypes[categories.indexOf("quazip")]); }

    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultMimeTypes() {
        setEnabledMimeTypesQt(defaultEnabledMimeTypes[categories.indexOf("qt")]);
        setEnabledMimeTypesXCFTools(defaultEnabledMimeTypes[categories.indexOf("xcftools")]);
        setEnabledMimeTypesPoppler(defaultEnabledMimeTypes[categories.indexOf("poppler")]);
        setEnabledMimeTypesGm(defaultEnabledMimeTypes[categories.indexOf("gm")]);
        setEnabledMimeTypesGmGhostscript(defaultEnabledMimeTypes[categories.indexOf("gmghostscript")]);
        setEnabledMimeTypesRAW(defaultEnabledMimeTypes[categories.indexOf("raw")]);
        setEnabledMimeTypesDevIL(defaultEnabledMimeTypes[categories.indexOf("devil")]);
        setEnabledMimeTypesFreeImage(defaultEnabledMimeTypes[categories.indexOf("freeimage")]);
        setEnabledMimeTypesQuaZIP(defaultEnabledMimeTypes[categories.indexOf("quazip")]);
    }

    Q_INVOKABLE QStringList getAllEnabledMimeTypes() {
        QStringList allMimeTypes;

        // Qt
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("qt")])
            allMimeTypes.append(entry.toString());
        // xcftools
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("xcftools")])
            allMimeTypes.append(entry.toString());
#ifdef POPPLER
        // Poppler
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("poppler")])
            allMimeTypes.append(entry.toString());
#endif
#ifdef GM
        // GraphicsMagick
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("gm")])
            allMimeTypes.append(entry.toString());
        // GraphicsMagick+Ghostscript
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("gmghostscript")])
            allMimeTypes.append(entry.toString());
#endif
#ifdef RAW
        // RAW
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("raw")])
            allMimeTypes.append(entry.toString());
#endif
#ifdef DEVIL
        // DevIL
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("devil")])
            allMimeTypes.append(entry.toString());
#endif
#ifdef FREEIMAGE
        // FreeImage
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("freeimage")])
            allMimeTypes.append(entry.toString());
#endif
#ifdef QUAZIP
        // QuaZIP
        foreach(QVariant entry, enabledMimeTypes[categories.indexOf("quazip")])
            allMimeTypes.append(entry.toString());
#endif

        return allMimeTypes;
    }

signals:
    void enabledMimeTypesQtChanged(QStringList val);
    void enabledMimeTypesXCFToolsChanged(QStringList val);
    void enabledMimeTypesPopplerChanged(QStringList val);
    void enabledMimeTypesGmChanged(QStringList val);
    void enabledMimeTypesGmGhostscriptChanged(QStringList val);
    void enabledMimeTypesRAWChanged(QStringList val);
    void enabledMimeTypesDevILChanged(QStringList val);
    void enabledMimeTypesFreeImageChanged(QStringList val);
    void enabledMimeTypesQuaZIPChanged(QStringList val);
    void enabledMimeTypesChanged();
    void enabledMimeTypesSaved();

    /****************************************************************************************/
    /****** Anything below here is agnostic to how many and what categories there are *******/
    /*********** As long as everything above is adjusted properly, that is enough ***********/
    /****************************************************************************************/

private:
    void setEnabledMimeTypes(QString cat, QStringList val, bool withSaving = true);

    // Watch for changes to the imageformats file
    QFileSystemWatcher *watcher;
    QTimer *watcherTimer;

    // This is only used for entering which mime types are available, the name of the type and whether it is enabled by default
    QMap<QString, QStringList> *setupAvailable;

    QStringList categories;

    // These are accessible from QML and hold the set info about the file endings
    QVariantList *availableMimeTypes;
    QVariantList *availableMimeTypesWithDescription;
    QStringList *enabledMimeTypes;

    // This is not accessible from outside. They are used when, e.g., the respective disabled MimeTypes file doesn't exist or when the settings are reset.
    QStringList *defaultEnabledMimeTypes;

    QTimer *saveTimer;

    // Called at setup, these do not change during runtime
    void composeAvailableMimeTypes();

private slots:

    // Save Qt file formats
    void saveEnabledMimeTypes();

    // Read the currently disabled mime types from file (and thus compose the list of currently enabled types)
    void composeEnabledMimeTypes(bool withSaving = true);

};

#endif // MIMETYPES_H
