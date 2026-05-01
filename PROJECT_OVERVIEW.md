# Special Defined Number Finder - Project Overview

## Summary

Special Defined Number Finder is an interactive Wolfram Mathematica notebook app for exploring olympiad-style number definitions. It supports two related workflows: finding target values such as `S`, and finding bounded variable assignments for fixed equations such as Pell-type equations.

The motivating example is the Sorensen-number style condition:

```wolfram
S == m^2 + x^2
S == (m + 1)^2 + y^2
S == (m + 2)^2 + z^2
```

The app searches for integer values of `S` that satisfy all entered rules and displays witness assignments such as:

```text
S = 1105
m -> 31, x -> 12, y -> 9, z -> 4
```

The project is intended as an exploratory mathematics tool, not just a single-problem solver. Users can define their own search mode, target variable, search variables, equations, inequalities, domains, distinctness requirements, bounds, and modular pruning settings.

## Main Goal

Many olympiad and recreational number theory problems define a special type of number by a rule, then ask for the first few numbers satisfying that rule. Examples include:

- Numbers representable in several different ways.
- Numbers that are simultaneously square, triangular, or polygonal.
- Numbers satisfying several square, cube, or sum constraints.
- Numbers with consecutive representations.
- Numbers satisfying bounded integer conditions.
- Variable tuples satisfying a fixed equation, such as `x^2 - a y^2 == 1`.

This app provides a notebook interface for experimenting with those rules without rewriting Mathematica code each time.

## Project Files

The active app folder is:

```text
SpecialDefinedNumberFinder/
```

Recommended GitHub files:

```text
SpecialDefinedNumberFinder/
  README.md
  PROJECT_OVERVIEW.md
  SpecialDefinedNumberFinder.wl
  RUN_SpecialDefinedNumberFinder.nb
  BuildSpecialDefinedNumberFinder.wls
  TestSpecialDefinedNumberFinder.wls
```

Do not publish backup folders such as:

```text
SpecialDefinedNumberFinder_BACKUP_WORKING_*
SpecialDefinedNumberFinder_BACKUP_PRE_ASSIGNMENT_MODE_*
```

Those folders are local restore points, not part of the public project.

## File Responsibilities

### `RUN_SpecialDefinedNumberFinder.nb`

This is the main notebook that users open in Mathematica. It contains a small launcher cell that loads the local Wolfram package and starts the interactive app.

Typical use:

1. Open the notebook in Mathematica.
2. Evaluate the input cell with `Shift+Enter`.
3. Use the app interface.

### `SpecialDefinedNumberFinder.wl`

This is the main implementation file. It contains:

- Preset definitions.
- User input parsing.
- Safety checks for entered expressions.
- Domain and constraint construction.
- The search engine.
- Modular pruning logic.
- Fast Sorensen preset search.
- Result formatting.
- The interactive notebook UI.

### `BuildSpecialDefinedNumberFinder.wls`

This script regenerates the runnable notebook.

```powershell
wolframscript -file .\BuildSpecialDefinedNumberFinder.wls
```

Use it when changing the launcher notebook structure.

### `TestSpecialDefinedNumberFinder.wls`

This script validates the project through WolframScript. It tests:

- Sorensen preset results.
- Built-in example scenarios.
- Domain controls.
- Variable bounds.
- Distinct-variable constraints.
- Distinct-representation constraints.
- Modular pruning.
- Bounded variable-assignment search.
- Invalid input handling.

Run it with:

```powershell
wolframscript -file .\TestSpecialDefinedNumberFinder.wls
```

### `README.md`

Short user-facing instructions for running the notebook, entering formulas, and using examples.

### `PROJECT_OVERVIEW.md`

This detailed project explanation.

## Core Concepts

### Search Modes

The app has two search modes.

`Target values` mode is the original workflow. It searches for unique integer values of a named target variable, usually `S`, and then displays witness assignments proving each value works.

Example:

```wolfram
S == a^2 + b^2
```

`Variable assignments` mode is for problems where the equation already has a fixed right-hand side or fixed condition, and the answer is the variables themselves.

Example:

```wolfram
x^2 - a y^2 == 1
```

In that case, the app returns rows such as:

```text
x -> 3, y -> 2, a -> 2
```

This distinction matters for Pell-type equations. A Pell equation is usually not asking "which `S` values work?" It is asking "which integer variables satisfy this fixed equation?" For those problems, the app uses variable-assignment search and requires finite bounds so the search remains computationally meaningful.

### Target Variable

The target variable is the integer value the app is trying to find in `Target values` mode. In most target-value examples this is `S`.

Example:

```wolfram
S == a^2 + b^2
```

Here `S` is the target value, while `a` and `b` are witness variables.

