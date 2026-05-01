BeginPackage["SpecialDefinedNumberFinder`"]

SpecialDefinedNumberFinderApp::usage =
  "SpecialDefinedNumberFinderApp[] launches an interactive notebook app for target-value and variable-assignment Diophantine searches.";

SpecialDefinedNumberSearch::usage =
  "SpecialDefinedNumberSearch[assoc] searches for target values or variable assignments satisfying the equations and constraints described by assoc.";

SpecialDefinedAssignmentSearch::usage =
  "SpecialDefinedAssignmentSearch[assoc] searches for variable assignments satisfying the equations and constraints described by assoc.";

SpecialDefinedNumberPreset::usage =
  "SpecialDefinedNumberPreset[\"Sorensen\"] returns the default Sorensen-number search configuration.";

SpecialDefinedNumberResultPanel::usage =
  "SpecialDefinedNumberResultPanel[result] formats a SpecialDefinedNumberSearch result for notebook display.";

Begin["`Private`"]

ClearAll[
  SpecialDefinedNumberPreset,
  SpecialDefinedNumberSearch,
  SpecialDefinedAssignmentSearch,
  SpecialDefinedNumberFinderApp,
  SpecialDefinedNumberResultPanel,
  examplePresetNames,
  targetExamplePresetNames,
  assignmentExamplePresetNames,
  examplePresetDescription,
  parseHeldString,
  parseSymbolInput,
  parseVariableListInput,
  parseRuleStrings,
  parseOptionalConstraintString,
  parseModularBasesInput,
  unsafeHeldExpressionQ,
  constraintExpressionQ,
  symbolsInHeldExpression,
  parseSearchConfig,
  targetSymbolQ,
  modularSystemPossibleQ,
  buildFullConstraints,
  verifiedRuleRows,
  sorensenPresetConfigQ,
  sorensenFastSearch,
  positiveSquareRoot,
  normalizePositiveInteger,
  normalizeInteger,
  normalizePositiveNumber,
  searchDomainConstraints,
  distinctVariableConstraints,
  distinctRepresentationConstraints,
  representationVariables,
  equationDifferenceExpressions,
  modularCandidatePossibleQ,
  integerValueQ,
  toIntegerValue,
  findNextTargetValue,
  findNextTargetValueByScan,
  findWitnessesForTarget,
  witnessRulesFromInstance,
  warningPanel,
  resultStatusPanel,
  resultTable,
  witnessRuleString,
  witnessString,
  assignmentResultTable,
  verificationString,
  uiSection,
  appCard,
  appHeader,
  fieldBlock,
  ruleInputRows,
  uiButton,
  uiInput,
  uiLabel,
  uiMuted,
  uiDomainSelector,
  uiPresetSelector,
  uiSearchModeSelector,
  uiText,
  sorensenRuleStrings
];

sorensenRuleStrings = {
  "S == m^2 + x^2",
  "S == (m + 1)^2 + y^2",
  "S == (m + 2)^2 + z^2"
};

targetSymbolQ[target_] := MatchQ[target, _Symbol] && target =!= None;

SpecialDefinedNumberPreset["Sorensen"] := <|
  "Description" -> "Find numbers with three consecutive square-sum representations.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{m, x, y, z}",
  "Rules" -> sorensenRuleStrings,
  "DesiredCount" -> 3,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 2000,
  "MaxTarget" -> 100000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 3,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

targetExamplePresetNames = {
  "Consecutive square sums",
  "Square triangular numbers",
  "Pythagorean square targets",
  "Square and cube sums",
  "Sum and difference of squares",
  "Square-cube target values",
  "Triangular target values",
  "Odd consecutive-square gaps",
  "Square plus one targets",
  "Three-square sums"
};

assignmentExamplePresetNames = {
  "Pell-type triples",
  "Fixed Pell x^2 - 2 y^2",
  "Pythagorean triples",
  "Markov triples",
  "Factor pairs of 360",
  "Difference of squares equals 45",
  "Egyptian fraction for 1/6",
  "Coin equation 5a + 7b",
  "Square roots modulo 15",
  "Pythagorean triples with perimeter 60"
};

examplePresetNames = Join[
  targetExamplePresetNames,
  assignmentExamplePresetNames
];

