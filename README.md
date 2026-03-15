#Advanced Weather

A premium, high-performance Weather Application built with Flutter. This project focuses on modern UI/UX principles, specifically **Glassmorphism**, and implements complex animations and custom graphics without relying on heavy external assets.

#Key Features

* **Glassmorphism UI:** Purely code-based glass effect using `BackdropFilter` and `ImageFilter`.
* **Dynamic Theming:** The background gradient and UI colors shift automatically based on the current weather condition (Clear, Rain, Clouds, etc.).
* **Custom Graphics:** Built a custom **Sun Arc Phase Indicator** using `CustomPainter` to show sunrise and sunset progress.
* **Interactive Charts:** Integrated `fl_chart` to visualize temperature trends with a smooth, minimalist line graph.
* **State Management:** Powered by `Provider` for clean architecture and efficient data flow.
* **Performance:** Optimized for 60FPS animations with custom `AnimationControllers`.

#Tech Stack

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Provider
* **UI Components:** Custom Painters, Fl Charts, Material Design 3
* **API:** OpenWeatherMap (via WeatherProvider)
