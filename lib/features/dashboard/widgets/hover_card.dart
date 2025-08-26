import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onTap,
  });

  final Widget title;
  final Widget description;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ShadCard(
          backgroundColor: _isHovered ? theme.colorScheme.muted : theme.colorScheme.card,
          title: widget.title,
          description: widget.description,
          child: widget.child,
        ),
      ),
    );
  }
}