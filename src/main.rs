mod server;
mod wasm_bindgen;

pub type Result<T, E = anyhow::Error> = std::result::Result<T, E>;
use std::{borrow::Cow, path::PathBuf, process::Command, str::FromStr};

use server::*;
use tracing::info;
use tracing_subscriber::EnvFilter;

use crate::server::Options;

fn main() -> Result<(), anyhow::Error> {
    let title = std::env::var("REPTILE_RUNNER_TITLE").unwrap_or_else(|_| "Snake".to_string());
    let address = std::env::var("REPTILE_RUNNER_ADDR").unwrap_or_else(|_| "127.0.0.1".to_string());

    let html_source = Cow::Borrowed(include_str!("./static/index.html"));
    let port = port_option("PORT");

    let directory = PathBuf::from_str(server::DIRECTORY).expect("Unpopulated git submodule");
    let wasm_file = PathBuf::from_str(server::WASM_FILE).expect("Invalid build directory");

    let output = wasm_bindgen::generate(&wasm_file)?;

    let options = Options {
        title,
        address,
        html_source,
        directory,
        port,
    };

    let rt = tokio::runtime::Runtime::new()?;
    rt.block_on(server::run_server(options, output))?;

    Ok(())
}

fn port_option(name: &str) -> u16 {
    let port = std::env::var(name)
        .unwrap_or("".to_owned())
        .parse::<u16>()
        .unwrap_or(server::PORT);

    pick_port::pick_free_port(port, 10).expect("free ports")
}
