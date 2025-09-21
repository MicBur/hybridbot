cmake_minimum_required(VERSION 3.16)
project(qt-redis-bridge)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Network HttpServer)

qt6_standard_project_setup()

qt6_add_executable(qt-redis-bridge
    qt-redis-bridge.cpp
)

target_link_libraries(qt-redis-bridge
    Qt6::Core
    Qt6::Network  
    Qt6::HttpServer
)