# Skip cleaning if using a system Python installation
if get(ENV, "PYTHON", nothing) == ""
    using Pkg
    installed_packages = collect(keys(Pkg.installed()))

    # Cleanup any installed conda packages (e.g., packages using `pyimport_conda` in an `__init__`)
    if "Conda" in installed_packages
        using Conda: _set_conda_env, conda

        # Similar to 'Conda.runconda(`clean -y --all`)' but skips installing Conda packages
        # if none are currently installed.
        isfile(conda) && run(_set_conda_env(`$conda clean -y --all`))
    end
end
