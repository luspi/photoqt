#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <pqc_configfiles.h>
#include <pqc_notify_cpp.h>
#include <pqc_settingscpp.h>

#include <QFile>
#include <QFileDialog>
#include <QCoreApplication>
#include <QProcess>

PQCScriptsColorProfiles &PQCScriptsColorProfiles::get() {
    static PQCScriptsColorProfiles instance;
    return instance;
}

PQCScriptsColorProfiles::PQCScriptsColorProfiles() {

    m_importedICCLastMod = 0;
    m_colorlastlocation = new QFile(QString("%1/%2").arg(PQCConfigFiles::get().CACHE_DIR(), "colorlastlocation"));

    loadColorProfileInfo();

    m_lcms2CountFailedApplications = 0;

}

PQCScriptsColorProfiles::~PQCScriptsColorProfiles() {
    delete m_colorlastlocation;
}

void PQCScriptsColorProfiles::loadColorProfileInfo() {

#ifdef PQMLCMS2

    QFileInfo info(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR());
    if(info.lastModified().toMSecsSinceEpoch() != m_importedICCLastMod) {

        // we always check for imported profile changes
        m_importedColorProfiles.clear();
        m_importedColorProfileDescriptions.clear();

        m_importedICCLastMod = info.lastModified().toMSecsSinceEpoch();

        QDir dir(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR());
        dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);
        QStringList lst = dir.entryList();
        for(auto &f : std::as_const(lst)) {

            QString fullpath = QString("%1/%2").arg(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR(), f);

            QFile file(fullpath);

            if(!file.open(QIODevice::ReadOnly)) {
                qWarning() << "Unable to open imported color profile:" << fullpath;
                continue;
            }

            QByteArray bt = file.readAll();
            cmsHPROFILE profile = cmsOpenProfileFromMem(bt.constData(), bt.size());

            if(!profile) {
                qWarning() << "Unable to create imported color profile:" << fullpath;
                continue;
            }

            const int bufSize = 100;
            char buf[bufSize];

#if LCMS_VERSION >= 2160
            cmsGetProfileInfoUTF8(profile, cmsInfoDescription,
                                  "en", "US",
                                  buf, bufSize);
#else
            cmsGetProfileInfoASCII(profile, cmsInfoDescription,
                                   "en", "US",
                                   buf, bufSize);
#endif

            m_importedColorProfiles << fullpath;
            m_importedColorProfileDescriptions << QString("%1 <i>(imported)</i>").arg(buf);

        }

    }

#endif


    if(m_externalColorProfiles.length() == 0) {

        m_externalColorProfiles.clear();
        m_externalColorProfileDescriptions.clear();

#ifdef Q_OS_UNIX
#ifdef PQMLCMS2

        if(m_externalColorProfiles.length() == 0) {

            QString basedir = "/usr/share/color/icc";
            QDir dir(basedir);
            dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);
            QStringList lst = dir.entryList();
            for(auto &f : std::as_const(lst)) {

                QString fullpath = QString("%1/%2").arg(basedir, f);

                QFile file(fullpath);

                if(!file.open(QIODevice::ReadOnly)) {
                    qWarning() << "Unable to open color profile:" << fullpath;
                    continue;
                }

                QByteArray bt = file.readAll();
                cmsHPROFILE profile = cmsOpenProfileFromMem(bt.constData(), bt.size());

                if(!profile) {
                    qWarning() << "Unable to create color profile:" << fullpath;
                    continue;
                }

                const int bufSize = 100;
                char buf[bufSize];

#if LCMS_VERSION >= 2160
                cmsGetProfileInfoUTF8(profile, cmsInfoDescription,
                                      "en", "US",
                                      buf, bufSize);
#else
                cmsGetProfileInfoASCII(profile, cmsInfoDescription,
                                       "en", "US",
                                       buf, bufSize);
#endif

                m_externalColorProfiles << fullpath;
                m_externalColorProfileDescriptions << QString("%1 <i>(system)</i>").arg(buf);

            }

        }

