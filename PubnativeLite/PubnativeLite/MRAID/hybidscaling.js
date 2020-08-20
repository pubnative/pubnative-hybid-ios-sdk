var elementToScaleFound = false;
var elementToScale = null;

const creativeResize = function (parent_width, parent_height, element) {
    let child_div = element;

    let child_height = parent_height;
    let child_width = parent_width;

    // DSPs could be attaching beacons(img 1X1) in child div, do not consider it as creative for resize
    if (child_div.offsetHeight > 1 && child_div.offsetWidth > 1) {
        child_height = child_div.offsetHeight;
        child_width = child_div.offsetWidth;
    }

    let aspect_width = child_width;
    let aspect_height = child_height;
    if (child_height < parent_height || child_width < parent_width) {
        let parent_aspect = parent_width / parent_height;
        let child_aspect = child_width / child_height;
        let scale_factor = 1;
        let scale_factor_y = 1;

        if (parent_aspect > child_aspect) {
            scale_factor = (parent_height / child_height);
            aspect_width = child_width * scale_factor;
            aspect_height = parent_height;
        } else {
            scale_factor = (parent_width / child_width);
            scale_factor_y = (parent_height / child_height);
            aspect_width = parent_width;
            aspect_height = child_height * (scale_factor);
        }

        if (aspect_width < parent_width) {
            child_div.style.marginLeft = (parent_width - aspect_width) / 2 + "px";
        }

        if (aspect_height < parent_height) {
            let translationPixels = (parent_height - child_height) / 2 + "px";
            child_div.style.transform += "translate(0px," + translationPixels + ")";
        }

        child_div.style.transform += "scale(" + scale_factor + "," + scale_factor_y + ")";
    }
};

const findElementBySize = function (currentElement, width, height) {
    if (currentElement.offsetHeight === height && currentElement.offsetWidth === width) {
        elementToScale = currentElement;
        elementToScaleFound = true;
    }
    if (currentElement.children.length !== 0) {
        for (var i = 0; i < currentElement.children.length && !elementToScaleFound; i++) {
            findElementBySize(currentElement.children[i], width, height);
        }
    }
}

const updateCreativeSize = function (width, height) {
    elementToScale = null;
    elementToScaleFound = false;
    let parent_height = height;
    let parent_width = width;
    let ad_container = document.getElementById('hybid-ad');
    findElementBySize(ad_container, 320, 480);

    if (elementToScaleFound && elementToScale != null) {
        creativeResize(parent_width, parent_height, elementToScale);
    }
}
