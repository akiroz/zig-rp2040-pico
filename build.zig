const std = @import("std");
const Builder = std.build.Builder;

const rp2040 = std.zig.CrossTarget {
    .cpu_arch = .thumb,
    .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
    .os_tag = .freestanding,
    .abi = .eabi
};

pub fn build(b: *Builder) !void {
    
    const compile_pio = build_pioasm(b).run();
    compile_pio.addArg("src/blink.pio.s");
    compile_pio.addArg("src/blink.pio.h");

    const firmware = b.addExecutable("firmware.elf", "src/main.cpp");
    firmware.step.dependOn(&compile_pio.step);
    firmware.setBuildMode(b.standardReleaseOptions());
    firmware.setTarget(rp2040);
    firmware.addIncludeDir("src"); // generated pio headers
    firmware.addIncludeDir("include/newlib");
    firmware.addIncludeDir("include/newlib/c++");
    firmware.addIncludeDir("include/newlib/c++/arm-none-eabi");
    firmware.addIncludeDir("include/pico-sdk");
    firmware.addObjectFile("lib/newlib-3.3.0/libnosys.a"); // ar dv read.o write.o 
    firmware.addObjectFile("lib/newlib-3.3.0/libc_nano.a"); // ar dv lib_a-exit.o
    firmware.addObjectFile("lib/newlib-3.3.0/libm.a");
    firmware.addObjectFile("lib/newlib-3.3.0/libstdc++_nano.a");
    firmware.addObjectFile("lib/pico-sdk-1.3.0/libpico_sdk.a");
    firmware.addAssemblyFile("lib/pico-sdk-1.3.0/bs2_default_padded_checksummed.S");
    firmware.setLinkerScriptPath(.{ .path = "lib/pico-sdk-1.3.0/memmap_default.ld" });
    firmware.strip = true;
    firmware.install();

    const make_uf2 = build_elf2uf2(b).run();
    make_uf2.step.dependOn(&firmware.step);
    make_uf2.addArg("zig-out/bin/firmware.elf");
    make_uf2.addArg("zig-out/bin/firmware.uf2");

    b.default_step.dependOn(&make_uf2.step);
}

fn build_pioasm(b: *Builder) *std.build.LibExeObjStep {
    const exe = b.addExecutable("pioasm", "lib/pico-sdk-1.3.0/pioasm/main.cpp");
    exe.addIncludeDir("lib/pico-sdk-1.3.0/pioasm");
    exe.addIncludeDir("lib/pico-sdk-1.3.0/pioasm/gen");
    exe.addCSourceFiles(
        &[_]([]const u8){
            "lib/pico-sdk-1.3.0/pioasm/gen/lexer.cpp",
            "lib/pico-sdk-1.3.0/pioasm/gen/parser.cpp",
            "lib/pico-sdk-1.3.0/pioasm/pio_assembler.cpp",
            "lib/pico-sdk-1.3.0/pioasm/pio_disassembler.cpp",
            "lib/pico-sdk-1.3.0/pioasm/c_sdk_output.cpp",
        },
        &[_]([]const u8){}
    );
    exe.linkLibCpp();
    return exe;
}

fn build_elf2uf2(b: *Builder) *std.build.LibExeObjStep {
    const exe = b.addExecutable("elf2uf2", "lib/pico-sdk-1.3.0/elf2uf2/main.cpp");
    exe.linkLibCpp();
    return exe;
}