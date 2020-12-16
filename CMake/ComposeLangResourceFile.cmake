function(composeLangResourceFile)

    file(WRITE  ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc "<RCC>\n")
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc "  <qresource prefix=\"/\">\n")
    file(GLOB files ${CMAKE_CURRENT_BINARY_DIR}/photoqt_*.ts)
    foreach(file ${files})
        get_filename_component(qmfile ${file} NAME_WE)
        file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc "    <file>${qmfile}.qm</file>\n")
    endforeach()
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc "  </qresource>\n")
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/lang.qrc "</RCC>\n")

endfunction()