#else

        QString basedir = "/usr/share/color/icc";
        QDir dir(basedir);
        dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);
        QStringList lst = dir.entryList();
        for(auto &f : std::as_const(lst)) {
            QFile iccfile(QString("%1/%2").arg(basedir, f));
            if(iccfile.open(QIODevice::ReadOnly)) {
                QColorSpace sp = QColorSpace::fromIccProfile(iccfile.readAll());
                if(sp.isValid()) {
                    m_externalColorProfiles << QString("%1/%2").arg(basedir, f);
                    m_externalColorProfileDescriptions << QString("%1 <i>(system)</i>").arg(sp.description());
                }
            }
        }

#endif
#endif

    }

    if(m_integratedColorProfileDescriptions.length() == 0) {

        m_integratedColorProfiles.clear();
        m_integratedColorProfileDescriptions.clear();

        m_integratedColorProfiles << QColorSpace::SRgb
                                << QColorSpace::SRgbLinear
                                << QColorSpace::AdobeRgb
                                << QColorSpace::DisplayP3
                                << QColorSpace::ProPhotoRgb;

        for(auto &c : std::as_const(m_integratedColorProfiles))
            m_integratedColorProfileDescriptions << QColorSpace(c).description();

    }

}

QStringList PQCScriptsColorProfiles::getColorProfileDescriptions() {

    qDebug() << "";

    QStringList ret;

    ret << m_importedColorProfileDescriptions;
    ret << m_integratedColorProfileDescriptions;
    ret << m_externalColorProfileDescriptions;

    return ret;

}

QStringList PQCScriptsColorProfiles::getColorProfiles() {

    qDebug() << "";

    QStringList ret;

    ret << m_importedColorProfiles;
    for(int i = 0; i < m_integratedColorProfiles.length(); ++i)
        ret << QString("::%1").arg(i);
    ret << m_externalColorProfiles;

    return ret;

}

QString PQCScriptsColorProfiles::getColorProfileID(int index) {

    if(index < m_importedColorProfiles.length())
        return m_importedColorProfiles[index];

    index -= m_importedColorProfiles.length();

    if(index < m_integratedColorProfiles.length())
        return QString("::%1").arg(static_cast<int>(index));

    index -= m_integratedColorProfiles.length();

    if(index < m_externalColorProfiles.length())
        return m_externalColorProfiles[index];

    return "";

}

void PQCScriptsColorProfiles::setColorProfile(QString path, int index) {

    qDebug() << "args: path =" << path;
    qDebug() << "args: index =" << index;

    if(index == -1)
        m_iccColorProfiles.remove(path);
    else
        m_iccColorProfiles[path] = getColorProfileID(index);

}

QString PQCScriptsColorProfiles::getColorProfileFor(QString path) {

    qDebug() << "args: path =" << path;

    return m_iccColorProfiles.value(path, "");

}

QStringList PQCScriptsColorProfiles::getImportedColorProfiles() {
    return m_importedColorProfiles;
}

#ifdef PQMLCMS2
int PQCScriptsColorProfiles::toLcmsFormat(QImage::Format fmt) {

    switch (fmt) {

    case QImage::Format_ARGB32:  //  (0xAARRGGBB)
    case QImage::Format_RGB32:   //  (0xffRRGGBB)
        return TYPE_BGRA_8;

    case QImage::Format_RGB888:
        return TYPE_RGB_8;       // 24-bit RGB format (8-8-8).

    case QImage::Format_RGBX8888:
    case QImage::Format_RGBA8888:
        return TYPE_RGBA_8;

    case QImage::Format_Grayscale8:
        return TYPE_GRAY_8;

    case QImage::Format_Grayscale16:
        return TYPE_GRAY_16;

    case QImage::Format_RGBA64:
    case QImage::Format_RGBX64:
        return TYPE_RGBA_16;

    case QImage::Format_BGR888:
        return TYPE_BGR_8;

    default:
        return 0;

    }

}
#endif

