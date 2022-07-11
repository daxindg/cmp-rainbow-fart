use rodio::{Decoder, OutputStream, Sink};
use std::fs::File;
use std::io::BufReader;
use std::env;

pub fn main() {
    let args:Vec<_> = env::args().collect();
    if args.len()  <= 1 {
        return
    }
    let uri = &args[1];
    let (_stream, stream_handle) = OutputStream::try_default().unwrap();
    let sink = Sink::try_new(&stream_handle).unwrap();
    let file = BufReader::new(File::open(uri).expect(uri));
    let source = Decoder::new(file).unwrap();
    sink.append(source);
    sink.sleep_until_end();
}
