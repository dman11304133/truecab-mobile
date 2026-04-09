# TruCab Passenger App: Feature Roadmap

This document tracks approved features for future implementation. Use this as a reference for client billing and development milestones.

## 1. Premium "Glassmorphism" UI Redesign (IN PROGRESS)
- **Goal**: Transform the traditional Material Design into a modern, high-end "frosted glass" aesthetic.
- **Components**: Bottom sheets, map overlays, prayer/alert dialogs.
- **Tech**: `BackdropFilter`, `ImageFilter.blur`, and custom gradient borders.

## 2. Driver Tipping System
- **Goal**: Allow passengers to tip drivers after a successful trip.
- **Integration**: Rating screen and Invoice screen.
- **Wallet**: Direct deduction from passenger wallet to driver wallet.

## 3. Native "Follow My Ride" Sharing
- **Goal**: Enhanced live tracking web-page for shared links.
- **Detail**: Beautiful, interactive map for family/friends tracking a live trip.

## 4. Split Fare
- **Goal**: Enable multiple passengers to share the cost of a single ride.
- **Logic**: Automated wallet deductions for all participating passengers.

## 5. Biometric Authentication
- **Goal**: Use FaceID/Fingerprint for fast login and secure payments.
- **Benefit**: Increases security and provides a "pro" user experience.

## 6. Codebase Modularization
- **Goal**: Refactor `booking_confirmation.dart` (10k lines) into smaller components.
- **Benefit**: Improves app performance, reduces bugs, and makes future feature additions faster.
