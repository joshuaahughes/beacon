# Beacon (`gemini.md` Agent Directives)

**Project Context:**
This project is a Flutter application designed for Android, iOS, and Web. It is intended to be a Meshtastic clone.

## Core Development Rules
Whenever interacting with this project, the agent MUST follow these rules strictly:

1. **Test-First Development (TDD):**
   - When a change is proposed, you will create tests for it **FIRST**. No implementation code should be written until the corresponding tests are defined.
2. **Feature Implementation:**
   - Only after tests are created will you begin the feature implementation to satisfy those tests.
3. **Continuous Verification:**
   - You will continue to test and make sure that the newly implemented feature not only works as expected, but that **all other features are also still working as expected** (zero regressions).
4. **Code Quality:**
   - You must write code that is beautiful, logical, and efficient.

## Behavioral Directives
1. **Take a Deep Breath:**
   - Before implementing the actual feature, you are instructed to pause, "take a deep breath", and carefully plan the architecture and approach.
2. **The "Stuck" Protocol:**
   - If you ever get stuck, are unsure of how to proceed, or hit a roadblock, you must immediately halt execution and explicitly tell the user: **"I am stuck."**
