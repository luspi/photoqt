# PhotoQt vdev
__Copyright (C) 2011-2022, Lukas Spies (Lukas@photoqt.org)__  
__License:__ GPLv2 (or later)  
__Website:__ https://photoqt.org  

PhotoQt is a fast and highly configurable image viewer with a simple and nice interface.

PhotoQt is available in the repositories of an increasing number of Linux distributions, and can also be installed in several other ways (Windows installer, Flatpak, etc.). [Check the website](https://photoqt.org/down) to get more information on that, or see below for instructions about how to build PhotoQt from scratch.

***************

## DEPENDENCIES

- Qt >= 5.9
- CMake (needed for building PhotoQt)
- Qt5 ImageFormats

Make sure that you have all the required QML modules installed:  
QtGraphicalEffects, QtMultimedia, QtQuick, QtQuick.Controls, QtQuick.Controls.Styles, QtQuick.Layouts, QtQuick.Window.  

Dependencies that are needed by default, but can be disabled via CMake:

- LibArchive
- Exiv2
- ImageMagick _or_ GraphicsMagick 
- LibRaw
- Poppler
- LibVips
- FreeImage
- DevIL
- pugixml
- Python (incl. pychromecast package)

Dependencies that are disabled by default, but can be enabled via CMake:

- libvips
- libmpv


Please note that you probably want to have as many of these enabled as possible as they greatly enhance the experience of PhotoQt.

#### NOTE

On some systems you also need the *-dev package for compiling (e.g. exiv2-dev - names can vary slightly depending on your distribution). These packages usually can be uninstalled again after compilation is done.

#### NOTE

PhotoQt can work with either ImageMagick and GraphicsMagick, but due to conflicting naming schemes it is not possible to use both at the same time. By default ImageMagick will be enabled in CMake.

## ADDITIONAL IMAGE FORMATS

These are some libraries and tools that can add additional formats to PhotoQt if installed. None of them are needed at compile time, but they can be picked up at runtime if available.

- KImageFormats - https://api.kde.org/frameworks/kimageformats/html/index.html
- Qt plug-in for AVIF images - https://github.com/novomesk/qt-avif-image-plugin
- Qt plug-in for JPEG XL images - https://github.com/novomesk/qt-jpegxl-image-plugin
- Qt plug-in for HEIF/HEIC images - https://github.com/novomesk/qt-heic-image-plugin
- XCFtools - https://github.com/j-jorge/xcftools
- libqpsd - https://github.com/Code-ReaQtor/libqpsd
- unrar

## INSTALL

1. _mkdir build && cd build/_

2. _cmake .._

    \# Note: This installs PhotoQt by default into /usr/local/{bin,share}  
    \# To install PhotoQt into another prefix e.g. /usr/{bin,share}, run:

    _cmake -DCMAKE\_INSTALL\_PREFIX=/usr .._

    \# At this step you can also en-/disable any compile time features.

3. _make_  

    \# This creates an executeable photoqt binary located in the ./build/ folder

4. (as root or sudo) _make install_

    \# This command:  
    1. installs the desktop file to share/applications/  
    2. moves some icons to icons/hicolor/  
    3. moves the binary to bin/
    4. installs the metainfo file to share/metainfo/

## UNINSTALL

If you want to uninstall PhotoQt, simply run __make uninstall__ as root. This removes the desktop file (via _xdg-desktop-menu uninstall_), the icons, the binary file, and the metainfo file. Alternatively you can simply remove all the files manually which should yield the same result.

## BUILDING ON WINDOWS

PhotoQt offers installers for pre-built binaries on its website: https://photoqt.org/downpopupwindows

If you prefer to build it yourself, this process is not as hard as it might seem at first. The main challenge in building PhotoQt on Windows lies in getting the environment set up and all dependencies installed.

The following are required dependencies:

1. Install Visual Studio 2019 Community Edition (free, be sure to install the 'Desktop Development with C++' workload)
    - Website: https://visualstudio.microsoft.com/
2. Install CMake
    - Website: https://cmake.org/
    - In the installer set the system path option to Add CMake to the system PATH for all users
3. Install Qt 5.15
    - Website: https://qt.io
    - In the installer, make sure to install all required modules as listed above under dependencies
    - After installation, confirm that your installation of Qt finds both CMake and the compiler installed in steps 1 and 2

The following dependencies are recommended but can be disabled through CMake if not wanted:

1. LibArchive: https://libarchive.org/
2. Exiv2: https://exiv2.org/
3. ImageMagick: https://imagemagick.org/
4. LibRaw: https://www.libraw.org/
5. pugixml: https://pugixml.org/
6. Poppler: https://poppler.freedesktop.org/
7. FreeImage: https://freeimage.sourceforge.io/
8. DevIL: http://openil.sourceforge.net/

Make sure that any installed dependency is added to the system path, or otherwise you need to explicitely point CMake to the right location for each of them. Regardless, CMake might have to be explicitely pointed to the library/include paths of some of the dependencies by specifying `target_include_directories()` and `target_link_libraries()`.

Once all the requried and desired dependencies are installed, then the source code of PhotoQt can be fetched from the website (https://photoqt.og/down). One way to build PhotoQt is to load it in the IDE QtCreator that is part of the Qt installation.
