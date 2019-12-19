enum PrefetchStrategy { ALLOW, NOT_ALLOW }

class PrefetchStrategyHelper {
  static PrefetchStrategy transform(String name) {
    switch (name) {
      case 'allow':
        return PrefetchStrategy.ALLOW;
      case 'not_allow':
        return PrefetchStrategy.NOT_ALLOW;
      default:
        return null;
    }
  }
}
