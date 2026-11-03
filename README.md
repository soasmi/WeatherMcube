# MeteoMcube — Weather Application

A high-performance, responsive weather application built with Flutter and Dart for the Mobile Application Developer Internship take-home assignment.

The application communicates with the free, open-access **Open-Meteo API** to deliver geocoding, current weather telemetry, a 24-hour hourly forecast radar, UV index and precipitation charts, and a 5-day daily outlook. Designed with an editorial athletic aesthetic inspired by modern high-contrast typography, crisp technical layouts, and structured telemetry presentation.

---

## 1. Technologies & Versions

- **Flutter**: `3.29.3` (Channel `stable`)
- **Dart**: `3.7.2`
- **Development Environment**: Android Studio `2024.2` / Visual Studio Community `2022 (17.10.5)`
- **Host OS**: Windows 11 (64-bit)
- **Target Platforms**: Android, iOS, Windows, macOS, Linux, Web

### Core Libraries & Dependencies

| Library | Version | Purpose |
| :--- | :--- | :--- |
| `flutter_riverpod` | `^3.3.2` | Reactive state management, dependency injection, and monotonic race-condition protection |
| `http` | `^1.6.0` | Asynchronous REST client with configurable request timeouts and response parsing |
| `geolocator` | `^14.0.2` | Native GPS device location integration with full permission management |
| `shared_preferences` | `^2.5.3` | Lightweight local persistence for offline weather caching, recent search history, and settings |
| `intl` | `^0.20.2` | Date/time parsing and formatting for daily forecast and telemetry timestamps |
| `cupertino_icons` | `^1.0.8` | Cross-platform icon sets |

---

## 2. Features Implemented

### Core Requirements
- **Two-Step Geocoding & Forecast Flow**: Converts city name to exact coordinates using the Open-Meteo Geocoding API (`count=5`), then queries the Forecast API.
- **Location Disambiguation Interface**: When multiple matching cities are returned (e.g. *Berlin, Germany* vs. *Berlin, New Hampshire, US*), an interactive disambiguation panel displays the city name, administrative region (`admin1`), country, and coordinates so the user selects the intended location.
- **Current Weather & Telemetry Hero**:
  - Selected city, administrative region, country, and live coordinate tags.
  - Large temperature display in the active unit (°C / °F).
  - Standardised WMO condition icon and description.
  - Telemetry matrix:
    - **Relative Humidity** (%) with comfort classification (*Dry*, *Comfortable*, *Humid*).
    - **Wind Speed** (`km/h` or `mph`) with velocity scale rating.
    - **Apparent "Feels Like" Temperature** calculated from wind chill and humidity.
    - **Surface Atmospheric Pressure** (`hPa`) with barometric status (*Low Pressure*, *Normal Baro*, *High Pressure*).
    - **Today's Range**: Minimum and maximum temperatures.
- **24-Hour Hourly Forecast Radar**:
  - Horizontal timeline covering the next 24 hours.
  - Highlights current hour (*NOW*) with speed-lime accent border.
  - Shows hour label, condition icon, temperature, precipitation chance (%), and UV index level.
- **UV Index & Precipitation Radar Card**:
  - Real-time and maximum daily UV index rating.
  - WHO UV risk level (*Low*, *Moderate*, *High*, *Very High*, *Extreme*) with actionable health advisory.
  - 5-segment visual UV spectrum meter.
  - 12-hour precipitation probability bar chart (%) with 24-hour cumulative precipitation sum (`mm`).
- **5-Day Weather Forecast**:
  - Day label (*TODAY*, *TOMORROW*, weekday name) and formatted date.
  - WMO condition icon and description.
  - Minimum and maximum temperatures with relative visual range bar indicator.
- **Centralised WMO Weather Code Mapping**:
  - Comprehensive mapping in `lib/core/utils/wmo_code_mapper.dart` covering codes 0 through 99.
  - Resilient fallback returning `"Unknown"` and `Icons.cloud_outlined` for undocumented codes.
- **Offline Mode & Local Caching**:
  - Automatically persists the last successfully retrieved weather result locally.
  - Restores cached weather upon application startup.
  - Clearly alerts the user via a prominent offline banner indicating that the telemetry is cached and displaying the exact recording timestamp.
  - Never overwrites valid cached information with failed network requests.
