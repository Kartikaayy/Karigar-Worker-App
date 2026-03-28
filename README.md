<div align="center">

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                ██████╗ █████╗ ██╗     ██╗                     ║
║                ██╔════╝██╔══██╗██║     ██║                    ║
║                ██║     ███████║██║     ██║                    ║
║                ██║     ██╔══██║██║     ██║                    ║
║                ╚██████╗██║  ██║███████╗███████╗               ║
║                 ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝               ║
║                                                               ║
║                   K A R I G A R   W O R K E R                 ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

**MP Government Services · Worker-Side Mobile Application**

[![Flutter](https://img.shields.io/badge/Flutter-3.32.6-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-success?style=for-the-badge)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Backend](https://img.shields.io/badge/Backend-Railway-6D28D9?style=for-the-badge&logo=railway&logoColor=white)](https://railway.app)

<br/>

> *Connecting skilled workers with customers across Madhya Pradesh.*
> *Accept jobs. Track earnings. Build your reputation. — All in one place.*

<br/>

---

</div>

## ✦ What is Call KARIGAR?

**Call KARIGAR** is a government-backed service platform for Madhya Pradesh that connects verified local workers *(karigar)* with customers who need skilled services — plumbing, electrical, painting, AC installation, and more.

This repository is the **Worker Application** — the mobile app used by karigar to:

- Receive and manage job bookings
- Track their earnings and ratings
- Submit KYC documents for verification
- Browse and offer services across categories

<br/>

---

## ✦ Screenshots

<div align="center">

| Splash | Login | Dashboard |
|--------|-------|-----------|
| *Animated brand entry* | *Secure JWT auth* | *Live active jobs* |

| All Jobs | Earnings | Profile |
|----------|----------|---------|
| *Filter by status* | *Revenue + ratings* | *Editable profile* |

| Document KYC | Categories | Notifications |
|--------------|------------|---------------|
| *Auto-verify polling* | *Browse services* | *Real-time updates* |

</div>

<br/>

---

## ✦ Features at a Glance

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🔐  JWT Authentication     →  Secure login + register    │
│   📋  Job Management         →  Accept / reject / complete │
│   💰  Earnings Dashboard     →  Live payment tracking      │
│   ⭐  Rating & Reviews       →  Customer feedback system   │
│   📄  KYC Verification       →  Auto-navigate on approval  │
│   🔔  Notifications          →  Real-time job alerts       │
│   🗂️  Service Categories     →  Browse & add services      │
│   👤  Worker Profile         →  Editable personal info     │
│   🔑  Forgot Password        →  Email reset flow           │
│   🎨  Slate & Teal Theme     →  Consistent design system   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

<br/>

---

## ✦ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.32.6 |
| **Language** | Dart 3.8.1 |
| **State Management** | `setState` + `SharedPreferences` |
| **HTTP Client** | `package:http` |
| **File Upload** | `file_picker` + `http_parser` |
| **Real-time Polling** | `dart:async` Timer |
| **Storage** | `shared_preferences` |
| **Image Storage** | Cloudinary |
| **Backend** | Node.js REST API on Railway |
| **Auth** | JWT Bearer Token |

<br/>

---

## ✦ Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── api/                          ← Centralized API layer
│   │   ├── api_client.dart           ← Base URL lives HERE
│   │   ├── api.dart                  ← Barrel export
│   │   ├── auth_api.dart             ← Login, register, forgot password
│   │   ├── bookings_api.dart         ← Accept, reject, complete jobs
│   │   ├── notifications_api.dart    ← Fetch, read, delete
│   │   ├── payments_reviews_api.dart ← Earnings + ratings
│   │   ├── services_api.dart         ← Categories + worker services
│   │   └── users_api.dart            ← Profile fetch
│   │
│   ├── app_theme.dart                ← Design system (colors, widgets)
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── forgot_password_screen.dart
│   ├── landing_page.dart             ← KYC gate
│   ├── home_page.dart                ← Active jobs + bottom nav
│   ├── all_jobs.dart                 ← Full job history + filters
│   ├── earning_page.dart
│   ├── notification_page.dart
│   ├── profile_page.dart
│   ├── categories_page.dart
│   ├── services_by_category_page.dart
│   └── add_service_page.dart
│
└── verification/
    └── document_verification_page.dart
```

<br/>

---

## ✦ Getting Started
### Prerequisites

```bash
# Verify Flutter installation
flutter --version    # needs ≥ 3.0.0

# Check doctor
flutter doctor
```

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/your-username/call-karigar-worker.git
cd call-karigar-worker

# 2. Install dependencies
flutter pub get

# 3. Add your assets
#    Place mp_logo.png and main_qr.png inside assets/

# 4. Run
flutter run
```

### Changing the Backend URL

All API calls route through a **single file**. To point to a different backend, open `lib/screens/api/api_client.dart` and change one line:

```dart
// ↓ Change this and ONLY this
const String kBaseUrl = "https://your-new-backend.railway.app/api";
```

That's it. Every screen updates automatically.

<br/>

---

## ✦ API Architecture

This app uses a **centralized API layer** — no hardcoded URLs scattered across screens.

```
                     ┌─────────────────────┐
                     │   api_client.dart   │  ← kBaseUrl defined here
                     │  GET / POST / PATCH │
                     │  DELETE / headers   │
                     └──────────┬──────────┘
                                │
           ┌────────────────────┼────────────────────┐
           │                    │                    │
    ┌──────▼──────┐    ┌────────▼──────┐    ┌───────▼───────┐
    │  auth_api   │    │ bookings_api  │    │  services_api │
    │  login      │    │ getBookings   │    │  getCategories│
    │  register   │    │ handleRequest │    │  getAllServices│
    │  forgotPwd  │    │ complete      │    │  addService   │
    └─────────────┘    └───────────────┘    └───────────────┘
           │                    │                    │
    ┌──────▼──────┐    ┌────────▼──────┐    ┌───────▼───────┐
    │  users_api  │    │ payments_api  │    │notifications  │
    │  getProfile │    │ getEarnings   │    │  getAll       │
    │  workerById │    │ getReviews    │    │  markRead     │
    └─────────────┘    └───────────────┘    │  delete       │
                                            └───────────────┘
```

### Screens import via barrel file:
```dart
import 'api/api.dart';  // ← imports everything above at once
```

<br/>

---

## ✦ Key Flows

### 🔐 Authentication Flow
```
Splash → Login → LandingPage (KYC Gate) → HomePage
                     ↓
              Document Upload → Admin Review → Auto-navigate ✓
```

### 📋 Job Booking Flow
```
Incoming Job → Active Jobs Page → Review Details
    ↓               ↓                  ↓
 Notify         Accept / Reject    Mark Complete
    ↓
Status: pending → confirmed → completed
```

### 📄 KYC Verification Flow
```
Upload 4 documents → POST /worker-documents
        ↓
  Status: pending (polls every 5s)
        ↓
  Admin reviews → verified ✓ → Auto navigate to Dashboard
              ↘  rejected  → Re-upload prompt
```

<br/>

---

## ✦ Design System

The app uses a custom **Slate & Teal** theme defined in `app_theme.dart`:

```dart
// Core palette
slate800  = #1E293B   // headers, nav bar
teal500   = #14B8A6   // primary accent, buttons, active states
slate100  = #F1F5F9   // page backgrounds
white     = #FFFFFF   // cards

// Status colors
amber500  = #F59E0B   // pending
green500  = #22C55E   // verified / completed
red500    = #EF4444   // rejected / errors
```

**Reusable components exported from `app_theme.dart`:**

| Widget | Purpose |
|--------|---------|
| `SlateAppBar` | Consistent header with teal bottom border |
| `AppCard` | White card with slate border + inkwell |
| `TealButton` | Full-width primary / outlined button |
| `StatusChip` | Color-coded status pill (pending/confirmed/etc.) |

<br/>

---

## ✦ Environment & Dependencies

```yaml
dependencies:
  flutter:
  http: ^1.0.0
  shared_preferences: ^2.0.0
  file_picker: ^10.0.0
  http_parser: ^4.0.0
  intl: ^0.19.0
  google_fonts: ^6.0.0
  animated_text_kit: ^4.2.0
  socket_io_client: ^2.0.0
```

<br/>

---

## ✦ Contributing

```bash
# 1. Fork the repository
# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Commit your changes
git commit -m "feat: add your feature"

# 4. Push and open a Pull Request
git push origin feature/your-feature-name
```

**Branch naming convention:**
- `feature/` — new features
- `fix/` — bug fixes
- `ui/` — design / theme changes
- `api/` — API integration changes

<br/>

---

## ✦ Roadmap

- [ ] WebSocket integration for real-time job notifications
- [ ] In-app chat with customers
- [ ] Offline mode with local job caching
- [ ] Push notifications (FCM)
- [ ] Multi-language support (Hindi + English)
- [ ] Worker availability toggle
- [ ] Earnings withdrawal integration

<br/>

---

## ✦ License

```
MIT License — feel free to use, modify, and distribute.
See LICENSE file for full terms.
```

<br/>

---

<div align="center">

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Built with ♥ for the workers of Madhya Pradesh
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**[⬆ Back to top](#)**

</div>
