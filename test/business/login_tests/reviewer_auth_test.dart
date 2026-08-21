import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/managers/other/reviewer_aware_login_service.dart';
import 'package:wildrapport/utils/reviewer_auth.dart';
import '../mock_generator.mocks.dart';

void main() {
  const reviewerEmail = 'reviewer@example.com';
  const reviewerPin = '654321';
  const longToken = 'reviewer-session-token-abcdefgh';

  ReviewerAuth configuredAuth({
    String email = reviewerEmail,
    String token = longToken,
    String pin = reviewerPin,
  }) {
    return ReviewerAuth(
      env: {
        'REVIEWER_EMAIL': email,
        'REVIEWER_TOKEN': token,
        'REVIEWER_PIN': pin,
      },
    );
  }

  group('ReviewerAuth', () {
    test('bypass stays OFF when REVIEWER_TOKEN is a short 6-digit mail code', () {
      final auth = ReviewerAuth(
        env: {
          'REVIEWER_EMAIL': reviewerEmail,
          'REVIEWER_TOKEN': '123456',
          'REVIEWER_PIN': reviewerPin,
        },
      );

      expect(auth.hasValidToken, isFalse);
      expect(auth.isConfigured, isFalse);
      expect(auth.isReviewerEmail(reviewerEmail), isFalse);
    });

    test('bypass ON when all three keys are set with long token', () {
      final auth = configuredAuth();
      expect(auth.isConfigured, isTrue);
      expect(auth.isReviewerEmail(reviewerEmail), isTrue);
      expect(auth.isReviewerEmail('other@example.com'), isFalse);
      expect(auth.isValidPin(reviewerPin), isTrue);
      expect(auth.isValidPin('000000'), isFalse);
    });

    test('bypass OFF when any required key is missing', () {
      expect(
        ReviewerAuth(
          env: {
            'REVIEWER_TOKEN': longToken,
            'REVIEWER_PIN': reviewerPin,
          },
        ).isConfigured,
        isFalse,
      );
      expect(
        ReviewerAuth(
          env: {
            'REVIEWER_EMAIL': reviewerEmail,
            'REVIEWER_PIN': reviewerPin,
          },
        ).isConfigured,
        isFalse,
      );
      expect(
        ReviewerAuth(
          env: {
            'REVIEWER_EMAIL': reviewerEmail,
            'REVIEWER_TOKEN': longToken,
          },
        ).isConfigured,
        isFalse,
      );
    });
  });

  group('ReviewerAwareLoginService', () {
    late MockLoginInterface inner;
    late ReviewerAwareLoginService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      inner = MockLoginInterface();
      service = ReviewerAwareLoginService(
        inner,
        reviewerAuth: configuredAuth(),
      );
      when(inner.validateEmail(any)).thenReturn(null);
    });

    test('reviewer email skips authenticate (no sendLoginCode on inner)', () async {
      final ok = await service.sendLoginCode(reviewerEmail);

      expect(ok, isTrue);
      verifyNever(inner.sendLoginCode(any));
    });

    test('normal email still calls authenticate', () async {
      when(inner.sendLoginCode(any)).thenAnswer((_) async => true);

      final ok = await service.sendLoginCode('user@example.com');

      expect(ok, isTrue);
      verify(inner.sendLoginCode('user@example.com')).called(1);
    });

    test('correct pin stores REVIEWER_TOKEN under bearer_token', () async {
      final result = await service.verifyCode(reviewerEmail, reviewerPin);

      expect(result, isA<Map>());
      expect((result as Map)['reviewerBypass'], isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(ReviewerAwareLoginService.tokenKey),
        longToken,
      );
      expect(
        prefs.getStringList(ReviewerAwareLoginService.scopesKey),
        isNotEmpty,
      );
      verifyNever(inner.verifyCode(any, any));
    });

    test('wrong pin throws and does not store token', () async {
      expect(
        () => service.verifyCode(reviewerEmail, '000000'),
        throwsA(isA<Exception>()),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ReviewerAwareLoginService.tokenKey), isNull);
      verifyNever(inner.verifyCode(any, any));
    });

    test('normal email verify still uses server authorize', () async {
      when(inner.verifyCode(any, any))
          .thenAnswer((_) async => {'token': 'server-token'});

      final result = await service.verifyCode('user@example.com', '111222');

      expect(result, {'token': 'server-token'});
      verify(inner.verifyCode('user@example.com', '111222')).called(1);
    });
  });
}
