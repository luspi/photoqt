function(composeDesktopFile)

    file(WRITE  "photoqt.desktop" "[Desktop Entry]\n")
    file(APPEND "photoqt.desktop" "Name=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[ca]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[cs]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[de]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[es]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[fr]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[nl]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[sr]=ФотоQт\n")
    file(APPEND "photoqt.desktop" "Name[sr@ijekavian]=ФотоQт\n")
    file(APPEND "photoqt.desktop" "Name[sr@ijekavianlatin]=FotoQt\n")
    file(APPEND "photoqt.desktop" "Name[sr@latin]=FotoQt\n")
    file(APPEND "photoqt.desktop" "GenericName=Image Viewer\n")
    file(APPEND "photoqt.desktop" "GenericName[ca]=Visor d'imatges\n")
    file(APPEND "photoqt.desktop" "GenericName[cs]=Prohlížeč obrázků\n")
    file(APPEND "photoqt.desktop" "GenericName[de]=Bildbetrachter\n")
    file(APPEND "photoqt.desktop" "GenericName[es]=Visor de imagenes\n")
    file(APPEND "photoqt.desktop" "GenericName[fr]=Visualisateur d'images\n")
    file(APPEND "photoqt.desktop" "GenericName[nl]=Afbeeldingen-viewer\n")
    file(APPEND "photoqt.desktop" "GenericName[sr]=Приказивач слика\n")
    file(APPEND "photoqt.desktop" "GenericName[sr@ijekavian]=Приказивач слика\n")
    file(APPEND "photoqt.desktop" "GenericName[sr@ijekavianlatin]=Prikazivač slika\n")
    file(APPEND "photoqt.desktop" "GenericName[sr@latin]=Prikazivač slika\n")
    file(APPEND "photoqt.desktop" "Comment=View and manage images\n")
    file(APPEND "photoqt.desktop" "Comment[ca]=Visualitza i gestiona imatges\n")
    file(APPEND "photoqt.desktop" "Comment[cs]=Prohlížet and spravovat obrázky\n")
    file(APPEND "photoqt.desktop" "Comment[de]=Betrachte und manage Bilder\n")
    file(APPEND "photoqt.desktop" "Comment[es]=Visualizar y gestionar imágenes\n")
    file(APPEND "photoqt.desktop" "Comment[fr]=Voir et gérer des images\n")
    file(APPEND "photoqt.desktop" "Comment[nl]=Bekijk en beheer afbeeldingen\n")
    file(APPEND "photoqt.desktop" "Comment[sr]=Приказује и управља сликама\n")
    file(APPEND "photoqt.desktop" "Comment[sr@ijekavian]=Приказује и управља сликама\n")
    file(APPEND "photoqt.desktop" "Comment[sr@ijekavianlatin]=Prikazuje i upravlja slikama\n")
    file(APPEND "photoqt.desktop" "Comment[sr@latin]=Prikazuje i upravlja slikama\n")
    file(APPEND "photoqt.desktop" "Exec=photoqt %f\n")
    file(APPEND "photoqt.desktop" "Icon=photoqt\n")
    file(APPEND "photoqt.desktop" "Type=Application\n")
    file(APPEND "photoqt.desktop" "Terminal=false\n")
    file(APPEND "photoqt.desktop" "Categories=Graphics;Viewer;\n")


    # this string will hold all the mime types to be added to desktop file
    set(COMBINEDMIMETYPE "")

    ##########################
    # QT mime types
    set(QTMIME "image/bmp;image/gif;image/jp2;video/x-mng;image/vnd.microsoft.icon;image/x-win-bitmap;image/x-icns;image/jpeg;image/png;")
    set(QTMIME "${QTMIME};image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-portable-anymap;image/svg+xml;image/tiff;")
    set(QTMIME "${QTMIME};image/vnd.wap.wbmp;image/x-xbitmap;image/x-xpixmap;image/x-sgi;image/webp;image/bmp")
    foreach(MIME ${QTMIME})
        list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
        if(${FOUNDPOS} MATCHES -1)
            list(APPEND COMBINEDMIMETYPE ${MIME})
        endif(${FOUNDPOS} MATCHES -1)
    endforeach()

    ##########################
    # KDE mime types
    set(KDEMIME "image/x-eps;image/x-exr;image/openraster;image/vnd.zbrush.pcx;image/vnd.adobe.photoshop;image/x-tga;image/x-xcf;")
    foreach(MIME ${KDEMIME})
        list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
        if(${FOUNDPOS} MATCHES -1)
            list(APPEND COMBINEDMIMETYPE ${MIME})
        endif(${FOUNDPOS} MATCHES -1)
    endforeach()

    ##########################
    # POPPLER mime types
    set(POPPLERMIME "application/pdf")
    if(POPPLER)
        list(FIND COMBINEDMIMETYPE "${POPPLERMIME}" FOUNDPOS)
        if(${FOUNDPOS} MATCHES -1)
            list(APPEND COMBINEDMIMETYPE ${POPPLERMIME})
        endif(${FOUNDPOS} MATCHES -1)
    endif(POPPLER)

    ##########################
    # GRAPHICSMAGICK mime types
    set(GMMIME "image/bmp;image/rle;image/x-cmu-raster;application/dicom;image/dpx;image/fax-g3;image/fits;image/gif;image/x-jng;image/jp2;")
    set(GMMIME "${GMMIME};image/jpeg;application/x-mif;video/x-mng;image/x-portable-bitmap;image/x-photo-cd;image/vnd.zbrush.pcx;")
    set(GMMIME "${GMMIME};image/x-portable-graymap;image/x-xpixmap;image/x-portable-pixmap;image/x-portable-anymap;image/x-pict;")
    set(GMMIME "${GMMIME};image/png;audio/vnd.dts.hd;text/x-mpsub;image/rle;image/x-sgi;image/x-sun-raster;image/x-tga;image/tiff;")
    set(GMMIME "${GMMIME};image/vnd.wap.wbmp;image/webp;application/x-wpg;image/x-xbitmap;image/x-xpixmap;image/x-xwindowdump")
    if(GM)
        foreach(MIME ${GMMIME})
            list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
            if(${FOUNDPOS} MATCHES -1)
                list(APPEND COMBINEDMIMETYPE ${MIME})
            endif(${FOUNDPOS} MATCHES -1)
        endforeach()
    endif(GM)

    ##########################
    # RAW mime types
    set(RAWMIME "image/x-sony-arw;image/x-sony-sr2;image/x-canon-crw;image/x-canon-cr2;image/x-kodak-dcr;image/x-kodak-kdc;image/x-adobe-dng;")
    set(RAWMIME "${RAWMIME};image/x-kde-raw;image/x-minolta-mrw;image/x-nikon-nef;image/x-olympus-orf;image/x-pentax-pef;image/x-fuji-raf;")
    set(RAWMIME "${RAWMIME};image/x-panasonic-rw2;image/x-panasonic-rw;image/x-adobe-dng;image/x-sigma-x3f")
    if(RAW)
        foreach(MIME ${RAWMIME})
            list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
            if(${FOUNDPOS} MATCHES -1)
                list(APPEND COMBINEDMIMETYPE ${MIME})
            endif(${FOUNDPOS} MATCHES -1)
        endforeach()
    endif(RAW)

    ##########################
    # DEVIL mime types
    set(DEVILMIME "image/bmp;image/x-dds;image/x-exr;image/fits;image/x-hdr;image/x-icns;image/vnd.microsoft.icon;image/x-win-bitmap;image/x-ilbm;")
    set(DEVILMIME "${DEVILMIME};image/gif;image/jpeg;image/x-photo-cd;image/png;image/x-portable-bitmap;image/x-portable-graymap;")
    set(DEVILMIME "${DEVILMIME};image/x-portable-pixmap;image/x-portable-anymap;image/vnd.adobe.photoshop;image/x-panasonic-rw;image/x-sgi;")
    set(DEVILMIME "${DEVILMIME};image/x-tga;image/tiff")
    if(DEVIL)
        foreach(MIME ${DEVILMIME})
            list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
            if(${FOUNDPOS} MATCHES -1)
                list(APPEND COMBINEDMIMETYPE ${MIME})
            endif(${FOUNDPOS} MATCHES -1)
        endforeach()
    endif(DEVIL)

    ##########################
    # FREEIMAGE mime types
    set(FREEMIME "image/bmp;image/x-dds;image/fax-g3;image/gif;image/vnd.microsoft.icon;image/x-ilbm;image/x-jng;image/jpeg;image/jp2;")
    set(FREEMIME "${FREEMIME};image/x-photo-cd;video/x-mng;image/vnd.zbrush.pcx;image/x-portable-bitmap;image/x-portable-graymap;")
    set(FREEMIME "${FREEMIME};image/x-portable-pixmap;image/x-portable-anymap;image/png;image/x-pict;image/vnd.adobe.photoshop;image/x-sun-raster;")
    set(FREEMIME "${FREEMIME};image/x-sgi;image/x-tga;image/tiff;image/vnd.wap.wbmp;image/webp;image/x-xbitmap;image/x-xpixmap")
    if(FREEIMAGE)
        foreach(MIME ${FREEMIME})
            list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
            if(${FOUNDPOS} MATCHES -1)
                list(APPEND COMBINEDMIMETYPE ${MIME})
            endif(${FOUNDPOS} MATCHES -1)
        endforeach()
    endif(FREEIMAGE)

    # ... and add to file
    file(APPEND "photoqt.desktop" "MimeType=${COMBINEDMIMETYPE};")

endfunction()

