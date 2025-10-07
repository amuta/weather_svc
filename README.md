# Weather Service API

A Rails API service that provides weather forecasts by address. It geocodes addresses using OpenStreetMap Nominatim and fetches weather data from Open-Meteo, with intelligent caching to minimize upstream API calls.

**Quick Start:**
```bash
curl "http://localhost:3000/api/forecast?address=1600+Pennsylvania+Avenue+NW,+Washington,+DC+20500"
# => {"zip":"20500","current_c":26.1,"high_c":27.1,"low_c":16.0,"daily":[...],"issued_at":"2025-10-07T17:45","cached":false}
```



## Assessment checklist

* [x] **Rails API**: Rails API-only app.
* [x] **Accepts address input**: `GET /api/forecast?address=...` (trimmed, max 512).
* [x] **Retrieves forecast by zip**: address → geocode (Nominatim) → **zip** → forecast (Open-Meteo).
* [x] **Current temperature**: `current_c`.
* [x] **Bonus details**: `high_c`, `low_c`, `daily` 7-day; optional `hourly` via `hourly=true`.
* [x] **30-minute caching by zip**: TTL 1800s, race TTL 300s, cache key = zip.
* [x] **Cache indicator**: body `cached: true|false`, header `X-Cache: HIT|MISS`.
* [x] **HTTP caching headers**: `Cache-Control: public, max-age=1800`.
* [x] **Error handling**: `400` invalid input, `404` not found/no zip, `502` upstream.
* [x] **Tests**: request + unit + client parsing + VCR; SimpleCov 100% lines.


## Requirements

- Ruby 3.3+
- Bundler

## Setup

```bash
bundle install
```

## Configuration

All configuration is optional and has sensible defaults. Create a `.env` file to customize:

```bash
# Cache settings
CACHE_NAMESPACE=wx:v1
FORECAST_TTL_SECONDS=1800        # 30 minutes
FORECAST_RACE_TTL_SECONDS=300    # 5 minutes
GEOCODE_TTL_SECONDS=43200        # 12 hours

# Upstream APIs
NOMINATIM_BASE_URL=https://nominatim.openstreetmap.org/search
OPENMETEO_BASE_URL=https://api.open-meteo.com/v1/forecast
OPENMETEO_TIMEZONE=auto

# HTTP client
HTTP_OPEN_TIMEOUT=3
HTTP_READ_TIMEOUT=5
HTTP_RETRIES=1
HTTP_REDIRECTS=2
HTTP_USER_AGENT=rails-weather-assessment
CONTACT_EMAIL=your-email@example.com  # Required for Nominatim best practices
```

## Running the Application

```bash
bundle exec rails server
```

The API will be available at `http://localhost:3000`

## API Usage

### Get Weather Forecast

**Endpoint:** `GET /api/forecast`

**Parameters:**
- `address` (required): The address to look up (string, max 512 characters)
- `hourly` (optional): `true` or `false` (default: `false`). Any other value returns `400`.

**Validation:**
- `address` is trimmed. Empty or length > 512 returns `400 Bad Request`.
- `hourly` must be `true` or `false`. Other values return `400 Bad Request`.

**Response Headers:**
- `Cache-Control: public, max-age=1800` (mirrors `FORECAST_TTL_SECONDS`)
- `X-Cache: HIT` (cached) or `MISS` (fresh from upstream)

**Example: Basic Request**

```bash
curl "http://localhost:3000/api/forecast?address=1600+Pennsylvania+Avenue+NW,+Washington,+DC+20500"
```

**Response:**

```json
{
  "zip": "20500",
  "current_c": 26.1,
  "high_c": 27.1,
  "low_c": 16.0,
  "daily": [
    {"date": "2025-10-07", "max_c": 27.1, "min_c": 16.0},
    {"date": "2025-10-08", "max_c": 21.9, "min_c": 12.3},
    {"date": "2025-10-09", "max_c": 18.2, "min_c": 7.5},
    {"date": "2025-10-10", "max_c": 19.6, "min_c": 9.6},
    {"date": "2025-10-11", "max_c": 20.8, "min_c": 14.3},
    {"date": "2025-10-12", "max_c": 17.1, "min_c": 11.7},
    {"date": "2025-10-13", "max_c": 12.3, "min_c": 10.9}
  ],
  "issued_at": "2025-10-07T17:45",
  "cached": false
}
```

