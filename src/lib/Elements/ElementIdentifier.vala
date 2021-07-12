namespace LibBiome.Elements {

    public class ElementIdentifier {

        public string fully_qualified_name;

        public string version;

        private string unique_string() {
            return @"$(fully_qualified_name):$(version)";
        }

        public uint hash() {
            return unique_string().hash();
        }

        public bool equals(ElementIdentifier other) {
            return unique_string() == other.unique_string();
        }

        public ElementIdentifier.from_json (Json.Object? obj) {
            fully_qualified_name = obj.get_string_member("fqn");
            version = obj.get_string_member("version");
        }

    }

}