bool PQCScriptsColorProfiles::importColorProfile() {

    qDebug() << "";

#ifdef Q_OS_UNIX
    QString loc = "/usr/share/color/icc";
#else
    QString loc = QDir::homePath();
#endif
    if(m_colorlastlocation->open(QIODevice::ReadOnly)) {
        QTextStream in(m_colorlastlocation);
        QString tmp = in.readAll();
        if(tmp != "" && QFileInfo::exists(tmp))
            loc = tmp;
        m_colorlastlocation->close();
    }

    QFileDialog diag;
    diag.setLabelText(QFileDialog::Accept, "Import");
    diag.setFileMode(QFileDialog::AnyFile);
    diag.setModal(true);
    diag.setAcceptMode(QFileDialog::AcceptOpen);
    diag.setOption(QFileDialog::DontUseNativeDialog, false);
    diag.setNameFilter("*.icc;;All Files (*.*)");
    diag.setDirectory(loc);

    if(diag.exec()) {
        QStringList fileNames = diag.selectedFiles();
        if(fileNames.length() > 0) {

            QString fn = fileNames[0];
            QFileInfo info(fn);

            if(m_colorlastlocation->open(QIODevice::WriteOnly)) {
                QTextStream out(m_colorlastlocation);
                out << info.absolutePath();
                m_colorlastlocation->close();
            }

            QDir dir(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR());
            if(!dir.exists()) {
                if(!dir.mkpath(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR())) {
                    qWarning() << "Unable to create internal ICC directory";
                    return false;
                }
            }

            if(!QFile::copy(fn,QString("%1/%2").arg(PQCConfigFiles::get().ICC_COLOR_PROFILE_DIR(), info.fileName()))) {
                qWarning() << "Unable to import file";
                return false;
            }

            loadColorProfileInfo();

            return true;

        }
    }

    return true;

}

bool PQCScriptsColorProfiles::removeImportedColorProfile(int index) {

    qDebug() << "args: index =" << index;

    if(index < m_importedColorProfiles.length()) {

        if(QFile::remove(m_importedColorProfiles[index])) {
            m_importedColorProfiles.remove(index, 1);
            m_importedColorProfileDescriptions.remove(index, 1);
            loadColorProfileInfo();
            return true;
        } else
            return false;

    } else
        return false;


}