### Search Variables

Search variables are the unknown integers used to prove that a target value satisfies the rule.

Example:

```wolfram
Search variables: {m, x, y, z}
```

For the Sorensen preset, a result is meaningful only when values for all of these variables are found.

### Rules

Rules are Mathematica equations, inequalities, or Boolean combinations. Each row in the app is part of the full condition.

Example:

```wolfram
S == m^2 + x^2
S == (m + 1)^2 + y^2
S == (m + 2)^2 + z^2
```

All rows are combined with logical `And`.

### Witness Assignments

A witness assignment is one set of variable values proving that the target works.

Example:

```text
S = 1105
m -> 31, x -> 12, y -> 9, z -> 4
```

This verifies:

```wolfram
1105 == 31^2 + 12^2
1105 == 32^2 + 9^2
1105 == 33^2 + 4^2
```

## Features

## 1. Custom Rule Definition

Users can define their own problem by editing:

- Search mode.
- Target variable.
- Search variables.
- Constraint rows.
- Number of target values to find.
- Search bounds.
- Witness count.

The app accepts Mathematica syntax.

Correct:

```wolfram
S == a^2 + b^2
```

Incorrect:

```wolfram
S = a^2 + b^2
```

The app rejects assignment-style input because `=` mutates Mathematica state, while `==` represents an equation.

## 2. Assignment Search Mode

Assignment mode solves bounded systems where the result is a list of variable assignments rather than target values.

Example Pell-type triple search:

```wolfram
Search mode: Variable assignments
Search variables: {x, y, a}
Rule: x^2 - a y^2 == 1
Variable bounds: 2 <= a <= 50 && 1 <= x <= 500 && 1 <= y <= 500
```

The solver uses `FindInstance` over the listed variables and integer domain. Each result row includes:

- The assignment.
- A verification display showing whether each entered rule becomes `True` after substitution.

Example fixed Pell equation:

```wolfram
Search mode: Variable assignments
Search variables: {x, y}
Rule: x^2 - 2 y^2 == 1
Variable bounds: 1 <= x <= 100 && 1 <= y <= 100
```

This can return assignments such as:

```text
x -> 3, y -> 2
```

Classical Pell equations can have infinitely many solutions, so this app intentionally implements bounded assignment search rather than a symbolic Pell recurrence generator.

## 3. Domain Controls

The app supports three variable domains:

```text
Positive integers
Nonnegative integers
All integers
```

This is important because many number theory problems are sensitive to whether zero or negative values are allowed.

Examples:

Positive integer domain:

```wolfram
a >= 1
```

Nonnegative integer domain:

```wolfram
a >= 0
```

All integer domain:

```wolfram
a in Integers
```

The target variable is searched over integer values from `Target minimum` to `Maximum target`.

## 4. Variable Bounds

Users can add extra bounds such as:

```wolfram
3 <= a <= 20
```

or:

```wolfram
1 <= m <= 500 && x <= 100
```

This helps keep searches finite and lets users test restricted versions of problems. Bounds are especially important in assignment mode.

## 5. Distinct Variables

The `Distinct variables` option forces all listed search variables to take pairwise different values.

For variables:

```wolfram
{a, b, c}
```

the app adds constraints equivalent to:

```wolfram
a != b && a != c && b != c
```

This is useful for problems where repeated witness values are not allowed.

## 6. Distinct Representations

The `Distinct representations` option helps with problems that require multiple different representations of the same number.

For example:

```wolfram
S == a^2 + b^2
S == c^2 + d^2
```

The app can require the two representation variable lists `{a, b}` and `{c, d}` not to be identical.

This is especially relevant for statements like:

```text
Find numbers that can be written in three distinct ways.
```

## 7. Modular Pruning

The app can skip target values that are impossible modulo selected bases.

Default modular bases:

```wolfram
{4, 8, 9, 16}
```

This matters because powers have restricted residues. For example:

- Squares modulo 4 are only `0` or `1`.
- Squares modulo 8 are only `0`, `1`, or `4`.
- Cubes modulo 9 are only `0`, `1`, or `8`.

In target-value mode, if a candidate target value is impossible modulo one of the selected bases, the app does not send that candidate to the slower integer solver. In assignment mode, modular pruning can also reject an entire equation system if no residue assignment can satisfy it for the selected bases.

This can improve performance for searches involving:

- Squares.
- Cubes.
- Sums of powers.
- Consecutive power expressions.

## 8. Fast Sorensen Preset Solver

The Sorensen preset has a special fast path because the generic integer solver may spend a long time proving that large gaps contain no solutions.

The fast path searches directly through the structure:

```wolfram
S == m^2 + x^2
S == (m + 1)^2 + y^2
S == (m + 2)^2 + z^2
```

