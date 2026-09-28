import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habits/components/app_text_field.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Importe en céntimos enteros formateado con la moneda ISO y el locale
/// (`1.234,50 €`, `$1,234.50`). Nunca hay `double` en el modelo de dinero.
String formatMoney(int cents, String currency, String locale) {
  final format = NumberFormat.simpleCurrency(locale: locale, name: currency);
  return format.format(cents / 100);
}

/// Igual que [formatMoney] pero con signo explícito para deltas (`+12,00 €`).
String formatSignedMoney(int cents, String currency, String locale) {
  final base = formatMoney(cents.abs(), currency, locale);
  if (cents == 0) return base;
  return cents > 0 ? '+$base' : '−$base';
}

/// Convierte lo escrito por el usuario ("12,5", "12.50", "1200") a
/// céntimos. Acepta coma o punto como separador y como máximo dos
/// decimales; null si no es un importe válido.
int? parseAmountToCents(String raw) {
  final text = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (text.isEmpty) return null;
  final match = RegExp(r'^(\d{1,9})(?:\.(\d{0,2}))?$').firstMatch(text);
  if (match == null) return null;
  final whole = int.parse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  return whole * 100 + int.parse(fraction);
}

/// Texto editable a partir de céntimos ("12,50" según el locale).
String amountTextFromCents(int cents, String locale) {
  final separator = NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;
  final whole = cents ~/ 100;
  final fraction = cents % 100;
  if (fraction == 0) return '$whole';
  return '$whole$separator${fraction.toString().padLeft(2, '0')}';
}

/// Entrada de importe: teclado decimal, separador según el locale, símbolo
/// de moneda como sufijo y devolución en céntimos enteros por [onChanged].
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.currency,
    this.label,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String currency;
  final String? label;
  final bool autofocus;
  final ValueChanged<int?>? onChanged;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final symbol = NumberFormat.simpleCurrency(
      locale: locale,
      name: currency,
    ).currencySymbol;
    return AppTextField(
      controller: controller,
      label: label,
      prefixIcon: PhosphorIconsBold.coins,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.none,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(12),
      ],
      suffix: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          symbol,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      onChanged: (value) => onChanged?.call(parseAmountToCents(value)),
      onSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
