# See the history of this file here
# https://gitlab.invenia.ca/invenia/eis/blob/9cbf147eeec2c75d425ca867ae8e02067af1216e/docker/build/checkout.jl

# Allows users to select specific branches of a package
using LibGit2
using Pkg

# Full path is necessary because the base `PackageSpec` is now an alias to a function :/
specs = Pkg.Types.PackageSpec[]

# Note: `pkg` could either be a package name or a URL
for spec in ARGS
    pkg, branch = String.(split(spec, r"\s*@\s*"))

    if occursin("://", pkg)
        push!(specs, PackageSpec(; url=pkg, rev=branch))
    else
        push!(specs, PackageSpec(; name=pkg, rev=branch))
    end
end

if !isempty(specs)
    Pkg.add(specs)
end
