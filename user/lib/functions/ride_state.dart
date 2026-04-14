import 'package:flutter/material.dart';

// --- Shared Ride State globals ---

Map userRequestData = {};
// Snapshot of the last completed ride — kept alive for Invoice & Review pages
Map completedRideSnapshot = {};

List etaDetails = [];
dynamic choosenVehicle;
int waitingTime = 0;
bool ismulitipleride = false;

// Shared between functions, booking_confirmation, etc.
bool noDriverFound = false;
bool tripReqError = false;
String tripError = '';
List rentalOption = [];
int rentalChoosenOption = 0;

// Polyline states
List fmpoly = [];
bool polyGot = false;
