**Core Features**

AI-Powered Detection

* Upload or capture leaf/fruit/stem images.
* On-device inference using TensorFlow Lite (offline support).
* Disease detection in ≤10 seconds.
* Works for major crops: wheat, rice, sugarcane, cotton, pulses.

Treatment Recommendations

* Organic solutions (e.g., neem oil, cow dung-based pesticides, natural extracts).
* Chemical solutions with dosage & safety guidelines.
* Low-cost remedies using locally available resources.
* Preventive measures (crop rotation, irrigation, plant spacing).

Farmer Support

* Regional language interface (Hindi, Tamil, Telugu, Kannada, Bengali, Marathi, etc.).
* Voice-based guidance for semi-literate farmers.
* Weather-based alerts for high-risk disease conditions.
* Crop calendar with region-specific farming tasks.
* Daily mandi prices via market data API.
* Community forum for farmer-to-farmer discussions and optional expert advisory.


**Tech Stack**

* Mobile App: Flutter
* AI Models: TensorFlow Lite
* Database: SQLite (offline storage)
* Cloud Sync (Optional): Firebase Realtime Database
* APIs Used:

  * Weather → OpenWeather API
  * Market Data → Agmarknet API
    

**Repository Structure**

1. **Root Files**

   * `README.md`
   * `pubspec.yaml`
   * `.gitignore`


2. **Assets**

   * **images/** → App images/icons
   * **model/** → ML models

     * `crop_disease_model.tflite`
   * **translations/** → Language JSON files

     * `en.json`
     * `hi.json`
     * `ta.json`
     * `te.json`
      * `logo.jpg`
   * `Government_Schemes_for_Farmers.xlsx`
   * `crop_manure_data.csv`

3. **Lib**

   * `main.dart` → App entry point

   * `weather.dart` → Weather integration

   * `database_helper.dart` → SQLite database helper

   * **models/** → Data & AI models

     * `community_models.dart`
     * `scheme_model.dart`

   * **screens/** → UI screens

     * `community_screen.dart`
     * `fertilizer_calculator.dart`
     * `market_screen.dart`
     * `plant_scanner_screen.dart`
     * `scheme_detail_screen.dart`

   * **services/** → APIs & logic

     * `community_service.dart`
     * `market_service.dart`
     * `schemes_service.dart`

   * **widgets/** → Reusable UI components

     * `language_selector.dart`
     * `scheme_carousel.dart`

4. **Platform-specific**

   * `linux/`
   * `macos/`


