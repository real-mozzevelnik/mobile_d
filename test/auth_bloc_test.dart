import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile_d/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:mobile_d/presentation/screens/auth/bloc/auth_event.dart';
import 'package:mobile_d/presentation/screens/auth/bloc/auth_state.dart';
import 'package:mobile_d/data/repositories/auth_repository.dart';
import 'package:mobile_d/data/models/auth_model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_d/data/datasources/remote/updates_service.dart';

@GenerateMocks([AuthRepository, UpdatesService])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockUpdatesService mockUpdatesService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUpdatesService = MockUpdatesService();
    authBloc = AuthBloc(authRepository: mockAuthRepository, updatesService: mockUpdatesService);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    final testAuthModel = AuthModel(
      userId: 123,
      email: 'test@test.com',
      username: 'Test User',
      budgetLimit: 500.0,
    );

    final loginRequest = LoginRequest(
      email: 'test@test.com',
      password: 'password123',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockAuthRepository.login(loginRequest))
            .thenAnswer((_) async => testAuthModel);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(loginRequest)),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(testAuthModel),
      ],
      verify: (_) {
        verify(mockAuthRepository.login(loginRequest)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockAuthRepository.login(loginRequest))
            .thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(loginRequest)),
      expect: () => [
        AuthLoading(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is requested',
      build: () {
        when(mockAuthRepository.logout())
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockAuthRepository.logout()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when checking auth status and user is logged in',
      build: () {
        when(mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testAuthModel);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(testAuthModel),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when checking auth status and user is not logged in',
      build: () {
        when(mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
    );
  });
}