- **Concurrency & Edge Case Protection**:
  - **Race Condition Prevention**: Monotonic request IDs guarantee that older pending network requests can never overwrite newer searches.
  - Rejects blank and whitespace-only searches without network calls.
  - Handles nonexistent cities gracefully with descriptive user notifications.
  - 15-second request timeout translates into clear, user-friendly messages rather than technical stack traces.

### Bonus Features
- **Device GPS Auto-Location**: Dedicated location button in the search bar. Requests location permissions, retrieves device coordinates via GPS, and fetches live weather for the user's location with graceful permission fallback.
- **Pull-to-Refresh**: Native `RefreshIndicator` triggers live weather refresh.
- **Unit Toggle (°C / °F)**: Instant switching between Celsius and Fahrenheit; automatically converts temperature, wind speed (`km/h` vs `mph`), and persists preference locally.
- **Dedicated Theme Selector Modal**: Tapping the theme icon opens an appearance modal sheet with 3 clearly described options (*System Default*, *Matte Carbon Dark*, and *Industrial Chalk Light*), eliminating ambiguity.
- **Recent Search History**: Persists up to 6 recently selected cities with interactive chips for quick switching.
- **First-Launch Quick Presets**: Provides 6 sample cities (*Tokyo*, *London*, *Berlin*, *New York*, *Paris*, *Singapore*) for one-tap assessment testing.
- **Comprehensive Automated Test Suite**: 38 automated unit, widget, and integration tests covering WMO mapping, temperature conversion, model JSON serialization, API client error translation, repository cache fallback, race-condition prevention, hourly carousel rendering, and live API queries.

---

## 3. Architecture & Code Organisation

The project follows a clean, pragmatic **MVVM (Model-View-ViewModel) architecture with Riverpod 3**:

```
lib/
├── app.dart                                # Root MaterialApp with dynamic theme binding
├── main.dart                               # App entry point & SharedPreferences provider scope
├── core/
│   ├── constants/
│   │   └── api_constants.dart             # Open-Meteo URLs, timeouts, query parameters
│   ├── errors/
│   │   └── app_exceptions.dart            # Typed domain exceptions (no internet, timeout, not found)
│   ├── theme/
│   │   └── app_theme.dart                 # Editorial athletic color tokens, typography & theme data
│   └── utils/
│       ├── temperature_formatter.dart     # Unit conversion logic & display formatting
│       └── wmo_code_mapper.dart           # Centralised WMO weather code mapping
├── data/
│   ├── models/
│   │   ├── current_weather.dart           # Current weather entity with apparent temp & pressure
│   │   ├── forecast_day.dart              # Daily forecast entity with UV max & precipitation sum
│   │   ├── hourly_forecast_item.dart      # 24h hourly forecast point with UV risk classification
│   │   ├── location_item.dart             # Geocoding location entity with admin1 & country
│   │   └── weather_data.dart              # Composite weather aggregate with cache flag
│   ├── repositories/
│   │   └── weather_repository.dart        # Coordinates API client and local storage fallback
│   └── services/
│       ├── location_service.dart          # Native device GPS integration & permission handling
│       ├── open_meteo_api_client.dart     # HTTP client with timeouts & status validation
│       └── weather_storage_service.dart   # SharedPreferences persistence layer
└── features/
    └── weather/
        ├── providers/
        │   ├── settings_provider.dart     # Notifier for temperature unit and theme mode
        │   ├── weather_provider.dart      # Notifier for search, disambiguation & fetch lifecycle
        │   └── weather_state.dart         # Sealed class hierarchy representing UI states
        ├── screens/
        │   └── weather_screen.dart        # Main screen hosting search, states & pull-to-refresh
        └── widgets/
            ├── current_weather_view.dart  # Editorial hero telemetry card (4-metric matrix)
            ├── forecast_list_view.dart    # 5-day outlook with relative temperature bars
            ├── hourly_forecast_carousel.dart # 24-hour horizontal forecast timeline
            ├── location_selection_dialog.dart # Disambiguation list for multiple city matches
            ├── offline_banner.dart        # Outdated cache warning banner
            ├── recent_searches_view.dart  # Horizontal chips for recent searches
            ├── theme_selector_sheet.dart  # Intuitive appearance modal sheet
            ├── uv_and_precipitation_card.dart # UV meter & 12h precipitation probability chart
            ├── weather_empty_state.dart   # First launch prompt with quick presets
            ├── weather_error_view.dart    # Error card with retry trigger
            └── weather_search_bar.dart    # Search input with GPS location trigger, trim & clear
```

