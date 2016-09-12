# PhotoQt v1.4.1.1
__Copyright (C) 2016, Lukas Spies (Lukas@photoqt.org)
License: GPLv2 (or later)
Website: http://photoqt.org__

PhotoQt is a fast and highly configurable image viewer with a simple and nice interface.

***************

## DEPENDENCIES

- Qt >= 5.3
- CMake (needed for building PhotoQt)

Make sure that you have the needed Qt modules installed:  
QtQuick, QtQuick.Controls, QtQuick.Controls.Styles, QtQuick.Dialogs, QtQuick.Layouts, QtQuick.Window, QtQml.Models, Qt.labs.folderlistmodel, QtGraphicalEffects, QtMultimedia.  
Dependencies, that are needed by default, but can be disabled via CMake

- Exiv2
- GraphicsMagick
- LibRaw

#### NOTE

On some systems you also need the *-dev package for compiling (e.g. exiv2-dev - names can vary slightly depending on your distribution). These files usually can be uninstalled again after compilation is done.

#### NOTE

Even though GraphicsMagick initially started as a fork of ImageMagick (in 2002), trying to build PhotoQt with ImageMagick wont work!

## OPTIONAL DEPENDENCIES

- XCFtools - https://github.com/j-jorge/xcftools
- libqpsd - https://github.com/Code-ReaQtor/libqpsd

These dependencies are not needed for compiling PhotoQt. However, if they are installed, you can set PhotoQt (via settings) to make use of them for improved XCF/PSD support.

## INSTALL

1. _cd build/_

2. _cmake .._

	 \# Note: This installs PhotoQt by default into /usr/local/{bin,share}  
	 \# To install PhotoQt into another prefix e.g. /usr/{bin,share}, run:

    _cmake -DCMAKE\_INSTALL\_PREFIX=/usr .._

	 \# PhotoQt makes use of the libraries Exiv2, GraphicsMagick ("gm") and LibRaw.  
	 \# You can en-/disable them with the following options:  
	 \# (if you don't specify anything, it asumes a value of ON)

	 _-DEXIV2=OFF_  
	 _-DGM=OFF_  
	 _-DRAW=OFF_

	 \# You can combine them in any way you want.  
	 \# The following option equates to setting the two above options to OFF

	 _-DQTONLY=ON_

	 \# If CMake aborts with the error that it can't find Exiv2 and/or GraphicsMagick and/or LibRaw,  
	 \# but you're certain that the header files are available, then  
	 \# you can pass their locations to CMake:

	 _-DMAGICK_LOCATION=/path/to/graphicsmagick_  
     _-DEXIV2_LOCATION=/path/to/exiv2_  
     _-DLIBRAW_LOCATION=/path/to/libraw_

3. _make_  
	 \# This creates an executeable photoqt binary located in the ./build/ folder

4. (as root or sudo) _make install_

	 \# This command:  
	 1. installs the desktop file to share/applications/  
	 2. moves some icons to icons/hicolor/  
	 3. moves the binary to bin/

## UNINSTALL

If you want to uninstall PhotoQt, simply run __make uninstall__ as root. This removes the desktop file (via _xdg-desktop-menu uninstall_), the icons and the binary file. Alternatively you can simply remove all the files manually, that should yield the same result.
