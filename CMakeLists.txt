cmake_minimum_required(VERSION 2.8.12)

project(photoqt LANGUAGES CXX)

ADD_DEFINITIONS(-DVERSION="dev")
ADD_DEFINITIONS(-DQT_DEPRECATED_WARNINGS)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_BUILD_TYPE "Debug")

find_package(Qt5 COMPONENTS Core Quick Svg Sql REQUIRED)


INCLUDE(CMake/ListFilesCPlusPlus.cmake)
INCLUDE(CMake/ListFilesQML.cmake)
INCLUDE(CMake/ListFilesResources.cmake)

add_executable(${PROJECT_NAME} ${photoqt_SOURCES} ${photoqt_QML} ${photoqt_RESOURCES})
QT5_USE_MODULES(photoqt Core Quick Svg Sql)

target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick)
