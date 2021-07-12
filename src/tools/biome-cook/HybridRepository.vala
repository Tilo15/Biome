using LibBiome.Elements;
using Gee;

namespace Biome.Cook {

    public class HybridElementRepository : FilesystemRepository {

        private HashMap<ElementIdentifier, Element> in_memory_elements = new HashMap<ElementIdentifier, Element>(a => a.hash(), (a, b) => a.equals(b));

        public HybridElementRepository(string path) {
            base(path);
        }

        public override bool has_element (ElementIdentifier identifier) {
            if (in_memory_elements.has_key(identifier)) {
                return true;
            }
            return base.has_element(identifier);
        }

        public override Element get_element(ElementIdentifier identifier) throws GLib.Error {
            if (in_memory_elements.has_key(identifier)) {
                return in_memory_elements.get(identifier);
            }
            return base.get_element(identifier);
        }

        public void add_element(Element element) {
            in_memory_elements.set(element.identifier, element);
        }

    }

}