# Test cases for gdImageCircularCrop function
# TDD: These tests define the expected behavior before implementation

BEGIN {
    test_count = 0
    pass_count = 0
    fail_count = 0

    print "=== gdImageCircularCrop Test Suite ==="
    print ""

    # Create a test image (100x100 red square)
    test_create_and_crop_basic()
    test_crop_center()
    test_crop_returns_new_handle()
    test_crop_preserves_alpha()
    test_invalid_handle()
    test_output_dimensions()

    print ""
    print "=== Test Summary ==="
    printf "Total: %d, Passed: %d, Failed: %d\n", test_count, pass_count, fail_count

    exit (fail_count > 0 ? 1 : 0)
}

function assert_true(condition, test_name) {
    test_count++
    if (condition) {
        pass_count++
        printf "[PASS] %s\n", test_name
        return 1
    } else {
        fail_count++
        printf "[FAIL] %s\n", test_name
        return 0
    }
}

function assert_equal(expected, actual, test_name) {
    test_count++
    if (expected == actual) {
        pass_count++
        printf "[PASS] %s (expected=%s, actual=%s)\n", test_name, expected, actual
        return 1
    } else {
        fail_count++
        printf "[FAIL] %s (expected=%s, actual=%s)\n", test_name, expected, actual
        return 0
    }
}

# Test 1: Basic circular crop creates a valid image
function test_create_and_crop_basic() {
    print "--- Test: Basic circular crop ---"

    # Create a 100x100 test image
    src = gdImageCreateTrueColor(100, 100)
    assert_true(src != "", "Create source image")

    # Fill with red
    red = gdImageColorAllocate(src, 255, 0, 0)
    gdImageFilledRectangle(src, 0, 0, 99, 99, red)

    # Crop to a circle centered at (50,50) with radius 25
    cropped = gdImageCircularCrop(src, 50, 50, 25)
    assert_true(cropped != "", "Circular crop returns valid handle")

    # Cleanup
    if (cropped != "") gdImageDestroy(cropped)
    gdImageDestroy(src)
}

# Test 2: Crop from center of image
function test_crop_center() {
    print "--- Test: Crop from image center ---"

    # Create a 200x200 test image with gradient (simulate real image)
    src = gdImageCreateTrueColor(200, 200)

    # Create different colored quadrants
    red = gdImageColorAllocate(src, 255, 0, 0)
    green = gdImageColorAllocate(src, 0, 255, 0)
    blue = gdImageColorAllocate(src, 0, 0, 255)
    yellow = gdImageColorAllocate(src, 255, 255, 0)

    gdImageFilledRectangle(src, 0, 0, 99, 99, red)      # top-left
    gdImageFilledRectangle(src, 100, 0, 199, 99, green) # top-right
    gdImageFilledRectangle(src, 0, 100, 99, 199, blue)  # bottom-left
    gdImageFilledRectangle(src, 100, 100, 199, 199, yellow) # bottom-right

    # Crop circle at center (100,100) with radius 50
    cropped = gdImageCircularCrop(src, 100, 100, 50)
    assert_true(cropped != "", "Crop from center succeeds")

    # Output should be 100x100 (2*radius)
    if (cropped != "") {
        width = gdImageSX(cropped)
        height = gdImageSY(cropped)
        assert_equal(100, width, "Output width = 2*radius")
        assert_equal(100, height, "Output height = 2*radius")
        gdImageDestroy(cropped)
    }

    gdImageDestroy(src)
}

# Test 3: Cropped image has different handle than source
function test_crop_returns_new_handle() {
    print "--- Test: Returns new handle ---"

    src = gdImageCreateTrueColor(100, 100)
    cropped = gdImageCircularCrop(src, 50, 50, 25)

    assert_true(src != cropped, "Cropped handle differs from source")

    if (cropped != "") gdImageDestroy(cropped)
    gdImageDestroy(src)
}

# Test 4: Cropped image preserves alpha channel (transparent outside circle)
function test_crop_preserves_alpha() {
    print "--- Test: Alpha channel preserved ---"

    src = gdImageCreateTrueColor(100, 100)
    white = gdImageColorAllocate(src, 255, 255, 255)
    gdImageFilledRectangle(src, 0, 0, 99, 99, white)

    # Crop to circle at center with radius 40
    cropped = gdImageCircularCrop(src, 50, 50, 40)

    if (cropped != "") {
        # Save to PNG and verify it can be saved with alpha
        ret = gdImagePngName(cropped, "/tmp/test_circular_alpha.png")
        assert_equal(0, ret, "Save cropped image with alpha")
        gdImageDestroy(cropped)
    }

    gdImageDestroy(src)
}

# Test 5: Invalid handle returns empty string
function test_invalid_handle() {
    print "--- Test: Invalid handle handling ---"

    cropped = gdImageCircularCrop("invalid_handle", 50, 50, 25)
    assert_equal("", cropped, "Invalid handle returns empty string")
}

# Test 6: Output dimensions are exactly 2*radius
function test_output_dimensions() {
    print "--- Test: Output dimensions ---"

    src = gdImageCreateTrueColor(500, 500)
    blue = gdImageColorAllocate(src, 0, 0, 255)
    gdImageFilledRectangle(src, 0, 0, 499, 499, blue)

    # Test with radius 75
    cropped = gdImageCircularCrop(src, 250, 250, 75)

    if (cropped != "") {
        assert_equal(150, gdImageSX(cropped), "Width = 2*75 = 150")
        assert_equal(150, gdImageSY(cropped), "Height = 2*75 = 150")
        gdImageDestroy(cropped)
    }

    gdImageDestroy(src)
}
