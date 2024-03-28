/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include <pqc_providerfull.h>
#include <pqc_loadimage.h>
#include <scripts/pqc_scriptsfilespaths.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_settings.h>
#include <QFileInfo>
#include <QCoreApplication>
#include <QColorSpace>
#include <pqc_notify.h>

#ifdef PQMLCMS2
#include <lcms2.h>
#endif

PQCProviderFull::PQCProviderFull() : QQuickImageProvider(QQuickImageProvider::Image) {}

PQCProviderFull::~PQCProviderFull() {}

QImage PQCProviderFull::requestImage(const QString &url, QSize *origSize, const QSize &requestedSize) {

    qDebug() << "args: url =" << url;
    qDebug() << "args: requestedSize =" << requestedSize;

    QString filename = PQCScriptsFilesPaths::cleanPath(QByteArray::fromPercentEncoding(url.toUtf8()));

    QString filenameForChecking = filename;
    if(filenameForChecking.contains("::PDF::"))
        filenameForChecking = filenameForChecking.split("::PDF::").at(1);
    if(filenameForChecking.contains("::ARC::"))
        filenameForChecking = filenameForChecking.split("::ARC::").at(1);

    if(!QFileInfo::exists(filenameForChecking)) {
        QString err = QCoreApplication::translate("imageprovider", "File failed to load, it does not exist!");
        qWarning() << "ERROR:" << err;
        qWarning() << "Filename:" << filenameForChecking;
        return QImage();
    }

    // Load image
    QImage ret;
    PQCLoadImage::get().load(filename, requestedSize, *origSize, ret);

    // if returned image is not an error image ...
    if(ret.isNull())
        return QImage();

    // If enabled we do some color profile management now
    if(PQCSettings::get()["imageviewColorSpaceEnable"].toBool()) {

        // check if a color profile has been set by the user for this file
        QString profileName = PQCScriptsImages::get().getColorProfileFor(filename);

        // we applied a profile, nothing to do further
        bool profileApplied = false;

        // if internal profile is manually selected
        if(profileName.startsWith("::")) {

            int index = profileName.remove(0,2).toInt();

            QList<QColorSpace::NamedColorSpace> integ = PQCScriptsImages::get().getIntegratedColorProfiles();
            if(index < integ.length()) {
                QColorSpace sp = QColorSpace(integ[index]);
                QColorSpace defaultSpace(QColorSpace::SRgb);
                if(sp != defaultSpace) {
                    qDebug() << "Applying color profile:" << sp.description();
                    QImage ret2 = ret.convertedToColorSpace(sp);
                    if(ret2.isNull()) {
                        qWarning() << "Color profile could not be applied, falling back to default";
                    } else {
                        ret = ret2;
                        PQCNotify::get().setColorProfileFor(filename, sp.description());
                        profileApplied = true;
                    }
                }

            }

        }

#ifdef PQMLCMS2

        // if external profile is manually selected
        if(!profileApplied && profileName != "" && !profileName.startsWith("::")) {

            QStringList profileList;
            profileList << PQCScriptsImages::get().getImportedColorProfiles();
            profileList << PQCScriptsImages::get().getExternalColorProfiles();
            int index = profileList.indexOf(profileName);
            cmsHPROFILE targetProfile = nullptr;
            if(index != -1) {

                QFile f(profileName);
                if(f.open(QIODevice::ReadOnly)) {
                    QByteArray bt = f.readAll();
                    targetProfile = cmsOpenProfileFromMem(bt.constData(), bt.size());
                }

                if(targetProfile == nullptr) {

                    qWarning() << "Error creating target color profile:" << profileList[index];

                } else {

                    int lcms2format = PQCScriptsImages::get().toLcmsFormat(ret.format());

                    // Create a transformation from source (sRGB) to destination (provided ICC profile) color space
                    cmsHTRANSFORM transform = cmsCreateTransform(cmsCreate_sRGBProfile(), lcms2format, targetProfile, lcms2format, INTENT_PERCEPTUAL, 0);
                    if (!transform) {
                        // Handle error, maybe close profile and return original image or null image
                        cmsCloseProfile(targetProfile);
                        qWarning() << "Error creating transform for color profile";
                    } else {

                        QImage ret2(ret.size(), ret.format());
                        ret2.fill(Qt::transparent);

                        // Perform color space conversion
                        cmsDoTransform(transform, ret.constBits(), ret2.bits(), ret.width() * ret.height());

                        int bufSize = 100;
                        char buf[bufSize];

                        cmsGetProfileInfoUTF8(targetProfile, cmsInfoDescription,
                                              "en", "US",
                                              buf, bufSize);

                        // Release resources
                        cmsDeleteTransform(transform);
                        cmsCloseProfile(targetProfile);

                        ret = ret2;

                        PQCNotify::get().setColorProfileFor(filename, buf);

                        profileApplied = true;

                    }

                }

            }

        }

        // if no profile has been applied and we need to check for embedded profiles
        if(!profileApplied && PQCSettings::get()["imageviewColorSpaceLoadEmbedded"].toBool()) {

            cmsHPROFILE targetProfile = cmsOpenProfileFromMem(ret.colorSpace().iccProfile().constData(),
                                                              ret.colorSpace().iccProfile().size());
            if(targetProfile) {

                int lcms2format = PQCScriptsImages::get().toLcmsFormat(ret.format());

                // Create a transformation from source (sRGB) to destination (provided ICC profile) color space
                cmsHTRANSFORM transform = cmsCreateTransform(
                    cmsCreate_sRGBProfile(), lcms2format, targetProfile, lcms2format,
                    INTENT_PERCEPTUAL, 0);
                if (!transform) {
                    // Handle error, maybe close profile and return original image or null image
                    cmsCloseProfile(targetProfile);
                    qWarning() << "Error creating transform for color profile";
                } else {

                    int bufSize = 100;
                    char buf[bufSize];

                    cmsGetProfileInfoUTF8(targetProfile, cmsInfoDescription,
                                          "en", "US",
                                          buf, bufSize);

                    PQCNotify::get().setColorProfileFor(filename, buf);

                    QImage ret2(ret.size(), ret.format());
                    ret2.fill(Qt::transparent);

                    // Perform color space conversion
                    cmsDoTransform(transform, ret.constBits(), ret2.bits(), ret.width() * ret.height());

                    // Release resources
                    cmsDeleteTransform(transform);
                    cmsCloseProfile(targetProfile);

                    ret = ret2;

                    profileApplied = true;

                }

            }

        }

#else

        // basic handling of external color profiles

        index -= integ.length();
        QStringList ext = PQCScriptsImages::get().getExternalColorProfiles();
        QColorSpace sp;
        if(index < ext.length()) {
            QFile f(ext[index]);
            if(f.open(QIODevice::ReadOnly))
                sp = QColorSpace::fromIccProfile(f.readAll());
        } else
            sp = QColorSpace(QColorSpace::SRgb);
        QColorSpace defaultSpace(QColorSpace::SRgb);
        if(sp != defaultSpace) {
            qDebug() << "Applying color profile:" << sp.description();
            QImage ret2 = ret.convertedToColorSpace(sp);
            if(ret2.isNull()) {
                qWarning() << "Color profile could not be applied, falling back to sRGB";
            } else {
                ret = ret2;
                PQCNotify::get().setCurrentColorProfile(sp.description());
                profileApplied = true;
            }
        }

#endif

        // no profile (successfully) applied, set default name
        if(!profileApplied)
            PQCNotify::get().setColorProfileFor(filename, QColorSpace(QColorSpace::SRgb).description());

    } else
        // no color profile handling => default profile used
        PQCNotify::get().setColorProfileFor(filename, QColorSpace(QColorSpace::SRgb).description());

    // return scaled version
    if(requestedSize.width() > 2 && requestedSize.height() > 2 && origSize->width() > requestedSize.width() && origSize->height() > requestedSize.height())
        return ret.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    // return full version
    return ret;

}
