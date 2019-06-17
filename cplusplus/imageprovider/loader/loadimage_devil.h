#include <QFile>
#include <QImageReader>
#include <QMutexLocker>

#ifdef DEVIL
#include <IL/il.h>
#endif

#include "../../logger.h"
#include "../../variables.h"

namespace PQLoadImage {

    namespace DevIL {

        static QString errormsg = "";

        static QImage load(QString filename, QSize maxSize, QSize *origSize) {

    #ifdef DEVIL

            // DevIL is NOT threadsafe -> need to ensure only one image is loaded at a time...
            QMutexLocker locker(&PQVariables::get().devilMutex);

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
            const int width  = ilGetInteger(IL_IMAGE_WIDTH);
            const int height = ilGetInteger(IL_IMAGE_HEIGHT);
            *origSize = QSize(width, height);

            // This is the temporary file we will load the image into
            QString tempimage = QDir::tempPath() + "/photoqtdevil.bmp";

            // Make sure DevIL can overwrite any previously created file
            ilEnable(IL_FILE_OVERWRITE);

            // Save the decoded image to this temporary file
            if(!ilSaveImage(tempimage.toStdString().c_str())) {
                // If it fails, return error image
                ilBindImage(0);
                ilDeleteImages(1, &imageID);
                errormsg = "Failed to save image decoded with DevIL!";
                return QImage();
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

            if(img.isNull() || img.size() == QSize(1,1)) {
                errormsg = "Failed to load image with DevIL!";
                return QImage();
            }

            return img;

#endif

            errormsg = "Failed to load image with DevIL!";
            return QImage();

        }

    }

}
