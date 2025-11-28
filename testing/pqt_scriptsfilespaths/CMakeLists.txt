#####################################
#####################################

# ONLY THIS VARIABLE SHOULD NEED TO BE CHANGED!

set(testname "pqt_scriptsfilespaths")

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

if(WITH_QTPDF)
    find_package(Qt6 COMPONENTS Pdf)
    target_link_libraries(${testname} PRIVATE Qt6::Pdf)
endif()

target_compile_definitions(${testname} PRIVATE QT_NO_KEYWORDS)
target_compile_definitions(${testname} PRIVATE QT_MESSAGELOGCONTEXT)

if(WITHOUT_ICU)
    target_compile_definitions(${testname} PRIVATE PQMWITHOUTICU)
endif()


if(WITH_IMAGEMAGICK)
    target_compile_definitions(${testname} PRIVATE PQMIMAGEMAGICK)
    target_link_libraries(${testname} PRIVATE ImageMagick::Magick++)
endif()

if(WITH_GRAPHICSMAGICK)
    target_include_directories(${testname} PRIVATE ${MAGICK++_INCLUDE_DIR})
    target_compile_definitions(${testname} PRIVATE PQMGRAPHICSMAGICK)
    target_link_libraries(${testname} PRIVATE "GraphicsMagick++")
endif()

if(WITH_LIBRAW)
    target_compile_definitions(${testname} PRIVATE PQMRAW)
    target_include_directories(${testname} PRIVATE ${LibRaw_INCLUDE_DIR})
    target_link_libraries(${testname} PRIVATE ${LibRaw_LIBRARIES})
endif()

if(WITH_DEVIL)
    target_compile_definitions(${testname} PRIVATE PQMDEVIL)
    target_link_libraries(${testname} PRIVATE DevIL::IL)
endif()

if(WITH_FREEIMAGE)
    target_include_directories(${testname} PRIVATE ${FREEIMAGE_INCLUDE_DIRS})
    target_compile_definitions(${testname} PRIVATE PQMFREEIMAGE)
    target_link_libraries(${testname} PRIVATE ${FREEIMAGE_C_LIBRARY})
endif()

if(WITH_POPPLER)
    target_include_directories(${testname} PRIVATE ${Poppler_INCLUDE_DIRS})
    target_compile_definitions(${testname} PRIVATE PQMPOPPLER)
    target_link_libraries(${testname} PRIVATE ${Poppler_LIBRARIES})
endif()

if(WITH_QTPDF)
    target_compile_definitions(${testname} PRIVATE PQMQTPDF)
endif()

if(WITH_LIBARCHIVE)
    target_compile_definitions(${testname} PRIVATE PQMLIBARCHIVE)
    target_link_libraries(${testname} PRIVATE LibArchive::LibArchive)
endif()

if(WITH_VIDEO_QT)
    target_compile_definitions(${testname} PRIVATE PQMVIDEOQT)
endif()

if(WITH_VIDEO_MPV)
    target_compile_definitions(${testname} PRIVATE PQMVIDEOMPV)
    target_link_libraries(${testname} PRIVATE Libmpv::Libmpv)
endif()

if(WITH_LIBVIPS)
    target_compile_definitions(${testname} PRIVATE PQMLIBVIPS)
    target_include_directories(${testname} PRIVATE ${GLIB_INCLUDE_DIRS})
    target_link_libraries(${testname} PRIVATE ${GLIB_LIBRARIES})
    target_link_libraries(${testname} PRIVATE "vips")
    target_link_libraries(${testname} PRIVATE "gobject-2.0")
    target_link_libraries(${testname} PRIVATE "vips-cpp")
endif()

if(WITH_RESVG)
    target_link_libraries(${testname} PRIVATE "resvg")
    target_compile_definitions(${testname} PRIVATE PQMRESVG)
endif()

if(WITH_EXIV2)
    target_compile_definitions(${testname} PRIVATE PQMEXIV2)
    target_link_libraries(${testname} PRIVATE exiv2lib)
    if(WITH_EXIV2_ENABLE_BMFF)
        target_compile_definitions(${testname} PRIVATE PQMEXIV2_ENABLE_BMFF)
    endif()
endif()

if(WITH_PUGIXML)
    target_compile_definitions(${testname} PRIVATE PQMPUGIXML)
    target_link_libraries(${testname} PRIVATE pugixml::pugixml)
endif()

if(WITH_ZXING)
    target_compile_definitions(${testname} PRIVATE PQMZXING)
    target_link_libraries(${testname} PRIVATE ZXing::ZXing)
endif()

if(WITH_CHROMECAST)
    target_compile_definitions(${testname} PRIVATE PQMCHROMECAST)
    target_include_directories(${testname} PRIVATE ${Python3_INCLUDE_DIRS})
    target_link_libraries(${testname} PRIVATE ${Python3_LIBRARIES})
endif()

if(WITH_LOCATION)
    target_compile_definitions(${testname} PRIVATE PQMLOCATION)
endif()

if(WITH_LCMS2)
    target_include_directories(${testname} PRIVATE ${LCMS2_INCLUDE_DIR})
    target_compile_definitions(${testname} PRIVATE PQMLCMS2)
    target_link_libraries(${testname} PRIVATE ${LCMS2_LIBRARIES})
endif()

if(WITH_MOTIONPHOTO)
    target_compile_definitions(${testname} PRIVATE PQMMOTIONPHOTO)
endif()

if(WITH_PHOTOSPHERE)
    target_compile_definitions(${testname} PRIVATE PQMPHOTOSPHERE)
endif()

if(WITH_EXTENSIONS_SUPPORT)
    target_compile_definitions(${testname} PRIVATE PQMEXTENSIONS)
    target_link_libraries(${testname} PRIVATE yaml-cpp)
endif()
