
namespace LibBiome.Elements {

    public class PatchInfo {

        public string url { get; set; }

        public string filename { get; set; }

        public string sha512 { get; set; }

        public string name { get; set; }

        public string description { get; set; }

        public List<string> patch_commands = new List<string>();

        public PatchInfo.from_json (Json.Object? obj) {
            url = obj.get_string_member_with_default("url", "");
            filename = obj.get_string_member_with_default("filename", "");
            sha512 = obj.get_string_member_with_default("sha512", "");
            name = obj.get_string_member("name");
            description = obj.get_string_member_with_default("description", "");

            foreach (var patch_command in obj.get_array_member("patch_commands").get_elements()) {
                patch_commands.append(patch_command.get_string());
            }
        }

    }

}