FROM rust:slim-bookworm AS builder

WORKDIR /app

# Copy only necessary files for build
COPY Cargo.toml Cargo.lock ./
COPY src ./src/
COPY static ./static/

# Download release files first
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip curl ca-certificates && \
    curl -s https://api.github.com/repos/yonson2/reptile/releases/latest | grep "browser_download_url.*zip" | cut -d : -f 2,3 | tr -d \" | wget -qi - && \
    unzip *.zip && \
    mv release/* . && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build with limited parallel jobs to reduce memory usage
RUN RUSTFLAGS="-C opt-level=s" cargo build --release -j 1

# Runtime stage
FROM rust:slim-bookworm

WORKDIR /app

COPY --from=builder /app/target/release/reptile-runner .
COPY --from=builder /app/ ./

# Set environment variables
ENV PORT=10000
ENV REPTILE_RUNNER_ADDR=0.0.0.0

CMD ["./reptile-runner"]
