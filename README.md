# MeteoMcube — Weather Application

A high-performance, responsive weather application built with Flutter and Dart for the Mobile Application Developer Internship take-home assignment.

The application communicates with the free, open-access **Open-Meteo API** to deliver geocoding, current weather conditions, telemetry metrics, and a 5-day forecast. Designed with an editorial athletic aesthetic inspired by modern high-contrast typography, crisp technical layouts, and structured data presentation.

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
| `shared_preferences` | `^2.5.3` | Lightweight local persistence for offline weather caching, recent search history, and settings |
| `intl` | `^0.20.2` | Date/time parsing and formatting for daily forecast and telemetry timestamps |
| `cupertino_icons` | `^1.0.8` | Cross-platform icon sets |

---

## 2. Features Implemented

### Core Requirements
- **Two-Step Geocoding & Forecast Flow**: Converts city name to exact coordinates using the Open-Meteo Geocoding API (`count=5`), then queries the Forecast API.
- **Location Disambiguation Interface**: When multiple matching cities are returned (e.g. *Berlin, Germany* vs. *Berlin, New Hampshire, US*), an interactive disambiguation panel displays the city name, administrative region (`admin1`), country, and coordinates so the user selects the intended location.
- **Current Weather & Telemetry**:
  - Selected city, administrative region, country, and coordinate tags.
  - Current temperature formatted in the chosen unit (°C / °F).
  - Weather condition label and dedicated icon mapped via WMO weather standards.
  - Relative humidity percentage with comfort classification (*Dry*, *Comfortable*, *Humid*).
  - Wind speed with velocity classification (*Light Breeze*, *Moderate*, *Strong*).
  - Today's minimum and maximum temperature range.
- **5-Day Weather Forecast**:
  - Day label (*TODAY*, *TOMORROW*, day of week) and formatted date.
  - WMO condition icon and description.
  - Minimum and maximum temperatures with relative visual range bar indicator.
- **Centralised WMO Weather Code Mapping**:
  - Full mapping for codes `0` (Clear sky), `1–3` (Mainly clear, partly cloudy, overcast), `45/48` (Fog), `51/53/55` (Drizzle), `56/57` (Freezing drizzle), `61/63/65` (Rain), `66/67` (Freezing rain), `71/73/75` (Snow fall), `77` (Snow grains), `80–82` (Showers), `85/86` (Snow showers), `95/96/99` (Thunderstorms).
  - Resilient fallback returning `"Unknown"` and `Icons.cloud_outlined` for undocumented codes.
- **Robust Error & Edge Case Handling**:
  - Rejects empty and whitespace-only searches without network calls.
  - Handles nonexistent cities gracefully with descriptive user notifications.
  - Request timeouts (15 seconds) to prevent hanging requests.
  - Network disconnection states with actionable error banners.
  - Safe parallel array parsing for daily forecasts with fallback values.
  - **Overlapping Search Race Condition Protection**: Monotonic request IDs guarantee that older pending network requests can never overwrite newer searches.
- **Offline Mode & Local Caching**:
  - Automatically persists the last successfully retrieved weather result locally.
  - Restores cached weather upon application startup.
  - Clearly alerts the user via a prominent offline banner indicating that the telemetry is cached and displaying the exact recording timestamp.
  - Never overwrites valid cached information with failed network requests.
- **First Launch Empty State**:
  - Helpful onboarding prompt (*"Search for a city to discover its weather"*) accompanied by one-tap quick-selection city presets (*Tokyo*, *London*, *Berlin*, *New York*, *Paris*, *Singapore*).

