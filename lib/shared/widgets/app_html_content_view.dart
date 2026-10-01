import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Premium HTML Renderer for Terms, Privacy, Policies, and CMS content
class AppHtmlContentView extends StatelessWidget {
  final String htmlContent;
  final TextStyle? baseTextStyle;
  final EdgeInsetsGeometry padding;

  const AppHtmlContentView({
    super.key,
    required this.htmlContent,
    this.baseTextStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
  });

  @override
  Widget build(BuildContext context) {
    if (htmlContent.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: HtmlWidget(
        htmlContent,
        textStyle: baseTextStyle ??
            GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF2D3748),
              height: 1.6,
            ),
        onTapUrl: (url) async {
          try {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return true;
            }
          } catch (_) {}
          return false;
        },
        customStylesBuilder: (element) {
          switch (element.localName?.toLowerCase()) {
            case 'h1':
              return {
                'font-size': '20px',
                'font-weight': '800',
                'color': '#6B1D28',
                'margin-top': '18px',
                'margin-bottom': '8px',
                'line-height': '1.3',
              };
            case 'h2':
              return {
                'font-size': '17px',
                'font-weight': '700',
                'color': '#8B1A2E',
                'margin-top': '16px',
                'margin-bottom': '6px',
                'line-height': '1.35',
              };
            case 'h3':
              return {
                'font-size': '15px',
                'font-weight': '700',
                'color': '#1A1A1A',
                'margin-top': '14px',
                'margin-bottom': '6px',
                'line-height': '1.4',
              };
            case 'h4':
            case 'h5':
            case 'h6':
              return {
                'font-size': '14px',
                'font-weight': '700',
                'color': '#1A1A1A',
                'margin-top': '10px',
                'margin-bottom': '4px',
              };
            case 'p':
              return {
                'margin-bottom': '10px',
                'line-height': '1.6',
                'color': '#374151',
              };
            case 'ul':
            case 'ol':
              return {
                'margin-top': '4px',
                'margin-bottom': '12px',
                'padding-left': '20px',
              };
            case 'li':
              return {
                'margin-bottom': '6px',
                'line-height': '1.55',
                'color': '#374151',
              };
            case 'a':
              return {
                'color': '#8B1A2E',
                'text-decoration': 'underline',
                'font-weight': '600',
              };
            case 'b':
            case 'strong':
              return {
                'font-weight': '700',
                'color': '#111827',
              };
            case 'blockquote':
              return {
                'background-color': '#FDF9F3',
                'border-left': '3.5px solid #D4AF37',
                'padding': '10px 14px',
                'margin': '12px 0',
                'border-radius': '0 8px 8px 0',
                'color': '#4A5568',
              };
            case 'hr':
              return {
                'border-color': '#E5E7EB',
                'margin': '16px 0',
              };
            case 'table':
              return {
                'border-collapse': 'collapse',
                'width': '100%',
                'margin': '12px 0',
              };
            case 'th':
              return {
                'background-color': '#F7FAFC',
                'padding': '8px 10px',
                'border': '1px solid #E2E8F0',
                'font-weight': '700',
                'color': '#1A202C',
                'text-align': 'left',
              };
            case 'td':
              return {
                'padding': '8px 10px',
                'border': '1px solid #E2E8F0',
                'color': '#4A5568',
              };
          }
          return null;
        },
      ),
    );
  }
}
