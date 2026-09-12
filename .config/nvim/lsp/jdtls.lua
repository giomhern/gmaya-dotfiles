-- Eclipse JDT language server. JAVA_HOME is discovered from Homebrew by the
-- shared shell config when an OpenJDK installation is available.

-- Lombok generates members during annotation processing, so "log" from @Slf4j,
-- the accessors from @Getter / @Data and the constructors from
-- @RequiredArgsConstructor do not exist in the source jdtls reads. Attaching
-- lombok as a javaagent lets it patch the compiler jdtls uses internally, the
-- same way IntelliJ's bundled Lombok support does. Without it every one of
-- those members reports as unresolved while Maven builds the project happily.
--
-- The jar is deliberately outside this repo (2MB of binary). Install with:
--   mkdir -p ~/.local/share/lombok
--   cp ~/.m2/repository/org/projectlombok/lombok/<ver>/lombok-<ver>.jar \
--      ~/.local/share/lombok/lombok.jar
local cmd = { "jdtls" }

local lombok = vim.fs.joinpath(vim.env.HOME, ".local/share/lombok/lombok.jar")
if vim.uv.fs_stat(lombok) then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
end

return {
  cmd = cmd,
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
      format = { enabled = true },
      signatureHelp = { enabled = true },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
    },
  },
}
