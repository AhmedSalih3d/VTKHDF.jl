using Documenter, Example

#Test
makedocs(sitename="VTKHDF.jl")

# if get(ENV, "CI", "") != "" && (get(ENV, "GITHUB_REF", "") == "refs/heads/main" || startswith(get(ENV, "GITHUB_REF", ""), "refs/tags/"))
    deploydocs(repo = "github.com/AhmedSalih3d/VTKHDF.jl.git")
# end