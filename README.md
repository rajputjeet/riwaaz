# ShaadiHub — Flutter App Demo

## Project Structure

```
lib/
├── main.dart                          ← App entry point
│
├── core/                              ← Reusable foundation
│   ├── constants/
│   │   ├── app_colors.dart            ← Brand color palette
│   │   ├── app_text_styles.dart       ← Typography system
│   │   └── app_constants.dart         ← Strings & dimensions
│   ├── theme/
│   │   └── app_theme.dart             ← Material 3 theme
│   └── utils/
│       └── app_animations.dart        ← Page transitions & animations
│
├── features/                          ← Screen modules (by feature)
│   ├── splash/
│   │   └── splash_screen.dart         ← Screen 1: Animated Splash
│   ├── wedding_details/
│   │   └── wedding_details_screen.dart ← Screen 2: Wedding Setup Form
│   ├── dashboard/
│   │   └── dashboard_screen.dart      ← Screen 3: Home Dashboard
│   ├── explore/
│   │   └── explore_screen.dart        ← Screen 4: Explore Services
│   ├── service_listing/
│   │   └── service_listing_screen.dart ← Screen 5: Photography Listing
│   └── vendor_detail/
│       └── vendor_detail_screen.dart  ← Screen 6: Vendor Detail
│
└── shared/                            ← Common UI components
    └── widgets/
        └── bottom_nav_bar.dart        ← Animated bottom navigation
```

## Screens Implemented

| # | Screen | Description |
|---|--------|-------------|
| 1 | **Splash** | Particle animation, elastic logo bounce, gold shimmer CTA |
| 2 | **Wedding Details** | Form with sliders, dropdowns, date picker |
| 3 | **Dashboard** | Countdown timer, progress bar, task checklist |
| 4 | **Explore Services** | Service grid (12 categories), search, featured cards |
| 5 | **Service Listing** | Filter chips, vendor cards with ratings & price |
| 6 | **Vendor Detail** | Collapsing AppBar, tabs, packages, Book Now sheet |

## Animations Used

- 🎆 **Particle effect** — floating gold particles on splash
- 🔵 **Elastic logo** — bounce-in logo with rotation on load
- 📊 **Progress bar** — animated fill on dashboard
- 🃏 **Staggered cards** — fade-in + slide-up list items
- 💫 **Tap feedback** — scale-down on press for all buttons
- 🔄 **Page transitions** — slide + fade-scale between screens
- 🎛️ **Tab switches** — animated container highlight

## Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Deep Maroon | `#8B1A2E` |
| Gold Accent | Rich Gold | `#D4A017` |
| Background | Warm Cream | `#FFF8F0` |
| Success | Forest Green | `#2E7D32` |

## Run the app

```bash
flutter pub get
flutter run
```
