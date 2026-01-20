# gawk-pgsql-docker

Docker image with gawk and [gawkextlib](https://gawkextlib.sourceforge.net/) extensions (PostgreSQL, JSON, Redis, GD graphics).

## Extensions

- **lib** - gawkextlib core library
- **pgsql** - PostgreSQL database access
- **json** - JSON parsing and manipulation
- **redis** - Redis database access
- **gd** - GD graphics library (image creation and manipulation)

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
