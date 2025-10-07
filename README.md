# Weather Service API

Rails API that geocodes an address with OpenStreetMap Nominatim and returns a forecast from Open-Meteo. Caches by ZIP/postcode to reduce upstream calls.

## Requirements
- Ruby 3.3.x (add `.ruby-version` and `ruby "3.3.x"` in Gemfile)
- Rails 8.0.x
- Bundler 2.5.x

## Quick start
```bash
bin/setup || bundle install
bin/rails s
curl "http://localhost:3000/api/forecast?address=Avenida+Paulista,+Sao+Paulo,+Brazil" | jq
````

## Assessment checklist

- [X] Rails API-only
- [X] `GET /api/forecast?address=...`
- [X] Geocode → ZIP → forecast
- [X] `current_c`, bonus: `high_c`, `low_c`, `daily`, optional `hourly`
- [X] Cache by ZIP 30 min + race TTL
- [X] Cache indicator in body and `X-Cache` header
- [X] HTTP `Cache-Control`
- [X] 400/404/502 error mapping
- [X] Tests: request, unit, clients, VCR/WebMock

## Configuration

All have defaults. Override via env.

| var                       | default                                                                                  | meaning                     |
| ------------------------- | ---------------------------------------------------------------------------------------- | --------------------------- |
| CACHE_NAMESPACE           | wx:v1                                                                                    | cache key prefix            |
| FORECAST_TTL_SECONDS      | 1800                                                                                     | forecast TTL                |
| FORECAST_RACE_TTL_SECONDS | 300                                                                                      | dogpile protection          |
| GEOCODE_TTL_SECONDS       | 43200                                                                                    | geocode TTL                 |
| NOMINATIM_BASE_URL        | [https://nominatim.openstreetmap.org/search](https://nominatim.openstreetmap.org/search) | geocoder URL                |
| OPENMETEO_BASE_URL        | [https://api.open-meteo.com/v1/forecast](https://api.open-meteo.com/v1/forecast)         | forecast URL                |
| OPENMETEO_TIMEZONE        | auto                                                                                     | timezone hint to upstream   |
| HTTP_OPEN_TIMEOUT         | 3                                                                                        | seconds                     |
| HTTP_READ_TIMEOUT         | 5                                                                                        | seconds                     |
| HTTP_RETRIES              | 1                                                                                        | retry count                 |
| HTTP_REDIRECTS            | 2                                                                                        | max redirects               |
| HTTP_USER_AGENT           | rails-weather-assessment                                                                 | UA for upstreams            |
| CONTACT_EMAIL             | —                                                                                        | set for Nominatim etiquette |

Optional `.env`:

```bash
CACHE_NAMESPACE=wx:v1
FORECAST_TTL_SECONDS=1800
FORECAST_RACE_TTL_SECONDS=300
GEOCODE_TTL_SECONDS=43200
NOMINATIM_BASE_URL=https://nominatim.openstreetmap.org/search
OPENMETEO_BASE_URL=https://api.open-meteo.com/v1/forecast
OPENMETEO_TIMEZONE=auto
HTTP_OPEN_TIMEOUT=3
HTTP_READ_TIMEOUT=5
HTTP_RETRIES=1
HTTP_REDIRECTS=2
HTTP_USER_AGENT=rails-weather-assessment
CONTACT_EMAIL=you@example.com
```

## API contract

**Endpoint:** `GET /api/forecast`

**Query**

| param   | type   | required | notes                                 |
| ------- | ------ | -------- | ------------------------------------- |
| address | string | yes      | trimmed, max 512 UTF-8 chars          |
| hourly  | bool   | no       | `'true'` or `'false'` (default false) |

**200 OK**

```json
{
  "zip": "string",
  "current_c": 26.1,
  "high_c": 27.1,
  "low_c": 16.0,
  "daily": [{"date":"YYYY-MM-DD","max_c":27.1,"min_c":16.0}, ...],
  "hourly": [{"time":"YYYY-MM-DDThh:mm","temp_c":21.7}, ...],  // only when hourly=true
  "issued_at": "YYYY-MM-DDThh:mm[:ss][Z]",
  "cached": false
}
```

**Errors**

| code | body                                                                         |          |
| ---: | ---------------------------------------------------------------------------- | -------- |
|  400 | `{"error":"address required or too long"}` or `{"error":"hourly must be true | false"}` |
|  404 | `{"error":"address not found"}`                                              |          |
|  502 | `{"error":"<upstream message>"}`                                             |          |

**Response headers**

* `Cache-Control: public, max-age=1800`
* `X-Cache: HIT|MISS`

Notes:

* `daily` length mirrors upstream; don’t assume 7.
* `cached` reflects ZIP cache status, independent of `hourly`.

## Examples

Basic:

```bash
curl "http://localhost:3000/api/forecast?address=1600+Pennsylvania+Avenue+NW,+Washington,+DC+20500"
```

With hourly:

```bash
curl "http://localhost:3000/api/forecast?address=Rio+de+Janeiro,+RJ,+Brazil&hourly=true"
```

## Architecture

* **Controller:** param validation, headers
* **Services:** `GeocodeService`, `ForecastService` (orchestrate + cache)
* **Model:** `Forecast` DTO
* **Clients:** `NominatimClient`, `OpenMeteoClient`
* **Utilities:** `HttpHelpers`, `Cache`, JSON logging

## Caching

* Geocode: 12h per normalized address (accent-insensitive)
* Forecast: 30m per ZIP with race TTL 5m
* Store: `Rails.cache` (MemoryStore dev/test; use Redis in prod)
* Keys: namespaced + SHA256

## Tests

```bash
bundle exec rspec
```

## License

MIT