---

## 4. Open-Meteo API Endpoints Used

### 1. Geocoding Search
```http
GET https://geocoding-api.open-meteo.com/v1/search?name={city}&count=5
```
- Retrieves up to 5 matching locations with `id`, `name`, `latitude`, `longitude`, `country`, and `admin1`.
- If no matches exist, the `results` key is absent from the response, which our parser safely treats as an empty list.

### 2. Weather Forecast & Hourly Telemetry
```http
GET https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,surface_pressure&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_sum&forecast_days=5&timezone=auto
```
- Fetches real-time observations, 24-hour hourly progression, and 5-day daily forecasts with parallel arrays.

---

## 5. Setup & Running Instructions

### Prerequisites
- Flutter SDK `^3.29.0`
- Dart SDK `^3.7.0`
- A connected device, emulator, or desktop/browser target (Windows, macOS, Linux, Chrome, Edge)

### Step-by-Step Execution

1. **Clone the repository**:
   ```bash
   git clone https://github.com/soasmi/WeatherMcube.git
   cd WeatherMcube
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis and formatting**:
   ```bash
   dart format --set-exit-if-changed .
   flutter analyze
   ```

4. **Execute automated test suite**:
   ```bash
   flutter test
   ```

5. **Run the application**:
   - On Windows Desktop:
     ```bash
     flutter run -d windows
     ```
   - On Chrome (Web):
     ```bash
     flutter run -d chrome
     ```
   - On an Android device / emulator:
     ```bash
     flutter run -d android
     ```

---

## 6. Assumptions & Known Limitations

### Assumptions
- **Multiple Geocoding Results**: When multiple cities are found (e.g. searching *"Berlin"* returns Germany, US New Hampshire, US New Jersey, etc.), the user is presented with a disambiguation list showing city name, administrative region, country, and coordinates rather than silently picking the first entry.
- **Single Geocoding Result**: If only 1 result is returned, the app automatically selects it and immediately loads its weather.
- **Offline Startup**: When the device is offline on initial launch with existing cached data, the cached weather is displayed with a visible warning banner indicating the recording timestamp. If no cache exists, a clear offline error screen with a retry button is shown.
- **Data Freshness**: Cached data is marked with `isFromCache = true`. A live network pull-to-refresh replaces the cache only upon a successful response.

### Known Limitations
- **Meteorological Numerical Model Refresh Intervals**: Open-Meteo forecasts rely on global numerical weather models (ECMWF IFS, GFS, ICON) that re-assimilate atmospheric observations every 1 to 3 hours. Rapidly developing hyper-local convective squalls or sudden micro-bursts are best captured by real-time Doppler radar tile feeds rather than numerical simulations.
- **Background Push Notification Constraints**: In a pure client-side mobile application without an external cloud backend or push notification service (e.g. Firebase Cloud Messaging / APNs), native push notifications for sudden severe weather warnings cannot be dispatched while the application process is completely terminated.
- **Geocoding Coordinate Disambiguation**: The free Open-Meteo geocoding database resolves cities, municipalities, and administrative states (`admin1`). Hyper-local street address resolution or precise postal sub-districts would require a commercial GIS service such as Google Places or Mapbox Geocoding.

---

## 7. Future Improvements (With More Time)

1. **Interactive Weather Radar Map Tiles**: Embedding a Leaflet / MapLibre vector tile layer displaying live precipitation radar and cloud satellite imagery.
2. **Background WorkManager Periodic Cache Sync**: Scheduling a low-power periodic background worker to refresh weather telemetry for recent cities while connected to unmetered Wi-Fi.
3. **Severe Weather System Alerts**: Integrating local notification plugins (`flutter_local_notifications`) to alert users when the WMO code indicates thunderstorm, storm gale, or extreme UV index levels.
