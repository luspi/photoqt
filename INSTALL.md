# Installing PhotoQt

The instructions below serve as a guide to compile and install PhotoQt from source. PhotoQt is available in the repositories of an increasing number of Linux distributions. In addition, various means of installing PhotoQt (Windows installer, Flatpak, etc.) are listed on the website at [PhotoQt.org/down](https://photoqt.org/down).

## DEPENDENCIES

- Qt >= 6.4 (6.5 or higher recommended)
- CMake (needed for building PhotoQt)
- Qt6 ImageFormats

Make sure that you have all the required QML modules installed:
QtGraphicalEffects, QtMultimedia, QtQuick, QtQuick.Controls, QtQuick.Controls.Styles, QtQuick.Layouts, QtQuick.Window, QtLocation, QtPositioning, QtCharts.

Dependencies that are needed by default, but can be disabled via CMake:

- [yaml-cpp](https://github.com/jbeder/yaml-cpp)
- [QCA (with rsa/openssl support)](https://invent.kde.org/libraries/qca)
- [LibArchive](https://libarchive.org)
- [Exiv2](https://exiv2.org)
- [ImageMagick](https://imagemagick.org) *or* [GraphicsMagick](http://www.graphicsmagick.org/)
- [LibRaw](https://www.libraw.org)
- [Poppler](https://poppler.freedesktop.org) (can be replaced by QtPDF)
- [FreeImage](https://freeimage.sourceforge.io)
- [DevIL](http://openil.sourceforge.net)
- [pugixml](https://pugixml.org)
- [libmpv](https://mpv.io/)
- [Python](https://www.python.org/) (incl. [pychromecast](https://pypi.org/project/PyChromecast/) package)
- [ZXing-C++](https://github.com/zxing-cpp/zxing-cpp/)
- [LittleCMS](https://littlecms.com/)

Dependencies that are disabled by default, but can be enabled via CMake:

- [LibVips](https://www.libvips.org/)
- [resvg](https://github.com/RazrFalcon/resvg)


Please note that you probably want to have as many of these enabled as possible as they greatly enhance the experience of PhotoQt.

#### NOTE

On some systems you also need the *-dev package for compiling (e.g. exiv2-dev - names can vary slightly depending on your distribution). These packages usually can be uninstalled again after compilation is done.

#### NOTE

PhotoQt can work with either ImageMagick and GraphicsMagick, but due to conflicting naming schemes it is not possible to use both at the same time. By default ImageMagick will be enabled in CMake.

#### NOTE

Exiv2 can be compiled with support for the BMFF format. Note that there is the possibility that BMFF support may be the subject of patent rights. PhotoQt will by default opt-in to reading this format (if supported by Exiv2). If you prefer to not include support for this format in PhotoQt simply set the `EXIV2_ENABLE_BMFF` CMake option to `OFF`.

## ADDITIONAL IMAGE FORMATS

These are some libraries and tools that can add additional formats to PhotoQt if installed. None of them are needed at compile time, but they can be picked up at runtime if available.

- [KImageFormats](https://api.kde.org/frameworks/kimageformats/html/)
- [Qt plug-in for AVIF images](https://github.com/novomesk/qt-avif-image-plugin)
- [Qt plug-in for JPEG XL images](https://github.com/novomesk/qt-jpegxl-image-plugin)
- [Qt plug-in for HEIF/HEIC images](https://github.com/novomesk/qt-heic-image-plugin)
- [XCFtools](https://github.com/j-jorge/xcftools)
- [libqpsd](https://github.com/Code-ReaQtor/libqpsd)
- [unrar](https://www.rarlab.com/)

## BUILDING AND INSTALLING

1. _mkdir build && cd build/_

2. _cmake .._

    \# Note: This installs PhotoQt by default into /usr/local/{bin,share}  
    \# To install PhotoQt into another prefix e.g. /usr/{bin,share}, run:

    _cmake -DCMAKE\_INSTALL\_PREFIX=/usr .._

    \# At this step you can also en-/disable any compile time features.

3. _make_

    \# This creates an executable photoqt binary located in the ./build/ folder

4. (as root or sudo) _make install_

    \# This command:  
    \# 1. is only required if you want to **install** PhotoQt  
    \# 2. installs the desktop file to share/applications/  
    \# 3. moves some icons to icons/hicolor/  
    \# 4. moves the binary to bin/  
    \# 5. installs the metainfo file to share/metainfo/

## UNINSTALL

If you want to uninstall PhotoQt, simply run __make uninstall__ as root. This removes the desktop file (via _xdg-desktop-menu uninstall_), the icons, the binary file, and the metainfo file. Alternatively you can simply remove all the files manually which should yield the same result.

## BUILDING ON WINDOWS

PhotoQt offers installers for pre-built binaries on its website: https://photoqt.org/downpopupwindows

If you prefer to build it yourself, this process is not as hard as it might seem at first. The main challenge in building PhotoQt on Windows lies in getting the environment set up and all dependencies installed.

The following are required dependencies:

1. Install Visual Studio 2022 Community Edition (free, be sure to install the 'Desktop Development with C++' workload)
    - Website: https://visualstudio.microsoft.com/
2. Install CMake
    - Website: https://cmake.org/
    - In the installer set the system path option to Add CMake to the system PATH for all users
3. Install Qt 6.4 (6.5+ recommended)
    - Website: https://qt.io
    - In the installer, make sure to install all required modules as listed above under dependencies
    - After installation, confirm that your installation of Qt finds both CMake and the compiler installed in steps 1 and 2

The following dependencies are recommended but can be disabled through CMake if not wanted:

1. [yaml-cpp](https://github.com/jbeder/yaml-cpp)
2. [QCA (with rsa/openssl support)](https://invent.kde.org/libraries/qca)
3. [LibArchive](https://libarchive.org)
4. [Exiv2](https://exiv2.org)
5. [ImageMagick](https://imagemagick.org)
6. [LibRaw](https://www.libraw.org)
7. [pugixml](https://pugixml.org)
8. [Poppler](https://poppler.freedesktop.org) (can be replaced by QtPDF)
9. [FreeImage](https://freeimage.sourceforge.io)
10. [DevIL](http://openil.sourceforge.net)
11. [ZXing-C++](https://github.com/zxing-cpp/zxing-cpp/)
12. [LittleCMS](https://littlecms.com/)

One easy way to get many of the dependencies is by taking advantage of [vcpkg](https://vcpkg.io/). A sample `vcpkg.conf` can be found in the `windows/` subfolder.

Whatever way you obtain the dependencies, make sure that any installed dependency can be found by CMake. It might have to be explicitly pointed to the library/include paths of  some of the dependencies by specifying `target_include_directories()` and  `target_link_libraries()`.

Once all the required and desired dependencies are installed, then the source code of PhotoQt can be fetched from the website (https://photoqt.og/down). Then simply follow the instructions in the `BUILDING AND INSTALLING` section above
