# PackageCompiler v1 and v2 are currently supported by this script
using PackageCompiler: create_sysimage
using Pkg

MARCH = ARGS[1]
PRECOMPILE_FILE = ARGS[2]

if filesize(PRECOMPILE_FILE) > 0 && !startswith(readline(PRECOMPILE_FILE), "precompile")
    error("Invalid precompile statement found in $PRECOMPILE_FILE")
end

# Add all installed packages into the system image
deps = collect(values(Pkg.dependencies()))
direct_deps = filter(p -> p.is_direct_dep, deps)

package_compiler = first(filter(d -> d.name == "PackageCompiler", direct_deps))

# PackageCompiler v2 requires a sysimage_path and no longer requires an explicit list of
# dependencies to install
# https://julialang.github.io/PackageCompiler.jl/stable/#Upgrading-from-PackageCompiler-1.0.
if package_compiler.version >= v"2"
    create_sysimage(
        sysimage_path="/root/eis-sysimg.so",
        precompile_statements_file=PRECOMPILE_FILE,
        cpu_target=MARCH,
    )
else
    create_sysimage(
        map(d -> d.name, direct_deps);
        replace_default=true,
        precompile_statements_file=PRECOMPILE_FILE,
        cpu_target=MARCH,
    )
end
