const err = @cImport(@cInclude("errno.h"));

extern fn __errno() *c_int;

export fn _close(fd: c_int) c_int {
    _ = fd;
    __errno().* = err.ENOSYS;
    return -1;
}

export fn _fstat(fd: c_int, st: *anyopaque) c_int {
    _ = fd;
    _ = st;
    __errno().* = err.ENOSYS;
    return -1;
}

export fn _isatty(fd: c_int) c_int {
    _ = fd;
    __errno().* = err.ENOSYS;
    return 0;
}

export fn _lseek(fd: c_int, ptr: c_int, dir: c_int) c_int {
    _ = fd;
    _ = ptr;
    _ = dir;
    __errno().* = err.ENOSYS;
    return -1;
}
