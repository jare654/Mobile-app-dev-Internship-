# PulseNews Code Standards

## Overview

This document outlines the coding standards, conventions, and best practices for the PulseNews Flutter project. Following these standards ensures code consistency, maintainability, and quality across the entire codebase.

## General Principles

### 1. Clean Code
- **Readability**: Code should be self-documenting and easy to understand
- **Simplicity**: Favor simple solutions over complex ones
- **Consistency**: Apply patterns consistently throughout the codebase
- **Testability**: Write code that is easy to test

### 2. SOLID Principles
- **S**ingle Responsibility: Each class should have one reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable for base types
- **I**nterface Segregation: Many specific interfaces are better than one general interface
- **D**ependency Inversion: Depend on abstractions, not concretions

### 3. DRY (Don't Repeat Yourself)
- Extract common functionality into reusable components
- Use inheritance and composition appropriately
- Avoid copy-paste programming

## Dart/Flutter Specific Standards

### File Organization
```
lib/
├── core/                 # Core utilities and shared code
│   ├── constants/        # App constants
│   ├── di/              # Dependency injection
│   ├── errors/           # Custom error types
│   ├── network/          # Network utilities
│   ├── performance/      # Performance optimizations
│   ├── theme/            # App theme
│   └── utils/           # Utility functions
├── data/                 # Data layer
│   ├── datasources/       # Data sources (remote/local)
│   ├── models/            # Data models
│   ├── repositories/      # Repository implementations
│   └── services/         # Data services
├── domain/               # Domain layer
│   ├── entities/          # Business entities
│   ├── failures/         # Failure types
│   ├── providers/        # State providers
│   ├── repositories/      # Repository interfaces
│   ├── services/         # Domain services
│   ├── usecases/         # Use cases
│   ├── validators/       # Validation logic
│   └── transformers/     # Data transformation
├── presentation/         # Presentation layer
│   ├── pages/            # Full-screen pages
│   ├── widgets/          # Reusable widgets
│   └── providers/       # UI state providers
└── main.dart            # App entry point
```

### Naming Conventions

#### Files and Directories
- **Files**: `snake_case.dart` (e.g., `news_provider.dart`)
- **Directories**: `snake_case` (e.g., `data_sources/`)
- **Private files**: Leading underscore (`_private_file.dart`)

#### Classes and Types
- **Classes**: `PascalCase` (e.g., `NewsProvider`, `ArticleEntity`)
- **Abstract classes**: `PascalCase` with descriptive names (e.g., `NewsRepository`)
- **Enums**: `PascalCase` (e.g., `LoadingState`, `ArticleCategory`)
- **Type aliases**: `PascalCase` (e.g., `ArticleId`)

#### Variables and Functions
- **Variables**: `camelCase` (e.g., `userName`, `articleList`)
- **Functions**: `camelCase` (e.g., `fetchArticles()`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `API_BASE_URL`)
- **Private members**: Leading underscore (`_privateVariable`)

#### Parameters
- **Named parameters**: `camelCase` (e.g., `fetchArticles({required String query})`)
- **Positional parameters**: `camelCase` (e.g., `fetchArticles(String query)`)

### Code Style

#### Imports
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

// 4. Project imports (relative)
import '../entities/article.dart';
import '../failures/failure.dart';
```

#### Class Structure
```dart
/// Brief description of the class purpose.
/// 
/// More detailed explanation if needed.
/// 
/// **Example:**
/// ```dart
/// final provider = NewsProvider();
/// await provider.fetchArticles();
/// ```
class ClassName extends SuperClass {
  // 1. Static constants
  static const String constantName = 'value';
  
  // 2. Private properties
  final Type _privateProperty;
  Type _publicProperty;
  
  // 3. Constructor
  const ClassName({
    required this._privateProperty,
    this.publicProperty = defaultValue,
  }) : super();
  
  // 4. Public getters
  Type get publicGetter => _publicProperty;
  
  // 5. Public methods
  Future<Result> publicMethod() async {
    // Implementation
  }
  
  // 6. Private methods
  Future<void> _privateMethod() async {
    // Implementation
  }
  
