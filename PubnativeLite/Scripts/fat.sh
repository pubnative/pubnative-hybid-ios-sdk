echo "RUN FAT"

_OUTDIR="${SRCROOT}/../Export"

TEMP_VARS="${_OUTDIR}/vars.tmp"

FW_NAME="HyBidStatic"

mkdir -p "${_OUTDIR}"

echo "### Cleanup"

rm -rf "${_OUTDIR}/"{*,.*}

if [ -f ${TEMP_VARS} ]; then
 rm ${TEMP_VARS}
fi


echo " ### Build"


xcodebuild clean build -workspace 'HyBid.xcworkspace' -scheme "${FW_NAME}" -configuration Release -sdk iphoneos -arch armv7 -arch arm64 -UseModernBuildSystem=1 -showBuildSettings | grep -E "BUILD_DIR|TARGET_BUILD_DIR = " | sed -e 's/    /export /g'  | sed -e 's/ = /="/g' | sed -e 's/$/"/g' >  ${TEMP_VARS}

if [ -f ${TEMP_VARS} ]; then
 source ${TEMP_VARS}
 echo "TARGET_BUILD_DIR = ${TARGET_BUILD_DIR}"
 echo "BUILD_DIR = ${BUILD_DIR}"
 rm ${TEMP_VARS}
else
 echo "Impossibiru error"
 exit 1;
fi

xcodebuild clean build -workspace 'HyBid.xcworkspace' -scheme "${FW_NAME}" -configuration Release -sdk iphoneos -arch armv7 -arch arm64 -UseModernBuildSystem=1

if [ $? -eq 0 ]; then
echo " ### BUILD HyBidStatic iphoneos DONE"
else
echo " ### BUILD HyBidStatic iphoneos FAIL"
exit 1
fi

RESULT_FRAMEWORK_IOS="${TARGET_BUILD_DIR}/${FW_NAME}.framework"
echo " ### IOS: ${RESULT_FRAMEWORK_IOS}"

xcodebuild build -workspace 'HyBid.xcworkspace' -scheme "${FW_NAME}" -configuration Release -sdk iphonesimulator -arch x86_64 -arch i386 -UseModernBuildSystem=1 -showBuildSettings | grep -E "BUILD_DIR|TARGET_BUILD_DIR = " | sed -e 's/    /export /g'  | sed -e 's/ = /="/g' | sed -e 's/$/"/g' >  ${TEMP_VARS}

if [ -f ${TEMP_VARS} ]; then
 source ${TEMP_VARS}
 echo "TARGET_BUILD_DIR = ${TARGET_BUILD_DIR}"
 echo "BUILD_DIR = ${BUILD_DIR}"
 rm ${TEMP_VARS}
else
 echo "Impossibiru error"
 exit 1;
fi

xcodebuild build -workspace 'HyBid.xcworkspace' -scheme "${FW_NAME}" -configuration Release -sdk iphonesimulator -arch x86_64 -arch i386 -UseModernBuildSystem=1

if [ $? -eq 0 ]; then
echo " ### BUILD HyBidStatic simulator DONE"
else
echo " ### BUILD HyBidStatic simulator FAIL"
exit 1
fi

RESULT_FRAMEWORK_SYM="${BUILD_DIR}/Release-iphonesimulator/${FW_NAME}.framework"
echo " ### SYM: ${RESULT_FRAMEWORK_SYM}"

cp -R "${RESULT_FRAMEWORK_IOS}" "${_OUTDIR}"

lipo -create -output "${_OUTDIR}/${FW_NAME}.framework/${FW_NAME}" "${RESULT_FRAMEWORK_IOS}/${FW_NAME}" "${RESULT_FRAMEWORK_SYM}/${FW_NAME}"

if [ $? -eq 0 ]; then
echo " ### BUILD FAT DONE"
else
echo " ### BUILD FAT FAIL"
exit 1
fi

echo "### DONE !!!"


exit 0;
