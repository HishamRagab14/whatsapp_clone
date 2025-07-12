# Contributing to WhatsApp Clone 🤝

Thank you for your interest in contributing to WhatsApp Clone! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

## 🤝 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please be respectful and inclusive in all interactions.

## 🚀 How Can I Contribute?

### Types of Contributions

- 🐛 **Bug Reports** - Report bugs and issues
- 💡 **Feature Requests** - Suggest new features
- 🔧 **Code Contributions** - Submit code improvements
- 📚 **Documentation** - Improve documentation
- 🎨 **UI/UX Improvements** - Enhance user interface
- 🧪 **Testing** - Add or improve tests

### Before You Start

1. Check existing issues and pull requests
2. Read the project documentation
3. Understand the project architecture
4. Follow the coding standards

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK (3.16.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code
- Firebase account

### Local Development

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/whatsapp_clone.git
   cd whatsapp_clone
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create Firebase project
   - Configure authentication, firestore, and storage
   - Add configuration files

4. **Run the App**
   ```bash
   flutter run
   ```

## 📝 Coding Standards

### Dart/Flutter Standards

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Code Organization

```
lib/
├── core/           # Core utilities, services, repositories
├── model/          # Data models
├── view/           # UI screens and widgets
├── view_model/     # Controllers and state management
└── main.dart       # App entry point
```

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Example Code Structure

```dart
// Good example
class ChatService {
  static const String _collectionName = 'chats';
  
  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderId,
  }) async {
    try {
      // Implementation
    } catch (e) {
      throw ChatException('Failed to send message: $e');
    }
  }
}
```

## 🔄 Pull Request Process

### Before Submitting

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Write clean, documented code
   - Add tests if applicable
   - Update documentation

3. **Test Your Changes**
   ```bash
   flutter test
   flutter analyze
   flutter run
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add voice message feature"
   ```

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat: add new feature
fix: bug fix
docs: documentation changes
style: formatting changes
refactor: code refactoring
test: adding tests
chore: maintenance tasks
```

### Pull Request Guidelines

1. **Title**: Clear and descriptive
2. **Description**: Explain what and why, not how
3. **Screenshots**: Include for UI changes
4. **Tests**: Ensure all tests pass
5. **Documentation**: Update if needed

### Example PR Description

```markdown
## Description
Adds voice message recording functionality to chat screen.

## Changes
- Added voice recorder service
- Created voice message bubble widget
- Integrated with Firebase Storage
- Added permission handling

## Screenshots
[Add screenshots here]

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Added unit tests
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🐛 Reporting Bugs

### Before Reporting

1. Check existing issues
2. Try to reproduce the bug
3. Check if it's a known issue

### Bug Report Template

```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g. Android 12, iOS 15]
- Device: [e.g. Samsung Galaxy S21, iPhone 13]
- App Version: [e.g. 1.0.0]
- Flutter Version: [e.g. 3.16.0]

## Screenshots
[Add screenshots if applicable]

## Additional Context
Any other context about the problem
```

## 💡 Feature Requests

### Before Requesting

1. Check if feature already exists
2. Consider if it fits project scope
3. Think about implementation complexity

### Feature Request Template

```markdown
## Feature Description
Brief description of the feature

## Problem Statement
What problem does this solve?

## Proposed Solution
How should this be implemented?

## Alternatives Considered
Other approaches you considered

## Additional Context
Any other relevant information
```

## 🧪 Testing Guidelines

### Unit Tests

- Test business logic
- Mock external dependencies
- Aim for high coverage

### Widget Tests

- Test UI components
- Test user interactions
- Mock dependencies

### Integration Tests

- Test complete user flows
- Test Firebase integration
- Test cross-platform compatibility

## 📚 Documentation

### Code Documentation

- Document public APIs
- Add inline comments for complex logic
- Keep documentation up to date

### User Documentation

- Update README.md for new features
- Add setup instructions
- Include troubleshooting guides

## 🎯 Getting Help

- 📧 Email: your.email@example.com
- 💬 Discord: [Join our server]
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/whatsapp_clone/issues)
- 💭 Discussions: [GitHub Discussions](https://github.com/yourusername/whatsapp_clone/discussions)

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

---

 