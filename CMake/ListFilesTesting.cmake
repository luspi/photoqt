#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus/testing")
SET(photoqt_TESTING ${photoqt_TESTING} ${d}/maintest.cpp ${d}/getanddostufftest.h ${d}/getmetadatatest.h)

SET(d "cplusplus/scripts")
SET(photoqt_TESTING ${photoqt_TESTING} ${d}/getmetadata.cpp)

SET(d "cplusplus/scripts/getanddostuff")
SET(photoqt_TESTING ${photoqt_TESTING} ${d}/context.cpp ${d}/file.cpp ${d}/manipulation.cpp ${d}/other.cpp)
