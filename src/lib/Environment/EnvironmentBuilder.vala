using LibBiome.Elements;
using LibBiome.Filesystem;

using Gee;

namespace LibBiome.Environment {

    public class EnvironmentBuilder {

        public EnvironmentBuilder(ElementRepository repo) {
            element_repository = repo;
        }

        public ElementRepository element_repository { get; private set; }

        public Environment build(EnvironmentDescription description) throws GLib.Error {
            DependencyResolver resolver = new DependencyResolver(element_repository);
            HashSet<Element> elements = resolver.get_required_elements(description.root_element, description.is_build_environment);

            string[] overlays = new string[elements.size];
            int next_overlay_slot = 0;

            ArrayList<Filesystem.Mount> mounts = new ArrayList<Filesystem.Mount>();

            foreach (var element in elements) {
                var mount = element.mount(0755);
                overlays[next_overlay_slot] = mount.path;
                next_overlay_slot ++;
                if(!mount.is_mounted) {
                    throw new GLib.Error(Quark.from_string("mount_error"), 2, "Failed to mount element");
                }
                mounts.add(mount);
            }

            uint8[] environment_secret = Standard.Paths.new_secret();
            string mount_point = Standard.Paths.get_environment_mount(description.name, environment_secret);

            var overlay = new Filesystem.Mount.overlay(overlays, description.upperdir, description.workdir, mount_point, 0700);
            mounts.add(overlay);

            foreach (var mount_description in description.mounts) {
                mounts.add(Filesystem.Mount.build_from_description(overlay.path, mount_description));
            }

            return new Environment() {
                root_path = mount_point,
                elements = elements,
                secret = environment_secret,
                name = description.name,
                mounts = mounts
            };
            
        }

    }

}