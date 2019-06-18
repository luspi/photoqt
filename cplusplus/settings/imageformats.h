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
    Q_INVOKABLE QVariantList getAvailableEndingsXCF() {
        return availableFileformats[categories.indexOf("xcftools")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsPoppler() {
        return availableFileformats[categories.indexOf("poppler")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsGm() {
        return availableFileformats[categories.indexOf("gm")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsRAW() {
        return availableFileformats[categories.indexOf("raw")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsDevIL() {
        return availableFileformats[categories.indexOf("devil")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsFreeImage() {
        return availableFileformats[categories.indexOf("freeimage")];
    }

    // All possibly available file formats INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionQt() {
        return availableFileformatsWithDescription[categories.indexOf("qt")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionXCF() {
        return availableFileformatsWithDescription[categories.indexOf("xcftools")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionPoppler() {
        return availableFileformatsWithDescription[categories.indexOf("poppler")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGm() {
        return availableFileformatsWithDescription[categories.indexOf("gm")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionRAW() {
        return availableFileformatsWithDescription[categories.indexOf("raw")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionDevIL() {
        return availableFileformatsWithDescription[categories.indexOf("devil")];
    }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionFreeImage() {
        return availableFileformatsWithDescription[categories.indexOf("freeimage")];
    }

    // All possibly available file formats for the various categories
    Q_INVOKABLE QStringList getDefaultEnabledEndingsQt() {
        return defaultEnabledFileformats[categories.indexOf("qt")];
    }
    Q_INVOKABLE QStringList getDefaultEnabledEndingsXCF() {
        return defaultEnabledFileformats[categories.indexOf("xcftools")];
    }
    Q_INVOKABLE QStringList getDefaultEnabledEndingsPoppler() {
        return defaultEnabledFileformats[categories.indexOf("poppler")];
    }
    Q_INVOKABLE QStringList getDefaultEnabledEndingsGm() {
        return defaultEnabledFileformats[categories.indexOf("gm")];
    }
    Q_INVOKABLE QStringList getDefaultEnabledEndingsRAW() {
        return defaultEnabledFileformats[categories.indexOf("raw")];
    }
    Q_INVOKABLE QStringList getDefaultEnabledEndingsDevIL() {
        return defaultEnabledFileformats[categories.indexOf("devil")];
    }
    Q_INVOKABLE QStringList getDefaultEnabledEndingsFreeImage() {
        return defaultEnabledFileformats[categories.indexOf("freeimage")];
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

    // ... XCF
    Q_PROPERTY(QStringList enabledFileformatsXCF
               READ getEnabledFileformatsXCF
               WRITE setEnabledFileformatsXCF
               NOTIFY enabledFileformatsXCFChanged)
    QStringList getEnabledFileformatsXCF() { return enabledFileformats[categories.indexOf("xcftools")]; }
    void setEnabledFileformatsXCF(QStringList val) { enabledFileformats[categories.indexOf("xcftools")] = val;
                                                    emit enabledFileformatsXCFChanged(val); }
    void setEnabledFileformatsXCFWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("xcftools")] = val; }

    // ... Poppler
    Q_PROPERTY(QStringList enabledFileformatsPoppler
               READ getEnabledFileformatsPoppler
               WRITE setEnabledFileformatsPoppler
               NOTIFY enabledFileformatsPopplerChanged)
    QStringList getEnabledFileformatsPoppler() { return enabledFileformats[categories.indexOf("poppler")]; }
    void setEnabledFileformatsPoppler(QStringList val) { enabledFileformats[categories.indexOf("poppler")] = val;
                                                    emit enabledFileformatsPopplerChanged(val); }
    void setEnabledFileformatsPopplerWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("poppler")] = val; }

    // ... GM
    Q_PROPERTY(QStringList enabledFileformatsGm
               READ getEnabledFileformatsGm
               WRITE setEnabledFileformatsGm
               NOTIFY enabledFileformatsGmChanged)
    QStringList getEnabledFileformatsGm() { return enabledFileformats[categories.indexOf("gm")]; }
    void setEnabledFileformatsGm(QStringList val) { enabledFileformats[categories.indexOf("gm")] = val;
                                                    emit enabledFileformatsGmChanged(val); }
    void setEnabledFileformatsGmWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("gm")] = val; }

    // ... RAW
    Q_PROPERTY(QStringList enabledFileformatsRAW
               READ getEnabledFileformatsRAW
               WRITE setEnabledFileformatsRAW
               NOTIFY enabledFileformatsRAWChanged)
    QStringList getEnabledFileformatsRAW() { return enabledFileformats[categories.indexOf("raw")]; }
    void setEnabledFileformatsRAW(QStringList val) { enabledFileformats[categories.indexOf("raw")] = val;
                                                    emit enabledFileformatsRAWChanged(val); }
    void setEnabledFileformatsRAWWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("raw")] = val; }

    // ... DevIL
    Q_PROPERTY(QStringList enabledFileformatsDevIL
               READ getEnabledFileformatsDevIL
               WRITE setEnabledFileformatsDevIL
               NOTIFY enabledFileformatsDevILChanged)
    QStringList getEnabledFileformatsDevIL() { return enabledFileformats[categories.indexOf("devil")]; }
    void setEnabledFileformatsDevIL(QStringList val) { enabledFileformats[categories.indexOf("devil")] = val;
                                                    emit enabledFileformatsDevILChanged(val); }
    void setEnabledFileformatsDevILWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("devil")] = val; }

    // ... FreeImage
    Q_PROPERTY(QStringList enabledFileformatsFreeImage
               READ getEnabledFileformatsFreeImage
               WRITE setEnabledFileformatsFreeImage
               NOTIFY enabledFileformatsFreeImageChanged)
    QStringList getEnabledFileformatsFreeImage() { return enabledFileformats[categories.indexOf("freeimage")]; }
    void setEnabledFileformatsFreeImage(QStringList val) { enabledFileformats[categories.indexOf("freeimage")] = val;
                                                    emit enabledFileformatsFreeImageChanged(val); }
    void setEnabledFileformatsFreeImageWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("freeimage")] = val; }



    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultFileformats(QString category = "") {
        if(category == "" || category == "qt")
            setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
        if(category == "" || category == "xcftools")
            setEnabledFileformatsXCF(defaultEnabledFileformats[categories.indexOf("xcftools")]);
        if(category == "" || category == "poppler")
            setEnabledFileformatsPoppler(defaultEnabledFileformats[categories.indexOf("poppler")]);
        if(category == "" || category == "gm")
            setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]);
        if(category == "" || category == "raw")
            setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]);
        if(category == "" || category == "devil")
            setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]);
        if(category == "" || category == "freeimage")
            setEnabledFileformatsFreeImage(defaultEnabledFileformats[categories.indexOf("freeimage")]);
    }


    Q_INVOKABLE QStringList getAllEnabledFileFormats() {

        QStringList allFormats;

        // Qt
        foreach(QVariant entry, enabledFileformats[categories.indexOf("qt")])
            allFormats.append(entry.toString());

        // XCF
        foreach(QVariant entry, enabledFileformats[categories.indexOf("xcftools")])
            allFormats.append(entry.toString());

#ifdef POPPLER
        // Poppler
        foreach(QVariant entry, enabledFileformats[categories.indexOf("poppler")])
            allFormats.append(entry.toString());
#endif

#ifdef GM
        // GM
        foreach(QVariant entry, enabledFileformats[categories.indexOf("gm")])
            allFormats.append(entry.toString());
#endif

#ifdef RAW
        // RAW
        foreach(QVariant entry, enabledFileformats[categories.indexOf("raw")])
            allFormats.append(entry.toString());
#endif

#ifdef DEVIL
        // DEVIL
        foreach(QVariant entry, enabledFileformats[categories.indexOf("devil")])
            allFormats.append(entry.toString());
#endif

#ifdef FREEIMAGE
        // FREEIMAGE
        foreach(QVariant entry, enabledFileformats[categories.indexOf("freeimage")])
            allFormats.append(entry.toString());
#endif

        return allFormats;

    }

signals:
    void enabledFileformatsQtChanged(QStringList val);
    void enabledFileformatsGmChanged(QStringList val);
    void enabledFileformatsXCFChanged(QStringList val);
    void enabledFileformatsPopplerChanged(QStringList val);
    void enabledFileformatsRAWChanged(QStringList val);
    void enabledFileformatsDevILChanged(QStringList val);
    void enabledFileformatsFreeImageChanged(QStringList val);
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
