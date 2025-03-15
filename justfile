default: build

deps:
    rustup target install wasm32-unknown-unknown
    git submodule update --init --recursive

build-wasm:
    cd reptile && cargo build --target wasm32-unknown-unknown --profile wasm-release

build: deps build-wasm
    cargo build --release

run:
    ./target/release/reptile-runner
