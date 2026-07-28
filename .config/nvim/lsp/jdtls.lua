-- Eclipse JDT language server. Pinned to the same JDK the shell exports
-- (openjdk@25, the team standard) so nvim and the build agree on a version.
return {
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_markers = {
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    ".git",
  },
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-25",
            path = vim.env.JAVA_HOME,
            default = true,
          },
        },
      },
      format = { enabled = true },
      signatureHelp = { enabled = true },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
    },
  },
}