bool PQCScriptsColorProfiles::applyColorProfile(QString filename, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: img";

    // If enabled we do some color profile management now
    if(!PQCSettingsCPP::get().getImageviewColorSpaceEnable()) {
        qDebug() << "Color space handling disabled";
        PQCNotifyCPP::get().setColorProfileFor(filename, QColorSpace(QColorSpace::SRgb).description());
        return true;
    }

    bool manualSelectionCausedError = false;

    bool attemptedToSetLCMS2Profile = false;

    // check if a color profile has been set by the user for this file
    QString profileName = getColorProfileFor(filename);

    // if no color space is set we set the default one
    // without this some conversion below might fail
    bool colorSpaceManuallySet = false;
    if(profileName != "" && !img.colorSpace().isValid()) {
        colorSpaceManuallySet = true;
        img.setColorSpace(QColorSpace(QColorSpace::SRgb));
    }

    // if internal profile is manually selected
    if(profileName.startsWith("::")) {

        qDebug() << "Loading integrated color profile:" << profileName;

        int index = profileName.remove(0,2).toInt();

        if(index < m_integratedColorProfiles.length() && _applyColorSpaceQt(img, filename, QColorSpace(m_integratedColorProfiles[index])))
            return true;
        else
            manualSelectionCausedError = true;

#ifndef PQMLCMS2

    } else if(profileName != "") {

        // basic handling of external color profiles

        QColorSpace sp;

        QFile f(profileName);
        if(f.open(QIODevice::ReadOnly))
            sp = QColorSpace::fromIccProfile(f.readAll());

        if(_applyColorSpaceQt(img, filename, sp))
            return true;
        else
            manualSelectionCausedError = true;

#endif

    }

#ifdef PQMLCMS2

    QStringList lcmsProfileList;
    lcmsProfileList << m_importedColorProfiles;
    lcmsProfileList << m_externalColorProfiles;

    // if external profile is manually selected
    if(profileName != "" && !profileName.startsWith("::")) {

        qDebug() << "Loading external color profile:" << profileName;

        int index = lcmsProfileList.indexOf(profileName);
        cmsHPROFILE targetProfile = nullptr;
        if(index != -1) {

            QFile f(profileName);
            if(f.open(QIODevice::ReadOnly)) {
                QByteArray bt = f.readAll();
                targetProfile = cmsOpenProfileFromMem(bt.constData(), bt.size());
            }

            attemptedToSetLCMS2Profile = true;

            if(targetProfile && _applyColorSpaceLCMS2(img, filename, targetProfile)) {
                m_lcms2CountFailedApplications = 0;
                return true;
            } else
                manualSelectionCausedError = true;

        }

    }

    // if no profile has been applied and we need to check for embedded profiles
    if(!colorSpaceManuallySet && PQCSettingsCPP::get().getImageviewColorSpaceLoadEmbedded()) {

        qDebug() << "Checking for embedded color profiles";

        cmsHPROFILE targetProfile = cmsOpenProfileFromMem(img.colorSpace().iccProfile().constData(),
                                                          img.colorSpace().iccProfile().size());

        if(targetProfile) {
            attemptedToSetLCMS2Profile = true;
            if(_applyColorSpaceLCMS2(img, filename, targetProfile)) {
                m_lcms2CountFailedApplications = 0;
                return !manualSelectionCausedError;
            }
        }

    }

#endif

    // no profile (successfully) applied, set default one (if selected)
    QString def = PQCSettingsCPP::get().getImageviewColorSpaceDefault();
    if(def != "") {

        qDebug() << "Applying color profile selected as default:" << def;

        // make sure we have a valid starting profile
        if(!img.colorSpace().isValid())
            img.setColorSpace(QColorSpace(QColorSpace::SRgb));

        if(def.startsWith("::")) {

            int index = def.remove(0,2).toInt();

            if(index < m_integratedColorProfiles.length() && _applyColorSpaceQt(img, filename, QColorSpace(m_integratedColorProfiles[index])))
                return !manualSelectionCausedError;

#ifdef PQMLCMS2

        } else {

            int index = lcmsProfileList.indexOf(def);
            cmsHPROFILE targetProfile = nullptr;
            if(index != -1) {

                QFile f(def);
                if(f.open(QIODevice::ReadOnly)) {
                    QByteArray bt = f.readAll();
                    targetProfile = cmsOpenProfileFromMem(bt.constData(), bt.size());
                }

                if(targetProfile ) {
                    attemptedToSetLCMS2Profile = true;
                    if(_applyColorSpaceLCMS2(img, filename, targetProfile)) {
                        m_lcms2CountFailedApplications = 0;
                        return !manualSelectionCausedError;
                    }
                }

            }

# else

            } else {

            // basic handling of external color profiles

            QColorSpace sp;

            QFile f(def);
            if(f.open(QIODevice::ReadOnly))
                sp = QColorSpace::fromIccProfile(f.readAll());

            if(_applyColorSpaceQt(img, filename, sp))
                return !manualSelectionCausedError;

#endif

        }

    }

    // if a profile was attempted to be set with LCMS2 but failed (i.e., we ended up here)
    // then we increment a counter and show a notification message.
    // If the counter passes 5 then we disable support for color spaces.
    if(attemptedToSetLCMS2Profile && profileName == "") {

        m_lcms2CountFailedApplications += 1;

        if(m_lcms2CountFailedApplications > 5) {
            Q_EMIT PQCNotifyCPP::get().disableColorSpaceSupport();
            Q_EMIT PQCNotifyCPP::get().showNotificationMessage(QCoreApplication::translate("imageprovider", "Application of color profile failed."), PQCScriptsFilesPaths::get().getFilename(filename));
            Q_EMIT PQCNotifyCPP::get().showNotificationMessage(QCoreApplication::translate("imageprovider", "Application of color profiles failed repeatedly. Support for color spaces will be disabled, but can be enabled again in the settings manager."), "");
        } else {
            Q_EMIT PQCNotifyCPP::get().showNotificationMessage(QCoreApplication::translate("imageprovider", "Application of color profile failed."), PQCScriptsFilesPaths::get().getFilename(filename));
        }

    }

    // no profile (successfully) applied, set default name
    PQCNotifyCPP::get().setColorProfileFor(filename, QColorSpace(QColorSpace::SRgb).description());
    qDebug() << "Using default color profile";
    return !manualSelectionCausedError;

}

bool PQCScriptsColorProfiles::_applyColorSpaceQt(QImage &img, QString filename, QColorSpace sp) {

    QImage ret;
    ret = img.convertedToColorSpace(sp);
    if(ret.isNull()) {
        qWarning() << "Integrated color profile could not be applied.";
        return false;
    } else {
        const QString desc = sp.description();
        qDebug() << "Applying integrated color profile:" << desc;
        PQCNotifyCPP::get().setColorProfileFor(filename, desc);
        img = ret;
        return true;
    }

}

