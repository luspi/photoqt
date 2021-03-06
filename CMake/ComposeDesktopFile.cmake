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
    set(QTMIME "image/x-ms-bmp;image/bmp;image/x-win-bitmap;image/x-exr;image/gif;image/jp2;image/jpx;image/jpm;image/jpeg;video/x-mng")
    set(QTMIME "${QTMIME};image/openraster;image/x-portable-anymap;image/vnd.zbrush.pcx;image/x-pcx;image/x-portable-anymap;image/x-portable-greymap")
    set(QTMIME "${QTMIME};image/png;image/x-portable-anymap;image/x-portable-pixmap;image/vnd.adobe.photoshop;image/sgi;image/x-targa;image/x-tga")
    set(QTMIME "${QTMIME};image/tiff;image/tiff-fx;image/vnd.wap.wbmp;image/x-xbitmap;image/x-xbm;image/webp;image/vnd.microsoft.icon;image/x-icon")
    set(QTMIME "${QTMIME};image/x-xpixmap;image/x-xpmi;image/avif;image/avif-sequence")
    foreach(MIME ${QTMIME})
        list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
        if(${FOUNDPOS} MATCHES -1)
            list(APPEND COMBINEDMIMETYPE ${MIME})
        endif(${FOUNDPOS} MATCHES -1)
    endforeach()

    ##########################
    # GRAPHICSMAGICK mime types (not covered by Qt)
    set(GMMIME "application/x-fpt;image/x-ms-bmp;image/bmp;application/dicom;image/dicom-rle;image/x-dpx;image/fits;application/vnd.ms-office")
    set(GMMIME "${GMMIME};application/x-pnf;video/x-jng;image/x-miff;image/x-portable-arbitrarymap;image/x-portable-pixmap;image/x-xpmi;image/tiff")
    set(GMMIME "${GMMIME};image/bpg;image/x-canon-cr2;image/x-canon-crw;image/vnd.djvu;image/heic;image/heif;image/x-olympus-orf;image/x-pentax-pef;image/x-mvg")
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
    # DEVIL mime types (not covered by Qt)
    set(DEVILMIME "application/dicom;image/dicom-rle;image/fits")
    if(DEVIL)
        foreach(MIME ${DEVILMIME})
            list(FIND COMBINEDMIMETYPE "${MIME}" FOUNDPOS)
            if(${FOUNDPOS} MATCHES -1)
                list(APPEND COMBINEDMIMETYPE ${MIME})
            endif(${FOUNDPOS} MATCHES -1)
        endforeach()
    endif(DEVIL)

    ##########################
    # FREEIMAGE mime types (not covered by Qt)
    set(FREEMIME "application/x-pnf;video/x-jng")
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

