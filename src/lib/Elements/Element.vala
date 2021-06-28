namespace LibBiome.Elements {

    public class Element {

        public ElementIdentifier identifier { get; set; }

        public List<ElementIdentifier?> dependencies;

        public string path { get; set; }

        public string overlay_image_path { owned get {
            return this.path + ".squashfs";
        }}

        public string mount_point_path { owned get {
            return this.path + ".mount";
        }}

        public bool is_mounted { get {
            return Posix.access(mount_point_path, Posix.F_OK) == 0;
        }}

        public bool mount() throws GLib.Error {
            if (is_mounted) {
                return true;
            }

            Posix.mkdir(mount_point_path, 0700);

            string[] args = {
                "mount",
                "-t",
                "squashfs",
                overlay_image_path,
                mount_point_path
            };

            var subprocess = new Subprocess.newv(args, SubprocessFlags.NONE);
            return subprocess.wait_check();
        }

        public Element.from_string(string data, string file_path) throws GLib.Error{
            path = file_path;

            var parser = new Json.Parser();

            parser.load_from_data(data);
            var root = parser.get_root().get_object();

            identifier = parse_element_identifier(root.get_object_member("identity"));
            
            dependencies = new List<ElementIdentifier?>();

            foreach (var dependency in root.get_array_member("dependencies").get_elements()) {
                dependencies.append(parse_element_identifier(dependency.get_object()));
            }

        }

        private static ElementIdentifier parse_element_identifier(Json.Object? obj) {
            return ElementIdentifier() {
                fully_qualified_name = obj.get_string_member("fqn"),
                version = obj.get_string_member("version")
            };
        }
        
    }

}