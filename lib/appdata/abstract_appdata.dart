abstract class AppData {
  final List<String> _batches = [];

  void loadBatches() {
    print('something');
  }

  void createNewBatche(String name);
  void deleteBatche(String name);
  void updateBatche(String name);
}

class AppDataImplemented extends AppData {
  @override
  void createNewBatche(String name) {
    // TODO: implement createNewBatche
    _batches;
  }

  @override
  void deleteBatche(String name) {
    // TODO: implement deleteBatche
  }

  @override
  void loadBatches() {
    super.loadBatches();
    print('sdfsdfsdf');
  }

  @override
  void updateBatche(String name) {
    // TODO: implement updateBatche
  }
}

void main(List<String> args) {
  AppDataImplemented().loadBatches();
}
