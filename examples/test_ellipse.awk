#!/usr/bin/gawk -l gd -f
# Test script for gdImageFilledEllipse and gdImageEllipse functions

BEGIN {
  # Create a 300x200 white background image
  im = gdImageCreateTrueColor(300, 200)
  white = gdImageColorAllocate(im, 255, 255, 255)
  gdImageFilledRectangle(im, 0, 0, 299, 199, white)

  # Draw a filled red circle (ellipse with equal width and height)
  red = gdImageColorAllocate(im, 255, 0, 0)
  gdImageFilledEllipse(im, 75, 100, 100, 100, red)

  # Draw a blue ellipse outline
  blue = gdImageColorAllocate(im, 0, 0, 255)
  gdImageEllipse(im, 225, 100, 120, 80, blue)

  # Draw a green circle outline
  green = gdImageColorAllocate(im, 0, 200, 0)
  gdImageEllipse(im, 150, 100, 60, 60, green)

  # Save the image
  result = gdImagePngName(im, "/app/test_ellipse.png")
  print "Created 300x200 image with circles and ellipses"
  print "  - Red filled circle (left)"
  print "  - Green circle outline (center)"
  print "  - Blue ellipse outline (right)"
  print "Saved to ./test_ellipse.png (result:", result ")"

  # Clean up
  gdImageDestroy(im)
}
