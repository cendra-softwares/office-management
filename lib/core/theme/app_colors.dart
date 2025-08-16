import 'package:flutter/material.dart';

/// Centralized color palette for the app
/// Inspired by the Cendra SaaS lavender + teal UI
class AppColors {
  // 🌙 Primary brand colors
  static const Color primaryLavender = Color(0xFF9C8CF0); 
  // Use for buttons, highlights, and main brand accents

  static const Color secondaryTeal = Color(0xFF4CC9B0); 
  // Use for secondary buttons, hover states, subtle accents

  // 🎨 Backgrounds
  static const Color backgroundLight = Color(0xFFF7F8FA); 
  // General light background for app screens

  static const Color backgroundDark = Color(0xFF1C1C28); 
  // Dark mode background or elevated containers

  // ✨ Surface colors (cards, panels, navbars)
  static const Color surfaceWhite = Color(0xFFFFFFFF); 
  // Clean card backgrounds

  static const Color surfaceLavenderTint = Color(0xFFEDEBFA); 
  // Subtle tinted panels, sidebars

  // 🖋️ Text colors
  static const Color textPrimary = Color(0xFF1D1D1F); 
  // Main text on light backgrounds

  static const Color textSecondary = Color(0xFF6B7280); 
  // Subtitles, secondary labels

  static const Color textInverse = Color(0xFFFFFFFF); 
  // Text on dark/primary backgrounds

  // 🚨 Status colors
  static const Color success = Color(0xFF2ECC71); 
  static const Color warning = Color(0xFFF1C40F); 
  static const Color error = Color(0xFFE74C3C); 
  // Use these in snackbar alerts, badges, validation states
}
