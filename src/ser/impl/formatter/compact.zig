const std = @import("std");

const ser = @import("../../../lib.zig").ser;

const Formatter = ser.Formatter;

pub fn CompactFormatter(comptime Writer: type) type {
    return struct {
        const Self = @This();
        const impl = @"impl CompactFormatter"(Writer);

        pub usingnamespace Formatter(
            *Self,
            Writer,
            impl.formatter.writeNull,
            impl.formatter.writeBool,
            impl.formatter.writeInt,
            impl.formatter.writeFloat,
            impl.formatter.writeNumberString,
            impl.formatter.beginString,
            impl.formatter.endString,
            impl.formatter.writeStringFragment,
            impl.formatter.writeCharEscape,
            impl.formatter.beginArray,
            impl.formatter.endArray,
            impl.formatter.beginArrayValue,
            impl.formatter.endArrayValue,
            impl.formatter.beginObject,
            impl.formatter.endObject,
            impl.formatter.beginObjectKey,
            impl.formatter.endObjectKey,
            impl.formatter.beginObjectValue,
            impl.formatter.endObjectValue,
            impl.formatter.writeRawFragment,
        );
    };
}

fn @"impl CompactFormatter"(comptime Writer: type) type {
    const Self = CompactFormatter(Writer);

    return struct {
        pub const formatter = struct {
            pub fn writeNull(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("null");
            }

            pub fn writeBool(_: *Self, writer: Writer, value: bool) Writer.Error!void {
                try writer.writeAll(if (value) "true" else "false");
            }

            pub fn writeInt(_: *Self, writer: Writer, value: anytype) Writer.Error!void {
                var buf: [100]u8 = undefined;
                try writer.writeAll(std.fmt.bufPrintIntToSlice(&buf, value, 10, .lower, .{}));
            }

            pub fn writeFloat(_: *Self, writer: Writer, value: anytype) Writer.Error!void {
                // this should be enough to display all decimal places of a decimal f64 number.
                var buf: [512]u8 = undefined;
                var stream = std.io.fixedBufferStream(&buf);

                std.fmt.formatFloatScientific(value, std.fmt.FormatOptions{}, stream.writer()) catch |err| switch (err) {
                    error.NoSpaceLeft => unreachable,
                    else => unreachable, // TODO: handle error
                };

                // TODO: fix getPos error
                try writer.writeAll(buf[0 .. stream.getPos() catch unreachable]);
            }

            pub fn writeNumberString(_: *Self, writer: Writer, value: []const u8) Writer.Error!void {
                try writer.writeAll(value);
            }

            pub fn beginString(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("\"");
            }

            pub fn endString(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("\"");
            }

            pub fn writeStringFragment(_: *Self, writer: Writer, value: []const u8) Writer.Error!void {
                try writer.writeAll(value);
            }

            pub fn writeCharEscape(_: *Self, writer: Writer, value: u21) Writer.Error!void {
                try ser.escapeChar(value, writer);
            }

            pub fn beginArray(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("[");
            }

            pub fn endArray(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("]");
            }

            pub fn beginArrayValue(_: *Self, writer: Writer, first: bool) Writer.Error!void {
                if (!first)
                    try writer.writeAll(",");
            }

            pub fn endArrayValue(self: *Self, writer: Writer) Writer.Error!void {
                _ = self;
                _ = writer;
            }

            pub fn beginObject(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("{");
            }

            pub fn endObject(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll("}");
            }

            pub fn beginObjectKey(_: *Self, writer: Writer, first: bool) Writer.Error!void {
                if (!first)
                    try writer.writeAll(",");
            }

            pub fn endObjectKey(self: *Self, writer: Writer) Writer.Error!void {
                _ = self;
                _ = writer;
            }

            pub fn beginObjectValue(_: *Self, writer: Writer) Writer.Error!void {
                try writer.writeAll(":");
            }

            pub fn endObjectValue(self: *Self, writer: Writer) Writer.Error!void {
                _ = self;
                _ = writer;
            }

            pub fn writeRawFragment(self: *Self, writer: Writer, value: []const u8) Writer.Error!void {
                _ = self;

                try writer.writeAll(value);
            }
        };
    };
}
