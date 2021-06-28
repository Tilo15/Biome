using LibBiome.Elements;

namespace LibBiome {

    public class Biome {
        
        public string name { get; set; }

        public List<Element> elements = new List<Element>();

        public void build(string mount_point) throws GLib.Error {
            List<string> overlays = new List<string>();

            // Mount all required elements
            foreach (Element element in elements) {
                element.mount();
                overlays.append(element.mount_point_path);
            }

            FakeRoot.create_fake_root("/fakeroot");
            overlays.append("/fakeroot");
            
            Posix.mkdir(mount_point, 0700);

            string lowerdir = "";
            foreach (var overlay in overlays) {
                lowerdir += ":" + overlay;
            }
            lowerdir = lowerdir.substring(1);

            string[] mount = {
                "mount",
                "-t",
                "overlay", 
                "overlay",
                "-o",
                "lowerdir=" + lowerdir,
                mount_point
            };

            print(string.joinv(" ", mount) + "\n");

            var subprocess = new Subprocess.newv(mount, SubprocessFlags.NONE);
            subprocess.wait();
        }
    }

}