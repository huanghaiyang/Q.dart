import 'package:Q/src/aware/InterceptorContext.dart';

abstract class HttpRequestInterceptorState extends InterceptorContext<int, dynamic> {
  int get preProcessIndex;

  int get postProcessIndex;

  bool get preProcessSuspend;

  int get total;

  set preProcessIndex(int preProcessIndex);

  set postProcessIndex(int postProcessIndex);

  set preProcessSuspend(bool preProcessSuspend);

  set total(int total);

  factory HttpRequestInterceptorState() => _HttpRequestInterceptorState();
}

class _HttpRequestInterceptorState implements HttpRequestInterceptorState {
  int preProcessIndex_;

  int postProcessIndex_;

  bool preProcessSuspend_;

  int total_;

  Map<int, dynamic> store;

  @override
  int get preProcessIndex {
    return preProcessIndex_;
  }

  @override
  int get postProcessIndex {
    return postProcessIndex_;
  }

  @override
  set postProcessIndex(int postProcessIndex) {
    this.postProcessIndex_ = postProcessIndex;
  }

  @override
  set preProcessIndex(int preProcessIndex) {
    this.preProcessIndex_ = preProcessIndex;
  }

  @override
  set preProcessSuspend(bool preProcessSuspend) {
    this.preProcessSuspend_ = preProcessSuspend;
  }

  @override
  bool get preProcessSuspend {
    return this.preProcessSuspend_;
  }

  @override
  set total(int total) {
    this.total_ = total;
  }

  @override
  int get total {
    return this.total_;
  }

  @override
  void setState(int index, dynamic state) {
    this.store[index] = state;
  }

  @override
  void getState(int index) {
    return this.store[index];
  }
}
