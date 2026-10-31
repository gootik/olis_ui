%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "lib/",
          "test/",
          "preview/",
          "config/",
          "mix.exs",
          "examples/admin/lib/",
          "examples/admin/test/",
          "examples/admin/config/",
          "examples/admin/mix.exs"
        ],
        excluded: ["_build/", "deps/"]
      },
      checks: %{
        extra: [
          # HEEx templates currently make several component functions exceed
          # Credo's default complexity limit. Keep the existing maximum as a
          # baseline while the components are split into smaller modules.
          {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 46}
        ]
      }
    }
  ]
}