SpecialDefinedNumberPreset["Square-cube target values"] := <|
  "Description" -> "Find S that is both a perfect square and a perfect cube.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{a, b}",
  "Rules" -> {"S == a^2", "S == b^3"},
  "DesiredCount" -> 3,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 3,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Triangular target values"] := <|
  "Description" -> "Find triangular numbers S = n (n + 1) / 2.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{n}",
  "Rules" -> {"S == n (n + 1)/2"},
  "DesiredCount" -> 5,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 20,
  "MaxTarget" -> 100,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Odd consecutive-square gaps"] := <|
  "Description" -> "Find gaps between consecutive positive squares.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{n}",
  "Rules" -> {"S == (n + 1)^2 - n^2"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 15,
  "MaxTarget" -> 50,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Square plus one targets"] := <|
  "Description" -> "Find target values one greater than a positive square.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{n}",
  "Rules" -> {"S == n^2 + 1"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 20,
  "MaxTarget" -> 100,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Three-square sums"] := <|
  "Description" -> "Find S that can be written as a sum of three positive squares.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{a, b, c}",
  "Rules" -> {"S == a^2 + b^2 + c^2"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 15,
  "MaxTarget" -> 100,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Fixed Pell x^2 - 2 y^2"] := <|
  "Description" -> "Find positive integer solutions of x^2 - 2 y^2 == 1.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{x, y}",
  "Rules" -> {"x^2 - 2 y^2 == 1"},
  "DesiredCount" -> 5,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 8,
  "WitnessLimit" -> 5,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= x <= 500 && 1 <= y <= 500",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Pythagorean triples"] := <|
  "Description" -> "Find bounded positive integer triples a^2 + b^2 == c^2.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{a, b, c}",
  "Rules" -> {"a^2 + b^2 == c^2", "a < b"},
  "DesiredCount" -> 8,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 8,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= a <= 100 && 1 <= b <= 100 && 1 <= c <= 150",
  "DistinctVariables" -> True,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Markov triples"] := <|
  "Description" -> "Find bounded positive integer solutions of x^2 + y^2 + z^2 == 3 x y z.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{x, y, z}",
  "Rules" -> {"x^2 + y^2 + z^2 == 3 x y z"},
  "DesiredCount" -> 6,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 8,
  "WitnessLimit" -> 6,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= x <= 50 && 1 <= y <= 50 && 1 <= z <= 50",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Factor pairs of 360"] := <|
  "Description" -> "Find bounded factor pairs a b == 360 with a <= b.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{a, b}",
  "Rules" -> {"a b == 360", "a <= b"},
  "DesiredCount" -> 8,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 8,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= a <= 360 && 1 <= b <= 360",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Difference of squares equals 45"] := <|
  "Description" -> "Find bounded positive integer pairs satisfying x^2 - y^2 == 45.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{x, y}",
  "Rules" -> {"x^2 - y^2 == 45", "y < x"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 4,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= x <= 100 && 1 <= y <= 100",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Egyptian fraction for 1/6"] := <|
  "Description" -> "Find bounded positive integer pairs for 1/x + 1/y == 1/6.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{x, y}",
  "Rules" -> {"6 (x + y) == x y", "x <= y"},
  "DesiredCount" -> 5,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 5,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= x <= 100 && 1 <= y <= 100",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Coin equation 5a + 7b"] := <|
  "Description" -> "Find nonnegative integer solutions of 5 a + 7 b == 100.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{a, b}",
  "Rules" -> {"5 a + 7 b == 100"},
  "DesiredCount" -> 5,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 5,
  "VariableDomain" -> "NonNegativeIntegers",
  "VariableBounds" -> "0 <= a <= 20 && 0 <= b <= 20",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Square roots modulo 15"] := <|
  "Description" -> "Find bounded pairs showing x^2 is congruent to 1 modulo 15.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{x, k}",
  "Rules" -> {"x^2 == 1 + 15 k"},
  "DesiredCount" -> 8,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 8,
  "VariableDomain" -> "NonNegativeIntegers",
  "VariableBounds" -> "1 <= x <= 100 && 0 <= k <= 700",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Pythagorean triples with perimeter 60"] := <|
  "Description" -> "Find positive Pythagorean triples with a + b + c == 60.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{a, b, c}",
  "Rules" -> {"a^2 + b^2 == c^2", "a + b + c == 60", "a < b"},
  "DesiredCount" -> 2,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 5,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "1 <= a <= 60 && 1 <= b <= 60 && 1 <= c <= 60",
  "DistinctVariables" -> True,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Consecutive square sums"] := <|
  "Description" -> "Find S that can be written as n^2 + a^2 and also as (n + 1)^2 + b^2.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{n, a, b}",
  "Rules" -> {"S == n^2 + a^2", "S == (n + 1)^2 + b^2"},
  "DesiredCount" -> 3,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 500,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Square triangular numbers"] := <|
  "Description" -> "Find S that is both a square number and a triangular number.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{n, t}",
  "Rules" -> {"S == n^2", "S == t (t + 1)/2"},
  "DesiredCount" -> 3,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 2000,
  "ExpansionFactor" -> 4,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Pythagorean square targets"] := <|
  "Description" -> "Find square values S that are also sums of two positive squares.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{a, b, c}",
  "Rules" -> {"S == a^2 + b^2", "S == c^2"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 500,
  "MaxTarget" -> 5000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Square and cube sums"] := <|
  "Description" -> "Find S that is a sum of two squares and also a sum of two positive cubes.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{a, b, c, d}",
  "Rules" -> {"S == a^2 + b^2", "S == c^3 + d^3"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 200,
  "MaxTarget" -> 2000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Sum and difference of squares"] := <|
  "Description" -> "Find S that is both a sum of two squares and a difference of two squares.",
  "SearchMode" -> "TargetValues",
  "Target" -> "S",
  "Variables" -> "{a, b, c, d}",
  "Rules" -> {"S == a^2 + b^2", "S == c^2 - d^2"},
  "DesiredCount" -> 4,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 2000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 3,
  "WitnessLimit" -> 2,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

SpecialDefinedNumberPreset["Pell-type triples"] := <|
  "Description" -> "Find positive integer triples satisfying x^2 - a y^2 == 1.",
  "SearchMode" -> "VariableAssignments",
  "Target" -> "",
  "Variables" -> "{x, y, a}",
  "Rules" -> {"x^2 - a y^2 == 1"},
  "DesiredCount" -> 8,
  "TargetMinimum" -> 1,
  "InitialTargetMax" -> 100,
  "MaxTarget" -> 1000,
  "ExpansionFactor" -> 2,
  "CandidateTimeout" -> 8,
  "WitnessLimit" -> 8,
  "VariableDomain" -> "PositiveIntegers",
  "VariableBounds" -> "2 <= a <= 50 && 1 <= x <= 500 && 1 <= y <= 500",
  "DistinctVariables" -> False,
  "DistinctRepresentations" -> False,
  "UseModularPruning" -> True,
  "ModularBases" -> "{4, 8, 9, 16}"
|>;

examplePresetDescription[name_String] := Lookup[SpecialDefinedNumberPreset[name], "Description", ""];

SpecialDefinedNumberPreset[_] := SpecialDefinedNumberPreset["Sorensen"];

parseHeldString[str_String] := Module[{trimmed = StringTrim[str]},
  If[trimmed === "", Return[$Failed]];
  Quiet @ Check[
    Block[{$Context = "Global`", $ContextPath = {"System`", "Global`"}},
      ToExpression[trimmed, InputForm, HoldComplete]
    ],
    $Failed
  ]
];

parseHeldString[_] := $Failed;

unsafeHeldExpressionQ[held_] := ! FreeQ[
  held,
  (Set | SetDelayed | UpSet | UpSetDelayed | TagSet | TagSetDelayed |
    Unset | CompoundExpression | Get | Put | PutAppend | Run |
    RunProcess | StartProcess | Read | ReadList | Write | WriteString |
    Import | Export | ToExpression | Needs | Clear | ClearAll | Remove |
    CreateFile | DeleteFile | DeleteDirectory | CopyFile | RenameFile |
    NotebookWrite | NotebookEvaluate | FrontEndExecute | CreateDocument |
    SystemOpen)[___],
  {0, Infinity}
];

parseSymbolInput[str_, label_] := Module[{held, sym},
  held = parseHeldString[str];
  Which[
    held === $Failed,
      <|"Status" -> "InvalidInput", "Messages" -> {"Enter a valid " <> label <> " symbol."}|>,
    unsafeHeldExpressionQ[held],
      <|"Status" -> "InvalidInput", "Messages" -> {label <> " may only be a symbol."}|>,
    ! MatchQ[held, HoldComplete[_Symbol]],
      <|"Status" -> "InvalidInput", "Messages" -> {label <> " must be a single symbol, for example S."}|>,
    True,
      sym = held[[1]];
      <|"Status" -> "OK", "Symbol" -> sym, "Messages" -> {}|>
  ]
];

parseVariableListInput[str_] := Module[{held, vars},
  held = parseHeldString[str];
  Which[
    held === $Failed,
      <|"Status" -> "InvalidInput", "Messages" -> {"Enter variables as a Mathematica list, for example {m, x, y, z}."}|>,
    unsafeHeldExpressionQ[held],
      <|"Status" -> "InvalidInput", "Messages" -> {"The variables field may only contain symbols."}|>,
    ! MatchQ[held, HoldComplete[{___Symbol}]],
      <|"Status" -> "InvalidInput", "Messages" -> {"Variables must be written as a list of symbols, for example {m, x, y, z}."}|>,
    True,
      vars = DeleteDuplicates[List @@ held[[1]]];
      <|"Status" -> "OK", "Variables" -> vars, "Messages" -> {}|>
  ]
];

constraintExpressionQ[expr_] := MatchQ[
  HoldComplete[expr],
  HoldComplete[
    _Equal | _Unequal | _Less | _LessEqual | _Greater | _GreaterEqual |
      _Element | _And | _Or | _Not | True | False
  ]
];

symbolsInHeldExpression[held_] := DeleteDuplicates @ Cases[
  held,
  s_Symbol /; Context[s] =!= "System`",
  {0, Infinity},
  Heads -> True
];

parseRuleStrings[ruleStrings_List, target_, vars_List] := Module[
  {cleanRules, heldRules, badParseRows, unsafeRows, expressions, badConstraintRows,
    allowedSymbols, foundSymbols, unknownSymbols},

  cleanRules = Select[StringTrim /@ ruleStrings, # =!= "" &];
  If[cleanRules === {},
    Return @ <|"Status" -> "InvalidInput", "Messages" -> {"Enter at least one equation or constraint."}|>
  ];

  heldRules = parseHeldString /@ cleanRules;
  badParseRows = Flatten @ Position[heldRules, $Failed];
  If[badParseRows =!= {},
    Return @ <|
      "Status" -> "InvalidInput",
      "Messages" -> ("Rule " <> ToString[#] <> " could not be parsed. Use Mathematica syntax such as S == m^2 + x^2." & /@ badParseRows)
    |>
  ];

  unsafeRows = Flatten @ Position[unsafeHeldExpressionQ /@ heldRules, True];
  If[unsafeRows =!= {},
    Return @ <|
      "Status" -> "InvalidInput",
      "Messages" -> ("Rule " <> ToString[#] <> " contains an assignment or side-effecting command. Use == for equality, not =." & /@ unsafeRows)
    |>
  ];

  expressions = ReleaseHold /@ heldRules;
  badConstraintRows = Flatten @ Position[constraintExpressionQ /@ expressions, False];
  If[badConstraintRows =!= {},
    Return @ <|
      "Status" -> "InvalidInput",
      "Messages" -> ("Rule " <> ToString[#] <> " must be an equation, inequality, Element statement, or Boolean combination." & /@ badConstraintRows)
    |>
  ];

  allowedSymbols = If[targetSymbolQ[target], DeleteDuplicates @ Join[{target}, vars], vars];
  foundSymbols = DeleteDuplicates @ Flatten[symbolsInHeldExpression /@ heldRules];
  unknownSymbols = Complement[foundSymbols, allowedSymbols];
  If[unknownSymbols =!= {},
    Return @ <|
      "Status" -> "InvalidInput",
      "Messages" -> {
        "Unknown symbol(s) in rules: " <> StringRiffle[SymbolName /@ unknownSymbols, ", "] <>
          ". Add them to the variables list or correct the rule."
      }
    |>
  ];

  <|"Status" -> "OK", "Rules" -> expressions, "RuleStrings" -> cleanRules, "Messages" -> {}|>
];

parseOptionalConstraintString[str_, target_, vars_List, label_String] := Module[
  {clean = StringTrim[ToString[str]], held, expression, allowedSymbols, foundSymbols, unknownSymbols},

  If[clean === "",
    Return @ <|"Status" -> "OK", "Constraint" -> True, "Messages" -> {}|>
  ];

  held = parseHeldString[clean];
  Which[
    held === $Failed,
      Return @ <|"Status" -> "InvalidInput", "Messages" -> {label <> " could not be parsed."}|>,
    unsafeHeldExpressionQ[held],
      Return @ <|"Status" -> "InvalidInput", "Messages" -> {label <> " contains an assignment or side-effecting command."}|>
  ];

  expression = ReleaseHold[held];
  If[! constraintExpressionQ[expression],
    Return @ <|"Status" -> "InvalidInput", "Messages" -> {label <> " must be an equation, inequality, Element statement, or Boolean combination."}|>
  ];

  allowedSymbols = If[targetSymbolQ[target], DeleteDuplicates @ Join[{target}, vars], vars];
  foundSymbols = symbolsInHeldExpression[held];
  unknownSymbols = Complement[foundSymbols, allowedSymbols];
  If[unknownSymbols =!= {},
    Return @ <|
      "Status" -> "InvalidInput",
      "Messages" -> {
        label <> " contains unknown symbol(s): " <> StringRiffle[SymbolName /@ unknownSymbols, ", "] <>
          ". Add them to the variables list or correct the bounds."
      }
    |>
  ];

  <|"Status" -> "OK", "Constraint" -> expression, "Messages" -> {}|>
];

parseModularBasesInput[str_] := Module[{held, bases},
  held = parseHeldString[ToString[str]];
  Which[
    StringTrim[ToString[str]] === "",
      <|"Status" -> "OK", "Bases" -> {4, 8, 9, 16}, "Messages" -> {}|>,
    held === $Failed || unsafeHeldExpressionQ[held] || ! MatchQ[held, HoldComplete[{__Integer}]],
      <|"Status" -> "InvalidInput", "Messages" -> {"Modular bases must be a list of integers, for example {4, 8, 9, 16}."}|>,
    True,
      bases = DeleteDuplicates[List @@ held[[1]]];
      bases = Select[bases, 2 <= # <= 32 &];
      If[bases === {},
        <|"Status" -> "InvalidInput", "Messages" -> {"Use at least one modular base from 2 to 32."}|>,
        <|"Status" -> "OK", "Bases" -> bases, "Messages" -> {}|>
      ]
  ]
];

normalizePositiveInteger[value_, default_, minimum_: 1] := Module[{n},
  n = Quiet @ Check[Round[N[value]], default];
  If[IntegerQ[n] && n >= minimum, n, default]
];

normalizeInteger[value_, default_] := Module[{n},
  n = Quiet @ Check[Round[N[value]], default];
  If[IntegerQ[n], n, default]
];

normalizePositiveNumber[value_, default_, minimum_: 0.1] := Module[{n},
  n = Quiet @ Check[N[value], default];
  If[NumericQ[n] && n >= minimum, n, default]
];

parseSearchConfig[config_Association] := Module[
  {targetInput, varsInput, rulesInput, target, vars, duplicateTarget, ruleStrings,
    rules, messages = {}, desiredCount, initialTargetMax, maxTarget, expansionFactor,
    candidateTimeout, witnessLimit, targetMinimum, variableDomain, boundsInput,
    variableBounds, distinctVariables, distinctRepresentations, useModularPruning, searchMode,
    modularBasesInput, modularBases},

  searchMode = Lookup[config, "SearchMode", "TargetValues"];
  If[! MemberQ[{"TargetValues", "VariableAssignments"}, searchMode], searchMode = "TargetValues"];

  If[searchMode === "TargetValues",
    targetInput = parseSymbolInput[Lookup[config, "Target", "S"], "target variable"];
    If[targetInput["Status"] =!= "OK", Return[targetInput]];
    target = targetInput["Symbol"],
    target = None
  ];

  varsInput = parseVariableListInput[Lookup[config, "Variables", "{}"]];
  If[varsInput["Status"] =!= "OK", Return[varsInput]];
  vars = varsInput["Variables"];

  If[searchMode === "TargetValues",
    duplicateTarget = MemberQ[vars, target];
    vars = DeleteCases[vars, s_ /; SameQ[s, target]];
    If[duplicateTarget,
      AppendTo[messages, "The target variable was also listed as a search variable, so it was removed from the variable list."]
    ]
  ];

  ruleStrings = Lookup[config, "Rules", {}];
  If[! ListQ[ruleStrings], ruleStrings = {ToString[ruleStrings]}];
  rulesInput = parseRuleStrings[ruleStrings, target, vars];
  If[rulesInput["Status"] =!= "OK", Return[rulesInput]];
  rules = rulesInput["Rules"];

  variableDomain = Lookup[config, "VariableDomain", "PositiveIntegers"];
  If[! MemberQ[{"PositiveIntegers", "NonNegativeIntegers", "Integers"}, variableDomain],
    variableDomain = "PositiveIntegers"
  ];

  boundsInput = parseOptionalConstraintString[Lookup[config, "VariableBounds", ""], target, vars, "Variable bounds"];
  If[boundsInput["Status"] =!= "OK", Return[boundsInput]];
  variableBounds = boundsInput["Constraint"];

  modularBasesInput = parseModularBasesInput[Lookup[config, "ModularBases", "{4, 8, 9, 16}"]];
  If[modularBasesInput["Status"] =!= "OK", Return[modularBasesInput]];
  modularBases = modularBasesInput["Bases"];

  desiredCount = normalizePositiveInteger[Lookup[config, "DesiredCount", 3], 3, 1];
  targetMinimum = normalizeInteger[Lookup[config, "TargetMinimum", 1], 1];
  initialTargetMax = normalizePositiveInteger[Lookup[config, "InitialTargetMax", 2000], 2000, 1];
  maxTarget = normalizePositiveInteger[Lookup[config, "MaxTarget", 100000], 100000, 1];
  initialTargetMax = Max[targetMinimum, initialTargetMax];
  maxTarget = Max[targetMinimum, initialTargetMax, maxTarget];
  expansionFactor = normalizePositiveInteger[Lookup[config, "ExpansionFactor", 2], 2, 2];
  candidateTimeout = normalizePositiveNumber[Lookup[config, "CandidateTimeout", 20], 20, 0.25];
  witnessLimit = normalizePositiveInteger[Lookup[config, "WitnessLimit", 3], 3, 1];
  distinctVariables = TrueQ[Lookup[config, "DistinctVariables", False]];
  distinctRepresentations = TrueQ[Lookup[config, "DistinctRepresentations", False]];
  useModularPruning = TrueQ[Lookup[config, "UseModularPruning", True]];

  <|
    "Status" -> "OK",
    "SearchMode" -> searchMode,
    "Target" -> target,
    "TargetName" -> If[targetSymbolQ[target], SymbolName[target], ""],
    "Variables" -> vars,
    "VariableNames" -> SymbolName /@ vars,
    "Rules" -> rules,
    "RuleStrings" -> rulesInput["RuleStrings"],
    "DesiredCount" -> desiredCount,
    "TargetMinimum" -> targetMinimum,
    "InitialTargetMax" -> initialTargetMax,
    "MaxTarget" -> maxTarget,
    "ExpansionFactor" -> expansionFactor,
    "CandidateTimeout" -> candidateTimeout,
    "WitnessLimit" -> witnessLimit,
    "VariableDomain" -> variableDomain,
    "VariableBounds" -> variableBounds,
    "DistinctVariables" -> distinctVariables,
    "DistinctRepresentations" -> distinctRepresentations,
    "UseModularPruning" -> useModularPruning,
    "ModularBases" -> modularBases,
    "Messages" -> messages
  |>
];

parseSearchConfig[_] := <|"Status" -> "InvalidInput", "Messages" -> {"Search configuration must be an Association."}|>;

searchDomainConstraints[target_, vars_List, domain_String] := Module[
  {variableBounds, allVars},
  variableBounds = Switch[
    domain,
    "PositiveIntegers", If[vars === {}, True, And @@ Thread[vars >= 1]],
    "NonNegativeIntegers", If[vars === {}, True, And @@ Thread[vars >= 0]],
    "Integers", True,
    _, And @@ Thread[vars >= 1]
  ];
  allVars = If[targetSymbolQ[target], DeleteDuplicates@Join[{target}, vars], vars];
  Element[allVars, Integers] && variableBounds
];

distinctVariableConstraints[vars_List, requireDistinct_] := If[
  TrueQ[requireDistinct] && Length[vars] > 1,
  And @@ (Unequal @@@ Subsets[vars, {2}]),
  True
];

representationVariables[expr_, vars_List] := DeleteDuplicates @ Cases[
  HoldComplete[expr],
  s_Symbol /; MemberQ[vars, s],
  {0, Infinity}
];

distinctRepresentationConstraints[rules_List, target_, vars_List, requireDistinct_] := Module[
  {representations, pairs},
  If[! targetSymbolQ[target], Return[True]];
  If[! TrueQ[requireDistinct], Return[True]];

  representations = Cases[
    rules,
    Equal[target, rhs_] :> representationVariables[rhs, vars],
    {0, Infinity}
  ];
  representations = Join[
    representations,
    Cases[rules, Equal[lhs_, target] :> representationVariables[lhs, vars], {0, Infinity}]
  ];
  representations = Select[representations, Length[#] > 0 &];
  pairs = Select[Subsets[representations, {2}], Length[#[[1]]] === Length[#[[2]]] &];
  If[pairs === {},
    True,
    And @@ ((Or @@ MapThread[Unequal, #]) & /@ pairs)
  ]
];

equationDifferenceExpressions[rules_List] := DeleteDuplicates @ Flatten @ Cases[
  rules,
  Equal[args__] :> (Subtract @@@ Partition[List[args], 2, 1]),
  {0, Infinity}
];

modularCandidatePossibleQ[diffs_List, target_Symbol, vars_List, n_Integer, moduli_List, maxTuples_: 20000] := Module[
  {usableDiffs, q, tuples, targetRule, possibleQ},
  usableDiffs = Select[diffs, FreeQ[#, Rational[_, d_] /; d =!= 1] &];
  If[usableDiffs === {} || vars === {}, Return[True]];

  Do[
    If[q^Length[vars] > maxTuples, Continue[]];
    targetRule = target -> Mod[n, q];
    tuples = Tuples[Range[0, q - 1], Length[vars]];
    possibleQ = AnyTrue[
      tuples,
      Function[tuple,
        TrueQ @ And @@ Thread[
          Mod[usableDiffs /. targetRule /. Thread[vars -> tuple], q] == 0
        ]
      ]
    ];
    If[! TrueQ[possibleQ], Return[False]],
    {q, moduli}
  ];

  True
];

modularSystemPossibleQ[diffs_List, vars_List, moduli_List, maxTuples_: 20000] := Module[
  {usableDiffs, q, tuples, possibleQ},
  usableDiffs = Select[diffs, FreeQ[#, Rational[_, d_] /; d =!= 1] &];
  If[usableDiffs === {} || vars === {}, Return[True]];

  Do[
    If[q^Length[vars] > maxTuples, Continue[]];
    tuples = Tuples[Range[0, q - 1], Length[vars]];
    possibleQ = AnyTrue[
      tuples,
      Function[tuple,
        TrueQ @ And @@ Thread[
          Mod[usableDiffs /. Thread[vars -> tuple], q] == 0
        ]
      ]
    ];
    If[! TrueQ[possibleQ], Return[False]],
    {q, moduli}
  ];

  True
];

buildFullConstraints[parsed_Association] := And @@ Join[
  parsed["Rules"],
  {
    searchDomainConstraints[parsed["Target"], parsed["Variables"], parsed["VariableDomain"]],
    parsed["VariableBounds"],
    distinctVariableConstraints[parsed["Variables"], parsed["DistinctVariables"]],
    distinctRepresentationConstraints[parsed["Rules"], parsed["Target"], parsed["Variables"], parsed["DistinctRepresentations"]]
  }
];

verifiedRuleRows[rules_List, assignment_List] := <|
    "Rule" -> ToString[#, InputForm],
    "Valid" -> TrueQ[# /. assignment]
  |> & /@ rules;

sorensenPresetConfigQ[parsed_Association] := Module[{ruleKey},
  ruleKey = StringReplace[#, WhitespaceCharacter .. -> ""] & /@ Lookup[parsed, "RuleStrings", {}];
  Lookup[parsed, "TargetName", ""] === "S" &&
    Sort[Lookup[parsed, "VariableNames", {}]] === Sort[{"m", "x", "y", "z"}] &&
    Sort[ruleKey] === Sort[StringReplace[#, WhitespaceCharacter .. -> ""] & /@ sorensenRuleStrings] &&
    Lookup[parsed, "VariableDomain", "PositiveIntegers"] === "PositiveIntegers"
];

positiveSquareRoot[n_Integer] := Module[{r},
  If[n <= 0, Return[Missing["NotSquare"]]];
  r = Floor[Sqrt[n]];
  If[r^2 === n, r, Missing["NotSquare"]]
];

sorensenFastSearch[parsed_Association] := Module[
  {desiredCount, targetMinimum, maxTarget, witnessLimit, limit, buckets = <||>, m, x, s, y2, z2, y, z,
    sortedValues, results, status, targetSym, vars, mSym, xSym, ySym, zSym, assignmentRules, boundsOK,
    distinctVarsOK, distinctRepsOK},

  desiredCount = parsed["DesiredCount"];
  targetSym = parsed["Target"];
  targetMinimum = parsed["TargetMinimum"];
  maxTarget = parsed["MaxTarget"];
  witnessLimit = parsed["WitnessLimit"];
  limit = Floor[Sqrt[maxTarget - 1]];
  vars = AssociationThread[SymbolName /@ parsed["Variables"], parsed["Variables"]];
  {mSym, xSym, ySym, zSym} = Lookup[vars, {"m", "x", "y", "z"}];

  Do[
    s = m^2 + x^2;
    If[targetMinimum <= s <= maxTarget,
      y2 = s - (m + 1)^2;
      z2 = s - (m + 2)^2;
      y = positiveSquareRoot[y2];
      z = positiveSquareRoot[z2];
      If[IntegerQ[y] && IntegerQ[z],
        assignmentRules = {targetSym -> s, mSym -> m, xSym -> x, ySym -> y, zSym -> z};
        boundsOK = TrueQ[parsed["VariableBounds"] /. assignmentRules];
        distinctVarsOK = ! TrueQ[parsed["DistinctVariables"]] || DuplicateFreeQ[{m, x, y, z}];
        distinctRepsOK = ! TrueQ[parsed["DistinctRepresentations"]] || DuplicateFreeQ[{{m, x}, {m, y}, {m, z}}];
        If[TrueQ[boundsOK] && TrueQ[distinctVarsOK] && TrueQ[distinctRepsOK],
          If[! KeyExistsQ[buckets, s], buckets[s] = {}];
          If[Length[buckets[s]] < witnessLimit,
            buckets[s] = Append[buckets[s], {mSym -> m, xSym -> x, ySym -> y, zSym -> z}]
          ]
        ]
      ]
    ],
    {m, 1, limit},
    {x, 1, limit}
  ];

  sortedValues = Take[Sort[Keys[buckets]], UpTo[desiredCount]];
  results = <|
      "TargetValue" -> #,
      "Witnesses" -> buckets[#],
      "SearchUpperBound" -> maxTarget
    |> & /@ sortedValues;
  status = Which[
    Length[results] >= desiredCount, "Success",
    results === {}, "NoResults",
    True, "LimitReached"
  ];

  <|
    "Status" -> status,
    "Results" -> results,
    "Messages" -> parsed["Messages"],
    "TargetName" -> parsed["TargetName"],
    "VariableNames" -> parsed["VariableNames"],
    "DesiredCount" -> desiredCount,
    "TargetMinimum" -> targetMinimum,
    "InitialTargetMax" -> parsed["InitialTargetMax"],
    "MaxTarget" -> maxTarget
  |>
];

integerValueQ[value_] := Quiet @ TrueQ[
  NumericQ[N[value]] && Chop[N[value] - Round[N[value]]] == 0
];

toIntegerValue[value_] := Round[N[value]];

findNextTargetValue[constraints_, target_Symbol, vars_List, allVars_List, lower_Integer, upper_Integer, timeout_, diffs_List, useModularPruning_, moduli_List] := Module[
  {boundedConstraints, answer, value, rules},

  boundedConstraints = constraints && target >= lower && target <= upper;
  answer = TimeConstrained[
    Quiet @ Check[Minimize[{target, boundedConstraints}, allVars, Integers], $Failed],
    timeout,
    $TimedOut
  ];

  Which[
    answer === $TimedOut,
      <|"Status" -> "Timeout", "Message" -> "Timed out while searching target values up to " <> ToString[upper] <> "."|>,
    MatchQ[answer, {Infinity, _}],
      <|"Status" -> "NoSolution"|>,
    MatchQ[answer, {_, _List}],
      value = answer[[1]];
      rules = answer[[2]];
      If[integerValueQ[value],
        <|"Status" -> "Found", "TargetValue" -> toIntegerValue[value], "Rules" -> rules|>,
        findNextTargetValueByScan[constraints, target, vars, allVars, lower, upper, timeout, diffs, useModularPruning, moduli]
      ],
    True,
      findNextTargetValueByScan[constraints, target, vars, allVars, lower, upper, timeout, diffs, useModularPruning, moduli]
  ]
];

findNextTargetValueByScan[constraints_, target_Symbol, vars_List, allVars_List, lower_Integer, upper_Integer, timeout_, diffs_List, useModularPruning_, moduli_List] := Module[
  {window, deadline, remaining, n, answer},

  window = upper - lower + 1;
  If[window > 50000,
    Return @ <|
      "Status" -> "Inconclusive",
      "Message" -> "Mathematica could not optimize this rule set, and the fallback exact-target scan would cover " <>
        ToString[window] <> " target values."
    |>
  ];

  deadline = AbsoluteTime[] + timeout;
  For[n = lower, n <= upper, n++,
    remaining = deadline - AbsoluteTime[];
    If[remaining <= 0,
      Return @ <|"Status" -> "Inconclusive", "Message" -> "Could not finish exact-target scanning from " <> ToString[lower] <> " to " <> ToString[upper] <> " within the time limit."|>
    ];
    If[TrueQ[useModularPruning] && ! modularCandidatePossibleQ[diffs, target, vars, n, moduli],
      Continue[]
    ];
    answer = TimeConstrained[
      Quiet @ Check[FindInstance[constraints && target == n, allVars, Integers, 1], $Failed],
      Min[0.75, Max[0.05, remaining]],
      $TimedOut
    ];
    Which[
      answer === $TimedOut,
        Return @ <|"Status" -> "Inconclusive", "Message" -> "Could not finish checking target value " <> ToString[n] <> " within the time limit."|>,
      ListQ[answer] && answer =!= {},
        Return @ <|"Status" -> "Found", "TargetValue" -> n, "Rules" -> First[answer]|>
    ];
  ];

  <|"Status" -> "NoSolution"|>
];

witnessRulesFromInstance[rules_List, target_, vars_List] := Cases[
  Table[
    With[{value = var /. rules},
      If[SameQ[value, var], Missing["NotAssigned"], var -> value]
    ],
    {var, vars}
  ],
  _Rule
];

findWitnessesForTarget[constraints_, target_Symbol, vars_List, allVars_List, value_Integer, limit_Integer, timeout_, fallbackRules_: {}] := Module[
  {answer, witnesses, fallbackWitness},

  answer = TimeConstrained[
    Quiet @ Check[FindInstance[constraints && target == value, allVars, Integers, limit], $Failed],
    timeout,
    $TimedOut
  ];

  fallbackWitness = witnessRulesFromInstance[fallbackRules, target, vars];

  Which[
    ListQ[answer] && answer =!= {},
      witnesses = DeleteDuplicates[witnessRulesFromInstance[#, target, vars] & /@ answer];
      <|"Status" -> "OK", "Witnesses" -> witnesses, "Messages" -> {}|>,
    fallbackWitness =!= {},
      <|"Status" -> "Fallback", "Witnesses" -> {fallbackWitness}, "Messages" -> {"Witness search was limited; showing the optimizer witness for S = " <> ToString[value] <> "."}|>,
    answer === $TimedOut,
      <|"Status" -> "Timeout", "Witnesses" -> {}, "Messages" -> {"Timed out while finding witnesses for S = " <> ToString[value] <> "."}|>,
    True,
      <|"Status" -> "Failed", "Witnesses" -> {}, "Messages" -> {"No witness assignment could be displayed for S = " <> ToString[value] <> "."}|>
  ]
];

SpecialDefinedAssignmentSearch[config_Association] := Module[
  {parsed, vars, constraints, timeout, desiredCount, answer, assignments, results,
    status, messages, equationDiffs},

  parsed = parseSearchConfig[Join[config, <|"SearchMode" -> "VariableAssignments"|>]];
  If[parsed["Status"] =!= "OK",
    Return @ <|
      "Status" -> parsed["Status"],
      "ResultType" -> "Assignments",
      "Results" -> {},
      "Messages" -> parsed["Messages"],
      "TargetName" -> ""
    |>
  ];

  vars = parsed["Variables"];
  constraints = buildFullConstraints[parsed];
  timeout = parsed["CandidateTimeout"];
  desiredCount = parsed["DesiredCount"];
  messages = parsed["Messages"];
  equationDiffs = equationDifferenceExpressions[parsed["Rules"]];

  If[TrueQ[parsed["UseModularPruning"]] && ! modularSystemPossibleQ[equationDiffs, vars, parsed["ModularBases"]],
    Return @ <|
      "Status" -> "NoResults",
      "ResultType" -> "Assignments",
      "Results" -> {},
      "Messages" -> Join[messages, {"Modular pruning proved that no assignment can satisfy these equations for the selected modular bases."}],
      "TargetName" -> "",
      "VariableNames" -> parsed["VariableNames"],
      "DesiredCount" -> desiredCount
    |>
  ];

  answer = TimeConstrained[
    Quiet @ Check[FindInstance[constraints, vars, Integers, desiredCount], $Failed],
    timeout,
    $TimedOut
  ];

  Which[
    answer === $TimedOut,
      status = "Timeout";
      assignments = {};
      messages = Join[messages, {"Timed out while finding variable assignments."}],
    answer === $Failed,
      status = "Failed";
      assignments = {};
      messages = Join[messages, {"Mathematica could not complete the assignment search."}],
    ListQ[answer] && answer =!= {},
      status = "Success";
      assignments = DeleteDuplicates[witnessRulesFromInstance[#, None, vars] & /@ answer],
    True,
      status = "NoResults";
      assignments = {}
  ];

  results = <|
      "Assignment" -> #,
      "VerifiedRules" -> verifiedRuleRows[parsed["Rules"], #]
    |> & /@ assignments;

  <|
    "Status" -> status,
    "ResultType" -> "Assignments",
    "Results" -> results,
    "Messages" -> DeleteDuplicates[messages],
    "TargetName" -> "",
    "VariableNames" -> parsed["VariableNames"],
    "DesiredCount" -> desiredCount
  |>
];

SpecialDefinedAssignmentSearch[_] := <|
  "Status" -> "InvalidInput",
  "ResultType" -> "Assignments",
  "Results" -> {},
  "Messages" -> {"Search configuration must be an Association."},
  "TargetName" -> ""
|>;

SpecialDefinedNumberSearch[config_Association] := Module[
  {parsed, target, vars, allVars, baseConstraints, desiredCount, initialUpper,
    maxTarget, expansionFactor, timeout, witnessLimit, messages, results = {},
    lower, upper, next, witnesses, status = "Success", equationDiffs},

  parsed = parseSearchConfig[config];
  If[parsed["Status"] =!= "OK",
    Return @ <|
      "Status" -> parsed["Status"],
      "Results" -> {},
      "Messages" -> parsed["Messages"],
      "TargetName" -> Lookup[parsed, "TargetName", "S"]
    |>
  ];

  If[parsed["SearchMode"] === "VariableAssignments",
    Return @ SpecialDefinedAssignmentSearch[config]
  ];

  If[sorensenPresetConfigQ[parsed],
    Return @ sorensenFastSearch[parsed]
  ];

  target = parsed["Target"];
  vars = parsed["Variables"];
  allVars = DeleteDuplicates @ Join[{target}, vars];
  baseConstraints = buildFullConstraints[parsed];
  equationDiffs = equationDifferenceExpressions[parsed["Rules"]];

  desiredCount = parsed["DesiredCount"];
  lower = parsed["TargetMinimum"];
  initialUpper = parsed["InitialTargetMax"];
  maxTarget = parsed["MaxTarget"];
  expansionFactor = parsed["ExpansionFactor"];
  timeout = parsed["CandidateTimeout"];
  witnessLimit = parsed["WitnessLimit"];
  messages = parsed["Messages"];
  upper = initialUpper;

  While[Length[results] < desiredCount && lower <= maxTarget,
    upper = Min[maxTarget, Max[upper, lower]];
    next = findNextTargetValue[
      baseConstraints, target, vars, allVars, lower, upper, timeout,
      equationDiffs, parsed["UseModularPruning"], parsed["ModularBases"]
    ];

    Switch[next["Status"],
      "Found",
        witnesses = findWitnessesForTarget[
          baseConstraints, target, vars, allVars, next["TargetValue"], witnessLimit, timeout, Lookup[next, "Rules", {}]
        ];
        messages = Join[messages, witnesses["Messages"]];
        AppendTo[
          results,
          <|
            "TargetValue" -> next["TargetValue"],
            "Witnesses" -> witnesses["Witnesses"],
            "SearchUpperBound" -> upper
          |>
        ];
        lower = next["TargetValue"] + 1,

      "NoSolution",
        If[upper >= maxTarget,
          status = If[results === {}, "NoResults", "LimitReached"];
          Break[],
          upper = Min[maxTarget, Max[upper + 1, Ceiling[upper * expansionFactor]]]
        ],

      "Inconclusive",
        AppendTo[messages, next["Message"] <> " Expanding the target bound."];
        If[upper >= maxTarget,
          status = "Timeout";
          Break[],
          upper = Min[maxTarget, Max[upper + 1, Ceiling[upper * expansionFactor]]]
        ],

      "Timeout",
        status = "Timeout";
        AppendTo[messages, next["Message"]];
        Break[],

      "Failed",
        status = "Failed";
        AppendTo[messages, next["Message"]];
        Break[],

      _,
        status = "Failed";
        AppendTo[messages, "Search stopped because Mathematica returned an unexpected result."];
        Break[]
    ];
  ];

  If[Length[results] >= desiredCount, status = "Success"];
  If[lower > maxTarget && Length[results] < desiredCount && status === "Success",
    status = If[results === {}, "NoResults", "LimitReached"]
  ];

  <|
    "Status" -> status,
    "Results" -> results,
    "Messages" -> DeleteDuplicates[messages],
    "TargetName" -> parsed["TargetName"],
    "VariableNames" -> parsed["VariableNames"],
    "DesiredCount" -> desiredCount,
    "TargetMinimum" -> parsed["TargetMinimum"],
    "InitialTargetMax" -> initialUpper,
    "MaxTarget" -> maxTarget
  |>
];

SpecialDefinedNumberSearch[_] := <|
  "Status" -> "InvalidInput",
  "Results" -> {},
  "Messages" -> {"Search configuration must be an Association."},
  "TargetName" -> "S"
|>;

appTextColor = RGBColor[0.08, 0.10, 0.13];
appMutedTextColor = RGBColor[0.38, 0.43, 0.50];
appBackgroundColor = RGBColor[0.95, 0.97, 0.99];
appPanelColor = White;
appPanelAltColor = RGBColor[0.98, 0.99, 1.0];
appBorderColor = RGBColor[0.80, 0.84, 0.90];
appAccentColor = RGBColor[0.06, 0.34, 0.68];
appAccentDarkColor = RGBColor[0.03, 0.20, 0.42];
appAccentLightColor = RGBColor[0.86, 0.92, 1.0];

uiText[text_, size_: 11, weight_: Plain, color_: appTextColor] :=
  Style[text, size, weight, color, FontFamily -> "Segoe UI"];

uiLabel[text_] := uiText[text, 11, Bold, appTextColor];
uiMuted[text_] := uiText[text, 10, Plain, appMutedTextColor];

uiInput[dynamic_, type_, fieldSize_] := InputField[
  dynamic,
  type,
  FieldSize -> fieldSize,
  Background -> White,
  BaseStyle -> {FontFamily -> "Consolas", FontSize -> 12, FontColor -> appTextColor}
];

uiPresetSelector[dynamic_, names_List: examplePresetNames] := PopupMenu[
  dynamic,
  Thread[names -> names],
  Background -> White,
  BaseStyle -> {FontFamily -> "Segoe UI", FontSize -> 11, FontColor -> appTextColor}
];

uiSearchModeSelector[dynamic_] := PopupMenu[
  dynamic,
  {
    "TargetValues" -> "Target values",
    "VariableAssignments" -> "Variable assignments"
  },
  Background -> White,
  BaseStyle -> {FontFamily -> "Segoe UI", FontSize -> 11, FontColor -> appTextColor}
];

uiDomainSelector[dynamic_] := PopupMenu[
  dynamic,
  {
    "PositiveIntegers" -> "Positive integers",
    "NonNegativeIntegers" -> "Nonnegative integers",
    "Integers" -> "All integers"
  },
  Background -> White,
  BaseStyle -> {FontFamily -> "Segoe UI", FontSize -> 11, FontColor -> appTextColor}
];

SetAttributes[uiButton, HoldRest];

uiButton[label_, action_, kind_: "Secondary", width_: Automatic] := Button[
  Style[
    label,
    11,
    Bold,
    If[kind === "Primary", White, appAccentDarkColor],
    FontFamily -> "Segoe UI"
  ],
  action,
  Method -> "Queued",
  Appearance -> "Palette",
  Background -> If[kind === "Primary", appAccentColor, appAccentLightColor],
  ImageSize -> If[width === Automatic, Automatic, {width, 34}],
  BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> If[kind === "Primary", White, appAccentDarkColor]}
];

fieldBlock[label_, control_, hint_: ""] := Column[
  DeleteCases[
    {
      uiLabel[label],
      control,
      If[hint === "", Nothing, uiMuted[hint]]
    },
    Nothing
  ],
  Spacings -> 0.35
];

appCard[title_, content_, width_: Automatic] := Framed[
  Column[
    {
      uiText[title, 13, Bold, appTextColor],
      content
    },
    Spacings -> 0.85
  ],
  Background -> appPanelColor,
  FrameStyle -> appBorderColor,
  RoundingRadius -> 6,
  FrameMargins -> 14,
  ImageSize -> width,
  BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
];

appHeader[] := Framed[
  Grid[
    {
      {
        Column[
          {
            uiText["Special Defined Number Finder", 24, Bold, appTextColor],
            uiText["Find target values or bounded variable assignments satisfying custom olympiad-style rules.", 11, Plain, appMutedTextColor]
          },
          Spacings -> 0.25
        ],
        Framed[
          uiText["Positive integers", 10, Bold, appAccentDarkColor],
          Background -> appAccentLightColor,
          FrameStyle -> RGBColor[0.72, 0.82, 0.96],
          RoundingRadius -> 4,
          FrameMargins -> {{10, 10}, {5, 5}}
        ]
      }
    },
    Alignment -> {{Left, Right}, Center},
    ItemSize -> {{64, 18}, Automatic}
  ],
  Background -> appPanelColor,
  FrameStyle -> appBorderColor,
  RoundingRadius -> 6,
  FrameMargins -> 16,
  BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
];

SetAttributes[ruleInputRows, HoldFirst];

ruleInputRows[ruleStrings_] := Dynamic @ Column[
  Table[
    With[{i = i},
      Grid[
        {{
          uiText[ToString[i] <> ".", 11, Bold, appMutedTextColor],
          uiInput[Dynamic[ruleStrings[[i]]], String, 68]
        }},
        Alignment -> {Left, Center},
        Spacings -> {0.7, 0.25}
      ]
    ],
    {i, Length[ruleStrings]}
  ],
  Spacings -> 0.6
];

warningPanel[messages_List] := If[messages === {},
  Nothing,
  Framed[
    Column[Style[#, 11, RGBColor[0.45, 0.25, 0.05]] & /@ messages, Spacings -> 0.35],
    Background -> RGBColor[1, 0.97, 0.88],
    FrameStyle -> RGBColor[0.89, 0.72, 0.42],
    RoundingRadius -> 5,
    FrameMargins -> 8,
    BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
  ]
];

resultStatusPanel[result_Association] := Module[{status, results, targetName, messages, resultType},
  status = Lookup[result, "Status", "NotRun"];
  results = Lookup[result, "Results", {}];
  targetName = Lookup[result, "TargetName", "S"];
  messages = Lookup[result, "Messages", {}];
  resultType = Lookup[result, "ResultType", "TargetValues"];

  Which[
    status === "NotRun",
      Framed[
        Style["Press Find numbers to start the search.", 12, GrayLevel[0.35]],
        Background -> GrayLevel[0.97],
        FrameStyle -> GrayLevel[0.82],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ],
    status === "InvalidInput",
      Framed[
        Column[Style[#, 11, Red] & /@ messages, Spacings -> 0.4],
        Background -> Lighter[Red, 0.94],
        FrameStyle -> Lighter[Red, 0.55],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ],
    status === "Success",
      Framed[
        Style[
          If[resultType === "Assignments",
            "Found " <> ToString[Length[results]] <> " assignment(s).",
            "Found " <> ToString[Length[results]] <> " unique " <> targetName <> " value(s)."
          ],
          12,
          Darker[Green],
          Bold
        ],
        Background -> Lighter[Green, 0.92],
        FrameStyle -> Lighter[Green, 0.55],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ],
    status === "NoResults",
      Framed[
        Style[
          If[resultType === "Assignments",
            "No assignments were found for the selected rules and bounds.",
            "No target values were found before the maximum bound."
          ],
          12,
          RGBColor[0.6, 0.32, 0.02],
          Bold
        ],
        Background -> RGBColor[1, 0.96, 0.88],
        FrameStyle -> RGBColor[0.88, 0.7, 0.42],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ],
    status === "LimitReached",
      Framed[
        Style["The search reached the maximum bound after finding " <> ToString[Length[results]] <> " value(s).", 12, RGBColor[0.6, 0.32, 0.02], Bold],
        Background -> RGBColor[1, 0.96, 0.88],
        FrameStyle -> RGBColor[0.88, 0.7, 0.42],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ],
    status === "Timeout",
      Framed[
        Style["The search timed out. Increase the time limit or reduce the search bounds.", 12, RGBColor[0.65, 0.16, 0.1], Bold],
        Background -> Lighter[Red, 0.94],
        FrameStyle -> Lighter[Red, 0.55],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ],
    True,
      Framed[
        Style["The search stopped before completing.", 12, RGBColor[0.65, 0.16, 0.1], Bold],
        Background -> Lighter[Red, 0.94],
        FrameStyle -> Lighter[Red, 0.55],
        RoundingRadius -> 5,
        FrameMargins -> 10,
        BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
      ]
  ]
];

witnessRuleString[Rule[s_Symbol, value_]] := SymbolName[s] <> " -> " <> ToString[value, InputForm];
witnessRuleString[other_] := ToString[other, InputForm];

witnessString[rules_List] := If[rules === {},
  "(no witness displayed)",
  StringRiffle[witnessRuleString /@ rules, ", "]
];

verificationString[rows_List] := Column[
  If[rows === {},
    {uiMuted["No rules recorded."]},
    (Style[
        If[TrueQ[Lookup[#, "Valid", False]], "True: ", "False: "] <> Lookup[#, "Rule", ""],
        10,
        If[TrueQ[Lookup[#, "Valid", False]], Darker[Green], Red],
        FontFamily -> "Consolas"
      ] & /@ rows)
  ],
  Spacings -> 0.25
];

verificationString[_] := uiMuted["No rules recorded."];

assignmentResultTable[result_Association] := Module[{rows, results},
  results = Lookup[result, "Results", {}];
  If[results === {}, Return[Nothing]];

  rows = Prepend[
    MapIndexed[
      {
        #2[[1]],
        Style[witnessString[Lookup[#1, "Assignment", {}]], 10, appTextColor, FontFamily -> "Consolas"],
        verificationString[Lookup[#1, "VerifiedRules", {}]]
      } &,
      results
    ],
    {Style["#", Bold], Style["Assignment", Bold], Style["Verified rules", Bold]}
  ];

  Grid[
    rows,
    Frame -> All,
    Alignment -> {Left, Top},
    Background -> {None, {GrayLevel[0.94], {White, GrayLevel[0.985]}}},
    Spacings -> {1.2, 0.75},
    ItemSize -> {{3, 58, 58}, Automatic},
    BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
  ]
];

resultTable[result_Association] := Module[{rows, targetName, results},
  If[Lookup[result, "ResultType", "TargetValues"] === "Assignments",
    Return @ assignmentResultTable[result]
  ];

  results = Lookup[result, "Results", {}];
  targetName = Lookup[result, "TargetName", "S"];
  If[results === {}, Return[Nothing]];

  rows = Prepend[
    MapIndexed[
      {
        #2[[1]],
        #1["TargetValue"],
        Column[witnessString /@ Lookup[#1, "Witnesses", {}], Spacings -> 0.35],
        #1["SearchUpperBound"]
      } &,
      results
    ],
    {Style["#", Bold], Style[targetName, Bold], Style["Witness assignment(s)", Bold], Style["Bound used", Bold]}
  ];

  Grid[
    rows,
    Frame -> All,
    Alignment -> {Left, Top},
    Background -> {None, {GrayLevel[0.94], {White, GrayLevel[0.985]}}},
    Spacings -> {1.2, 0.75},
    ItemSize -> {{3, 10, 62, 10}, Automatic},
    BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
  ]
];

SpecialDefinedNumberResultPanel[result_Association] := Column[
  DeleteCases[
    {
      resultStatusPanel[result],
      warningPanel[If[Lookup[result, "Status", "NotRun"] === "InvalidInput", {}, Lookup[result, "Messages", {}]]],
      resultTable[result]
    },
    Nothing
  ],
  Spacings -> 0.9
];

SpecialDefinedNumberResultPanel[_] := SpecialDefinedNumberResultPanel[<|"Status" -> "NotRun"|>];

uiSection[title_, content_] := appCard[title, content];

SpecialDefinedNumberFinderApp[] := DynamicModule[
  {
    preset = SpecialDefinedNumberPreset["Sorensen"],
    searchMode = "TargetValues",
    targetString = "S",
    variableString = "{m, x, y, z}",
    ruleStrings = sorensenRuleStrings,
    desiredCount = 3,
    initialTargetMax = 2000,
    maxTarget = 100000,
    expansionFactor = 2,
    candidateTimeout = 5,
    witnessLimit = 3,
    targetMinimum = 1,
    variableDomain = "PositiveIntegers",
    variableBoundsString = "",
    distinctVariables = False,
    distinctRepresentations = False,
    useModularPruning = True,
    modularBasesString = "{4, 8, 9, 16}",
    targetExampleChoice = First[targetExamplePresetNames],
    assignmentExampleChoice = First[assignmentExamplePresetNames],
    applyPreset,
    isRunning = False,
    lastResult = <|"Status" -> "NotRun", "ResultType" -> "TargetValues", "Messages" -> {}, "Results" -> {}, "TargetName" -> "S"|>
  },

  searchMode = preset["SearchMode"];
  targetString = preset["Target"];
  variableString = preset["Variables"];
  ruleStrings = preset["Rules"];
  desiredCount = preset["DesiredCount"];
  targetMinimum = preset["TargetMinimum"];
  initialTargetMax = preset["InitialTargetMax"];
  maxTarget = preset["MaxTarget"];
  expansionFactor = preset["ExpansionFactor"];
  candidateTimeout = preset["CandidateTimeout"];
  witnessLimit = preset["WitnessLimit"];
  variableDomain = preset["VariableDomain"];
  variableBoundsString = preset["VariableBounds"];
  distinctVariables = preset["DistinctVariables"];
  distinctRepresentations = preset["DistinctRepresentations"];
  useModularPruning = preset["UseModularPruning"];
  modularBasesString = preset["ModularBases"];

  applyPreset[loadedPreset_Association] := (
    preset = loadedPreset;
    searchMode = preset["SearchMode"];
    targetString = preset["Target"];
    variableString = preset["Variables"];
    ruleStrings = preset["Rules"];
    desiredCount = preset["DesiredCount"];
    targetMinimum = preset["TargetMinimum"];
    initialTargetMax = preset["InitialTargetMax"];
    maxTarget = preset["MaxTarget"];
    expansionFactor = preset["ExpansionFactor"];
    candidateTimeout = preset["CandidateTimeout"];
    witnessLimit = preset["WitnessLimit"];
    variableDomain = preset["VariableDomain"];
    variableBoundsString = preset["VariableBounds"];
    distinctVariables = preset["DistinctVariables"];
    distinctRepresentations = preset["DistinctRepresentations"];
    useModularPruning = preset["UseModularPruning"];
    modularBasesString = preset["ModularBases"];
    lastResult = <|
      "Status" -> "NotRun",
      "ResultType" -> If[searchMode === "VariableAssignments", "Assignments", "TargetValues"],
      "Messages" -> {},
      "Results" -> {},
      "TargetName" -> targetString
    |>
  );

  Framed[
    Column[
      {
        appHeader[],
        Grid[
          {
            {
              Column[
                {
                  appCard[
                    "Examples",
                    Column[
                      {
                        uiText["Target-value examples", 12, Bold, appTextColor],
                        uiPresetSelector[Dynamic[targetExampleChoice], targetExamplePresetNames],
                        Dynamic @ uiMuted[examplePresetDescription[targetExampleChoice]],
                        uiButton[
                          "Load target example",
                          applyPreset[SpecialDefinedNumberPreset[targetExampleChoice]],
                          "Secondary",
                          320
                        ],
                        Spacer[4],
                        uiText["Variable-assignment examples", 12, Bold, appTextColor],
                        uiPresetSelector[Dynamic[assignmentExampleChoice], assignmentExamplePresetNames],
                        Dynamic @ uiMuted[examplePresetDescription[assignmentExampleChoice]],
                        uiButton[
                          "Load assignment example",
                          applyPreset[SpecialDefinedNumberPreset[assignmentExampleChoice]],
                          "Secondary",
                          320
                        ]
                      },
                      Spacings -> 0.8
                    ],
                    360
                  ],
                  appCard[
                    "Setup",
                    Column[
                      {
                        fieldBlock["Search mode", uiSearchModeSelector[Dynamic[searchMode]], "Target values finds S-like outputs. Variable assignments finds tuples such as {x, y, a}."],
                        Dynamic @ If[
                          searchMode === "TargetValues",
                          fieldBlock["Target variable", uiInput[Dynamic[targetString], String, 8], "The unique values are counted for this symbol."],
                          uiMuted["Assignment mode returns full variable assignments, so no target variable is needed."]
                        ],
                        fieldBlock["Search variables", uiInput[Dynamic[variableString], String, 28], "Example: {m, x, y, z}"],
                        fieldBlock["Variable domain", uiDomainSelector[Dynamic[variableDomain]], "Applies to listed search variables."],
                        fieldBlock["Variable bounds", uiInput[Dynamic[variableBoundsString], String, 28], "Optional, for example 1 <= m <= 500 && x <= 100."],
                        Row[{Checkbox[Dynamic[distinctVariables]], Spacer[6], uiLabel["Distinct variables"]}],
                        Dynamic @ If[
                          searchMode === "TargetValues",
                          Row[{Checkbox[Dynamic[distinctRepresentations]], Spacer[6], uiLabel["Distinct representations"]}],
                          Nothing
                        ],
                        Dynamic @ If[
                          searchMode === "TargetValues",
                          uiMuted["The target is searched over integer values from the target minimum to maximum."],
                          uiMuted["Use finite variable bounds for Pell-type problems because they can have infinitely many solutions."]
                        ]
                      },
                      Spacings -> 1.0
                    ],
                    360
                  ],
                  appCard[
                    "Search controls",
                    Column[
                      {
                        Dynamic @ Grid[
                          If[
                            searchMode === "TargetValues",
                            {
                              {uiLabel["Values to find"], uiInput[Dynamic[desiredCount], Number, 8]},
                              {uiLabel["Target minimum"], uiInput[Dynamic[targetMinimum], Number, 8]},
                              {uiLabel["Initial target max"], uiInput[Dynamic[initialTargetMax], Number, 8]},
                              {uiLabel["Maximum target"], uiInput[Dynamic[maxTarget], Number, 8]},
                              {uiLabel["Expansion factor"], uiInput[Dynamic[expansionFactor], Number, 8]},
                              {uiLabel["Time limit"], Row[{uiInput[Dynamic[candidateTimeout], Number, 8], Spacer[6], uiMuted["seconds"]}]},
                              {uiLabel["Witnesses per value"], uiInput[Dynamic[witnessLimit], Number, 8]},
                              {uiLabel["Modular pruning"], Row[{Checkbox[Dynamic[useModularPruning]], Spacer[6], uiInput[Dynamic[modularBasesString], String, 14]}]}
                            },
                            {
                              {uiLabel["Assignments to find"], uiInput[Dynamic[desiredCount], Number, 8]},
                              {uiLabel["Time limit"], Row[{uiInput[Dynamic[candidateTimeout], Number, 8], Spacer[6], uiMuted["seconds"]}]},
                              {uiLabel["Modular pruning"], Row[{Checkbox[Dynamic[useModularPruning]], Spacer[6], uiInput[Dynamic[modularBasesString], String, 14]}]}
                            }
                          ],
                          Alignment -> {Left, Center},
                          Spacings -> {1.0, 0.7},
                          BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
                        ],
                        uiButton[
                          Dynamic @ If[searchMode === "VariableAssignments", "Find assignments", "Find numbers"],
                          isRunning = True;
                          CheckAbort[
                            lastResult = Quiet @ Check[
                              SpecialDefinedNumberSearch[
                                <|
                                  "SearchMode" -> searchMode,
                                  "Target" -> targetString,
                                  "Variables" -> variableString,
                                  "Rules" -> ruleStrings,
                                  "DesiredCount" -> desiredCount,
                                  "TargetMinimum" -> targetMinimum,
                                  "InitialTargetMax" -> initialTargetMax,
                                  "MaxTarget" -> maxTarget,
                                  "ExpansionFactor" -> expansionFactor,
                                  "CandidateTimeout" -> candidateTimeout,
                                  "WitnessLimit" -> witnessLimit,
                                  "VariableDomain" -> variableDomain,
                                  "VariableBounds" -> variableBoundsString,
                                  "DistinctVariables" -> distinctVariables,
                                  "DistinctRepresentations" -> distinctRepresentations,
                                  "UseModularPruning" -> useModularPruning,
                                  "ModularBases" -> modularBasesString
                                |>
                              ],
                              <|"Status" -> "Failed", "ResultType" -> If[searchMode === "VariableAssignments", "Assignments", "TargetValues"], "Results" -> {}, "Messages" -> {"The search failed before returning a result."}, "TargetName" -> targetString|>
                            ],
                            isRunning = False;
                            lastResult = <|"Status" -> "Failed", "ResultType" -> If[searchMode === "VariableAssignments", "Assignments", "TargetValues"], "Results" -> {}, "Messages" -> {"The search was aborted."}, "TargetName" -> targetString|>;
                            Abort[]
                          ];
                          isRunning = False,
                          "Primary",
                          320
                        ],
                        Dynamic @ If[
                          TrueQ[isRunning],
                          Row[{ProgressIndicator[Appearance -> "Indeterminate"], Spacer[8], uiMuted["Searching..."]}],
                          uiMuted["Ready"]
                        ]
                      },
                      Spacings -> 1.0
                    ],
                    360
                  ]
                },
                Spacings -> 1.0
              ],
              Column[
                {
                  appCard[
                    "Rule definition",
                    Column[
                      {
                        uiMuted["Write one equation or constraint per row. Use == for equality."],
                        ruleInputRows[ruleStrings],
                        Row[
                          {
                            uiButton["Add constraint", AppendTo[ruleStrings, ""], "Secondary", 135],
                            Spacer[8],
                            uiButton["Remove last", If[Length[ruleStrings] > 1, ruleStrings = Most[ruleStrings]], "Secondary", 125],
                            Spacer[8],
                            uiButton[
                              "Load Sorensen preset",
                              applyPreset[SpecialDefinedNumberPreset["Sorensen"]],
                              "Secondary",
                              170
                            ]
                          }
                        ]
                      },
                      Spacings -> 0.9
                    ],
                    760
                  ],
                  appCard[
                    "Results",
                    Dynamic @ SpecialDefinedNumberResultPanel[lastResult],
                    760
                  ]
                },
                Spacings -> 1.0
              ]
            }
          },
          Alignment -> {Left, Top},
          Spacings -> {1.2, 0.8}
        ]
      },
      Spacings -> 1.0
    ],
    Background -> appBackgroundColor,
    FrameStyle -> appBorderColor,
    RoundingRadius -> 8,
    FrameMargins -> 18,
    ImageSize -> 1180,
    BaseStyle -> {FontFamily -> "Segoe UI", FontColor -> appTextColor}
  ]
];

End[]

EndPackage[]
