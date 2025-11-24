import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class ErrorOverlay extends StatelessWidget {
  final List<String> messages;
  final String? title;
  final String? instruction;

  /// messages: one or more descriptive messages. If the first message is
  /// short it will be used as the title and the remainder shown as details.
  /// Optionally provide [title] and [instruction] to override defaults.
  const ErrorOverlay({super.key, required this.messages, this.title, this.instruction});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap:
                () {}, // Prevents taps on the container from closing the overlay
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
              constraints: BoxConstraints(maxWidth: responsive.wp(80)),
              decoration: BoxDecoration(
                color: AppColors.lightMintGreen,
                borderRadius: BorderRadius.circular(responsive.sp(3.1)),
                border: Border.all(color: Colors.red.shade700, width: responsive.sp(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: responsive.hp(1.5)),
                    child: IconButton(
                      icon: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.red.shade700, Colors.red.shade500],
                          ).createShader(bounds);
                        },
                        child: Icon(
                          Icons.error_outline,
                          size: responsive.sp(4),
                          color: Colors.red.shade700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      iconSize: responsive.sp(6),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(responsive.wp(5), responsive.hp(1), responsive.wp(5), responsive.hp(2.5)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Determine title and body from provided values
                          Builder(builder: (context) {
                            final rawTitle = title;
                            String titleToShow;
                            String bodyToShow = '';

                            if (rawTitle != null && rawTitle.isNotEmpty) {
                              titleToShow = rawTitle;
                              bodyToShow = messages.join('\n');
                            } else if (messages.isNotEmpty) {
                              // If first message is short, use it as title
                              if (messages.first.length <= 60 && messages.length > 1) {
                                titleToShow = messages.first;
                                bodyToShow = messages.sublist(1).join('\n');
                              } else if (messages.length == 1 && messages.first.length <= 80) {
                                // Single, reasonably short message -> show as title with optional instruction
                                titleToShow = messages.first;
                                bodyToShow = instruction ?? '';
                              } else {
                                // Long first message -> use generic title and show full message as body
                                titleToShow = 'Fout';
                                bodyToShow = messages.join('\n');
                              }
                            } else {
                              titleToShow = 'Fout';
                              bodyToShow = instruction ?? '';
                            }

                            return Column(
                              children: [
                                Text(
                                  titleToShow,
                                  style: AppTextTheme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.fontSize(20),
                                    color: Colors.red.shade700,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: responsive.spacing(12)),
                                if (bodyToShow.isNotEmpty) ...[
                                  Text(
                                    bodyToShow,
                                    style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.18),
                                          offset: const Offset(0, 2),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: responsive.spacing(8)),
                                ],
                                // If an instruction was not provided and there is no body,
                                // show a small default guidance line.
                                if ((instruction == null || instruction!.isEmpty) && bodyToShow.isEmpty)
                                  Text(
                                    'Controleer de invoer en probeer het opnieuw.',
                                    style: AppTextTheme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
