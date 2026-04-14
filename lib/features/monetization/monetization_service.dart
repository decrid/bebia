import 'monetization_feature.dart';

class MonetizationService {
  const MonetizationService();

  BebiaPlan get currentPlan => BebiaPlan.free;

  String get recommendedModel => 'predplatne_freemium';
  String get plusName => 'Bebia Plus';
  String get plusTagline => 'Klidnější dny díky hlubšímu porozumění.';

  List<MonetizationFeature> getFeatures() {
    return const [
      MonetizationFeature(
        id: 'tracking_core',
        title: 'Základní záznamy',
        description:
            'Krmení, spánek, přebalení, pláč, přehled historie a úpravy.',
        includedInFree: true,
        businessReason:
            'Aplikace potřebuje silný bezplatný návyk, než začne dávat smysl placení.',
        plusPillar: 'Denní návyk',
        launchPhase: 'Teď',
        upgradeMoment:
            'Toto by nemělo být zamčené. Právě tady vzniká důvěra a retence.',
      ),
      MonetizationFeature(
        id: 'profiles_and_sharing',
        title: 'Profily a základní sdílení',
        description:
            'Profil dítěte, přepínání aktivního dítěte, příprava pozvánky a pečující osoby.',
        includedInFree: true,
        businessReason:
            'Základní spolupráce zvyšuje retenci a připravuje prostor pro budoucí placenou vrstvu.',
        plusPillar: 'Koordinace péče',
        launchPhase: 'Teď',
        upgradeMoment:
            'Základní nastavení má zůstat zdarma. Placená vrstva může rozšířit koordinaci.',
      ),
      MonetizationFeature(
        id: 'ai_daily_assistant',
        title: 'Denní AI asistent',
        description: 'Lehká doporučení a návrhy dalšího kroku v průběhu dne.',
        includedInFree: true,
        businessReason:
            'Rodiče musí nejdřív zažít hodnotu produktu, teprve pak budou ochotní upgradovat.',
        plusPillar: 'Důkaz hodnoty',
        launchPhase: 'Teď',
        upgradeMoment:
            'Nech uživatele nejdřív zažít první AI úspěch, teprve pak ukazuj nabídku placené verze.',
      ),
      MonetizationFeature(
        id: 'weekly_ai_briefing',
        title: 'Týdenní AI souhrn',
        description:
            'Srozumitelný týdenní přehled vzorců, změn a možných náročných momentů.',
        includedInFree: false,
        businessReason:
            'Je to opakovaná a odlišující hodnota, která dobře sedí na předplatné.',
        plusPillar: 'Interpretace',
        launchPhase: 'Fáze 1',
        upgradeMoment:
            'Po 7 až 10 dnech dat nebo po zachycení prvního silného vzorce.',
      ),
      MonetizationFeature(
        id: 'predictive_routines',
        title: 'Prediktivní rutiny',
        description:
            'Okna bdělosti, odhad další potřeby a proaktivní vedení během dne.',
        includedInFree: false,
        businessReason:
            'Šetří čas opakovaně, a proto může dobře ospravedlnit měsíční platbu.',
        plusPillar: 'Predikce',
        launchPhase: 'Fáze 1',
        upgradeMoment:
            'Ve chvíli, kdy uživatel opakovaně sleduje odhady před dalším zápisem.',
      ),
      MonetizationFeature(
        id: 'crying_intelligence_history',
        title: 'Historie porozumění pláči',
        description:
            'Vzorce příčin, trend jistoty a co obvykle pomohlo v podobných situacích.',
        includedInFree: false,
        businessReason:
            'Proměňuje jednorázové AI výstupy v dlouhodobě užitečný systém.',
        plusPillar: 'Interpretace',
        launchPhase: 'Fáze 2',
        upgradeMoment:
            'Po více analýzách pláče nebo při opakovaném výskytu stejné příčiny.',
      ),
      MonetizationFeature(
        id: 'care_reports',
        title: 'Reporty a exporty',
        description: 'Přehledy pro pediatra, předání péče a sdílitelný export.',
        includedInFree: false,
        businessReason:
            'Jde o užitečný výstup s vysokou hodnotou v konkrétním okamžiku.',
        plusPillar: 'Koordinace',
        launchPhase: 'Fáze 2',
        upgradeMoment: 'Před návštěvou lékaře, cestou nebo předáním péče.',
      ),
      MonetizationFeature(
        id: 'advanced_family_coordination',
        title: 'Pokročilá koordinace rodiny',
        description:
            'Chytré handoff poznámky, sdílené připomínky a role pro více pečujících osob.',
        includedInFree: false,
        businessReason:
            'Dokáže ušetřit reálný čas v domácnostech, kde aplikaci používá více lidí.',
        plusPillar: 'Koordinace',
        launchPhase: 'Fáze 3',
        upgradeMoment:
            'Ve chvíli, kdy aplikaci aktivně používá více než jeden pečující.',
      ),
    ];
  }

  List<MonetizationFeature> get freeFeatures =>
      getFeatures().where((feature) => feature.includedInFree).toList();

  List<MonetizationFeature> get premiumFeatures =>
      getFeatures().where((feature) => !feature.includedInFree).toList();

  String get positioningSummary {
    return 'Denní zapisování nech zdarma. Plať až za hlubší interpretaci, predikci a koordinaci, jakmile uživatel produktu důvěřuje.';
  }

  List<String> get plusValueProps => const [
    'Rychleji pochopit, co se během dne děje',
    'Vidět vzorce dřív, než začnou být stresující',
    'Koordinovat péči s menší mentální zátěží',
  ];

  List<String> get rolloutPlan => const [
    'Fáze 1: Týdenní AI souhrn a prediktivní rutiny',
    'Fáze 2: Historie porozumění pláči a reporty/exporty',
    'Fáze 3: Pokročilá koordinace rodiny',
  ];
}
