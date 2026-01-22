# Circular Crop Demo
# Usage: gawk -l gd -f circular_crop_demo.awk

BEGIN {
    # Create a 200x200 test image with 4 colored quadrants
    src = gdImageCreateTrueColor(200, 200)
    if (src == "") {
        print "Error: Failed to create source image"
        exit 1
    }

    # Allocate colors
    red = gdImageColorAllocate(src, 255, 0, 0)
    green = gdImageColorAllocate(src, 0, 255, 0)
    blue = gdImageColorAllocate(src, 0, 0, 255)
    yellow = gdImageColorAllocate(src, 255, 255, 0)

    # Fill quadrants
    gdImageFilledRectangle(src, 0, 0, 99, 99, red)        # Top-left: Red
    gdImageFilledRectangle(src, 100, 0, 199, 99, green)   # Top-right: Green
    gdImageFilledRectangle(src, 0, 100, 99, 199, blue)    # Bottom-left: Blue
    gdImageFilledRectangle(src, 100, 100, 199, 199, yellow) # Bottom-right: Yellow

    # Save the original image
    gdImagePngName(src, "/tmp/original.png")
    print "Created original image: /tmp/original.png (200x200, 4 colored quadrants)"

    # Circular crop from center with radius 80
    cropped = gdImageCircularCrop(src, 100, 100, 80)
    if (cropped == "") {
        print "Error: Circular crop failed"
        gdImageDestroy(src)
        exit 1
    }

    # Save the cropped image
    gdImagePngName(cropped, "/tmp/circular_cropped.png")
    print "Created circular crop: /tmp/circular_cropped.png (160x160, circular)"

    # Verify dimensions
    width = gdImageSX(cropped)
    height = gdImageSY(cropped)
    print "Cropped image dimensions: " width "x" height " (expected: 160x160)"

    # Cleanup
    gdImageDestroy(cropped)
    gdImageDestroy(src)

    print ""
    print "Demo complete! Check the PNG files in /tmp/"
    print "The circular cropped image should show parts of all 4 colors in a circle,"
    print "with transparent corners."
}