**Example: With Hourly Data**

```bash
curl "http://localhost:3000/api/forecast?address=1600+Pennsylvania+Avenue+NW,+Washington,+DC+20500&hourly=true"
```

**Response:**

```json
{
  "zip": "20500",
  "current_c": 26.1,
  "high_c": 27.1,
  "low_c": 16.0,
  "daily": [
    {"date": "2025-10-07", "max_c": 27.1, "min_c": 16.0},
    {"date": "2025-10-08", "max_c": 21.9, "min_c": 12.3}
  ],
  "hourly": [
    {"time": "2025-10-07T00:00", "temp_c": 21.7},
    {"time": "2025-10-07T01:00", "temp_c": 21.2},
    {"time": "2025-10-07T02:00", "temp_c": 20.8},
    ...
  ],
  "issued_at": "2025-10-07T17:45",
  "cached": true
}
```

**Example: Cached Response**

On subsequent requests for the same zip code within 30 minutes, `cached: true`:

```bash
curl "http://localhost:3000/api/forecast?address=1600+Pennsylvania+Avenue+NW,+Washington,+DC+20500"
```

**Response Headers:**
```
Cache-Control: public, max-age=1800
X-Cache: HIT
```

**Response Body:**
```json
{
  "zip": "20500",
  "current_c": 26.1,
  "high_c": 27.1,
  "low_c": 16.0,
  "daily": [...],
  "issued_at": "2025-10-07T17:45",
  "cached": true
}
```

**Error Responses:**

```bash
# Missing address
curl "http://localhost:3000/api/forecast"
# HTTP 400: {"error": "address required or too long"}

# Invalid hourly parameter
curl "http://localhost:3000/api/forecast?address=Rio&hourly=maybe"
# HTTP 400: {"error": "hourly must be true|false"}

# Address not found
curl "http://localhost:3000/api/forecast?address=InvalidAddress12345"
# HTTP 404: {"error": "address not found"}

# Upstream service error
# HTTP 502: {"error": "upstream error"}
```

## Running Tests

```bash
bundle exec rspec
```
**Coverage:** 100% lines (SimpleCov), open `coverage/index.html` after running tests.

## Architecture

### Layers

- **Controller** (`ForecastsController`): Handles HTTP requests, validates params, filters response
- **Service** (`ForecastService`, `GeocodeService`): Orchestrates business logic
- **Model** (`Forecast`): Value object with caching logic
- **Clients** (`NominatimClient`, `OpenMeteoClient`): HTTP API integrations
- **Helpers** (`HttpHelpers`, `Cache`): Shared utilities

### Caching Strategy

- **Geocoding**: 12-hour cache per normalized address (reduces load on Nominatim)
- **Forecasts**: 30-minute cache per zip code with 5-minute race condition protection
- **Storage**: Rails.cache (MemoryStore in dev/test, configure Redis for production)
- **Cache key**: Namespaced with SHA256 digest for consistent length

### Production Considerations

For production deployment:

1. **Cache Store**: Configure Redis in `config/environments/production.rb`:
   ```ruby
   config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
   ```

2. **Rate Limiting**: Implement rate limiting for the API endpoint

3. **Monitoring**: Add logging for cache hits, upstream latency, and errors

4. **Geocoding**: Use a production geocoding service or self-hosted Nominatim

## Notes

- **No database or Redis required** - Uses in-memory cache for simplicity.
- **Caching by zip code** - Maximizes cache hit rate since many addresses map to the same zip.
- **Hourly data filtering** - Always fetches and caches full data, filters at the model boundary based on `include_hourly` param to avoid cache fragmentation.

## License

This project is available as open source under the terms of the MIT License.
