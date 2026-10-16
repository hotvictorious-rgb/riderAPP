# Victorious MARKET — Sovereign Rider & Dispatch Terminal (`riderAPP`)

> **FinTech-Grade Omnichannel Courier & Fleet Operating System**  
> Sovereign Terminal for Motorbike Couriers, Cargo Van Drivers, and Logistics Fleet Companies.  
> Strictly integrated with the `newVmarket` backend delivery handshake, cryptographic courier pickup verification, doorstep 6-digit customer OTP completion, and 48-hour bank cooldown security.

---

## 🛡️ Core Security Invariants & Principles

1. **Cryptographic 6-Digit Vendor Handover Code**
   - When a rider arrives at a merchant shop to pick up an order, they present their device's unique 6-digit pickup verification code (`pickup_verification_code`).
   - The vendor enters or validates this code to certify physical package handover, updating order status from `ready_for_pickup` to `out_for_delivery`.
2. **Doorstep Customer Delivery Completion OTP**
   - The dispatch courier cannot mark an order delivered on their own.
   - At the customer's delivery doorstep, the customer shares their 6-digit delivery security PIN (`delivery_verification_code`).
   - Validating this code via `/api/v1/rider/orders/verify-delivery-otp`:
     - Sets order status to `delivered`.
     - Automatically releases the 100% customer delivery fee into the Rider's Wallet balance.
     - Enqueues customer cashback rewards and creates an immutable audit trail.
3. **Strict Mathematical Role Invariant (`user_type === 'rider'` only)**
   - **Logistics Companies Blocked**: A logistics company admin account (`user_type === 'logistics_company'`) **cannot** log into this app. Company owners and fleet managers must manage fleets via the web-based Logistics Fleet Desk (`/logistics/login`).
   - **Merchants & Customers Blocked**: Vendors (`vendor`) and buyers (`customer`) receive an immediate `403 Forbidden` response and their sessions are purged immediately.
   - **Zero Token Leakage**: Tokens issued to non-riders are rejected at the API gateway and purged from local storage on the terminal.
4. **Mandatory Logistics Company Affiliation Invariant**
   - **All Riders Must Belong to a Logistics Company**: Independent, unassigned rogue couriers cannot log in or operate dispatch terminals.
   - Every rider profile (`RiderProfile`) must have a non-null `logistics_company_id` linked to an active `LogisticsCompanyProfile`.
   - If a rider's parent fleet is inactive or suspended, terminal authentication and package dispatch are immediately blocked.
5. **Anti-Brute-Force Lockout Shield**
   - Protects delivery verification against OTP brute-forcing.
   - After 5 consecutive failed attempts on an order, the system locks verification for 15 minutes, safeguarding buyers and couriers against code interception.
6. **48-Hour Bank Cooldown Anti-Theft HUD**
   - If a courier changes their linked 10-digit NUBAN bank account, disbursements are locked for 48 hours to prevent unauthorized account drain if a courier's phone is stolen.

---

## 🎨 Visual Design Language

- **Primary Colors:** Royal Purple (`#5E17EB`), Deep Obsidian Dark Background (`#080414`), Midnight Surface Cards (`#13092A`), Card Borders (`#2A1654`).
- **Dispatch Accents:** Neon Emerald Dispatch Green (`#10B981` — On Duty, GPS Active, Completed), Sovereign Gold (`#FFD700` — Wallet & Delivery Fees), Electric Amber (`#F59E0B` — Urgent Shop Pickups).
- **Tactile Duty Radar:** One-tap pulsing radar switch allowing couriers to toggle between Online (accepting routes) and Offline (standby).

---

## 📱 Architecture & Directory Tree

