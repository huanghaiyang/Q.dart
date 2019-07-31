import 'dart:io';

abstract class Session {
  HttpSession get httpSession;

  bool get isEmpty;

  set httpSession(HttpSession httpSession);

  factory Session() => _Session();

  factory Session.from(HttpRequest request) = _Session.from;
}

class _Session implements Session {
  HttpSession _httpSession;

  _Session();

  factory _Session.from(HttpRequest request) {
    Session session = Session();
    session.httpSession = request.session;
    return session;
  }

  @override
  HttpSession get httpSession {
    return this._httpSession;
  }

  @override
  set httpSession(HttpSession httpSession) {
    this._httpSession = httpSession;
  }

  @override
  bool get isEmpty {
    return this.httpSession == null || this.httpSession.isEmpty;
  }
}
