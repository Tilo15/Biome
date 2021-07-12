dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gee-0.8'),
    dependency('json-glib-1.0'),
    meson.get_compiler('vala').find_library('posix'),
    libbiome_dep
]

sources = files('Cook.vala')
sources += files('HybridRepository.vala')

executable('biome-cook', sources, dependencies: dependencies)
