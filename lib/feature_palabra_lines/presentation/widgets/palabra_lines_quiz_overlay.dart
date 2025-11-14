import 'package:flutter/material.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';

/// Overlay that pauses the board and displays the Spanish vocabulary quiz.
class PalabraLinesQuizOverlay extends StatelessWidget {
  const PalabraLinesQuizOverlay({
    required this.question,
    required this.onOptionTap,
    super.key,
  });

  final PalabraLinesQuestionState question;
  final void Function(int index) onOptionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wrongAttempt = question.wrongAttempts > 0;
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 250),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Material(
                color: theme.colorScheme.surface,
                elevation: 12,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Traduce esta palabra',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.entry.spanish,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (wrongAttempt) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'Inténtalo otra vez',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, boxConstraints) {
                          final availableWidth =
                              boxConstraints.maxWidth.isFinite
                              ? boxConstraints.maxWidth
                              : 320.0;
                          final computedWidth =
                              (availableWidth - 12).clamp(120.0, 420.0) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List<Widget>.generate(
                              question.options.length,
                              (index) {
                                final option = question.options[index];
                                return SizedBox(
                                  width: computedWidth,
                                  child: ElevatedButton(
                                    onPressed: () => onOptionTap(index),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: theme
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.9),
                                      textStyle: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(option),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
