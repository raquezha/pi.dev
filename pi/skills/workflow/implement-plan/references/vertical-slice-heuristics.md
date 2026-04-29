# Vertical vs. Horizontal Implementation

To "own" the implementation like a Staff Engineer, avoid the "Horizontal Layer" trap.

### ❌ The Horizontal Trap (Avoid)
- **What it is:** Building all Data Models, then all Repositories, then all Presenters, then all UI.
- **Why it fails:** You don't know if the architecture works for the feature until the very end. Integration bugs are discovered too late.

### ✅ The Vertical Slice (Follow)
- **What it is:** Implementing one functional "path" from the foundation to the surface.
- **Example:** For a "User Profile" feature:
  1. **Slice 1:** Fetch name from DB and display in a simple text view. (Verifiable)
  2. **Slice 2:** Add profile picture loading and caching. (Verifiable)
  3. **Slice 3:** Add "Edit Name" functionality. (Verifiable)

### How to identify a slice:
1. Look at a single **Success Criterion** in `Problem.md`.
2. Identify the minimum code needed across all layers (Foundations, Mechanics, Surface) to satisfy *only* that criterion.
3. Build, test, and commit that slice before moving to the next.
