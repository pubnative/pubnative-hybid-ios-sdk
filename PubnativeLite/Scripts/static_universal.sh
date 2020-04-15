# define output folder environment variable
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
FRAMEWORK_NAME=HyBidStatic
 
cd ..
# Step 1. Build Device and Simulator versions
xcodebuild -project PubnativeLite/HyBid.xcodeproj -scheme HyBidStatic ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

xcodebuild -project PubnativeLite/HyBid.xcodeproj -scheme HyBidStatic -configuration ${CONFIGURATION} -sdk iphonesimulator -arch i386 -arch x86_64 BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
 
# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
 
# Step 2. Create universal binary file using lipo
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/lib${FRAMEWORK_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${FRAMEWORK_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${FRAMEWORK_NAME}.a"
 
# Last touch. copy the header files. Just for convenience
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include" "${UNIVERSAL_OUTPUTFOLDER}/"
