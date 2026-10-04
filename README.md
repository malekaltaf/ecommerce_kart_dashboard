# Ecommerce Kart Dashboard 🛒

A modern, responsive web dashboard built with Flutter and Firebase for managing an ecommerce platform's inventory and customer orders. 

This is a **portfolio project** demonstrating the use of Flutter for web applications, state management, and custom authentication flows using Firebase Firestore.

## ✨ Features

- **MVVM Architecture:** Clean separation of concerns using Models, Views, ViewModels, and Repositories.
- **State Management:** Utilizes the `provider` package for efficient state management and reactivity.
- **Custom Authentication:** Implements a custom authentication flow using Firestore and SHA-256 password hashing, rather than standard Firebase Auth, to demonstrate custom backend logic.
- **Inventory Management:** Full CRUD (Create, Read, Update, Delete) functionality for managing the product catalog.
- **Order Management:** View customer orders and perform actions like Approve or Reject.
- **Material 3 Design:** Beautiful, expressive UI utilizing Flutter's latest Material 3 design system.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Web & Mobile ready)
- **Language:** Dart
- **Backend:** Firebase (Cloud Firestore)
- **State Management:** Provider
- **Security:** `crypto` (SHA-256 hashing)

## 🏗️ Project Structure

The project follows a scalable MVVM pattern:
- `/models`: Data classes for Users, Items, and Orders.
- `/repositories`: Abstraction layers for interacting directly with Firebase Firestore.
- `/viewmodels`: Business logic and state holders connected to the UI.
- `/views`: Flutter UI widgets and screens.

## 🚀 Getting Started

To run this project locally, follow these steps:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (v3.13+)
- A Firebase project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/ecommerce_kart_dashboard.git
   cd ecommerce_kart_dashboard
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Since this project uses Firebase Firestore, you need to link it to your own Firebase project.
   - Create a project in the [Firebase Console](https://console.firebase.google.com/).
   - Set up Cloud Firestore.
   - Run the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) to generate your own `firebase_options.dart`:
     ```bash
     flutterfire configure
     ```

4. **Run the App:**
   ```bash
   flutter run -d chrome
   ```

## 🛡️ Note on Security Rules
Because this project uses a custom authentication system (checking passwords manually against a Firestore `users` collection), standard Firebase Auth `request.auth` rules cannot be applied. For a real production app, it is highly recommended to migrate to standard Firebase Authentication to fully secure the Firestore database rules.

---
*Built with ❤️ using Flutter.*
