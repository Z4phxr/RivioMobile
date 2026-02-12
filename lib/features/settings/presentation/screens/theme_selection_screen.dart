import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_definition.dart';
import '../../../../core/providers/app_theme_provider.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);

    return Scaffold(
      appBar: AppBar(),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: AppThemeRegistry.themes.length,
        itemBuilder: (context, index) {
          final theme = AppThemeRegistry.themes[index];
          final isSelected = currentTheme.key == theme.key;

          return _ThemeTile(
            theme: theme,
            isSelected: isSelected,
            onTap: () => _selectTheme(context, ref, theme),
          );
        },
      ),
    );
  }

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeDefinition theme,
  ) async {
    await ref.read(appThemeProvider.notifier).setTheme(theme.key);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${theme.displayName} theme applied'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

class _ThemeTile extends StatelessWidget {
  final AppThemeDefinition theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          width: 3,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Theme name
              Text(
                theme.displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.primaryColor : null,
                ),
              ),
              const SizedBox(height: 12),

              // Gradient preview bar
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: theme.gradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.primaryColor,
                  size: 24,
                )
              else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
