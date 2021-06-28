using LibBiome.Elements;

namespace Biome.Shittest {

    void main(string[] argv) {
        var biome = new LibBiome.Biome();
        biome.name = "test";
        
        var repo = new FilesystemRepository("/biome/repo");

        foreach (var arg in argv[1:argv.length]) {
            var data = arg.split(":", 2);
            ElementIdentifier id = ElementIdentifier() {
                fully_qualified_name = data[0],
                version = data[1]
            };
            print(@"Loading element $(id.fully_qualified_name) version $(id.version)\n");
            biome.elements.append(repo.GetElement(id));
        }

        print("Starting build...\n");
        biome.build("/stupidmountpoint");
    }

}