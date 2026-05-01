projectDir = DirectoryName[$InputFileName];
Get[FileNameJoin[{projectDir, "SpecialDefinedNumberFinder.wl"}]];

preset = Join[
  SpecialDefinedNumberFinder`SpecialDefinedNumberPreset["Sorensen"],
  <|"CandidateTimeout" -> 30, "WitnessLimit" -> 3|>
];

sorensen = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[preset];
sorensenValues = Lookup[Lookup[sorensen, "Results", {}], "TargetValue", {}];

resultFor[value_] := SelectFirst[
  Lookup[sorensen, "Results", {}],
  Lookup[#, "TargetValue", Missing["NoValue"]] === value &,
  <|"Witnesses" -> {}|>
];

witnessFor[value_, witness_] := MemberQ[Lookup[resultFor[value], "Witnesses", {}], witness];

custom = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a, b}",
    "Rules" -> {"S == a^2 + b^2"},
    "DesiredCount" -> 3,
    "InitialTargetMax" -> 20,
    "MaxTarget" -> 20,
    "CandidateTimeout" -> 10,
    "WitnessLimit" -> 2
  |>
];
customValues = Lookup[Lookup[custom, "Results", {}], "TargetValue", {}];

invalidAssignment = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|"Target" -> "S", "Variables" -> "{m}", "Rules" -> {"S = m^2"}|>
];

unknownVariable = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|"Target" -> "S", "Variables" -> "{m}", "Rules" -> {"S == q^2"}|>
];

nonnegativeDomain = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a}",
    "Rules" -> {"S == a^2"},
    "VariableDomain" -> "NonNegativeIntegers",
    "TargetMinimum" -> 0,
    "DesiredCount" -> 3,
    "InitialTargetMax" -> 10,
    "MaxTarget" -> 10,
    "CandidateTimeout" -> 3
  |>
];
nonnegativeValues = Lookup[Lookup[nonnegativeDomain, "Results", {}], "TargetValue", {}];

allIntegerDomain = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a}",
    "Rules" -> {"S == a"},
    "VariableDomain" -> "Integers",
    "TargetMinimum" -> -2,
    "DesiredCount" -> 5,
    "InitialTargetMax" -> 2,
    "MaxTarget" -> 2,
    "CandidateTimeout" -> 3
  |>
];
allIntegerValues = Lookup[Lookup[allIntegerDomain, "Results", {}], "TargetValue", {}];

boundedVariables = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a}",
    "Rules" -> {"S == a^2"},
    "VariableBounds" -> "3 <= a <= 4",
    "DesiredCount" -> 2,
    "InitialTargetMax" -> 20,
    "MaxTarget" -> 20,
    "CandidateTimeout" -> 3
  |>
];
boundedValues = Lookup[Lookup[boundedVariables, "Results", {}], "TargetValue", {}];

distinctVariables = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a, b}",
    "Rules" -> {"S == a + b"},
    "DistinctVariables" -> True,
    "DesiredCount" -> 3,
    "InitialTargetMax" -> 8,
    "MaxTarget" -> 8,
    "CandidateTimeout" -> 3
  |>
];
distinctVariableValues = Lookup[Lookup[distinctVariables, "Results", {}], "TargetValue", {}];

distinctRepresentations = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a, b, c, d}",
    "Rules" -> {"S == a + b", "S == c + d"},
    "DistinctRepresentations" -> True,
    "DesiredCount" -> 3,
    "InitialTargetMax" -> 8,
    "MaxTarget" -> 8,
    "CandidateTimeout" -> 3
  |>
];
distinctRepresentationValues = Lookup[Lookup[distinctRepresentations, "Results", {}], "TargetValue", {}];

modularPruning = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "Target" -> "S",
    "Variables" -> "{a, b}",
    "Rules" -> {"S == a^2 + b^2"},
    "UseModularPruning" -> True,
    "ModularBases" -> "{4, 8, 9}",
    "DesiredCount" -> 3,
    "InitialTargetMax" -> 20,
    "MaxTarget" -> 20,
    "CandidateTimeout" -> 3
  |>
];
modularValues = Lookup[Lookup[modularPruning, "Results", {}], "TargetValue", {}];

verifiedAssignmentResultsQ[results_List] := results =!= {} && And @@ (
  Function[result, And @@ (TrueQ[Lookup[#, "Valid", False]] & /@ Lookup[result, "VerifiedRules", {}])] /@ results
);

assignmentHas[assignments_List, expected_List] := MemberQ[
  assignments,
  rules_ /; And @@ (MemberQ[rules, #] & /@ expected)
];

pellTriples = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "SearchMode" -> "VariableAssignments",
    "Variables" -> "{x, y, a}",
    "Rules" -> {"x^2 - a y^2 == 1"},
    "VariableBounds" -> "2 <= a <= 20 && 1 <= x <= 100 && 1 <= y <= 100",
    "DesiredCount" -> 5,
    "CandidateTimeout" -> 10,
    "UseModularPruning" -> True,
    "ModularBases" -> "{4, 8, 9, 16}"
  |>
];
pellTripleResults = Lookup[pellTriples, "Results", {}];

fixedPell = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "SearchMode" -> "VariableAssignments",
    "Variables" -> "{x, y}",
    "Rules" -> {"x^2 - 2 y^2 == 1"},
    "VariableBounds" -> "1 <= x <= 3 && 1 <= y <= 2",
    "DesiredCount" -> 1,
    "CandidateTimeout" -> 10,
    "UseModularPruning" -> True,
    "ModularBases" -> "{4, 8, 9, 16}"
  |>
];
fixedPellAssignments = Lookup[Lookup[fixedPell, "Results", {}], "Assignment", {}];

tightPellNoResults = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "SearchMode" -> "VariableAssignments",
    "Variables" -> "{x, y}",
    "Rules" -> {"x^2 - 2 y^2 == 1"},
    "VariableBounds" -> "1 <= x <= 2 && 1 <= y <= 2",
    "DesiredCount" -> 1,
    "CandidateTimeout" -> 5
  |>
];

invalidAssignmentMode = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[
  <|
    "SearchMode" -> "VariableAssignments",
    "Variables" -> "{x, y}",
    "Rules" -> {"x = y + 1"},
    "DesiredCount" -> 1
  |>
];

exampleExpected = <|
  "Consecutive square sums" -> {5, 13, 25},
  "Square triangular numbers" -> {1, 36, 1225},
  "Pythagorean square targets" -> {25, 100, 169, 225},
  "Square and cube sums" -> {2, 65, 72, 128},
  "Sum and difference of squares" -> {5, 8, 13, 17},
  "Square-cube target values" -> {1, 64, 729},
  "Triangular target values" -> {1, 3, 6, 10, 15},
  "Odd consecutive-square gaps" -> {3, 5, 7, 9},
  "Square plus one targets" -> {2, 5, 10, 17},
  "Three-square sums" -> {3, 6, 9, 11}
|>;

exampleResults = Association @ KeyValueMap[
  Function[{name, expected},
    name -> Module[
      {r = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[SpecialDefinedNumberFinder`SpecialDefinedNumberPreset[name]]},
      <|
        "Status" -> Lookup[r, "Status", "Missing"],
        "Values" -> Lookup[Lookup[r, "Results", {}], "TargetValue", {}],
        "Expected" -> expected
      |>
    ]
  ],
  exampleExpected
];

