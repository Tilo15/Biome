using LibBiome.Elements;

namespace LibBiome.Standard {

    public class Paths {
        public const string REPOSITORY = "/biome/repo";
        public const string RUNFILES = "/biome/run";
        public const string SOCKET = "/biome/daemon/biomed.socket";
        public const string ELEMENT_MOUNTS = "/stage/elements";
        public const string INTERMEDIATE_MOUNTS = "/stage/intermediate";
        public const string ENVIRONMENT_MOUNTS = "/stage/envrionments";
        public const string WORK_DIRS = "/stage/workdirs";

        public static string element_information_path(ElementIdentifier identifier) {
            return @"$(REPOSITORY)/$(identifier.fully_qualified_name)__$(identifier.version).element";
        }

        public static string element_squashfs_path(ElementIdentifier identifier) {
            return @"$(REPOSITORY)/$(identifier.fully_qualified_name)__$(identifier.version).squashfs";
        }

        public static string element_mount_path(ElementIdentifier identifier) {
            return @"$(ELEMENT_MOUNTS)/$(identifier.fully_qualified_name)__$(identifier.version)";
        }

        public static string get_new_work_dir() {
            return @"$(WORK_DIRS)/$(GLib.Uuid.string_random())";
        }

        public static string get_new_base_mount() {
            return @"$(INTERMEDIATE_MOUNTS)/$(GLib.Uuid.string_random())";
        }

        public static string get_environment_mount(string name, uint8[] secret) {
            Checksum checksum = new Checksum(ChecksumType.SHA256);
            checksum.update(secret, secret.length);
            string hash = checksum.get_string();
            return @"$(ENVIRONMENT_MOUNTS)/$(name)-$(hash)";
        }

        public static uint8[] new_secret() {
            uint8[512] secret = new uint8[512];
            for (int i = 0; i < 512; i++) {
                secret[i] = (uint8)Random.int_range(uint8.MIN, uint8.MAX);
            }

            return secret;
        }
    }

}