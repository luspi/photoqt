#####################################
#####################################

# ONLY THIS VARIABLE SHOULD NEED TO BE CHANGED!

set(testname "pqt_scriptsfilemanagement")

#####################################
#####################################

set(test_SRC "${testname}.h" "${testname}.cpp"
             ${photoqt_testscripts_SOURCES})

qt_add_resources(RESOURCE_FILES ../resources/testing.qrc ../../misc/misc.qrc ../../img/img.qrc ../../img/filetypes.qrc ../../python/python.qrc)
qt_add_executable(${testname} ${test_SRC} ${RESOURCE_FILES})

target_compile_definitions(${testname} PRIVATE PQMTESTING)

add_test(NAME ${testname} COMMAND ${testname})
target_compile_definitions(${testname} PRIVATE PQMVERSION="${APPVERSION}")
target_link_libraries(${testname} PRIVATE Qt6::Quick Qt6::Widgets Qt6::Sql Qt6::Core Qt6::Svg Qt6::Concurrent Qt6::Multimedia Qt6::PrintSupport Qt6::DBus Qt6::Test)
target_include_directories(${testname} PRIVATE "../../cplusplus/header")
target_include_directories(${testname} PRIVATE "../../cplusplus/extensions")

if(NOT _WITH_PUGIXML)
    target_link_libraries(${testname} PRIVATE Qt6::Xml)
endif()

if(_WITH_QTPDF)
    find_package(Qt6 COMPONENTS Pdf)
    target_link_libraries(${testname} PRIVATE Qt6::Pdf)
endif()

target_compile_definitions(${testname} PRIVATE QT_NO_KEYWORDS)
target_compile_definitions(${testname} PRIVATE QT_MESSAGELOGCONTEXT)

if(_WITHOUT_ICU)
    target_compile_definitions(${testname} PRIVATE PQMWITHOUTICU)
endif()


if(_WITH_IMAGEMAGICK)
    target_compile_definitions(${testname} PRIVATE PQMIMAGEMAGICK)
    target_link_libraries(${testname} PRIVATE ImageMagick::Magick++)
endif()

if(_WITH_GRAPHICSMAGICK)
    target_include_directories(${testname} PRIVATE ${MAGICK++_INCLUDE_DIR})
    target_compile_definitions(${testname} PRIVATE PQMGRAPHICSMAGICK)
    target_link_libraries(${testname} PRIVATE "GraphicsMagick++")
endif()

if(_WITH_LIBRAW)
    target_compile_definitions(${testname} PRIVATE PQMRAW)
    target_include_directories(${testname} PRIVATE ${LibRaw_INCLUDE_DIR})
    target_link_libraries(${testname} PRIVATE ${LibRaw_LIBRARIES})
endif()

if(_WITH_DEVIL)
    target_compile_definitions(${testname} PRIVATE PQMDEVIL)
    target_link_libraries(${testname} PRIVATE DevIL::IL)
endif()

if(_WITH_POPPLER)
    target_include_directories(${testname} PRIVATE ${Poppler_INCLUDE_DIRS})
    target_compile_definitions(${testname} PRIVATE PQMPOPPLER)
    target_link_libraries(${testname} PRIVATE ${Poppler_LIBRARIES})
endif()

if(_WITH_QTPDF)
    target_compile_definitions(${testname} PRIVATE PQMQTPDF)
endif()

if(_WITH_LIBARCHIVE)
    target_compile_definitions(${testname} PRIVATE PQMLIBARCHIVE)
    target_link_libraries(${testname} PRIVATE LibArchive::LibArchive)
endif()

if(_WITH_VIDEO_QT)
    target_compile_definitions(${testname} PRIVATE PQMVIDEOQT)
endif()

if(_WITH_VIDEO_MPV)
    SET(photoqt_testscripts_SOURCES ${photoqt_testscripts_SOURCES} ${photoqt_testscripts_SOURCES_LIBMPV})
    target_compile_definitions(${testname} PRIVATE PQMVIDEOMPV)
    target_link_libraries(${testname} PRIVATE Libmpv::Libmpv)
endif()

if(_WITH_LIBVIPS)
    target_compile_definitions(${testname} PRIVATE PQMLIBVIPS)
    target_include_directories(${testname} PRIVATE ${GLIB_INCLUDE_DIRS})
    target_link_libraries(${testname} PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(${testname} PRIVATE "vips")
    target_link_libraries(${testname} PRIVATE "gobject-2.0")
    target_link_libraries(${testname} PRIVATE "vips-cpp")
endif()

if(_WITH_RESVG)
    target_link_libraries(${testname} PRIVATE "resvg")
    target_compile_definitions(${testname} PRIVATE PQMRESVG)
endif()

if(_WITH_EXIV2)
    target_compile_definitions(${testname} PRIVATE PQMEXIV2)
    target_link_libraries(${testname} PRIVATE exiv2lib)
    if(_WITH_EXIV2_ENABLE_BMFF)
        target_compile_definitions(${testname} PRIVATE PQMEXIV2_ENABLE_BMFF)
    endif()
endif()

if(_WITH_PUGIXML)
    target_compile_definitions(${testname} PRIVATE PQMPUGIXML)
    target_link_libraries(${testname} PRIVATE pugixml::pugixml)
endif()

if(_WITH_ZXING)
    target_compile_definitions(${testname} PRIVATE PQMZXING)
    target_link_libraries(${testname} PRIVATE ZXing::ZXing)
endif()

if(_WITH_CHROMECAST)
    target_compile_definitions(${testname} PRIVATE PQMCHROMECAST)
    target_include_directories(${testname} PRIVATE ${Python3_INCLUDE_DIRS})
    target_link_libraries(${testname} PRIVATE ${Python3_LIBRARIES})
endif()

if(_WITH_LOCATION)
    target_compile_definitions(${testname} PRIVATE PQMLOCATION)
endif()

if(_WITH_LCMS2)
    target_include_directories(${testname} PRIVATE ${LCMS2_INCLUDE_DIR})
    target_compile_definitions(${testname} PRIVATE PQMLCMS2)
    target_link_libraries(${testname} PRIVATE ${LCMS2_LIBRARIES})
endif()

if(_WITH_MOTIONPHOTO)
    target_compile_definitions(${testname} PRIVATE PQMMOTIONPHOTO)
endif()

if(_WITH_PHOTOSPHERE)
    target_compile_definitions(${testname} PRIVATE PQMPHOTOSPHERE)
endif()

if(_WITH_EXTENSIONS_SUPPORT)
    target_compile_definitions(${testname} PRIVATE PQMEXTENSIONS)
    target_link_libraries(${testname} PRIVATE yaml-cpp)
endif()
