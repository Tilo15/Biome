namespace LibBiome.Elements {

    public interface ElementRepository : Object {

        public abstract bool has_element(ElementIdentifier identifier);

        public abstract Element get_element(ElementIdentifier identifier) throws GLib.Error;

    }

}