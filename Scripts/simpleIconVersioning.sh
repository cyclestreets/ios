IFS=$'\n'
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}")
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLIST_FILE}")
PATH=${PATH}:/usr/local/bin

function checkFileExists () {
    if [[ ! -e "$1" ]]; then
    echo "Required file unable to be found: $1"
    exit 1
    fi
}

function generateIcon () {
    BASE_IMAGE_NAME=$1
    
    IDENTIFY_BIN=$(which identify)
    if [[ "$IDENTIFY_BIN" == '' ]]; then
    echo "No 'identify' command found. Please ensure image magick is installed correctly"
    else
    
    BUILD_RESOURCES_DIR="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    TARGET_PATH="${BUILD_RESOURCES_DIR}/${BASE_IMAGE_NAME}"
    BASE_IMAGE_PATH=$(find ${BUILD_RESOURCES_DIR} -name ${BASE_IMAGE_NAME})
    
    checkFileExists "iconAdhocBanner.png"
    checkFileExists "$BASE_IMAGE_PATH"
    
    WIDTH=$(identify -format %w $BASE_IMAGE_PATH)
    echo "Image width: $WIDTH"
    FONT_SIZE=$(echo "$WIDTH * .15" | bc -l)
    echo "Font size: $FONT_SIZE"
    BADGE_TEXT="$buildNumber"
    echo "Creating badged icon for: '$BASE_IMAGE_NAME' with '$BADGE_TEXT'"
    
    if [ "${CONFIGURATION}" == "Debug" ]; then
    convert iconAdhocBanner.png -resize ${WIDTH}x${WIDTH} resizedAdhocRibbon.png
    convert ${BASE_IMAGE_PATH} -fill black -font Helvetica-Regular -pointsize ${FONT_SIZE} -gravity south -annotate 0 "$BADGE_TEXT" - | composite resizedAdhocRibbon.png - ${TARGET_PATH}
    fi
    
    fi
}

generateIcon "DevAppIcon60x60@2x.png"
generateIcon "DevAppIcon60x60@3x.png"