#include "loadimage_devil.h"

PQLoadImageDevil::PQLoadImageDevil() {
    errormsg = "";
}

QImage PQLoadImageDevil::load(QString filename, QSize maxSize, QSize *origSize) {

#ifdef DEVIL

    errormsg = "";

    // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
    QMutexLocker locker(&PQLoadImageDevilMutex::get().devilMutex);

    // THIS IS CURRENTLY SLIGHTLY HACKY:
    // DevIL loads the image and then writes it to a temporary jpg file.
    // This file is then loaded by Qt's built in image plugin and returned to the user
    // TODO: PASSING IMAGE DIRECTLY FROM DEVIL TO QIMAGE!

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    if(checkForError()) return QImage();

    // load the passed on image file
    ilLoadImage(filename.toStdString().c_str());

    if(checkForError()) return QImage();

    // get the width/height
    const int width  = ilGetInteger(IL_IMAGE_WIDTH);
    const int height = ilGetInteger(IL_IMAGE_HEIGHT);
    *origSize = QSize(width, height);

    if(checkForError()) return QImage();

/*
    // this would be the way to load images directly from DevIL into QImage,
    // but DevIL seems has some issues with being used simultaneously from different threads
    // this *will* make PhotoQt crash often (possibly not always)
    ILubyte *bt = ilGetData();
    if(bt == NULL) LOG << "bt is NULL!!" << NL;
    QImage tmpimg(bt, width, height, QImage::Format_ARGB32);
    if(tmpimg.isNull()) LOG << "QImage is NULL!!" << NL;

    QImage img;

    // If image needs to be scaled down, do so now
    if(maxSize.width() > 5 && maxSize.height() > 5) {
        double q = 1;
        if(width > maxSize.width())
            q = (double)maxSize.width()/(double)width;
        if(height*q > maxSize.height())
            q = (double)maxSize.height()/(double)height;
        img = tmpimg.scaled(width*q, height*q);
    } else
        img = tmpimg.copy();

    ilBindImage(0);
    ilDeleteImages(1, &imageID);
*/

    // This is the temporary file we will load the image into
    QString tempimage = QDir::tempPath() + "/photoqtdevil.bmp";

    // Make sure DevIL can overwrite any previously created file
    ilEnable(IL_FILE_OVERWRITE);

    // Save the decoded image to this temporary file
    if(!ilSaveImage(tempimage.toStdString().c_str())) {
        // If it fails, return error image
        ilBindImage(0);
        ilDeleteImages(1, &imageID);
        checkForError();
        if(errormsg == "") {
            errormsg = "Failed to save image decoded with DevIL!";
            LOG << CURDATE << "PQLoadImageDevIL::load(): " << errormsg.toStdString() << NL;
        }
        return QImage();
    }

    if(checkForError()) return QImage();

    // Create reader for temporary image
    QImageReader reader(tempimage);

    // If image needs to be scaled down, do so now
    if(maxSize.width() > 5 && maxSize.height() > 5) {
        double q = 1;
        if(width > maxSize.width())
            q = (double)maxSize.width()/(double)width;
        if(height*q > maxSize.height())
            q = (double)maxSize.height()/(double)height;
        reader.setScaledSize(reader.size()*q);
    }

    // Clear the DevIL memory
    ilBindImage(0);
    ilDeleteImages(1, &imageID);

    // Return read image file
    QImage img = reader.read();
    QFile(tempimage).remove();

    if(img.isNull() || img.size() == QSize(1,1)) {
        errormsg = "Failed to load image with DevIL (unknown error)!";
        LOG << CURDATE << "PQLoadImageDevIL::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    return img;

#endif

    errormsg = "Failed to load image, DevIL not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImageDevIL::load(): " << errormsg.toStdString() << NL;
    return QImage();

}

#ifdef DEVIL
bool PQLoadImageDevil::checkForError() {
    ILenum err_enum = ilGetError();
    while(err_enum != IL_NO_ERROR) {
        if(errormsg == "") errormsg = "Error: ";
        else errormsg += ", ";
        errormsg += QString::number(err_enum);
        err_enum = ilGetError();
    }
    if(errormsg != "") {
        LOG << CURDATE << "PQLoadImageDevIL::load(): " << errormsg.toStdString() << NL;
        return true;
    }
    return false;
}
#endif
