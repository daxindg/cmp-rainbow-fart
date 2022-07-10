use rodio::{Decoder, OutputStream, Sink};
use std::ffi::CStr;
use std::fs::File;
use std::io::BufReader;
use std::os::raw::c_char;
#[no_mangle]
pub extern "C" fn aplay(c_uri: *const c_char) {
    let uri = unsafe { CStr::from_ptr(c_uri) }.to_str().unwrap();
    let (_stream, stream_handle) = OutputStream::try_default().unwrap();
    let sink = Sink::try_new(&stream_handle).unwrap();
    let file = BufReader::new(File::open(uri).expect(uri));
    let source = Decoder::new(file).unwrap();
    sink.append(source);
    sink.sleep_until_end();
}

#[test]
fn test_aplay() {
    use std::path::PathBuf;
    let mut d = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    d.push("../lua/cmp_rainbow_fart/built-in-voice-packages/built-in-voice-chinese/function_02.mp3");
    let s = std::ffi::CString::new(d.to_str().unwrap()).unwrap();
    let p = s.as_ptr();
    std::mem::forget(s);

    aplay(p)
}