exampleTests = Association @ KeyValueMap[
  Function[{name, result},
    name -> (result["Status"] === "Success" && result["Values"] === result["Expected"])
  ],
  exampleResults
];

assignmentExampleNames = {
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

assignmentExampleResults = Association @ Table[
  name -> Module[
    {r = SpecialDefinedNumberFinder`SpecialDefinedNumberSearch[SpecialDefinedNumberFinder`SpecialDefinedNumberPreset[name]]},
    <|
      "Status" -> Lookup[r, "Status", "Missing"],
      "Results" -> Lookup[r, "Results", {})
    |>
  ],
  {name, assignmentExampleNames}
];

assignmentExampleTests = Association @ KeyValueMap[
  Function[{name, result},
    name -> (result["Status"] === "Success" && verifiedAssignmentResultsQ[result["Results"]])
  ],
  assignmentExampleResults
];

tests = <|
  "SorensenStatus" -> Lookup[sorensen, "Status", "Missing"] === "Success",
  "SorensenValues" -> Take[sorensenValues, UpTo[3]] === {1105, 12025, 66625},
  "SorensenWitness1105" -> witnessFor[1105, {m -> 31, x -> 12, y -> 9, z -> 4}],
  "SorensenWitness12025" -> witnessFor[12025, {m -> 107, x -> 24, y -> 19, z -> 12}],
  "SorensenWitness66625" -> witnessFor[66625, {m -> 255, x -> 40, y -> 33, z -> 24}],
  "CustomSumOfSquares" -> Take[customValues, UpTo[3]] === {2, 5, 8},
  "InvalidAssignment" -> Lookup[invalidAssignment, "Status", "Missing"] === "InvalidInput",
  "UnknownVariable" -> Lookup[unknownVariable, "Status", "Missing"] === "InvalidInput",
  "NonnegativeDomain" -> nonnegativeValues === {0, 1, 4},
  "AllIntegerDomain" -> allIntegerValues === {-2, -1, 0, 1, 2},
  "BoundedVariables" -> boundedValues === {9, 16},
  "DistinctVariables" -> distinctVariableValues === {3, 4, 5},
  "DistinctRepresentations" -> distinctRepresentationValues === {3, 4, 5},
  "ModularPruning" -> modularValues === {2, 5, 8},
  "PellTriplesAssignmentMode" -> Lookup[pellTriples, "Status", "Missing"] === "Success" && verifiedAssignmentResultsQ[pellTripleResults],
  "FixedPellAssignmentMode" -> Lookup[fixedPell, "Status", "Missing"] === "Success" && assignmentHas[fixedPellAssignments, {x -> 3, y -> 2}],
  "AssignmentNoResults" -> Lookup[tightPellNoResults, "Status", "Missing"] === "NoResults",
  "InvalidAssignmentMode" -> Lookup[invalidAssignmentMode, "Status", "Missing"] === "InvalidInput",
  "TargetExampleScenarios" -> And @@ Values[exampleTests],
  "AssignmentExampleScenarios" -> And @@ Values[assignmentExampleTests]
