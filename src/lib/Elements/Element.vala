using Gee;

namespace LibBiome.Elements {

    public class Element {

        public ElementIdentifier identifier { get; set; }

        public HashSet<ElementIdentifier> runtime_dependencies { get; default = new HashSet<ElementIdentifier>((m) => m.hash(), (a, b) => a.equals(b));}

        public HashSet<ElementIdentifier> buildtime_dependencies { get; default = new HashSet<ElementIdentifier>((m) => m.hash(), (a, b) => a.equals(b));}

        public HashSet<ElementIdentifier> can_provide { get; default = new HashSet<ElementIdentifier>((m) => m.hash(), (a, b) => a.equals(b));}

        public int64 serial { get; set; }

        public string license { get; set; }

        public string license_url { get; set; }

        public ElementType element_type { get; set; }

        public string simple_name { get; set; }

        public string description { get; set; }

        public BuildInfo build_information { get; set; }

        public HashSet<string> executables { get; default = new HashSet<string>((m) => m.hash(), (a, b) => a == b);}

        public string squashfs_path { get; set; }

        public bool is_mounted { get {
            return Filesystem.Mount.check_mounted(Standard.Paths.element_mount_path(identifier));
        }}

        public Filesystem.Mount mount(Posix.mode_t mode) throws GLib.Error {
            string mount_point = Standard.Paths.element_mount_path(identifier);
            return new Filesystem.Mount.squashfs(squashfs_path, mount_point, mode);
        }

        public Element.from_string(string data, string image_path) throws GLib.Error{
            squashfs_path = image_path;
            var parser = new Json.Parser();

            parser.load_from_data(data);
            var root = parser.get_root().get_object();

            identifier = new ElementIdentifier.from_json(root.get_object_member("identity"));

            var dependencies = root.get_object_member("dependencies");

            foreach (var dependency in dependencies.get_array_member("runtime").get_elements()) {
                runtime_dependencies.add(new ElementIdentifier.from_json(dependency.get_object()));
            }

            foreach (var dependency in dependencies.get_array_member("buildtime").get_elements()) {
                buildtime_dependencies.add(new ElementIdentifier.from_json(dependency.get_object()));
            }

            if(root.has_member("can_provide")) {
                foreach (var element in root.get_array_member("can_provide").get_elements()) {
                    can_provide.add(new ElementIdentifier.from_json(element.get_object()));
                }
            }

            license = root.get_string_member("license");
            license_url = root.get_string_member_with_default("license_url", "");
            element_type = ElementType.from_string(root.get_string_member("type"));
            simple_name = root.get_string_member("name");
            description = root.get_string_member_with_default("description", "");
            serial = root.get_int_member_with_default("serial", 0);
            
            build_information = new BuildInfo.from_json(root.get_object_member("build"));

            if(root.has_member("executables")) {
                foreach (var executable in root.get_array_member("executables").get_elements()) {
                    executables.add(executable.get_string());
                }
            }

            // Applications must contain executables
            if(executables.size == 0 && (element_type == ElementType.CLI_APPLICATION || element_type == ElementType.GUI_APPLICATION)) {
                assert_not_reached();
            }
        }
        
    }

}