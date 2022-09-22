"""
    registry_packages(config::Configuration)::Vector{Package}

Read all packages from a registry and return them as a vector of Package structs.
"""
function registry_packages(config::Configuration)
    packages = Package[]

    registry = get_registry(config)
    registry_instance = Pkg.Registry.RegistryInstance(registry)
    for (_, pkg) in registry_instance
        # TODO: read package compat info so that we can avoid testing uninstallable packages
        push!(packages, Package(name=pkg.name, uuid=pkg.uuid))
    end
    return packages
end

get_registry_repo(spec) = get_github_repo(spec, "JuliaRegistries/general")

const registry_lock = ReentrantLock()
const registry_cache = Dict()
function get_registry(config::Configuration)
    lock(registry_lock) do
        dir = get(registry_cache, config.registry, nothing)
        if dir === nothing || !isdir(dir)
            registry_cache[config.registry] = get_registry_repo(config.registry)
        end
        return registry_cache[config.registry]
    end
end
