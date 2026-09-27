import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../l10n/app_localizations.dart';

class BankCallSheet extends StatefulWidget {
  const BankCallSheet({super.key, this.openPhone});
  final Future<bool> Function(Uri)? openPhone;
  @override
  State<BankCallSheet> createState() => _BankCallSheetState();
}

class _BankCallSheetState extends State<BankCallSheet> {
  final _number = TextEditingController();
  bool _opening = false;
  bool _failed = false;
  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _call() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _failed = false;
    });
    var opened = false;
    try {
      final uri = Uri(scheme: 'tel', path: _number.text);
      opened =
          await (widget.openPhone?.call(uri) ??
                  launchUrl(uri, mode: LaunchMode.externalApplication))
              .timeout(const Duration(seconds: 5), onTimeout: () => false);
    } catch (_) {
      /* Friendly fallback below. */
    }
    if (!mounted) return;
    if (opened) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _opening = false;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          28,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.contactBankTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(s.bankCallHint),
            const SizedBox(height: 20),
            TextField(
              controller: _number,
              keyboardType: TextInputType.phone,
              maxLength: 15,
              enabled: !_opening,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: s.bankPhoneLabel,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: s.openPhone,
              icon: Icons.call_rounded,
              loading: _opening,
              onPressed: _number.text.length >= 7 ? _call : null,
            ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(s.phoneUnavailable),
              ),
          ],
        ),
      ),
    );
  }
}
