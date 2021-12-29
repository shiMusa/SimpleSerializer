#import "Basic";

#scope_file
NewResizableArray :: (count: s64, $T: Type, $initialized := true, allocator: Allocator = .{}, alignment: s32 = -1) -> [..]T {
    arr := NewArray(count, T, initialized, allocator, alignment); // ! alloc
    res := resizable(arr);
    res.count = 0;
    return res;
}
#scope_export

//  ######  ######## ########  ####    ###    ##       #### ######## ########
// ##    ## ##       ##     ##  ##    ## ##   ##        ##       ##  ##
// ##       ##       ##     ##  ##   ##   ##  ##        ##      ##   ##
//  ######  ######   ########   ##  ##     ## ##        ##     ##    ######
//       ## ##       ##   ##    ##  ######### ##        ##    ##     ##
// ##    ## ##       ##    ##   ##  ##     ## ##        ##   ##      ##
//  ######  ######## ##     ## #### ##     ## ######## #### ######## ########

Serializer :: struct {
    buffer: [..]u8;
}

serializer :: (initial_buffer_size: int) -> Serializer {
    res: Serializer;
    res.buffer = NewResizableArray(initial_buffer_size, u8);
    return res;
}

serializer_free :: (ser: Serializer) {
    array_free(ser.buffer);
}

write :: (ser: *Serializer, value: $T) {
    _write_bytes(ser, *value, size_of(T));
}

write_array :: (ser: *Serializer, value: *$T, count: int) {
    _write_bytes(ser, value, size_of(T) * count);
}

#scope_file
_write_bytes :: (ser: *Serializer, ptr: *void, count: int) {
    needed := ser.buffer.count + count;
    if needed > ser.buffer.allocated {
        array_reserve(*ser.buffer, ser.buffer.allocated * 2 + needed);
    }
    memcpy(*ser.buffer.data[ser.buffer.count], ptr, count);
    ser.buffer.count += count;
}
#scope_export


// ########  ########          ######  ######## ########  ####    ###    ##       #### ######## ########
// ##     ## ##               ##    ## ##       ##     ##  ##    ## ##   ##        ##       ##  ##
// ##     ## ##               ##       ##       ##     ##  ##   ##   ##  ##        ##      ##   ##
// ##     ## ######   #######  ######  ######   ########   ##  ##     ## ##        ##     ##    ######
// ##     ## ##                     ## ##       ##   ##    ##  ######### ##        ##    ##     ##
// ##     ## ##               ##    ## ##       ##    ##   ##  ##     ## ##        ##   ##      ##
// ########  ########          ######  ######## ##     ## #### ##     ## ######## #### ######## ########


Deserializer :: struct {
    buffer: []u8;
    cursor: int;
}

deserializer :: (data: []u8) -> Deserializer {
    res: Deserializer;
    res.buffer = data;
    return res;
}

read :: (dser: *Deserializer, $T: Type) -> T {
    res: T;
    read_array(dser, T, *res, 1);
    return res;
}

read_array :: (dser: *Deserializer, $T: Type, out: *T, count: int) {
    byte_count := size_of(T) * count;
    memcpy(out, dser.buffer.data + dser.cursor, byte_count);
    dser.cursor += byte_count;
    assert(dser.cursor <= dser.buffer.count);
}