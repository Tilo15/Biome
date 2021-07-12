

namespace LibBiome.Elements {

    public class BuildInfo {
    
        public string source_url { get; set; }

        public string source_filename { get; set; }

        public string source_sha512 { get; set; }

        public string build_shell_path { get; set; }

        public List<string> configure_commands = new List<string>();

        public List<string> build_commands = new List<string>();

        public List<string> install_commands = new List<string>();

        public List<string> exclude_paths = new List<string>();

        public List<PatchInfo> patches = new List<PatchInfo>();

        public BuildInfo.from_json (Json.Object? obj) {
            source_url = obj.get_string_member("source_url");
            source_filename = obj.get_string_member("source_filename");
            source_sha512 = obj.get_string_member("source_sha512");

            build_shell_path = obj.get_string_member("build_shell");
            
            foreach (var configure_command in obj.get_array_member("configure_commands").get_elements()) {
                configure_commands.append(configure_command.get_string());
            }

            foreach (var build_command in obj.get_array_member("build_commands").get_elements()) {
                build_commands.append(build_command.get_string());
            }

            foreach (var install_command in obj.get_array_member("install_commands").get_elements()) {
                install_commands.append(install_command.get_string());
            }

            if(obj.has_member ("patches")) {
                foreach (var patch in obj.get_array_member("patches").get_elements()) {
                    patches.append(new PatchInfo.from_json(patch.get_object()));
                }
            }

            if(obj.has_member ("excludes")) {
                foreach (var path in obj.get_array_member("excludes").get_elements()) {
                    exclude_paths.append(path.get_string());
                }
            }
        }


    }

}