using Pkg

home_path = ENV["HOME"]
eis_env = "$home_path/.julia/environments/eis"

Pkg.activate(eis_env)

using Cbc_jll
using Cgl_jll
using Clp_jll
using Preferences

local_pref_path = "$eis_env/LocalPreferences.toml"
coinbrew_path = "$home_path/coinbrew"
dist_path = "$coinbrew_path/dist"
bin_path = "$dist_path/bin"
lib_path = "$dist_path/lib"

set_preferences!(
    local_pref_path,
    "Clp_jll",
    "clp_path" => "$bin_path/clp",
    "libClp_path" => "$lib_path/libClp.so",
    "libOsiClp_path" => "$lib_path/libOsiClp.so",
    "libClpSolver_path" => "$lib_path/libClp.so"
)

set_preferences!(
    local_pref_path,
    "Cgl_jll",
    "libCgl_path" => "$lib_path/libCgl.so"
)

set_preferences!(
    local_pref_path,
    "Cbc_jll",
    "cbc_path" => "$bin_path/cbc",
    "libCbc_path" => "$lib_path/libCbc.so",
    "libOsiCbc_path" => "$lib_path/libOsiCbc.so",
    "libcbcsolver_path" => "$lib_path/libCbc.so"
)