|>;

report = <|
  "Tests" -> tests,
  "SorensenStatusActual" -> Lookup[sorensen, "Status", "Missing"],
  "SorensenValuesActual" -> sorensenValues,
  "SorensenMessages" -> Lookup[sorensen, "Messages", {}],
  "CustomStatusActual" -> Lookup[custom, "Status", "Missing"],
  "CustomValuesActual" -> customValues,
  "DomainControlValues" -> <|
    "Nonnegative" -> nonnegativeValues,
    "AllIntegers" -> allIntegerValues,
    "BoundedVariables" -> boundedValues,
    "DistinctVariables" -> distinctVariableValues,
    "DistinctRepresentations" -> distinctRepresentationValues,
    "ModularPruning" -> modularValues
  |>,
  "AssignmentMode" -> <|
    "PellTriplesStatus" -> Lookup[pellTriples, "Status", "Missing"],
    "PellTriplesResults" -> pellTripleResults,
    "FixedPellStatus" -> Lookup[fixedPell, "Status", "Missing"],
    "FixedPellAssignments" -> fixedPellAssignments,
    "NoResultsStatus" -> Lookup[tightPellNoResults, "Status", "Missing"],
    "InvalidAssignmentStatus" -> Lookup[invalidAssignmentMode, "Status", "Missing"]
  |>,
  "ExampleTests" -> exampleTests,
  "ExampleResults" -> exampleResults,
  "AssignmentExampleTests" -> assignmentExampleTests,
  "AssignmentExampleResults" -> assignmentExampleResults
|>;

Export[FileNameJoin[{$TemporaryDirectory, "SpecialDefinedNumberFinderTest.json"}], report, "JSON"];

If[And @@ Values[tests],
  Exit[0],
  Exit[1]
];
