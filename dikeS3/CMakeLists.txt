cmake_minimum_required(VERSION 3.10)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries")
add_subdirectory(poco)
add_subdirectory(dikeSQL)

include_directories(dikeSQL)

project(dikeS3)
add_executable(dikeS3 dikeS3.cpp)

target_include_directories(dikeS3 PUBLIC 
    ${CMAKE_SOURCE_DIR}/poco/Foundation/include 
    ${CMAKE_SOURCE_DIR}/poco/Util/include
    ${CMAKE_SOURCE_DIR}/poco/Net/include 
    /mnt/usb-SanDisk_Ultra_128GB/tmp/aws-stream/build/include
    )

target_link_libraries(dikeS3 PUBLIC 
    Poco::Foundation
    Poco::Util
    Poco::Net
    libsqlite
    "-lpthread -lm"
    "-L/mnt/usb-SanDisk_Ultra_128GB/tmp/aws-stream/build/lib -laws-c-event-stream  -laws-checksums -laws-c-common"
    )
