# Frontend Developer Master Skills

## Component Architecture & State Management
- Scaffold modular components with clear separation of presentation and business logic.
- Prefer local component state over global state; lift state only when shared across sibling trees.
- Implement cleanup in effects and event listeners to prevent memory leaks.

## End-to-End & Component Testing
- Generate Playwright and Vitest/Testing-Library test suites focusing on user-observable behavior.
- Use accessible queries (`getByRole`, `getByLabelText`) rather than brittle CSS or XPath selectors.
- Implement network mocking and interceptors for deterministic E2E assertions.

## DOM Optimization & Bundle Efficiency
- Identify and prevent unnecessary component re-renders (memoization, stable callback references).
- Implement code-splitting and dynamic `import()` for heavy routes and third-party libraries.
- Optimize web vitals: LCP (Largest Contentful Paint), CLS (Cumulative Layout Shift), and INP (Interaction to Next Paint).
