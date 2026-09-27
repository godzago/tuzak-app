import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/engine/rule_engine.dart';

class MessageInputCard extends StatelessWidget {
  const MessageInputCard({
    super.key,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Container(
      decoration: ClaySurface.decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.messageLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    tooltip: s.clear,
                    icon: const Icon(Icons.close_rounded, size: 17),
                    onPressed: enabled
                        ? () {
                            controller.clear();
                            onChanged('');
                          }
                        : null,
                  )
                else
                  const SizedBox(height: 48),
              ],
            ),
          ),
          TextField(
            key: const Key('messageInput'),
            controller: controller,
            enabled: enabled,
            onChanged: onChanged,
            minLines: 5,
            maxLines: 8,
            maxLength: RuleEngine.maxMessageLength,
            enableSuggestions: false,
            autocorrect: false,
            enableIMEPersonalizedLearning: false,
            keyboardType: TextInputType.multiline,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
            decoration: InputDecoration(
              hintText: s.messageHint,
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                const Icon(
                  Icons.short_text_rounded,
                  size: 19,
                  color: Color(0xFFB4BECC),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.characterCount(controller.text.length),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