It checks square roots directly and returns the first target values quickly.

Expected first results:

```text
S = 1105
S = 12025
S = 66625
```

## 9. Built-In Examples

The app includes 20 loadable examples besides the Sorensen preset. The notebook separates them into `Target-value examples` and `Variable-assignment examples`.

### Target-Value Examples

These presets search for unique target values such as `S`.

#### Consecutive Square Sums

Find target values satisfying:

```wolfram
S == n^2 + a^2
S == (n + 1)^2 + b^2
```

Expected first values:

```text
5, 13, 25
```

#### Square Triangular Numbers

Find values that are both square and triangular:

```wolfram
S == n^2
S == t (t + 1)/2
```

Expected first values:

```text
1, 36, 1225
```

#### Pythagorean Square Targets

Find square values that are also sums of two positive squares:

```wolfram
S == a^2 + b^2
S == c^2
```

Expected first values:

```text
25, 100, 169, 225
```

#### Square and Cube Sums

Find values that are sums of two squares and also sums of two positive cubes:

```wolfram
S == a^2 + b^2
S == c^3 + d^3
```

Expected first values:

```text
2, 65, 72, 128
```

#### Sum and Difference of Squares

Find values that can be written both as a sum and as a difference of two squares:

```wolfram
S == a^2 + b^2
S == c^2 - d^2
```

Expected first values:

```text
5, 8, 13, 17
```

Additional target-value examples:

- `Square-cube target values`: `S == a^2` and `S == b^3`, with first values `1, 64, 729`.
- `Triangular target values`: `S == n (n + 1)/2`, with first values `1, 3, 6, 10, 15`.
- `Odd consecutive-square gaps`: `S == (n + 1)^2 - n^2`, with first values `3, 5, 7, 9`.
- `Square plus one targets`: `S == n^2 + 1`, with first values `2, 5, 10, 17`.
- `Three-square sums`: `S == a^2 + b^2 + c^2`, with first values `3, 6, 9, 11`.

### Variable-Assignment Examples

These presets search for assignments to listed variables. They are useful when the problem already gives the equation value.

#### Pell-Type Triples

Find positive integer assignments satisfying:

```wolfram
x^2 - a y^2 == 1
```

The preset uses:

```wolfram
2 <= a <= 50 && 1 <= x <= 500 && 1 <= y <= 500
```

This example demonstrates the `Variable assignments` mode. It returns assignments, not target values.

Additional variable-assignment examples:

- `Fixed Pell x^2 - 2 y^2`: find bounded positive integer solutions of `x^2 - 2 y^2 == 1`.
- `Pythagorean triples`: find bounded triples satisfying `a^2 + b^2 == c^2` and `a < b`.
- `Markov triples`: find bounded triples satisfying `x^2 + y^2 + z^2 == 3 x y z`.
- `Factor pairs of 360`: find factor pairs satisfying `a b == 360` and `a <= b`.
- `Difference of squares equals 45`: find pairs satisfying `x^2 - y^2 == 45`.
- `Egyptian fraction for 1/6`: find pairs equivalent to `1/x + 1/y == 1/6` using `6 (x + y) == x y`.
- `Coin equation 5a + 7b`: find nonnegative solutions to `5 a + 7 b == 100`.
- `Square roots modulo 15`: find pairs satisfying `x^2 == 1 + 15 k`.
- `Pythagorean triples with perimeter 60`: find triples satisfying `a^2 + b^2 == c^2` and `a + b + c == 60`.

## What This App Can Solve

The app is suitable for small to medium olympiad-style integer searches, especially problems that can be expressed as algebraic equations and inequalities over integers.

Good use cases:

- Find numbers with multiple square-sum representations.
- Find numbers satisfying consecutive formulas.
- Find square-triangular or other figurate intersections.
- Explore Pythagorean-type constraints.
- Search for numbers expressible as both sums of squares and sums of cubes.
- Search for bounded Pell-type assignments.
- Find variables in fixed equations such as `x^2 - 2 y^2 == 1`.
- Add bounded conditions such as `1 <= n <= 1000`.
- Require variables or representations to be distinct.
- Test whether a custom number definition has small examples.

Example custom problems:

```wolfram
S == a^2 + b^2
S == c^2 + d^2
```

```wolfram
S == n^2
S == t (t + 1)/2
```

```wolfram
S == a^3 + b^3
S == c^2 + d^2
```

```wolfram
S == n^2 + 1
S == a^2 + b^2
```

```wolfram
x^2 - a y^2 == 1
```

## What This App Is Not Designed For

The app is not a full theorem prover or an unlimited Diophantine equation solver.

It may struggle with:

