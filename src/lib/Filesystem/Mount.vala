namespace LibBiome.Filesystem {

    public class Mount {

        public string path { get; private set; }

        public string? filesystem { get; private set; }

        public bool is_mounted  { get {
            return check_mounted(path, filesystem);
        }}

        public void unmount() {
            string[] args = {
                "umount",
                "-l",
                path
            };

            var subprocess = new Subprocess.newv(args, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public Mount.tmpfs(string mount_point, Posix.mode_t mode) throws GLib.Error {
            path = mount_point;
            filesystem = "tmpfs";

            Posix.mkdir(mount_point, mode);

            string[] args = {
                "mount",
                "-t",
                "tmpfs",
                "none",
                mount_point
            };

            var subprocess = new Subprocess.newv(args, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public Mount.proc(string mount_point, Posix.mode_t mode) throws GLib.Error {
            path = mount_point;
            filesystem = "tmpfs";

            Posix.mkdir(mount_point, mode);

            string[] args = {
                "mount",
                "-t",
                "proc",
                "none",
                mount_point
            };

            var subprocess = new Subprocess.newv(args, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public Mount.squashfs(string image, string mount_point, Posix.mode_t mode) throws GLib.Error {
            path = mount_point;
            filesystem = "squashfs";

            Posix.mkdir(mount_point, mode);

            string[] args = {
                "mount",
                "-t",
                "squashfs",
                image,
                mount_point
            };

            var subprocess = new Subprocess.newv(args, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public Mount.bind(string source, string mount_point, Posix.mode_t mode, bool recursive = false) throws GLib.Error {
            path = mount_point;
            filesystem = null;

            Posix.mkdir(mount_point, mode);

            string[] args = {
                "mount",
                recursive ? "--rbind" : "--bind",
                source,
                mount_point
            };

            var subprocess = new Subprocess.newv(args, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public Mount.overlay_readonly(string[] lowerdirs, string mount_point, Posix.mode_t mode) throws GLib.Error {
            path = mount_point;
            filesystem = null;

            Posix.mkdir(mount_point, mode);

            string lowerdir = "";
            foreach (var dir in lowerdirs) {
                lowerdir += ":" + dir;
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

            var subprocess = new Subprocess.newv(mount, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public Mount.overlay(string[] lowerdirs, string upperdir, string workdir, string mount_point, Posix.mode_t mode) throws GLib.Error {
            path = mount_point;
            filesystem = "overlay";

            Posix.mkdir(mount_point, mode);

            string config = "lowerdir=";
            for(int i = 0; i < lowerdirs.length; i++) {
                if(i != 0) config += ":";
                config += lowerdirs[i];
            }

            config += @",upperdir=$(upperdir)";
            config += @",workdir=$(workdir)";

            string[] mount = {
                "mount",
                "-t",
                "overlay", 
                "overlay",
                "-o",
                config,
                mount_point
            };
            
            var subprocess = new Subprocess.newv(mount, SubprocessFlags.NONE);
            subprocess.wait();
        }

        public static Mount build_from_description(string path, MountDescription description) throws GLib.Error {

            switch (description.mount_type) {
                case MountType.BIND:
                    return new Mount.bind(description.full_path, path + description.full_path, description.mode, false);
                case MountType.RBIND:
                    return new Mount.bind(description.full_path, path + description.full_path, description.mode, true);
                case MountType.PROC:
                    return new Mount.proc(path + description.full_path, description.mode);
                case MountType.TMPFS:
                    return new Mount.tmpfs(path + description.full_path, description.mode);
                default:
                    assert_not_reached();
            }

        }

        public static bool check_mounted(string path, string? expected_fs = null) throws GLib.Error {
            string data;
            FileUtils.get_contents("/proc/mounts", out data);

            var rows = data.split("\n");

            foreach (var row in rows) {
                var cols = row.split(" ");
                if(cols[1] == path && (expected_fs == null || expected_fs == cols[2])) {
                    return true;
                }
            }
            return false;
        }

    }

}