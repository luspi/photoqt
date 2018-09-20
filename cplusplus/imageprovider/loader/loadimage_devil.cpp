#include "loader.h"

QImage PLoadImage::DevIL(QString filename, QSize maxSize) {

#ifdef DEVIL

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageQt: Load image using Qt: " << QFileInfo(filename).fileName().toStdString() << NL;

    // THIS IS CURRENTLY SLIGHTLY HACKY:
    // DevIL loads the image and then writes it to a temporary jpg file.
    // This file is then loaded by Qt's built in image plugin and returned to the user
    // TODO: PASSING IMAGE DIRECTLY FROM DEVIL TO QIMAGE!

    // Create an image id and make current
    ILuint imageID;
    ilGenImages(1, &imageID);
    ilBindImage(imageID);

    // load the passed on image file
    ilLoadImage(filename.toStdString().c_str());

    // get the width/height
    int const width  = ilGetInteger(IL_IMAGE_WIDTH);
    int const height = ilGetInteger(IL_IMAGE_HEIGHT);

    // This is the temporary file we will load the image into
    QString tempimage = QDir::tempPath() + "/photoqtdevil.bmp";

    // Make sure DevIL can overwrite any previously created file
    ilEnable(IL_FILE_OVERWRITE);

    // Save the decoded image to this temporary file
    if(!ilSaveImage(tempimage.toStdString().c_str())) {
        // If it fails, return error image
        ilBindImage(0);
        ilDeleteImages(1, &imageID);
        PErrorImage::load("Failed to save image decoded with DevIL!");
    }

    // Create reader for temporary image
    QImageReader reader(tempimage);

    // If image needs to be scaled down, do so now
    if(maxSize.width() > 5 && maxSize.height() > 5) {
        if(width > maxSize.width() || height > maxSize.height())
            reader.setScaledSize(maxSize);
    }

    // Clear the DevIL memory
    ilBindImage(0);
    ilDeleteImages(1, &imageID);

    // Return read image file
    QImage img = reader.read();
    QFile(tempimage).remove();

    if(img.isNull() || img.size() == QSize(1,1))
        return PErrorImage::load("Failed to load image with DevIL!");

    return img;

#else
    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "LoadImageDevil: PhotoQt was compiled without DevIL support, returning error image" << NL;
    return PErrorImage::load("Failed to load image, DevIL not supported by this build of PhotoQt!");
#endif

}
