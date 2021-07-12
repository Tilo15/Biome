using LibBiome.Elements;
using LibBiome.Filesystem;

using Gee;

namespace LibBiome.Environment {

    public class Environment {

        public Collection<Element> elements { get; set; }

        public Collection<Filesystem.Mount> mounts { get; set; }

        public string root_path { get; set; }

        public uint8[] secret { get; set; }
        
        public string name { get; set; }

        public void clean() {
            var mount_array = mounts.to_array();
            for(var i = mount_array.length; i > 0; i--) {
                mount_array[i-1].unmount();
            }
        }

    }

}