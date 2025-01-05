import 'package:flutter/material.dart';

import '../style.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final bool isExpanded;
  final VoidCallback? onExpand;
  final Color? iconColor;

  const SectionCard({
    Key? key,
    required this.title,
    this.icon,
    required this.child,
    this.isExpanded = true,
    this.onExpand,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppStyle.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onExpand,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 20, color: iconColor ?? AppStyle.iconColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: AppStyle.sectionTitleStyle,
                  ),
                  if (onExpand != null) ...[
                    const Spacer(),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppStyle.iconColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
