const std = @import("std");
const Build = std.Build;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "liblo",
        .target = target,
        .optimize = optimize,
    });
    const t = lib.target_info.target;
    if (t.os.tag == .linux) {
        lib.defineCMacro("_BSD_SOURCE", "1");
        lib.linkLibC();
    }

    const config_h = b.addConfigHeader(.{
        .style = .{ .cmake = .{
            .path = "cmake/config.h.in",
        } },
        .include_path = "config.h",
    }, config_values);
    lib.addConfigHeader(config_h);
    lib.installConfigHeader(config_h, .{});

    const lo_h = b.addConfigHeader(.{
        .style = .{ .cmake = .{
            .path = "lo/lo.h.in",
        } },
        .include_path = "lo/lo.h",
    }, .{
        .THREADS_INCLUDE = "#include \"lo/lo_serverthread.h\"",
    });
    lib.addConfigHeader(lo_h);
    lib.installConfigHeader(lo_h, .{});
    const lo_endian_h = b.addConfigHeader(.{
        .style = .{ .cmake = .{
            .path = "lo/lo_endian.h.in",
        } },
        .include_path = "lo/lo_endian.h",
    }, .{
        .LO_BIGENDIAN = 2,
    });
    lib.addConfigHeader(lo_endian_h);
    lib.installConfigHeader(lo_endian_h, .{});
    lib.addIncludePath("src");
    lib.addIncludePath(".");
    lib.defineCMacro("HAVE_CONFIG_H", "1");
    lib.addCSourceFiles(&library_sources, &.{"-std=c11"});
    lib.step.dependOn(&config_h.step);
    lib.step.dependOn(&lo_endian_h.step);
    lib.step.dependOn(&lo_h.step);
    b.installArtifact(lib);
}

const config_values = .{
    .PACKAGE_NAME = "liblo",
    .PACKAGE_VERSION = "0.31",
    .LO_SO_VERSION = "{11, 1, 4}",
    .HAVE_POLL = 1,
    .HAVE_SELECT = 1,
    .HAVE_GETIFADDRS = 1,
    .HAVE_INET_PTON = 1,
    .HAVE_LIBPTHREAD = 1,
    .ENABLE_THREADS = 1,
    .PRINTF_LL = "ll",
};

const library_sources = .{
    "src/address.c",
    "src/blob.c",
    "src/bundle.c",
    "src/message.c",
    "src/method.c",
    "src/pattern_match.c",
    "src/send.c",
    "src/server.c",
    "src/timetag.c",
    "src/version.c",
    "src/server_thread.c",
};

const library_headers = .{
    "lo/lo_errors.h",
    "lo/lo_lowlevel.h",
    "lo/lo_macros.h",
    "lo/lo_osc_types.h",
    "lo/lo_serverthread.h",
    "lo/lo_throw.h",
    "lo/lo_types.h",
};
