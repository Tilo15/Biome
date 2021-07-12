namespace LibBiome.Elements {

    public class FilesystemRepository : Object, ElementRepository {

        public FilesystemRepository(string path) {
            this.path = path;
        }

        public string path { get; set; }

        public virtual bool has_element (ElementIdentifier identifier) {
            return Posix.access(Standard.Paths.element_information_path(identifier), Posix.F_OK) == 0;
        }

        public virtual Element get_element(ElementIdentifier identifier) throws GLib.Error {
            string path = Standard.Paths.element_information_path(identifier);
            string data;
            FileUtils.get_contents(path, out data);

            string image_path = Standard.Paths.element_squashfs_path(identifier);            
            return new Element.from_string(data, image_path);
        }

    }

}