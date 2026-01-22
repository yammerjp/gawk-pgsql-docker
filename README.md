# gawk-pgsql-docker

Docker image with gawk and [gawkextlib](https://gawkextlib.sourceforge.net/) extensions (PostgreSQL, JSON, Redis, GD graphics).

## Patches

This project includes custom patches for the GD extension:

- `patches/gd_api_fix.patch` - Fixes gawk 5.x API compatibility
- `patches/gd_ellipse_functions.patch` - Adds ellipse drawing and circular cropping functions

## Extensions

- **lib** - gawkextlib core library
- **pgsql** - PostgreSQL database access
- **json** - JSON parsing and manipulation
- **redis** - Redis database access
- **gd** - GD graphics library (image creation and manipulation)
  - Additional functions via patches:
    - `gdImageFilledEllipse` - Draw filled circles/ellipses
    - `gdImageEllipse` - Draw circle/ellipse outlines
    - `gdImageCircleCrop` - Crop images to circular shape

## Usage

```bash
docker compose build
docker compose up -d db redis  # Start PostgreSQL and Redis
```

### JSON - Parse and generate JSON

```bash
docker compose run --rm gawk gawk -l json 'BEGIN {
  data["name"] = "Alice"
  data["age"] = 30
  json_str = json::to_json(data)
  print "JSON:", json_str
  json::from_json(json_str, obj)
  print "Name:", obj["name"], "Age:", obj["age"]
}'
```

### GD - Create an image

```bash
docker compose run --rm gawk gawk -l gd 'BEGIN {
  im = gdImageCreateTrueColor(200, 100)
  blue = gdImageColorAllocate(im, 0, 0, 255)
  gdImageFilledRectangle(im, 10, 10, 190, 90, blue)
  result = gdImagePngName(im, "/app/test.png")
  print "Created 200x100 image, saved to ./test.png (result:", result ")"
  gdImageDestroy(im)
}'

# View the generated image (saved in current directory)
# open test.png  # macOS
# xdg-open test.png  # Linux
```

#### GD - Draw circles and ellipses

```bash
docker compose run --rm gawk gawk -l gd -f examples/test_ellipse.awk

# The script creates an image with:
# - Red filled circle (left)
# - Green circle outline (center)
# - Blue ellipse outline (right)
```

#### GD - Circular image crop

```bash
docker compose run --rm gawk gawk -l gd 'BEGIN {
  # Create a colorful image
  im = gdImageCreateTrueColor(300, 300)
  red = gdImageColorAllocate(im, 255, 0, 0)
  blue = gdImageColorAllocate(im, 0, 0, 255)
  green = gdImageColorAllocate(im, 0, 255, 0)
  yellow = gdImageColorAllocate(im, 255, 255, 0)

  gdImageFilledRectangle(im, 0, 0, 149, 149, red)
  gdImageFilledRectangle(im, 150, 0, 299, 149, blue)
  gdImageFilledRectangle(im, 0, 150, 149, 299, green)
  gdImageFilledRectangle(im, 150, 150, 299, 299, yellow)

  # Crop to circle
  gdImageCircleCrop(im, 150, 150, 280)

  gdImagePngName(im, "/app/cropped.png")
  print "Created circular cropped image"
  gdImageDestroy(im)
}'
```

#### GD - Overlay images with circular mask

This example downloads two random images and overlays one on top of the other with a circular crop.

```bash
# Download sample images
curl -sL -o bg_image.jpg "https://picsum.photos/400/400?random=1"
curl -sL -o fg_image.jpg "https://picsum.photos/400/400?random=2"

# Run the overlay script
docker compose run --rm gawk gawk -l gd -f examples/test_overlay.awk

# Result: Background image with circular foreground overlay in center
# open test_overlay.png
```

### PostgreSQL - Database operations

```bash
docker compose run --rm --use-aliases gawk gawk -l pgsql 'BEGIN {
  conn = pg_connect("host=db user=postgres password=passw0rd dbname=postgres")
  pg_exec(conn, "CREATE TABLE IF NOT EXISTS test (id SERIAL, name TEXT)")
  pg_exec(conn, "INSERT INTO test (name) VALUES ('\''Hello from gawk'\'')")
  res = pg_exec(conn, "SELECT * FROM test")
  printf "Found %d rows:\n", pg_ntuples(res)
  for (row = 0; row < pg_ntuples(res); row++)
    printf "  id=%s, name=%s\n", pg_getvalue(res, row, 0), pg_getvalue(res, row, 1)
  pg_clear(res)
  pg_disconnect(conn)
}'

# Verify with psql
docker compose exec db psql -U postgres -d postgres -c "SELECT * FROM test;"
```

### Redis - Key-value operations

```bash
docker compose run --rm --use-aliases gawk gawk -l redis 'BEGIN {
  conn = redis_connect("redis", 6379)
  redis_set(conn, "mykey", "Hello from gawk")
  value = redis_get(conn, "mykey")
  print "Stored and retrieved:", value
  redis_close(conn)
}'

# Verify with redis-cli
docker compose exec redis redis-cli GET mykey
```
