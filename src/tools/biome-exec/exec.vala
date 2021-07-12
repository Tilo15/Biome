using LibBiome.Standard;

namespace Biome.Exec {

    void main(string[] argv) {
        var dir = Paths.get_environment_mount(argv[1], Paths.deserialise_secret(argv[2]));
        var wd = GLib.Environment.get_current_dir();
        check_fail(Posix.chroot(dir), "change root");
        if (Posix.stat(wd, null) == 0) {
            GLib.Environment.set_current_dir(wd);
        } else {
            GLib.Environment.set_current_dir("/");
        }
        check_fail(Posix.seteuid(Posix.getuid()), "set effective user id");
        check_fail(Posix.execv(argv[3], argv[3:argv.length - 3]), "execute binary");
    }

    void check_fail(int result, string action) {
        if(result != 0) {
            print(@"biome-exec: Failed to $(action): $(Posix.strerror(Posix.errno))\n");
            Posix.exit(result);
        }
    }

}