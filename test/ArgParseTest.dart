import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('verify arguments', () {
    setUp(() {});

    test('verify the parsed result of arguments', () {
      ApplicationArgumentsParsedDelegate applicationArgumentsParsedDelegate = ApplicationArgumentsParsedDelegate(null);
      applicationArgumentsParsedDelegate.args(['--a.b.c=1', '--x.y', 'j.k', 'f', '-o.p=0.0']);
      expect(applicationArgumentsParsedDelegate.parsedArguments, ['--a_b_c=1', '--x_y', 'j_k', 'f', '-o_p=0.0']);
    });
  });
}
