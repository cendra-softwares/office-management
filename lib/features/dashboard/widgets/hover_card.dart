import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HoverCard extends StatefulWidget {
  final Widget title;
  final Widget description;
  final Widget child;
  final VoidCallback onTap;

  const HoverCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    required this.onTap,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MouseRegion(
      onHover: (event) {
        if (!_isHovered) {
          setState(() {
            _isHovered = true;
          });
        }
      },
      onExit: (event) {
        if (_isHovered) {
          setState(() {
            _isHovered = false;
          });
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primary.withOpacity(0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.child,
              const SizedBox(height: 12),
              widget.title,
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: theme.textTheme.muted.copyWith(fontSize: 12),
                child: widget.description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
