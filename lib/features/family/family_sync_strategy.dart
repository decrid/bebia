enum FamilySyncStage { localOnly, accountReady, cloudSync }

class FamilySyncCapability {
  const FamilySyncCapability({
    required this.title,
    required this.description,
    required this.stage,
  });

  final String title;
  final String description;
  final FamilySyncStage stage;
}

class FamilySyncStrategy {
  const FamilySyncStrategy();

  List<FamilySyncCapability> getCapabilities() {
    return const [
      FamilySyncCapability(
        title: 'Samostatné účty rodičů',
        description:
            'Každý rodič bude mít vlastní přihlášení místo sdíleného jednoho účtu.',
        stage: FamilySyncStage.accountReady,
      ),
      FamilySyncCapability(
        title: 'Pozvánka do rodiny',
        description:
            'Druhý rodič se připojí přes pozvánku a vstoupí do stejného rodinného prostoru.',
        stage: FamilySyncStage.accountReady,
      ),
      FamilySyncCapability(
        title: 'Sdílené záznamy mezi telefony',
        description:
            'Události, děti i přehledy se budou synchronizovat mezi zařízeními v reálném čase.',
        stage: FamilySyncStage.cloudSync,
      ),
      FamilySyncCapability(
        title: 'Kdo co zapsal',
        description:
            'U důležitých záznamů bude vidět autor změny, aby bylo předání péče přehledné.',
        stage: FamilySyncStage.cloudSync,
      ),
      FamilySyncCapability(
        title: 'Role pro pečující osoby',
        description:
            'Do budoucna půjde přidat i další členy rodiny nebo chůvu s omezenou rolí.',
        stage: FamilySyncStage.cloudSync,
      ),
    ];
  }
}
