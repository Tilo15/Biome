using LibBiome.Elements;
using LibBiome.Environment;
using LibBiome.Filesystem;
using Gee;

namespace Biome.Cook {

    void main(string[] argv) {

        if (argv.length < 3) {
            print_help(argv[0]);
            Posix.exit(-1);
        }

        string element_src = argv[1];
        string build_dir = argv[2];
        string[] patch_names = argv.length > 4 ? argv[3:argv.length] : new string[] {};

        string data;
        FileUtils.get_contents(element_src, out data);

        // We are building the image, so obviously we don't have one yet
        Element element = new Element.from_string(data, "");

        ElementIdentifier identifier = new ElementIdentifier() {
            fully_qualified_name = element.identifier.fully_qualified_name,
            version = element.identifier.version
        };

        element.identifier.fully_qualified_name += ".source";

        string squashfs_dest = @"$(build_dir)/$(identifier.fully_qualified_name)__$(identifier.version).squashfs";
        string element_dest = @"$(build_dir)/$(identifier.fully_qualified_name)__$(identifier.version).element";
        Posix.system(@"cp \"$(element_src)\" \"$(element_dest)\"");

        message(@"Loaded element $(element.simple_name) ($(identifier.fully_qualified_name)).");

        HybridElementRepository repo = new HybridElementRepository(LibBiome.Standard.Paths.REPOSITORY);
        repo.add_element(element);

        element.squashfs_path = create_source_image(element, build_dir);
        if(element.squashfs_path[0] != '/') {
            element.squashfs_path = @"$(GLib.Environment.get_current_dir())/$(element.squashfs_path)";
        }

        message(@"Creating build environment...");

        string upperdir = @"$(build_dir)/upper";
        Posix.system(@"mkdir \"$(upperdir)\"");
        string workdir = @"$(build_dir)/overlay-work";
        Posix.system(@"mkdir \"$(workdir)\"");

        var mounts = new Gee.LinkedList<MountDescription>();
        mounts.add(new MountDescription() {
            full_path = "/dev",
            mount_type = MountType.RBIND,
        });
        mounts.add(new MountDescription() {
            full_path = "/proc",
            mount_type = MountType.RBIND,
        });
        mounts.add(new MountDescription() {
            full_path = "/sys",
            mount_type = MountType.RBIND,
        });
        mounts.add(new MountDescription() {
            full_path = "/run",
            mount_type = MountType.TMPFS,
        });
        mounts.add(new MountDescription() {
            full_path = "/tmp",
            mount_type = MountType.TMPFS,
        });

        EnvironmentDescription description = new EnvironmentDescription() {
            name = @"biome-cook-$(identifier.fully_qualified_name)__$(identifier.version)",
            root_element = element.identifier,
            upperdir = upperdir,
            workdir = workdir,
            is_build_environment = true,
            mounts = mounts
        };

        EnvironmentBuilder builder = new EnvironmentBuilder(repo);
        LibBiome.Environment.Environment environment = builder.build(description);
        
        // Run the build
        run_build_commands(environment, element);

        message("Cleaning up environment");
        environment.clean();

        message("Cleaning up result");
        Posix.system(@"rm -fr \"$(workdir)\"");
        Posix.system(@"rm -fr \"$(upperdir)\"/{proc,sys,dev,build,run,tmp}");
        foreach (var exclude in element.build_information.exclude_paths) {
            Posix.system(@"rm -fr \"$(upperdir)/$(exclude)\"");
        }

        message("Creating binary image...");
        Posix.system(@"mksquashfs \"$(upperdir)\" \"$(squashfs_dest)\" -noappend");
        Posix.system(@"rm -fr \"$(upperdir)\"");
        Posix.system(@"rm -fr \"$(element.squashfs_path)\"");

        message("That's all for now!");
        Posix.exit(0);
    }

    void get_file(string name, string url, string hash, string target, string label) {
        File copy = File.new_for_path(target);
        if(Posix.access(name, Posix.F_OK) == 0) {
            File source = File.new_for_path(name);
            source.copy(copy, FileCopyFlags.OVERWRITE, null, (r, t) => progress(@"Copying $(label)",(int)(((float)r / (float)t) * 100)));
        }
        else {
            //  File source = File.new_for_uri(url);
            //  source.copy(copy, FileCopyFlags.OVERWRIT, null, (r, t) => progress(@"Downloading $(label)",(int)(((float)r / (float)t) * 100)));
            Posix.system(@"wget -O $(target) $(url)");
        }

        Checksum checksum = new Checksum(ChecksumType.SHA512);
        FileStream stream = FileStream.open(target, "rb");
        uint8 fbuf[100];
        size_t size;
        while ((size = stream.read (fbuf)) > 0){
            checksum.update (fbuf, size);
        }

        if (checksum.get_string() == hash) {
            return;
        }

        message("ERROR: Hashes don't match!");
        Posix.exit(-1);
    }

    string create_source_image(Element element, string work_dir) {
        string archive_path = @"$(work_dir)/$(element.build_information.source_filename)";
        string image_fs_path = @"$(work_dir)/image_stage";
        string extract_path = image_fs_path + "/build/src";
        string image_path = @"$(work_dir)/source_image.squashfs";
        get_file(element.build_information.source_filename, element.build_information.source_url, element.build_information.source_sha512, archive_path, "source archive");
        Posix.system(@"mkdir -p \"$(image_fs_path)/\"{proc,sys,dev,build/src,run,tmp}");
        message(@"Extracting...");
        Posix.system(@"tar -xf \"$(archive_path)\" -C \"$(extract_path)\"");
        //Posix.system(@"rm \"$(archive_path)\"");
        message(@"Creating source image...");
        Posix.system(@"mksquashfs \"$(image_fs_path)\" \"$(image_path)\" -noappend");
        Posix.system(@"rm -fr \"$(image_fs_path)\"");
        return image_path;
    }

    void run_build_commands(LibBiome.Environment.Environment environment, Element element) {
        
        message("Running element configure commands...");
        foreach (var command in element.build_information.configure_commands) {
            biome_exec(environment, element.build_information.build_shell_path, command);
        }

        message("Running element build commands...");
        foreach (var command in element.build_information.build_commands) {
            biome_exec(environment, element.build_information.build_shell_path, command);
        }

        message("Running element install commands...");
        foreach (var command in element.build_information.install_commands) {
            biome_exec(environment, element.build_information.build_shell_path, command);
        }

    }


    void print_help(string executable) {
        print(@"Usage: $(executable) ELEMENT_FILE BUILD_DIR [OUTPUT_FILE [ ...PATCHES ]]\n");
    }

    void message(string message) {
        print(@"[COOK] $(message)\n");
    }

    void progress(string message, int percent) {
        print(@"[COOK] $(message)... $(percent)%\r");
        if(percent == 100) {
            print("\n");
        }
    }

    void biome_exec(LibBiome.Environment.Environment environment, string shell, string command) {
        int pid = Posix.fork();
        if (pid == 0) {
            var args = new string[] {
                "/biome/biome-exec",
                environment.name,
                LibBiome.Standard.Paths.serailise_secret(environment.secret),
                shell,
                "-c",
                @"cd /build/src && $(command)"
            };
            Posix.execv(args[0], args);
            message(@"CRITICAL: Executable did not take over process: $(Posix.strerror(Posix.errno))");
            Posix.exit(-1);
        }
        Posix.waitpid(pid, null, 0);
    }



}