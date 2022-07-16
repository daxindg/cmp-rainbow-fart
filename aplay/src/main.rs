use clap::Parser;
use rodio::{Decoder, OutputStream, Sink};
use std::{fs::File, io::BufReader, thread, time};
use rodio::source::{SineWave, Source};

#[derive(Parser)]
struct Args {
    uri: String,
    wait_time: u64,
}

pub fn main() {
    let args = Args::parse();

    let uri = &args.uri;
    let (_stream, stream_handle) = OutputStream::try_default().unwrap();
    let sink = Sink::try_new(&stream_handle).unwrap();
    let file = BufReader::new(File::open(uri).expect(uri));
    let source = Decoder::new(file).unwrap();
    sink.append(source);
    sleep(args.wait_time, &sink);
    sink.sleep_until_end();
}

pub fn sleep(millis: u64, s: &Sink) {
    let duration = time::Duration::from_millis(millis);
    let dummy = SineWave::new(440.0).take_duration(duration).amplify(0.0);
    s.append(dummy)
}