- Very large search spaces.
- High-degree equations with many variables.
- Problems requiring proof of infinitely many solutions.
- Symbolic generation of Pell recurrences.
- Problems requiring symbolic classification.
- Equations where Mathematica's integer solvers cannot find instances efficiently.
- Very large bounds without useful pruning.

For hard searches, use:

- Tighter variable bounds.
- Smaller maximum target values.
- Modular pruning.
- More specific equations.
- Built-in fast presets where available.

## Search Strategy

In target-value mode, the app searches target values in increasing order. For each target range:

1. It builds the full integer constraint system.
2. It applies domain, bounds, distinctness, and rule constraints.
3. It optionally uses modular pruning to skip impossible candidates.
4. It asks Mathematica to find integer witness assignments.
5. It records unique target values and their witnesses.

The app counts unique target values, not every variable assignment.

For example, if `S = 25` has several witness assignments, it still counts as one found number.

In variable-assignment mode, the app:

1. Builds the full integer constraint system.
2. Applies domain, variable bounds, distinct-variable constraints, and modular pruning where applicable.
3. Calls Mathematica `FindInstance` for the requested number of assignments.
4. Displays each assignment and verifies every rule by substitution.

Assignment mode counts one solution as one variable assignment.

## Input Safety

The parser rejects several side-effecting Mathematica constructs, including assignment-style input and file/system commands. This is important because user-entered strings are parsed as Wolfram expressions.

Rejected examples:

```wolfram
S = a^2
Run["..."]
DeleteFile["..."]
```

Accepted examples:

```wolfram
S == a^2
a <= 100
S == a^2 + b^2 && a < b
```

## Testing

Run:

```powershell
wolframscript -file .\TestSpecialDefinedNumberFinder.wls
```

The test suite validates:

- Sorensen preset.
- Ten target-value examples and ten variable-assignment examples.
- Positive/nonnegative/all-integer domain behavior.
- Target minimum behavior.
- Variable bounds.
- Distinct variable constraints.
- Distinct representation constraints.
- Modular pruning.
- Assignment mode for bounded Pell-type triples.
- Assignment mode for fixed Pell equation `x^2 - 2 y^2 == 1`.
- Assignment-mode no-result and invalid-input behavior.
- Invalid syntax and unknown variable handling.

Known local note: on some Windows installations, WolframScript may print a warning such as:

```text
Failed to open configuaration file at path: ... WolframScript.conf
```

In the current development environment, the scripts still executed successfully despite that warning.

## Publishing to GitHub

Recommended repository name:

```text
special-defined-number-finder
```

Recommended repository root contents:

```text
README.md
PROJECT_OVERVIEW.md
SpecialDefinedNumberFinder.wl
RUN_SpecialDefinedNumberFinder.nb
BuildSpecialDefinedNumberFinder.wls
TestSpecialDefinedNumberFinder.wls
```

For updating an existing GitHub copy of the app, replace these same six files with the current versions from:

```text
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder
```

Current files to upload:

```text
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder\README.md
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder\PROJECT_OVERVIEW.md
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder\SpecialDefinedNumberFinder.wl
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder\RUN_SpecialDefinedNumberFinder.nb
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder\BuildSpecialDefinedNumberFinder.wls
C:\Users\Artensar\Desktop\Codex Projects\Project 1\SpecialDefinedNumberFinder\TestSpecialDefinedNumberFinder.wls
```

These files include the latest app changes:

- Two search modes: target values and variable assignments.
- Two example sections with 10 presets each.
- Pell-type and bounded assignment-search support.
- Updated test coverage.
- Updated user and project documentation.

If publishing the whole folder, publish only:

```text
SpecialDefinedNumberFinder/
```

Do not include:

```text
SpecialDefinedNumberFinder_BACKUP_WORKING_*
SpecialDefinedNumberFinder_BACKUP_PRE_ASSIGNMENT_MODE_*
```

Suggested GitHub topics:

```text
mathematica
wolfram-language
number-theory
diophantine-equations
math-olympiad
recreational-mathematics
integer-search
```

## Possible Future Improvements

Useful future features:

- More fast solvers for common patterns.
- Proof view for each result.
- Export current setup to Wolfram code.
- Save/load user-created presets.
- Sequence analysis of found values.
- Graphing growth of target values.
- More advanced modular filters.
- Support for unordered representation equivalence, such as treating `{a, b}` and `{b, a}` as the same representation.
- A public examples gallery.

## License Recommendation

For a public GitHub release, consider adding a license file. Good choices:

- MIT License for permissive reuse.
- Apache-2.0 for permissive reuse with patent language.
- GPL-3.0 if derivative projects must remain open source.

If unsure, MIT is a simple default for a small educational tool.
