# ViewKigali
# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate different locations including hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions. It is built with Firebase Authentication, Cloud Firestore, Google Maps integration, and BLoC state management.

## SIX FEATURES 

### 1. Authentication
- Email and password sign-up via Firebase Authentication
- Email verification enforced before accessing the app
- Secure login and logout
- User profile automatically created in Firestore on sign-up, linked by Firebase UID

### 2. Location Listings (CRUD)
- **Create** new service/place listings with full details
- **Read** all listings in a shared real-time directory called "Home"
- **Update** listings owned by user
- **Delete** listings owned by user
- All changes are reflected instantly in the UI via BLoC state management

### 3. Search & Filtering
- Search listings by name 
- Filter listings by category
- Results update dynamically as Firestore data changes

### 4. Detail Page & Map Integration
- Full detail view for each listing
- Embedded Google Map with coordinates
- launches Google Maps with direction to the location

### 5. Navigation
Bottom navigation bar with four screens:
1. **Home** – Browse all listings
2. **My Listings** – View, edit, and delete your own listings
3. **Map View** – See all listings plotted on a full-screen map
4. **Settings** – User profile and notification preferences

### 6. Settings
- Toggle for enabling/disabling location-based notifications 
- Logout button

## Project Folder Structure

```
lib/
├── main.dart
├── app.dart                       
├── models/
│   ├── listing_model.dart
│   └── user_model.dart
├── services/
│   ├── auth_service.dart
│   ├── listing_service.dart
│   └── user_service.dart
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── listing/
│   │   ├── listing_bloc.dart
│   │   ├── listing_event.dart
│   │   └── listing_state.dart
│   ├── my_listings/
│   │   ├── my_listings_bloc.dart
│   │   ├── my_listings_event.dart
│   │   └── my_listings_state.dart
│   ├── search_filter/
│   │   └── search_filter_cubit.dart
│   └── notification/
│       └── notification_cubit.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── directory/
│   │   └── directory_screen.dart
│   ├── my_listings/
│   │   └── my_listings_screen.dart
│   ├── listing_detail/
│   │   └── listing_detail_screen.dart
│   ├── add_edit_listing/
│   │   └── add_edit_listing_screen.dart
│   ├── map_view/
│   │   └── map_view_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   ├── listing_card.dart
│   ├── category_filter_chips.dart
│   └── search_bar_widget.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```


## Firebase Setup

### 1. Create Firebase Project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a new project named `kigali-city-directory`
3. Enable **Google Analytics** (optional)

### 2. Register Android App
1. Add Android app with package name: `com.yourname.kigali_directory`
2. Download `google-services.json` → place in `android/app/`
3. Add the Google Services classpath and plugin to `android/build.gradle` and `android/app/build.gradle`
4. Set `minSdkVersion` to `23` in `android/app/build.gradle`

### 3. Register iOS App
1. Add iOS app with bundle ID: `com.yourname.kigaliDirectory`
2. Download `GoogleService-Info.plist` → place in `ios/Runner/`

### 4. Enable Authentication
1. In Firebase Console → Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Email verification** (handled in app code)

### 5. Set Up Firestore
1. Firebase Console → Firestore Database → Create database
2. Start in **production mode**
3. Choose region: `europe-west1` (closest to Kigali)
4. Apply security rules (see Firestore Security Rules section above)



### 8. FlutterFire CLI (Recommended)
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=kigali-city-directory
```
This auto-generates `lib/firebase_options.dart`.

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on Android emulator or physical device
flutter run

# Build release APK
flutter build apk --release
```


## Author

**Norette Atete**  
Course: Mobile Application development  
Institution: ALU  
