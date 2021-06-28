namespace LibBiome.Elements {

    public class FilesystemRepository : ElementRepository {

        public FilesystemRepository(string path) {
            this.path = path;
        }

        public string path { get; set; }

        public bool HasElement (ElementIdentifier identifier) {
            return Posix.access(get_element_path(identifier), Posix.F_OK) == 0;
        }

        public Element GetElement(ElementIdentifier identifier) throws GLib.Error {
            string path = get_element_path(identifier);
            string data;
            FileUtils.get_contents(path, out data);
            
            return new Element.from_string(data, path);
        }

        private string get_element_path(ElementIdentifier identifier) {
            return @"$(path)/$(identifier.fully_qualified_name)_$(identifier.version).element";
        }

    }

}