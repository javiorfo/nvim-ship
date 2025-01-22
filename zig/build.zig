const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ship",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_jwt = b.addExecutable(.{
        .name = "jwt",
        .root_source_file = b.path("src/jwt.zig"),
        .target = target,
        .optimize = optimize,
    });

    // CURL
    const dep_curl = b.dependency("curl", .{ .link_vendor = false });
    exe.root_module.addImport("curl", dep_curl.module("curl"));
    exe.linkSystemLibrary("curl");
    exe.linkLibC();

    // PRETTIZY
    const dep_prettizy = b.dependency("prettizy", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("prettizy", dep_prettizy.module("prettizy"));
    exe_jwt.root_module.addImport("prettizy", dep_prettizy.module("prettizy"));

    b.installArtifact(exe);
    b.installArtifact(exe_jwt);

    const run_cmd = b.addRunArtifact(exe);
    const run_cmd_jwt = b.addRunArtifact(exe_jwt);

    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd_jwt.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
        run_cmd_jwt.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const run_step_jwt = b.step("jwt", "Run the app");
    run_step_jwt.dependOn(&run_cmd_jwt.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
