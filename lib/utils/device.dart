import 'package:flutter/foundation.dart';

/// true quando está num celular/tablet: app nativo (Android/iOS)
/// ou navegador mobile. No navegador desktop, false.
///
/// No Flutter web, [defaultTargetPlatform] reflete o sistema do
/// navegador (Android/iOS para navegadores mobile), então a aba
/// Escanear aparece no celular mesmo acessando pela URL.
bool get isMobileDevice {
  if (!kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
