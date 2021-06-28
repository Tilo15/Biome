namespace LibBiome.Elements {

    public interface ElementRepository {

        public abstract bool HasElement(ElementIdentifier identifier);

        public abstract Element GetElement(ElementIdentifier identifier) throws GLib.Error;

    }

}