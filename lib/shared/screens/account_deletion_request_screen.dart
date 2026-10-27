import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AccountDeletionRequestScreen extends StatefulWidget {
  const AccountDeletionRequestScreen({
    super.key,
    required this.onSubmit,
    this.isVendor = false,
  });

  final Future<String?> Function(String reason, String? description) onSubmit;
  final bool isVendor;

  static Future<bool?> show({
    required BuildContext context,
    required Future<String?> Function(String reason, String? description)
    onSubmit,
    bool isVendor = false,
  }) => Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) =>
          AccountDeletionRequestScreen(onSubmit: onSubmit, isVendor: isVendor),
    ),
  );

  @override
  State<AccountDeletionRequestScreen> createState() =>
      _AccountDeletionRequestScreenState();
}

class _AccountDeletionRequestScreenState
    extends State<AccountDeletionRequestScreen> {
  static const _customerReasons = [
    "I don't need this app anymore",
    'Found a better platform / alternative',
    'Privacy or data security concerns',
    'Too many notifications or emails',
    'App is difficult to navigate',
    'Other reasons',
  ];
  static const _vendorReasons = [
    'Closing or pausing my business',
    'Subscription prices are too high',
    'Not receiving enough booking leads',
    'Switching to offline / personal marketing',
    'Technical issues or app bugs',
    'Other reasons',
  ];

  final _descriptionController = TextEditingController();
  String? _selectedReason;
  String? _error;
  bool _submitting = false;

  List<String> get _reasons =>
      widget.isVendor ? _vendorReasons : _customerReasons;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_selectedReason == null) {
      setState(() => _error = 'Choose a reason before continuing.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final description = _descriptionController.text.trim();
      final error = await widget.onSubmit(
        _selectedReason!,
        description.isEmpty ? null : description,
      );
      if (!mounted) return;
      if (error == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _error = error);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'Could not submit the request. Please try again.',
      );
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    const canvas = Color(0xFFFFFBF7);
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          backgroundColor: canvas,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'Account deletion',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF1E4DE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person_remove_alt_1_rounded,
                              color: AppColors.error,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'We’re sorry to see you go',
                            style: TextStyle(
                              fontSize: 23,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF252126),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tell us why you’re leaving. Your feedback helps us improve Widoora.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5E8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF9A6415),
                                  size: 19,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'After submission, account access may be disabled. Your deletion request will be processed within 24–48 hours.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.45,
                                      color: Color(0xFF73521F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Reason for leaving',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF252126),
                            ),
                          ),
                          TextSpan(
                            text: '  *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Select one option to continue',
                      style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 11),
                    ..._reasons.map(_buildReasonTile),
                    const SizedBox(height: 16),
                    const Text(
                      'Additional feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF252126),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Optional',
                      style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: _descriptionController,
                      enabled: !_submitting,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Share any details you’d like us to know',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE9DFDA),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE9DFDA),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEFE7E2))),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.error.withValues(
                              alpha: 0.55,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Submit deletion request'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    final selected = reason == _selectedReason;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _submitting
              ? null
              : () => setState(() {
                  _selectedReason = reason;
                  _error = null;
                }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE9DFDA),
                width: selected ? 1.5 : 1,
              ),
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.045)
                  : Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.grey,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF332E32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
