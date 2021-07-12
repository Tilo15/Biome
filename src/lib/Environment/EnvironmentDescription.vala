using LibBiome.Elements;
using LibBiome.Filesystem;

using Gee;

namespace LibBiome.Environment {

    public class EnvironmentDescription {

        public string name { get; set; }

        public Gee.List<MountDescription> mounts { get; set; }

        public ElementIdentifier root_element { get; set; }

        public string upperdir { get; set; }

        public string workdir { get; set; }

        public bool is_build_environment { get; set; }

    }

}