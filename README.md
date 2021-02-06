# PhotoQt v2.1.1
__Copyright (C) 2011-2021, Lukas Spies (Lukas@photoqt.org)__  
__License:__ GPLv2 (or later)  
__Website:__ http://photoqt.org  

PhotoQt is a fast and highly configurable image viewer with a simple and nice interface.

***************

## DEPENDENCIES

- Qt >= 5.9
- CMake (needed for building PhotoQt)
- Qt5 ImageFormats

Make sure that you have all the required QML modules installed:  
QtGraphicalEffects, QtMultimedia, QtQuick, QtQuick.Controls, QtQuick.Controls.Styles, QtQuick.Layouts, QtQuick.Window.  

Dependencies, that are needed by default, but can be disabled via CMake:

- LibArchive
- Exiv2
- ImageMagick _or_ GraphicsMagick 
- LibRaw
- Poppler
- FreeImage
- DevIL
- pugixml

Please note that some of these should remain enabled if at all possible as they greatly enhance the experience of PhotoQt (e.g., LibArchive, pugixml). Others can be disabled quite safely with the only effect being the number of supported image formats.

#### NOTE

On some systems you also need the *-dev package for compiling (e.g. exiv2-dev - names can vary slightly depending on your distribution). These packages usually can be uninstalled again after compilation is done.

#### NOTE

PhotoQt can work with either ImageMagick and GraphicsMagick, but due to conflicting naming schemes it is not possible to use both at the same time. By default ImageMagick will be enabled in CMake.

## ADDITIONAL IMAGE FORMATS

These are some libraries and tools that can add additional formats to PhotoQt if installed. None of them are needed at compile time, but they can be picked up at runtime if available.

- KImageFormats - https://api.kde.org/frameworks/kimageformats/html/index.html
- XCFtools - https://github.com/j-jorge/xcftools
- libqpsd - https://github.com/Code-ReaQtor/libqpsd
- unrar

## INSTALL

1. _mkdir build && cd build/_

2. _cmake .._

    \# Note: This installs PhotoQt by default into /usr/local/{bin,share}  
    \# To install PhotoQt into another prefix e.g. /usr/{bin,share}, run:

    _cmake -DCMAKE\_INSTALL\_PREFIX=/usr .._

    \# PhotoQt makes use of various libraries (Exiv2, ImageMagick/GraphicsMagick, etc.).
    \# Many of them are enabled by default but can be disabled using CMake options.

    \# If CMake aborts with the error that it can't find one of the libraries but they are in fact installed and available, then you can specify the location of some of them as:

    _-DMAGICK_LOCATION=/path/to/graphicsmagick_  
    _-DEXIV2_LOCATION=/path/to/exiv2_  
    _-DLIBRAW_LOCATION=/path/to/libraw_  
    _-DFREEIMAGE_LOCATION=/path/to/freeimage_

3. _make_  

    \# This creates an executeable photoqt binary located in the ./build/ folder

4. (as root or sudo) _make install_

    \# This command:  
    1. installs the desktop file to share/applications/  
    2. moves some icons to icons/hicolor/  
    3. moves the binary to bin/
    4. installs the appdata file to share/appdata/

## UNINSTALL

If you want to uninstall PhotoQt, simply run __make uninstall__ as root. This removes the desktop file (via _xdg-desktop-menu uninstall_), the icons, the binary file, and the appdata file. Alternatively you can simply remove all the files manually which should yield the same result.
