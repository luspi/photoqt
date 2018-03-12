#ifndef IMAGEFORMATS_H
#define IMAGEFORMATS_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QFile>
#include <QTimer>
#include <QFileSystemWatcher>

#include "../configfiles.h"
#include "../logger.h"

class ImageFormats : public QObject {

    Q_OBJECT

public:
    ImageFormats(QObject *parent = 0);

    void setEnabledFileformats(QString cat, QStringList val, bool withSaving = true);

    // All possibly available file formats for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsQt() { return availableFileformats[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsKDE() { return availableFileformats[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsExtras() { return availableFileformats[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGm() { return availableFileformats[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsGmGhostscript() { return availableFileformats[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsRAW() { return availableFileformats[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsDevIL() { return availableFileformats[categories.indexOf("devil")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsFreeImage() { return availableFileformats[categories.indexOf("freeimage")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsPoppler() { return availableFileformats[categories.indexOf("poppler")]; }

    // All possibly available file formats INCLUDING a description of the image type for the various categories
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionQt() { return availableFileformatsWithDescription[categories.indexOf("qt")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionKDE() { return availableFileformatsWithDescription[categories.indexOf("kde")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionExtras() { return availableFileformatsWithDescription[categories.indexOf("extras")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGm() { return availableFileformatsWithDescription[categories.indexOf("gm")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionGmGhostscript() { return availableFileformatsWithDescription[categories.indexOf("gmghostscript")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionRAW() { return availableFileformatsWithDescription[categories.indexOf("raw")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionDevIL() { return availableFileformatsWithDescription[categories.indexOf("devil")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionFreeImage() { return availableFileformatsWithDescription[categories.indexOf("freeimage")]; }
    Q_INVOKABLE QVariantList getAvailableEndingsWithDescriptionPoppler() { return availableFileformatsWithDescription[categories.indexOf("poppler")]; }

    // All currently enabled file formats for ...
    // ... Qt
    Q_PROPERTY(QStringList enabledFileformatsQt READ getEnabledFileformatsQt WRITE setEnabledFileformatsQt NOTIFY enabledFileformatsQtChanged)
    QStringList getEnabledFileformatsQt() { return enabledFileformats[categories.indexOf("qt")]; }
    void setEnabledFileformatsQt(QStringList val) { enabledFileformats[categories.indexOf("qt")] = val; enabledFileformatsQtChanged(val); }
    void setEnabledFileformatsQtWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("qt")] = val; }
    // ... KDE
    Q_PROPERTY(QStringList enabledFileformatsKDE READ getEnabledFileformatsKDE WRITE setEnabledFileformatsKDE NOTIFY enabledFileformatsKDEChanged)
    QStringList getEnabledFileformatsKDE() { return enabledFileformats[categories.indexOf("kde")]; }
    void setEnabledFileformatsKDE(QStringList val) { enabledFileformats[categories.indexOf("kde")] = val; emit enabledFileformatsKDEChanged(val); }
    void setEnabledFileformatsKDEWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("kde")] = val;}
    // ... Extras
    Q_PROPERTY(QStringList enabledFileformatsExtras READ getEnabledFileformatsExtras WRITE setEnabledFileformatsExtras NOTIFY enabledFileformatsExtrasChanged)
    QStringList getEnabledFileformatsExtras() { return enabledFileformats[categories.indexOf("extras")]; }
    void setEnabledFileformatsExtras(QStringList val) { enabledFileformats[categories.indexOf("extras")] = val; emit enabledFileformatsExtrasChanged(val); }
    void setEnabledFileformatsExtrasWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("extras")] = val; }
    // ... GraphicsMagick
    Q_PROPERTY(QStringList enabledFileformatsGm READ getEnabledFileformatsGm WRITE setEnabledFileformatsGm NOTIFY enabledFileformatsGmChanged)
    QStringList getEnabledFileformatsGm() { return enabledFileformats[categories.indexOf("gm")]; }
    void setEnabledFileformatsGm(QStringList val) { enabledFileformats[categories.indexOf("gm")] = val; emit enabledFileformatsGmChanged(val); }
    void setEnabledFileformatsGmWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("gm")] = val; }
    // ... GraphicsMagick w/ Ghostscript
    Q_PROPERTY(QStringList enabledFileformatsGmGhostscript READ getEnabledFileformatsGmGhostscript WRITE setEnabledFileformatsGmGhostscript NOTIFY enabledFileformatsGmGhostscriptChanged)
    QStringList getEnabledFileformatsGmGhostscript() { return enabledFileformats[categories.indexOf("gmghostscript")]; }
    void setEnabledFileformatsGmGhostscript(QStringList val) { enabledFileformats[categories.indexOf("gmghostscript")] = val; emit enabledFileformatsGmGhostscriptChanged(val); }
    void setEnabledFileformatsGmGhostscriptWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("gmghostscript")] = val; }
    // ... RAW
    Q_PROPERTY(QStringList enabledFileformatsRAW READ getEnabledFileformatsRAW WRITE setEnabledFileformatsRAW NOTIFY enabledFileformatsRAWChanged)
    QStringList getEnabledFileformatsRAW() { return enabledFileformats[categories.indexOf("raw")]; }
    void setEnabledFileformatsRAW(QStringList val) { enabledFileformats[categories.indexOf("raw")] = val; emit enabledFileformatsRAWChanged(val); }
    void setEnabledFileformatsRAWWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("raw")] = val; }
    // ... DevIL
    Q_PROPERTY(QStringList enabledFileformatsDevIL READ getEnabledFileformatsDevIL WRITE setEnabledFileformatsDevIL NOTIFY enabledFileformatsDevILChanged)
    QStringList getEnabledFileformatsDevIL() { return enabledFileformats[categories.indexOf("devil")]; }
    void setEnabledFileformatsDevIL(QStringList val) { enabledFileformats[categories.indexOf("devil")] = val; emit enabledFileformatsDevILChanged(val); }
    void setEnabledFileformatsDevILWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("devil")] = val; }
    // ... FreeImage
    Q_PROPERTY(QStringList enabledFileformatsFreeImage READ getEnabledFileformatsFreeImage WRITE setEnabledFileformatsFreeImage NOTIFY enabledFileformatsFreeImageChanged)
    QStringList getEnabledFileformatsFreeImage() { return enabledFileformats[categories.indexOf("freeimage")]; }
    void setEnabledFileformatsFreeImage(QStringList val) { enabledFileformats[categories.indexOf("freeimage")] = val; emit enabledFileformatsFreeImageChanged(val); }
    void setEnabledFileformatsFreeImageWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("freeimage")] = val; }
    // ... Poppler
    Q_PROPERTY(QStringList enabledFileformatsPoppler READ getEnabledFileformatsPoppler WRITE setEnabledFileformatsPoppler NOTIFY enabledFileformatsPopplerChanged)
    QStringList getEnabledFileformatsPoppler() { return enabledFileformats[categories.indexOf("poppler")]; }
    void setEnabledFileformatsPoppler(QStringList val) { enabledFileformats[categories.indexOf("poppler")] = val; emit enabledFileformatsPopplerChanged(val); }
    void setEnabledFileformatsPopplerWithoutSaving(QStringList val) { enabledFileformats[categories.indexOf("poppler")] = val; }

    Q_INVOKABLE void setDefaultFormatsQt() { setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]); }
    Q_INVOKABLE void setDefaultFormatsKDE() { setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]); }
    Q_INVOKABLE void setDefaultFormatsExtras() { setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]); }
    Q_INVOKABLE void setDefaultFormatsGm() { setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]); }
    Q_INVOKABLE void setDefaultFormatsGmGhostscript() { setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]); }
    Q_INVOKABLE void setDefaultFormatsRAW() { setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]); }
    Q_INVOKABLE void setDefaultFormatsDevIL() { setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]); }
    Q_INVOKABLE void setDefaultFormatsFreeImage() { setEnabledFileformatsFreeImage(defaultEnabledFileformats[categories.indexOf("freeimage")]); }
    Q_INVOKABLE void setDefaultFormatsPoppler() { setEnabledFileformatsPoppler(defaultEnabledFileformats[categories.indexOf("poppler")]); }

    // Can be called from QML when resetting the settings
    Q_INVOKABLE void setDefaultFileformats() {
        setEnabledFileformatsQt(defaultEnabledFileformats[categories.indexOf("qt")]);
        setEnabledFileformatsKDE(defaultEnabledFileformats[categories.indexOf("kde")]);
        setEnabledFileformatsExtras(defaultEnabledFileformats[categories.indexOf("extras")]);
        setEnabledFileformatsGm(defaultEnabledFileformats[categories.indexOf("gm")]);
        setEnabledFileformatsGmGhostscript(defaultEnabledFileformats[categories.indexOf("gmghostscript")]);
        setEnabledFileformatsRAW(defaultEnabledFileformats[categories.indexOf("raw")]);
        setEnabledFileformatsDevIL(defaultEnabledFileformats[categories.indexOf("devil")]);
        setEnabledFileformatsFreeImage(defaultEnabledFileformats[categories.indexOf("freeimage")]);
        setEnabledFileformatsPoppler(defaultEnabledFileformats[categories.indexOf("poppler")]);
    }

    Q_INVOKABLE QStringList getAllEnabledFileformats() {
        QStringList allFormats;
        for(int i = 0; i < categories.length(); ++i) {
            foreach(QVariant entry, enabledFileformats[i])
                allFormats.append(entry.toString());
        }
        return allFormats;
    }

signals:
    void enabledFileformatsQtChanged(QStringList val);
    void enabledFileformatsKDEChanged(QStringList val);
    void enabledFileformatsExtrasChanged(QStringList val);
    void enabledFileformatsGmChanged(QStringList val);
    void enabledFileformatsGmGhostscriptChanged(QStringList val);
    void enabledFileformatsRAWChanged(QStringList val);
    void enabledFileformatsDevILChanged(QStringList val);
    void enabledFileformatsFreeImageChanged(QStringList val);
    void enabledFileformatsPopplerChanged(QStringList val);
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
    QStringList formatsfiles;

    // These are accessible from QML and hold the set info about the file endings
    QVariantList *availableFileformats;
    QVariantList *availableFileformatsWithDescription;
    QStringList *enabledFileformats;

    // This is not accessible from outside. They are used when, e.g., the respective disabled fileformats file doesn't exist or when the settings are reset.
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


#endif // IMAGEFORMATS_H
