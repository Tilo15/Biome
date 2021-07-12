using LibBiome.Environment;
using LibBiome.Filesystem;
using LibBiome.Elements;

namespace Biome.Shittest {

    void main(string[] argv) {

        //  var element_id = argv[1].split(":");

        print(LibBiome.Standard.Paths.serailise_secret(LibBiome.Standard.Paths.new_secret()));
        print("\n");
        
        //  var description = new EnvironmentDescription() {
        //      name = "test-environment",
        //      base_filesystem = LibBiome.Standard.get_generic_structure(),
        //      root_element = new ElementIdentifier() {
        //          fully_qualified_name = element_id[0],
        //          version = element_id[1]
        //      }
        //  };

        //  var repo = new FilesystemRepository(LibBiome.Standard.Paths.REPOSITORY);
        //  var builder = new EnvironmentBuilder(repo);
        //  builder.build(description);

    }

}