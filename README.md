# Special Defined Number Finder

Interactive Wolfram Mathematica app for exploring olympiad-style Diophantine rules.

The app has two search modes:

- `Target values`: find unique values of a target variable such as `S`.
- `Variable assignments`: find tuples of variables satisfying fixed equations, such as Pell-type equations.

For a detailed explanation of the project, features, capabilities, solver behavior, examples, and GitHub publishing notes, see [`PROJECT_OVERVIEW.md`](PROJECT_OVERVIEW.md).

## Files

- `RUN_SpecialDefinedNumberFinder.nb` opens the notebook app.
- `SpecialDefinedNumberFinder.wl` contains the parser, search logic, and UI.
- `BuildSpecialDefinedNumberFinder.wls` regenerates the runnable notebook.
- `TestSpecialDefinedNumberFinder.wls` runs regression tests.
- `PROJECT_OVERVIEW.md` contains the detailed feature and publishing documentation.

## GitHub Update Files

To update an existing GitHub repository for this app, upload the active files from this folder:

```text
SpecialDefinedNumberFinder/
  README.md
  PROJECT_OVERVIEW.md
  SpecialDefinedNumberFinder.wl
  RUN_SpecialDefinedNumberFinder.nb
  BuildSpecialDefinedNumberFinder.wls
  TestSpecialDefinedNumberFinder.wls
```

Do not upload local backup folders:

```text
SpecialDefinedNumberFinder_BACKUP_WORKING_*
SpecialDefinedNumberFinder_BACKUP_PRE_ASSIGNMENT_MODE_*
```

If your GitHub repository already uses `SpecialDefinedNumberFinder/` as the repository root, upload the six files directly into the root. If the repository contains the project as a subfolder, upload the whole `SpecialDefinedNumberFinder/` folder.

## How to Run

1. Open `RUN_SpecialDefinedNumberFinder.nb` in Mathematica.
2. Evaluate the input cell with `Shift+Enter`.
3. Edit the target variable, variables, constraints, and search controls.
4. Press `Find numbers`.

If WolframScript is configured, the notebook can be regenerated with:

```powershell
wolframscript -file .\BuildSpecialDefinedNumberFinder.wls
```

## Input Syntax

Use Mathematica syntax.

- Equality uses `==`, not `=`.
- Powers use `^`, for example `m^2`.
- Variables are written as a list, for example `{m, x, y, z}`.
- Each constraint row may contain an equation, inequality, `Element` statement, or Boolean combination.
- The target is searched over integer values from `Target minimum` to `Maximum target`.
- The listed variables use the selected variable domain: positive integers, nonnegative integers, or all integers.
- Optional variable bounds can be entered as Mathematica constraints, for example `1 <= m <= 500 && x <= 100`.

In `Variable assignments` mode, the target-variable controls are not used. The app returns assignments for the listed variables, so finite bounds are important for equations that may have infinitely many solutions.

## Math Controls

- `Variable domain` controls whether listed search variables are positive, nonnegative, or unrestricted integers.
- `Variable bounds` adds extra constraints such as `3 <= a <= 20`.
- `Distinct variables` requires all listed variables to take pairwise different values.
- `Distinct representations` requires equal-length representation rows to use different variable assignments.
- `Modular pruning` skips target candidates that are impossible modulo the selected bases, such as `{4, 8, 9, 16}`. This is useful because squares and cubes have restricted residues.

## Default Sorensen Preset

The default preset searches for positive integer values of `S` satisfying:

```wolfram
S == m^2 + x^2
S == (m + 1)^2 + y^2
S == (m + 2)^2 + z^2
```

with positive integer variables `{m, x, y, z}`.

Expected first target values include:

```text
S = 1105   with m -> 31,  x -> 12, y -> 9,  z -> 4
S = 12025  with m -> 107, x -> 24, y -> 19, z -> 12
S = 66625  with m -> 255, x -> 40, y -> 33, z -> 24
```

## Custom Example

To search for positive integers that are sums of two positive squares:

```wolfram
Target variable: S
Search variables: {a, b}
Constraint: S == a^2 + b^2
```

The app counts unique target values, not every variable assignment.

## Pell-Type Example

Some problems already give the equation value and ask for the variables. For example:

```wolfram
x^2 - a y^2 == 1
```

For this kind of problem, choose `Variable assignments` mode.

```wolfram
Search variables: {x, y, a}
Rule: x^2 - a y^2 == 1
Variable bounds: 2 <= a <= 50 && 1 <= x <= 500 && 1 <= y <= 500
```

The results are assignments such as:

```text
x -> 3, y -> 2, a -> 2
```

For a fixed Pell equation, use only the unknown variables:

```wolfram
Search variables: {x, y}
Rule: x^2 - 2 y^2 == 1
Variable bounds: 1 <= x <= 100 && 1 <= y <= 100
```

## Built-In Example Scenarios

The `Examples` panel is split into two sections with 10 presets in each section.

Target-value examples:

- `Consecutive square sums`: `S == n^2 + a^2` and `S == (n + 1)^2 + b^2`.
- `Square triangular numbers`: `S == n^2` and `S == t (t + 1)/2`.
- `Pythagorean square targets`: `S == a^2 + b^2` and `S == c^2`.
- `Square and cube sums`: `S == a^2 + b^2` and `S == c^3 + d^3`.
- `Sum and difference of squares`: `S == a^2 + b^2` and `S == c^2 - d^2`.
- `Square-cube target values`: `S == a^2` and `S == b^3`.
- `Triangular target values`: `S == n (n + 1)/2`.
- `Odd consecutive-square gaps`: `S == (n + 1)^2 - n^2`.
- `Square plus one targets`: `S == n^2 + 1`.
- `Three-square sums`: `S == a^2 + b^2 + c^2`.

Variable-assignment examples:

- `Pell-type triples`: `x^2 - a y^2 == 1`.
- `Fixed Pell x^2 - 2 y^2`: `x^2 - 2 y^2 == 1`.
- `Pythagorean triples`: `a^2 + b^2 == c^2`.
- `Markov triples`: `x^2 + y^2 + z^2 == 3 x y z`.
- `Factor pairs of 360`: `a b == 360`.
- `Difference of squares equals 45`: `x^2 - y^2 == 45`.
- `Egyptian fraction for 1/6`: equivalent to `1/x + 1/y == 1/6`.
- `Coin equation 5a + 7b`: `5 a + 7 b == 100`.
- `Square roots modulo 15`: `x^2 == 1 + 15 k`.
- `Pythagorean triples with perimeter 60`: `a^2 + b^2 == c^2` and `a + b + c == 60`.

Choose an example from the relevant section, load it, then run the search.
