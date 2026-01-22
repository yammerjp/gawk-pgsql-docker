#!/usr/bin/gawk -l gd -f
# Test script for overlaying a circular cropped image on another image

BEGIN {
  # Load background image
  bg = gdImageCreateFromFile("/app/bg_image.jpg")
  if (bg == "") {
    print "Error: Failed to load background image"
    exit 1
  }
  print "✓ Loaded background image"

  # Get background image size
  bg_w = gdImageSX(bg)
  bg_h = gdImageSY(bg)
  print "  Background size:", bg_w "x" bg_h

  # Load foreground image
  fg = gdImageCreateFromFile("/app/fg_image.jpg")
  if (fg == "") {
    print "Error: Failed to load foreground image"
    gdImageDestroy(bg)
    exit 1
  }
  print "✓ Loaded foreground image"

  # Get foreground image size
  fg_w = gdImageSX(fg)
  fg_h = gdImageSY(fg)
  print "  Foreground size:", fg_w "x" fg_h

  # Crop foreground to circle (center of image, diameter = min(width, height) * 0.7)
  center_x = int(fg_w / 2)
  center_y = int(fg_h / 2)
  diameter = int((fg_w < fg_h ? fg_w : fg_h) * 0.7)

  gdImageCircleCrop(fg, center_x, center_y, diameter)
  print "✓ Cropped foreground to circle"
  print "  Center: (" center_x ", " center_y ")"
  print "  Diameter:", diameter

  # Overlay foreground (circular cropped) directly on background
  # Position it in the center of the background
  offset_x = int((bg_w - fg_w) / 2)
  offset_y = int((bg_h - fg_h) / 2)
  gdImageCopyResampled(bg, fg, offset_x, offset_y, 0, 0, fg_w, fg_h, fg_w, fg_h)
  print "✓ Overlayed circular foreground on background"
  print "  Position: (" offset_x ", " offset_y ")"

  # Save result
  status = gdImagePngName(bg, "/app/test_overlay.png")
  print "✓ Saved to ./test_overlay.png (status:", status ")"

  # Cleanup
  gdImageDestroy(bg)
  gdImageDestroy(fg)

  print ""
  print "Result: Background image with circular foreground overlay in center"
}
