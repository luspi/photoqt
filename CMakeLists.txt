cmake_minimum_required(VERSION 2.8.12)

project(photoqt2 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_BUILD_TYPE "Debug")

find_package(Qt5 COMPONENTS Core Quick REQUIRED)

set(photoqt_SOURCES "cplusplus/main.cpp" "cplusplus/mainwindow.cpp")
set(photoqt_QML "qml/mainwindow.qml" "qml/mainview/Background.qml" "qml/mainview/ImageItem.qml" "qml/mainview/ImageItemRectangle.qml" "qml/shortcuts/Shortcuts.qml")
set(photoqt_QML ${photoqt_QML} "qml/mainview/MainImage.qml" "qml/mainview/MainImageRectangle.qml")
set(photoqt_RESOURCES "qmlresources/qml.qrc" "img.qrc")

add_executable(${PROJECT_NAME} ${photoqt_SOURCES} ${photoqt_QML} ${photoqt_RESOURCES})

target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick)
