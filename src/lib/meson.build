
dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gee-0.8'),
    dependency('json-glib-1.0'),
    meson.get_compiler('vala').find_library('posix'),
]

sources = files('Environment/Environment.vala')
sources += files('Environment/EnvironmentDescription.vala')
sources += files('Environment/EnvironmentBuilder.vala')
sources += files('Standard/Paths.vala')
sources += files('Elements/ElementIdentifier.vala')
sources += files('Elements/Element.vala')
sources += files('Elements/ElementRepository.vala')
sources += files('Elements/FilesystemRepository.vala')
sources += files('Elements/Types.vala')
sources += files('Elements/BuildInfo.vala')
sources += files('Elements/PatchInfo.vala')
sources += files('Elements/DependencyResolver.vala')
sources += files('Filesystem/Mount.vala')
sources += files('Filesystem/MountDescription.vala')

pkg = import('pkgconfig')
libbiome = library('biome-0.1', sources, dependencies: dependencies, install: true, install_dir: ['/usr/lib64', true, '/usr/share/vala/vapi'])
libbiome_dep = declare_dependency(link_with: libbiome, include_directories: include_directories('.'))
pkg.generate(libbiome, install_dir: '/usr/lib64/pkgconfig')