import 'package:flutter/material.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.onCreateProfile,
    required this.onConnectParent,
    super.key,
  });

  final VoidCallback onCreateProfile;
  final VoidCallback onConnectParent;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _pageCount = 5;

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _pageCount - 1) {
      Navigator.pop(context);
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _openCreateProfile() {
    Navigator.pop(context);
    widget.onCreateProfile();
  }

  void _openConnectParent() {
    Navigator.pop(context);
    widget.onConnectParent();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Průvodce',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Přeskočit'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _page = value),
                children: [
                  _OnboardingPage(
                    imageAsset: 'assets/illustrations/feeding_illustration.png',
                    title: 'Sledování krmení',
                    subtitle:
                        'Rychle uložíš krmení a později uvidíš, jak se mění intervaly během dne.',
                    children: const [
                      _OnboardingPoint(
                        title: 'Rychlý zápis',
                        text:
                            'Krmení, spánek, přebalení a pláč uložíš pár klepnutími.',
                      ),
                      _OnboardingPoint(
                        title: 'Souvislosti',
                        text:
                            'Doporučení můžou zohlednit čas od posledního krmení.',
                      ),
                    ],
                  ),
                  const _OnboardingPage(
                    imageAsset: 'assets/illustrations/sleep_illustration.png',
                    title: 'Spánek a rytmus',
                    subtitle:
                        'Záznamy spánku pomáhají poznat, kdy se blíží další únavové okno.',
                    children: [
                      _OnboardingPoint(
                        title: 'Denní rytmus',
                        text:
                            'Aplikace postupně skládá obraz běžného dne dítěte.',
                      ),
                      _OnboardingPoint(
                        title: 'Historie',
                        text:
                            'V Přehledu můžeš historii filtrovat, otevřít a upravit.',
                      ),
                      _OnboardingPoint(
                        title: 'AI pláč',
                        text:
                            'Analýza pláče pracuje s pravděpodobností, ne s lékařskou diagnózou.',
                      ),
                    ],
                  ),
                  const _OnboardingPage(
                    imageAsset: 'assets/illustrations/crying_illustration.png',
                    title: 'Pláč a AI analýza',
                    subtitle:
                        'Pláč můžeš uložit ručně nebo zkusit audio analýzu jako podpůrný signál.',
                    children: [
                      _OnboardingPoint(
                        title: 'Kontext',
                        text:
                            'Výsledek se dívá i na poslední události, nejen na samotný zvuk.',
                      ),
                      _OnboardingPoint(
                        title: 'Bez diagnózy',
                        text:
                            'AI výstup je doporučení pro další krok, ne lékařský závěr.',
                      ),
                    ],
                  ),
                  const _OnboardingPage(
                    imageAsset: 'assets/illustrations/care_illustration.png',
                    title: 'Důvěra a soukromí',
                    subtitle:
                        'Rodičovská aplikace musí být rychlá, srozumitelná a bezpečná na každodenní používání.',
                    children: [
                      _OnboardingPoint(
                        title: 'Lokální historie',
                        text:
                            'Záznamy držíš přímo v aplikaci a máš je pod kontrolou.',
                      ),
                      _OnboardingPoint(
                        title: 'Upravitelné záznamy',
                        text:
                            'V Přehledu můžeš data kdykoli otevřít, opravit nebo smazat.',
                      ),
                      _OnboardingPoint(
                        title: 'AI jako opora',
                        text:
                            'Bebia pomáhá s dalším krokem, ale finální rozhodnutí nechává rodiči.',
                      ),
                    ],
                  ),
                  _OnboardingPage(
                    imageAsset: 'assets/illustrations/care_illustration.png',
                    title: 'Začít během dvou minut',
                    subtitle:
                        'Tyto kroky nejsou povinné, ale nejrychleji zvednou hodnotu aplikace hned od prvního dne.',
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openCreateProfile,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Vytvořit profil dítěte'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openConnectParent,
                          icon: const Icon(Icons.group_add_outlined),
                          label: const Text('Propojit s druhým rodičem'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  _PageDots(current: _page, count: _pageCount),
                  const Spacer(),
                  if (_page > 0)
                    TextButton(
                      onPressed: () {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: const Text('Zpět'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_page == _pageCount - 1 ? 'Dokončit' : 'Další'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = (screenHeight * 0.3).clamp(210.0, 280.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Image.asset(imageAsset, fit: BoxFit.contain),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface.withValues(alpha: 0),
                colorScheme.surface.withValues(alpha: 0.72),
                colorScheme.surface,
              ],
              stops: const [0, 0.42, 0.78],
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(20, imageHeight - 26, 20, 24),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ...children,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OnboardingPoint extends StatelessWidget {
  const _OnboardingPoint({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.count});

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(count, (index) {
        final selected = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
