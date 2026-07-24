import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/bebia_brand_mark.dart';

class BebiaBootstrap extends StatefulWidget {
  const BebiaBootstrap({required this.initialize, super.key});

  final Future<void> Function() initialize;

  @override
  State<BebiaBootstrap> createState() => _BebiaBootstrapState();
}

class _BebiaBootstrapState extends State<BebiaBootstrap> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = Future<void>.sync(widget.initialize);
  }

  void _retry() {
    setState(() {
      _initialization = Future<void>.sync(widget.initialize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const BebiaApp();
        }
        return MaterialApp(
          title: 'Bebia',
          debugShowCheckedModeBanner: false,
          theme: _bootstrapTheme(Brightness.light),
          darkTheme: _bootstrapTheme(Brightness.dark),
          home: _BootstrapScreen(
            error: snapshot.hasError ? snapshot.error : null,
            onRetry: _retry,
          ),
        );
      },
    );
  }

  ThemeData _bootstrapTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F6B5A),
      brightness: brightness,
      surface: dark ? const Color(0xFF17211D) : const Color(0xFFFFFCF7),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF101714)
          : const Color(0xFFF7F4EE),
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const BebiaBrandMark(size: 84),
                const SizedBox(height: 24),
                Text(
                  'Bebia',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 12),
                if (error == null)
                  SizedBox(
                    width: 88,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  )
                else ...<Widget>[
                  Text(
                    'Aplikaci se nepodařilo připravit. Vaše data zůstala beze změny.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Zkusit znovu'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
