use std::sync::{Mutex, MutexGuard};

use magnus::{define_module, exception, function, prelude::*, Error, RHash, RString, Ruby};
use once_cell::sync::OnceCell;

static SESSION: OnceCell<Mutex<magika_rust::Session>> = OnceCell::new();

fn session() -> Result<MutexGuard<'static, magika_rust::Session>, Error> {
    let mutex = SESSION.get_or_try_init(|| {
        magika_rust::Session::new().map(Mutex::new).map_err(to_runtime_error)
    })?;

    mutex
        .lock()
        .map_err(|_| Error::new(exception::runtime_error(), "Magika session lock was poisoned"))
}

fn identify_path(path: String) -> Result<RHash, Error> {
    let mut session = session()?;
    let result = session.identify_file_sync(path).map_err(to_runtime_error)?;
    result_to_hash(result)
}

fn identify_bytes(bytes: RString) -> Result<RHash, Error> {
    let content = unsafe { bytes.as_slice().to_vec() };
    let mut session = session()?;
    let result = session
        .identify_content_sync(content.as_slice())
        .map_err(to_runtime_error)?;
    result_to_hash(result)
}

fn result_to_hash(result: magika_rust::FileType) -> Result<RHash, Error> {
    let ruby = Ruby::get().map_err(|_| {
        Error::new(
            exception::runtime_error(),
            "Ruby VM is not available while converting Magika result",
        )
    })?;
    let info = result.info();
    let hash = ruby.hash_new();
    let extensions = ruby.ary_from_vec(
        info.extensions
            .iter()
            .map(|extension| extension.to_string())
            .collect::<Vec<_>>(),
    );

    hash.aset("label", info.label)?;
    hash.aset("description", info.description)?;
    hash.aset("mime_type", info.mime_type)?;
    hash.aset("group", info.group)?;
    hash.aset("extensions", extensions)?;
    hash.aset("is_text", info.is_text)?;
    hash.aset("score", result.score() as f64)?;

    Ok(hash)
}

fn to_runtime_error(error: magika_rust::Error) -> Error {
    Error::new(exception::runtime_error(), error.to_string())
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let magika = define_module("Magika")?;
    let native = magika.define_module("Native")?;
    native.define_singleton_method("identify_path", function!(identify_path, 1))?;
    native.define_singleton_method("identify_bytes", function!(identify_bytes, 1))?;
    Ok(())
}
