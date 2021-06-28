namespace LibBiome {

    public class FakeRoot {

        public static void create_fake_root(string path) throws GLib.Error{
            string[] included_folders = {
                "/bin",
                "/boot",
                "/dev",
                "/etc",
                "/lib",
                "/lib64",
                "/media",
                "/mnt",
                "/opt",
                "/proc",
                "/root",
                "/run",
                "/sbin",
                "/srv",
                "/sys",
                "/tmp",
                "/usr",
                "/var"
            };

            Posix.mkdir(path, 0700);
            foreach (var folder in included_folders) {
                Posix.mkdir(path + folder, 0700);

                string[] args = {
                    "mount",
                    "--bind",
                    folder,
                    path + folder
                };

                var proc = new Subprocess.newv(args, SubprocessFlags.NONE);
                proc.wait();
            }
        }
    }

}