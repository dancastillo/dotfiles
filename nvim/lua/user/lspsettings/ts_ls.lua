return {
  settings = {
    typescript = {
      diagnostics = {
        ignoredCodes = { 2593 },
      },
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithInsertText = true,
        includeCompletionsWithSnippetText = true,
      },
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
      },
      -- Better perf & correctness in monorepos
      tsserver = {
        maxTsServerMemory = 8192,
        disableAutomaticTypeAcquisition = true,
        disableAutomaticTypingAcquisition = true,
        disableSolutionSearching = true,
      },
      format = { enable = false }, -- prefer prettier/eslint
    },
    javascript = {
      diagnostics = {
        ignoredCodes = { 2593 },
      },
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithInsertText = true,
        includeCompletionsWithSnippetText = true,
      },
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
      },
    },
  },
}