```
riderAPP/
├── assets/
│   └── images/
│       ├── vm_icon.jpg              # Official VMarket App Icon
│       └── vic_logo.webp             # Victorious Brand Identity
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart    # 7 Sovereign Rider REST Routes
│   │   │   ├── app_colors.dart       # Obsidian, Emerald, Gold & Purple Palette
│   │   │   └── app_constants.dart    # Storage keys, timeouts & validation rules
│   │   ├── network/
│   │   │   ├── api_client.dart       # Dio client with Bearer Auth interceptor
│   │   │   └── api_exceptions.dart   # RFC-7807 error parser
│   │   ├── services/
│   │   │   └── storage_service.dart  # SharedPreferences with duty status persistence
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Material 3 Obsidian FinTech Theme
│   │   └── utils/
│   │       └── currency_formatter.dart# ₦ Naira currency formatter
│   ├── models/
│   │   ├── rider_profile_model.dart  # Vehicle type, license plate, fleet company
│   │   ├── rider_dashboard_model.dart# Wallet balance, today's pay, trips count
│   │   └── delivery_assignment_model.dart # Shop pickup coords, customer doorstep, OTPs
│   ├── providers/                    # PURE PROVIDER STATE MANAGEMENT ONLY
│   │   ├── rider_auth_provider.dart
│   │   ├── rider_dashboard_provider.dart
│   │   └── rider_delivery_provider.dart
│   ├── widgets/
│   │   ├── rider_duty_switch_card.dart     # Tactile radar switch with pulse glow
│   │   ├── rider_earnings_card.dart        # Daily earnings & wallet balance HUD
│   │   ├── active_delivery_card.dart       # Multi-stop pickup & route guidance
│   │   └── customer_delivery_otp_dialog.dart# 6-digit doorstep PIN input modal
│   ├── screens/
│   │   ├── auth/rider_login_screen.dart    # Demo credentials quick fill (Motorbike / Van)
│   │   ├── shell/rider_shell_screen.dart   # 4-tab persistent navigation shell
│   │   ├── dashboard/rider_dashboard_screen.dart # Realtime radar, earnings & active trips
│   │   ├── deliveries/rider_deliveries_screen.dart # Active dispatch trips stream
│   │   ├── history/rider_history_screen.dart # Completed deliveries & earnings ledger
│   │   ├── wallet/rider_wallet_screen.dart # Payout withdrawal & 48h cooldown HUD
│   │   └── profile/rider_profile_screen.dart # Vehicle details & dynamic IP configurator
│   └── main.dart                     # MultiProvider root setup
├── preview/                          # Interactive Web Simulator
│   ├── index.html                    # Smartphone Frame & Dispatch Terminal Simulator
│   ├── style.css                     # FinTech Dispatch CSS Design System
│   ├── app.js                        # Full Reactive State Engine
│   └── assets/                       # Preview brand assets
├── pubspec.yaml                      # Flutter dependencies (Provider, Dio, Google Fonts)
└── analysis_options.yaml             # Strict Dart linter configuration
```

---

## 🚀 How to Run

### 1. Interactive Web Simulator (Zero-Install Browser Preview)
The preview is served locally on port **3002**:
- Open [http://127.0.0.1:3002](http://127.0.0.1:3002) in your browser.
- **Test Online Duty**: Tap the power button on the Radar card to toggle Online / Offline.
- **Test Merchant Handover**: Tap "Merchant Verified Handover" on `VM-ORD-9081` (revealing Courier PIN `482910`).
- **Test Doorstep OTP**: Tap "Arrived at Doorstep • Enter Customer PIN" ➔ Enter `883921` ➔ Watch order complete and `₦ 2,500.00` deposit into Rider Wallet!

### 2. Flutter Mobile Application (Android / iOS / Desktop)
```powershell
cd C:\Users\USER\Downloads\riderAPP
flutter pub get
flutter run
```

### 3. Backend Test Suite Verification (`newVmarket`)
```powershell
cd C:\Users\USER\Downloads\newVmarket\backend
php artisan test --filter=RiderApiTerminalTest
php artisan test --filter=VendorRiderPickupHandshakeTest
```
Result: **12 passed, 204 assertions green**.
