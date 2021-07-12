
namespace LibBiome.Filesystem {

    public enum MountType {
        BIND,
        RBIND,
        PROC,
        TMPFS;

        public static MountType from_string(string value) {
            switch (value) {
                case "bind":
                    return BIND;
                case "rbind":
                    return RBIND;
                case "proc":
                    return PROC;
                case "tmpfs":
                    return TMPFS;
                default:
                    assert_not_reached();
            }
        }
    }
    
    public class MountDescription {

        public string full_path { get; set; }

        public MountType mount_type { get; set; }

        public Posix.mode_t mode { get; set; }

        public MountDescription.from_json (Json.Object? obj) {
            full_path = obj.get_string_member("path");
            mount_type = MountType.from_string(obj.get_string_member("type"));
            mode = (int16)obj.get_int_member("permissions");
        }

    }

}