#ifdef PQMLCMS2
bool PQCScriptsColorProfiles::_applyColorSpaceLCMS2(QImage &img, QString filename, cmsHPROFILE targetProfile) {

    int lcms2SourceFormat = toLcmsFormat(img.format());

    QImage::Format targetFormat = img.format();

    int lcms2targetFormat = toLcmsFormat(img.format());

    if(lcms2SourceFormat == 0 || lcms2targetFormat == 0) {
        qWarning() << "Unknown image format. Attempting to convert image to format known to LCMS2.";
        img.convertTo(QImage::Format_ARGB32);
        targetFormat = QImage::Format_RGB32;
        lcms2SourceFormat = toLcmsFormat(img.format());
        lcms2targetFormat = lcms2SourceFormat;
        if(img.isNull()) {
            qWarning() << "Error converting image to ARGB32. Not applying color profile.";
            return false;
        }
        if(lcms2targetFormat == 0) {
            qWarning() << "Unable to 'fix' image format. Not applying color profile.";
            return false;
        }
    }

    // Create a transformation from source (sRGB) to destination (provided ICC profile) color space
    cmsHTRANSFORM transform = cmsCreateTransform(targetProfile, lcms2SourceFormat, cmsCreate_sRGBProfile(), lcms2targetFormat, INTENT_PERCEPTUAL, 0);
    if (!transform) {
        // Handle error, maybe close profile and return original image or null image
        cmsCloseProfile(targetProfile);
        qWarning() << "Error creating transform for external color profile";
        return false;
    } else {

        // since the target format might not support alpha channels we use black instead of transparent to fill the initial image.
        // we don't have to fill the image for cmsDoTransform but it allows for additional checking whether cmsDoTransform succeeded.
        QImage ret(img.size(), targetFormat);
        ret.fill(Qt::black);

        // Perform color space conversion
        cmsDoTransform(transform, img.constBits(), ret.bits(), img.width() * img.height());

        // transform failed returning null image
        if(ret.isNull()) {
            qWarning() << "Failed to apply external color profile, null image returned";
            return false;
        }

        // check if image is all black -> transform failed
        bool allblack = true;
        for(int x = 0; x < img.width(); ++x) {
            for(int y = 0; y < img.height(); ++y) {
                if(ret.pixelColor(x,y).black() < 255) {
                    allblack = false;
                    break;
                }
            }
            if(!allblack) break;
        }

        if(allblack) {
            qWarning() << "Failed to apply external color profile, image completely black";
            return false;
        }

        const int bufSize = 100;
        char buf[bufSize];

#if LCMS_VERSION >= 2160
        cmsGetProfileInfoUTF8(targetProfile, cmsInfoDescription,
                              "en", "US",
                              buf, bufSize);
#else
        cmsGetProfileInfoASCII(targetProfile, cmsInfoDescription,
                               "en", "US",
                               buf, bufSize);
#endif

        // Release resources
        cmsDeleteTransform(transform);
        cmsCloseProfile(targetProfile);

        qDebug() << "Applying external color profile:" << buf;

        PQCNotifyCPP::get().setColorProfileFor(filename, buf);

        img = ret;

        return true;

    }
}
#endif

QString PQCScriptsColorProfiles::detectVideoColorProfile(QString path) {

    qDebug() << "args: path =" << path;

#ifdef Q_OS_UNIX

    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which", QStringList() << "mediainfo");
    which.waitForFinished();

    if(!which.exitCode()) {

        QProcess p;
        p.start("mediainfo", QStringList() << path);

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
            QString out = (toUtf16(outdata));

            if(out.contains("Color space  "))
                return out.split("Color space ")[1].split(" : ")[1].split("\n")[0].trimmed();

        }

    }

    which.start("which", QStringList() << "ffprobe");
    which.waitForFinished();

    if(!which.exitCode()) {

        QProcess p;
        p.start("ffprobe", QStringList() << "-show_streams" << path);

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            auto toUtf16 = QStringDecoder(QStringDecoder::Utf8);
            QString out = (toUtf16(outdata));

            if(out.contains("pix_fmt="))
                return out.split("pix_fmt=")[1].split("\n")[0].trimmed();

        }

    }


#endif

    return "";

}
