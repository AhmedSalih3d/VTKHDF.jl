using Documenter
using DocumenterCodeBlocks
using VTKHDF

makedocs(
  sitename = "VTKHDF.jl",
  modules = [VTKHDF],
  plugins = [CodeBlocks()],
  checkdocs = :exports,
  format = Documenter.HTML(
    canonical = "https://AhmedSalih3d.github.io/VTKHDF.jl/stable/",
    edit_link = "main",
    prettyurls = get(ENV, "CI", "false") == "true",
  ),
  pages = ["Home" => "index.md"],
)

if get(ENV, "CI", "") != "" && (
  get(ENV, "GITHUB_REF", "") == "refs/heads/main" ||
  startswith(get(ENV, "GITHUB_REF", ""), "refs/tags/")
)
  deploydocs(repo = "github.com/AhmedSalih3d/VTKHDF.jl.git", devbranch = "main")
end
