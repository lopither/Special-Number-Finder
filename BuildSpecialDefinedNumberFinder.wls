projectDir = DirectoryName[$InputFileName];
targetNotebook = FileNameJoin[{projectDir, "RUN_SpecialDefinedNumberFinder.nb"}];

notebook = Notebook[
  {
    Cell["Special Defined Number Finder", "Title"],
    Cell[
      "Evaluate the input cell below with Shift+Enter to load the local package and show the app.",
      "Text"
    ],
    Cell[
      BoxData[
        RowBox[
          {
            RowBox[
              {
                "Get", "[",
                RowBox[
                  {
                    "FileNameJoin", "[",
                    RowBox[
                      {
                        "{",
                        RowBox[
                          {
                            RowBox[{"NotebookDirectory", "[", "]"}],
                            ",",
                            "\"SpecialDefinedNumberFinder.wl\""
                          }
                        ],
                        "}"
                      }
                    ],
                    "]"
                  }
                ],
                "]"
              }
            ],
            ";",
            "\n",
            RowBox[{"SpecialDefinedNumberFinder`SpecialDefinedNumberFinderApp", "[", "]"}]
          }
        ]
      ],
      "Input",
      InitializationCell -> True
    ]
  },
  WindowSize -> {1320, 920},
  WindowMargins -> {{Automatic, 40}, {Automatic, 20}},
  WindowTitle -> "Special Defined Number Finder",
  Background -> RGBColor[0.95, 0.97, 0.99],
  StyleDefinitions -> "Default.nb"
];

Export[targetNotebook, notebook, "NB"];
Print["Wrote " <> targetNotebook];