### Bonus Features
- **Pull-to-Refresh**: Native `RefreshIndicator` enables instant weather refresh for the currently active city.
- **Unit Toggle (°C / °F)**: Instant switching between Celsius and Fahrenheit; automatically converts temperature and wind speed (`km/h` vs `mph`) and persists preference locally.
- **System-Aware Light & Dark Themes**: High-contrast, tailored palettes for Dark mode (Matte Carbon / Speed Lime accent) and Light mode (Chalk / Industrial Ink). User can cycle between System, Dark, and Light mode via top-bar control.
- **Recent Search History**: Persists up to 6 recently searched cities as horizontal quick-access chips for one-tap weather queries.
- **Comprehensive Automated Test Suite**: 35 automated unit, widget, and integration tests covering WMO mapping, temperature conversion, model JSON serialization, API client error translation, repository cache fallback, race-condition prevention, and UI rendering.

---

## 3. Architecture & Code Organisation

The project follows a clean, pragmatic **MVVM (Model-View-ViewModel) architecture with Riverpod 3**:

```
lib/
├── app.dart                                # Root MaterialApp with dynamic theme binding
├── main.dart                               # App entry point & SharedPreferences provider scope
├── core/
│   ├── constants/
│   │   └── api_constants.dart             # Open-Meteo URLs, timeouts, query constants
│   ├── errors/
│   │   └── app_exceptions.dart            # Typed domain exceptions (no internet, timeout, not found)
│   ├── theme/
│   │   └── app_theme.dart                 # Editorial athletic color tokens, typography & theme data
│   └── utils/
│       ├── temperature_formatter.dart     # Unit conversion logic & display formatting
│       └── wmo_code_mapper.dart           # Centralised WMO weather code mapping
├── data/
│   ├── models/
│   │   ├── current_weather.dart           # Current weather entity & JSON parsing
│   │   ├── forecast_day.dart              # Daily forecast entity & parallel array parser
│   │   ├── location_item.dart             # Geocoding location entity with admin1 & country
│   │   └── weather_data.dart              # Composite weather aggregate with cache flag
│   ├── repositories/
│   │   └── weather_repository.dart        # Coordinates API client and local storage fallback
│   └── services/
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
            ├── current_weather_view.dart  # Editorial hero telemetry card
            ├── forecast_list_view.dart    # 5-day outlook with relative temperature bars
            ├── location_selection_dialog.dart # Disambiguation list for multiple city matches
            ├── offline_banner.dart        # Outdated cache warning banner
            ├── recent_searches_view.dart  # Horizontal chips for recent searches
            ├── weather_empty_state.dart   # First launch prompt with quick presets
            ├── weather_error_view.dart    # Error card with retry trigger
            └── weather_search_bar.dart    # Search input with trim, submit & clear actions
```

---

## 4. Open-Meteo API Endpoints Used

### 1. Geocoding Search
```http
GET https://geocoding-api.open-meteo.com/v1/search?name={city}&count=5
```
- Retrieves up to 5 matching locations with `id`, `name`, `latitude`, `longitude`, `country`, and `admin1`.
- If no matches exist, the `results` key is absent from the response, which our parser safely treats as an empty list.

### 2. Weather Forecast
```http
GET https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=5&timezone=auto
```
- Fetches real-time observations and 5-day daily forecasts with parallel arrays (`time`, `weather_code`, `temperature_2m_max`, `temperature_2m_min`).

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
- The Open-Meteo free geocoding service resolves city and administrative area names; micro-neighborhoods or granular postal codes might require geocoordinates.
- Hourly precipitation breakdown and UV index charts are not displayed in the 5-day summary view to maintain a clean layout within the 6–8 hour scope.

---

## 7. Future Improvements (With More Time)

1. **Interactive Hourly Forecast Carousel**: A horizontal timeline showing hour-by-hour temperature and precipitation probability for the next 24 hours.
2. **Device GPS Auto-Location**: Integration with `geolocator` to provide a "Current Location" button with permission handling.
3. **Interactive Weather Radar Map**: Embedding a lightweight tile map layer displaying precipitation and cloud radar.
4. **Severe Weather Alerts**: Banner notifications for WMO thunderstorm, gale, or severe cold alerts.
