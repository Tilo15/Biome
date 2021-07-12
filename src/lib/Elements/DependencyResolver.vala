using Gee;

namespace LibBiome.Elements {

    public class DependencyResolver {
        
        private ElementRepository repository { get; set; }

        public DependencyResolver(ElementRepository repo) {
            repository = repo;
        }

        public HashSet<Element> get_required_elements(ElementIdentifier root, bool include_buildtime_dependencies = false) throws GLib.Error {
            HashSet<Element> elements = new HashSet<Element>((m) => m.identifier.hash(), (a, b) => a.identifier.equals(b.identifier));

            if(!repository.has_element(root)) {
                throw new GLib.Error(Quark.from_string("element_not_found"), 5, "Element not found");
            }

            Element element = repository.get_element(root);
            elements.add(element);

            foreach (var dep in element.runtime_dependencies) {
                elements.add_all(get_required_elements(dep, include_buildtime_dependencies));
            }

            if (include_buildtime_dependencies) {
                foreach (var dep in element.buildtime_dependencies) {
                    elements.add_all(get_required_elements(dep, include_buildtime_dependencies));
                }
            }

            return elements;
        }
    }

}