open Buffer

type test_driver = {
    buffer: Buffer.t;
    scroll_buffer: Buffer.t;
    pos: int * int
}
