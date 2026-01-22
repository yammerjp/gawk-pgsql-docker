#!/usr/bin/gawk -l gd -f
# Test script for gdImageCircleCrop function

BEGIN {
  # Create a 300x300 image with colorful rectangles
  im = gdImageCreateTrueColor(300, 300)

  # Draw colorful rectangles
  red = gdImageColorAllocate(im, 255, 0, 0)
  blue = gdImageColorAllocate(im, 0, 0, 255)
  green = gdImageColorAllocate(im, 0, 255, 0)
  yellow = gdImageColorAllocate(im, 255, 255, 0)

  gdImageFilledRectangle(im, 0, 0, 149, 149, red)
  gdImageFilledRectangle(im, 150, 0, 299, 149, blue)
  gdImageFilledRectangle(im, 0, 150, 149, 299, green)
  gdImageFilledRectangle(im, 150, 150, 299, 299, yellow)

  # Crop to circle (center: 150, 150, diameter: 280)
  gdImageCircleCrop(im, 150, 150, 280)

  # Save the image (must use PNG to preserve transparency)
  result = gdImagePngName(im, "/app/test_circle_crop.png")
  print "Created 300x300 image cropped to circular shape"
  print "  - Center: (150, 150)"
  print "  - Diameter: 280"
  print "Saved to ./test_circle_crop.png (result:", result ")"

  # Clean up
  gdImageDestroy(im)
}
