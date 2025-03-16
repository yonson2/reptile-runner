FROM rust:slim-bookworm

WORKDIR /app

COPY . .

RUN apt-get update && \
    apt-get install -y wget unzip curl && \
    curl -s https://api.github.com/repos/yonson2/reptile/releases/latest | grep "browser_download_url.*zip" | cut -d : -f 2,3 | tr -d \" | wget -qi - && \
    unzip *.zip && \
    mv release/* . && \
    cargo build --release

CMD ["/app/target/release/reptile-runner"]