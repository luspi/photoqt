# PhotoQt v2.0
__Copyright (C) 2011-2020, Lukas Spies (Lukas@photoqt.org)
License: GPLv2 (or later)
Website: http://photoqt.org__

PhotoQt is a fast and highly configurable image viewer with a simple and nice interface.

***************

## DEPENDENCIES

- Qt >= 5.9
- CMake (needed for building PhotoQt)
- libarchive
- Qt5 ImageFormats

Make sure that you have the required QML modules installed:  
QtGraphicalEffects, QtMultimedia, QtQuick, QtQuick.Controls, QtQuick.Controls.Styles, QtQuick.Layouts, QtQuick.Window.  
Dependencies, that are needed by default, but can be disabled via CMake

- Exiv2
- GraphicsMagick
- LibRaw
- Poppler
- FreeImage
- DevIL
- pugixml

#### NOTE

On some systems you also need the *-dev package for compiling (e.g. exiv2-dev - names can vary slightly depending on your distribution). These files usually can be uninstalled again after compilation is done.

#### NOTE

Even though GraphicsMagick initially started as a fork of ImageMagick (back in 2002), trying to build PhotoQt with ImageMagick wont currently work!

## OPTIONAL DEPENDENCIES

- KImageFormats - https://api.kde.org/frameworks/kimageformats/html/index.html
- XCFtools - https://github.com/j-jorge/xcftools
- libqpsd - https://github.com/Code-ReaQtor/libqpsd
- unrar

These dependencies are not needed for compiling PhotoQt. However, if they are installed then PhotoQt is able to support a wider range of image formats.

## INSTALL

1. _mkdir build && cd build/_

2. _cmake .._

    \# Note: This installs PhotoQt by default into /usr/local/{bin,share}  
    \# To install PhotoQt into another prefix e.g. /usr/{bin,share}, run:

    _cmake -DCMAKE\_INSTALL\_PREFIX=/usr .._

    \# PhotoQt makes use of various libraries (Exiv2, GraphicsMagick, etc.).
    \# You can en-/disable them with the following options:  
    \# (if you don't specify anything, it asumes a value of ON)

    _-DEXIV2=OFF_  
    _-DGRAPHICSMAGICK=OFF_  
    _-DRAW=OFF_  
    _-DPOPPLER=OFF_  
    _-DFREEIMAGE=OFF_  
    _-DDEVIL=OFF_

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
