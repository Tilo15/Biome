
dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('json-glib-1.0'),
    meson.get_compiler('vala').find_library('posix'),
]

sources = files('Biome.vala')
sources += files('FakeRoot.vala')
sources += files('Standard/Paths.vala')
sources += files('Elements/ElementIdentifier.vala')
sources += files('Elements/Element.vala')
sources += files('Elements/ElementRepository.vala')
sources += files('Elements/FilesystemRepository.vala')

libbiome = library('biome', sources, dependencies: dependencies)
libbiome_dep = declare_dependency(link_with: libbiome, include_directories: include_directories('.'))
