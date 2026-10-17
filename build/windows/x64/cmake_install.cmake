# Install script for directory: D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "$<TARGET_FILE_DIR:NKD_Smart_Printer>")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/flutter/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/desktop_drop/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/pdfx/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/printing/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/jni/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/NKD_Smart_Printer.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug" TYPE EXECUTABLE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/NKD_Smart_Printer.exe")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/NKD_Smart_Printer.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile" TYPE EXECUTABLE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/NKD_Smart_Printer.exe")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/NKD_Smart_Printer.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release" TYPE EXECUTABLE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/NKD_Smart_Printer.exe")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/data" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows/flutter/ephemeral/icudtl.dat")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows/flutter/ephemeral/icudtl.dat")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows/flutter/ephemeral/icudtl.dat")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows/flutter/ephemeral/flutter_windows.dll")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows/flutter/ephemeral/flutter_windows.dll")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/windows/flutter/ephemeral/flutter_windows.dll")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/desktop_drop_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/pdfx_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/pdfium.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/printing_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/pdfium.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug" TYPE FILE FILES
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/desktop_drop/Debug/desktop_drop_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/pdfx/Debug/pdfx_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/pdfium-src/x64/bin/pdfium.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/printing/Debug/printing_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/pdfium-src/x64/bin/pdfium.dll"
      )
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/desktop_drop_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/pdfx_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/pdfium.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/printing_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/pdfium.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile" TYPE FILE FILES
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/desktop_drop/Profile/desktop_drop_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/pdfx/Profile/pdfx_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/pdfium-src/x64/bin/pdfium.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/printing/Profile/printing_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/pdfium-src/x64/bin/pdfium.dll"
      )
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/desktop_drop_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/pdfx_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/pdfium.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/printing_plugin.dll;D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/pdfium.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release" TYPE FILE FILES
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/desktop_drop/Release/desktop_drop_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/pdfx/Release/pdfx_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/pdfium-src/x64/bin/pdfium.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/plugins/printing/Release/printing_plugin.dll"
      "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/pdfium-src/x64/bin/pdfium.dll"
      )
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug" TYPE DIRECTORY FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/native_assets/windows/")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile" TYPE DIRECTORY FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/native_assets/windows/")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release" TYPE DIRECTORY FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/native_assets/windows/")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    
  file(REMOVE_RECURSE "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/data/flutter_assets")
  
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    
  file(REMOVE_RECURSE "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data/flutter_assets")
  
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    
  file(REMOVE_RECURSE "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data/flutter_assets")
  
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Debug/data" TYPE DIRECTORY FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build//flutter_assets")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data" TYPE DIRECTORY FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build//flutter_assets")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data" TYPE DIRECTORY FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build//flutter_assets")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Profile/data" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/app.so")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/runner/Release/data" TYPE FILE FILES "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/app.so")
  endif()
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "D:/VSCode/nkd-smart-printer-2026-10-17-word-first/build/windows/x64/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