  // 7. Overrides
  @override
  void dispose() {
    // Cleanup
    super.dispose();
  }
}
```

#### Method Documentation
```dart
/// Brief description of the method.
/// 
/// Detailed description if needed.
/// 
/// **Parameters:**
/// - [param1]: Description of parameter 1
/// - [param2]: Description of parameter 2
/// 
/// **Returns:**
/// - Description of return value
/// 
/// **Throws:**
/// - [ExceptionType]: When this exception occurs
/// 
/// **Example:**
/// ```dart
/// final result = await method(param1, param2);
/// print(result);
/// ```
Future<ResultType> methodName({
  required Type param1,
  Type param2 = defaultValue,
}) async {
  // Implementation
}
```

## Architecture Standards

### Clean Architecture
- **Domain Layer**: Pure business logic, no framework dependencies
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: UI, widgets, and state management

### Dependency Injection
- Use GetIt with Injectable annotations
- Register dependencies in injection container
- Prefer constructor injection

### Error Handling
- Use Either<Failure, Success> pattern
- Create specific failure types
- Handle errors at appropriate layers

### State Management
- Use Provider pattern for state management
- Implement optimistic updates for better UX
- Persist state when appropriate

## Testing Standards

### Test Organization
```
test/
├── unit/                 # Unit tests
│   ├── data/            # Data layer tests
│   ├── domain/          # Domain layer tests
│   └── presentation/    # Presentation layer tests
├── widget/               # Widget tests
├── integration/          # Integration tests
└── test_helpers/         # Test utilities and mocks
```

### Test Naming
- **Files**: `*_test.dart` (e.g., `news_provider_test.dart`)
- **Test groups**: Descriptive names (e.g., `group('NewsProvider', () { ... })`)
- **Test cases**: Descriptive names (e.g., `test('should return articles when successful', () { ... })`)

### Test Structure
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ClassName', () {
    late MockDependency mockDependency;
    late ClassName className;

    setUp(() {
      mockDependency = MockDependency();
      className = ClassName(mockDependency);
    });

    tearDown(() {
      // Cleanup if needed
    });

    test('should perform expected behavior', () async {
      // Arrange
      when(mockDependency.method()).thenAnswer((_) async => result);

      // Act
      final actual = await className.method();

      // Assert
      expect(actual, expected);
      verify(mockDependency.method()).called(1);
    });
  });
}
```

## Performance Standards

### Memory Management
- Use weak references for large objects
- Dispose controllers and listeners
- Avoid memory leaks
- Monitor memory usage

### Network Optimization
- Implement request deduplication
- Use caching strategies
- Handle offline scenarios
- Implement retry logic

### UI Performance
- Use const constructors where possible
- Implement lazy loading
- Optimize list rendering
- Use efficient widgets

## Security Standards

### Data Protection
- Use secure storage for sensitive data
- Implement proper authentication
- Validate all inputs
- Use HTTPS for network requests

### Code Security
- Don't hardcode secrets
- Use environment variables for configuration
- Implement proper error handling
- Follow OWASP guidelines

## Documentation Standards

### Code Documentation
- Document all public APIs
- Use dartdoc format
- Include examples when helpful
- Keep documentation up to date

### README Files
- Project overview and setup instructions
- Architecture explanation
- API documentation links
- Contribution guidelines

### API Documentation
- Complete endpoint documentation
- Request/response examples
- Error code explanations
- Authentication details

## Git Standards

### Commit Messages
- Use conventional commit format
- Keep messages concise but descriptive
- Include issue numbers when relevant
- Use present tense ("add feature" not "added feature")

Format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

### Branch Strategy
- `main`: Production branch
- `develop`: Development branch
- `feature/*`: Feature branches
- `hotfix/*`: Hotfix branches

## Code Review Standards

### Review Checklist
- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No hardcoded secrets
- [ ] Error handling is appropriate
- [ ] Performance considerations addressed
- [ ] Security best practices followed

### Review Process
1. Create pull request with descriptive title
2. Fill out PR template completely
3. Request at least one code review
4. Address all feedback
5. Ensure CI/CD passes
6. Merge with squash or rebase

## Tool Configuration

### Linting
```yaml
analysis_options.yaml:
  include: package:flutter_lints/flutter.yaml
  
  linter:
    rules:
      - prefer_const_constructors
      - prefer_const_literals_to_create_immutables
      - avoid_print
      - prefer_single_quotes
      - sort_constructors_first
      - sort_unnamed_constructors_first
```

### Formatting
- Use `dart format` with default settings
- Format on save in IDE
- Include formatting in CI/CD pipeline

### Dependencies
- Pin dependency versions
- Regular security updates
- Remove unused dependencies
- Use dependency scanning tools

## Best Practices

### General
- Write self-documenting code
- Keep functions small and focused
- Use meaningful names
- Avoid magic numbers and strings
- Handle edge cases

### Flutter Specific
- Use const widgets where possible
- Implement proper disposal patterns
- Use appropriate widgets for the job
- Follow Material Design guidelines
- Test on multiple screen sizes

### Error Handling
- Use typed exceptions
- Provide meaningful error messages
- Implement graceful degradation
- Log errors appropriately

### Performance
- Profile regularly
- Optimize critical paths
- Use efficient algorithms
- Monitor memory usage

## Compliance

### Accessibility
- Follow WCAG guidelines
- Use semantic widgets
- Provide text alternatives
- Support screen readers

### Privacy
- Follow GDPR requirements
- Implement data minimization
- Provide privacy controls
- Secure user data

This code standards document should be updated regularly as the project evolves and new best practices emerge.
