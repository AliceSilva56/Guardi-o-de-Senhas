import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeWrapper extends StatelessWidget {
  final Widget child;
  
  const ThemeWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Theme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: child,
      ),
    );
  }
}
