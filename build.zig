const std = @import("std");
const Builder = std.build.Builder;
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) void {
    const rp2040 = CrossTarget {
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
        .os_tag = .freestanding,
        .abi = .eabi
    };

    // libc stubs
    const nosys = b.addObject("nosys", "src/nosys.zig");
    nosys.setBuildMode(b.standardReleaseOptions());
    nosys.setTarget(rp2040);
    nosys.addIncludeDir("include/newlib");

    const firmware = b.addExecutable("firmware.elf", "src/main.zig");
    firmware.setBuildMode(b.standardReleaseOptions());
    firmware.setTarget(rp2040);
    firmware.addIncludeDir("include/newlib");
    firmware.addIncludeDir("include/pico-sdk");
    firmware.addObject(nosys);
    firmware.addObjectFile("lib/newlib-3.3.0/libc_nano.a");
    firmware.addObjectFile("lib/newlib-3.3.0/libm.a");
    firmware.addObjectFile("lib/pico-sdk-1.3.0/pico_sdk.a");
    firmware.addAssemblyFile("lib/pico-sdk-1.3.0/bs2_default_padded_checksummed.S");
    firmware.setLinkerScriptPath(.{ .path = "lib/pico-sdk-1.3.0/memmap_default.ld" });
    firmware.strip = true;
    firmware.install();
    
    const elf2uf2 = b.addExecutable("elf2uf2", "lib/pico-sdk-1.3.0/elf2uf2/main.cpp");
    elf2uf2.linkLibCpp();

    const make_uf2 = elf2uf2.run();
    make_uf2.step.dependOn(&firmware.step);
    make_uf2.addArgs(&[2]([]const u8){"zig-out/bin/firmware.elf", "zig-out/bin/firmware.uf2"});

    b.default_step.dependOn(&make_uf2.step);
}
