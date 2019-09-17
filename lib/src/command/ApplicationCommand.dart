class ApplicationCommand {
  ApplicationCommand._();

  static ApplicationCommand _instance;

  static ApplicationCommand getInstance() {
    if (_instance == null) {
      _instance = ApplicationCommand._();
    }
    return _instance;
  }
}
