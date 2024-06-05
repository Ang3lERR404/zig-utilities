//! This is a general utilities module for use with the zig programming language.
//! ```zig
//! find // - Can find a given element within an array and return an index of that item.
//! BHMPP // - Can find a pattern within a string, highly optimized for strings
//! indexi // - Yet to be implemented, but planned to be used as a global indexOf library to encase all iteration handling types.
//! ```
const std = @import("std");
const builtin = @import("builtin");

pub fn assert(ok:bool) void {
  if (!ok) unreachable;
}
pub fn expect(ok:bool) !void {
  if (!ok) return error.TestUnexpectedResult;
}

const print = &std.debug.print;

/// backend can support
pub const backend = struct{
  /// | - native c/llvm vectors?
  pub const supportsVectors = switch (builtin.zig_backend) {
    .stage2_llvm, .stage2_c => true,
    else => false
  };
  /// | - equal bytes?
  pub const eqlBytes = switch (builtin.zig_backend) {
    .stage2_spirv64 => false,
    else => true
  };
  /// | - can print to console?
  pub const canPrint = builtin.zig_backend != .stage2_spirv64;
};

/// Can find a given element within an array and return an index of that item.
pub inline fn find(lit:anytype, ch:anytype, rev:bool) usize {
  var i:usize = undefined;
  if (rev) {
    i = lit.len - 1;
    while (i > 0) : (i -= 1) {
      if (lit[i] != ch) continue;
      return i;
    }
    return 0;
  }
  i = 0;
  while (i < lit.len) : (i += 1) {
    if (lit[i] != ch) continue;
    return i;
  }
  return 0;
}

/// B.M.H.P.P
/// Boyer
/// Moore
/// Horspool
/// PreProcess
pub inline fn BMHPP(pattern:[]const u8, table:*[256]usize, rev:bool) void {
  for (table) |*c| {
    c.* = pattern.len;
  }
  var i:usize = undefined;

  if (rev) {
    i = pattern.len - 1;
    while (i > 0) : (i -= 1) {
      table[pattern[i]] = i;
    }
    return;
  }

  i = 0;
  while (i < (pattern.len - 1)) : (i += 1) {
    table[pattern[i]] = (pattern.len - 1) - i;
  }
}




// TODO: YET TO BE IMPLIMENTED
/// YET TO BE IMPLIMENTED, DO NOT USE. 
pub const indexi = struct{
  fn ofScalar(comptime T: type, slice:[]const T, start:usize, value:T, rev:?bool) ?usize {
    var i:usize = undefined;
    if (rev) {
      while (i != 0) : (i -= 1) {
        if (slice[i] != value) continue;
        return i;
      }
      return null;
    } else {
      i = start;
      return switch (true) {
        start >= slice.len => null,
        backend.supportsVectors and !std.debug.inValgrind() and !@inComptime()
        and (@typeInfo(T) == (.Int or .Float))
        and std.math.isPowerOfTwo(@bitSizeOf(T)) => {

        }
      };
    }
  }
};