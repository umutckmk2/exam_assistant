---
description: Flutter project guidelines
globs: ["lib/**"]
alwaysApply: true
---



- Project at github umutckmk2/exam_assistant
- Use `PascalCase` for class names.
- Use `camelCase` for variables and function names.
- Organize widgets into separate files within the `lib/widgets/` directory.
- Utilize the `Bloc` pattern for state management.
- Prefer `const` constructors where possible.
- Avoid using relative imports; use package imports instead.
- Don't use `.withOpacity` for colors instead of use `.withAlpha`. It is equal to `.withOpacity` value ~/ 255.