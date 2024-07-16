# Stage 1: Build stage (This dockerfile for the Ubuntu OS)
FROM rust:1.79.0-slim AS builder

# Install necessary build tools and dependencies
RUN apt-get update && \
    apt-get install -y build-essential pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Create a new Rust binary project to leverage dependency caching
#RUN cd /tmp && USER=root cargo new --bin rust-app
WORKDIR /app

# Copy the Cargo.toml and Cargo.lock files to the container
COPY Cargo.toml Cargo.lock ./

# Copy the source code to the container
COPY . .

# Build the application
RUN cargo build --release


#################################################################################

# Stage 2: Final stage using Ubuntu
FROM ubuntu:20.04

# Install necessary runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the final container
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the built binary from the builder stage and change ownership
COPY --from=builder /app/target/release/rocket-app ./

# Set permissions and ownership
RUN chown appuser:appgroup /app/rocket-app 

# Switch to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8000

# # Command to run the application
 CMD ["./rocket-app"]
 #CMD [ "sleep","50000" ]


########################################################################################


## This Docker file for testing purpose ##

# FROM rust:1.79.0-slim 

# RUN cargo install cargo-build-deps

# RUN cd /tmp && USER=root cargo new --bin rust-app

# WORKDIR /tmp/rust-app

# COPY Cargo.toml Cargo.lock ./

# RUN cargo build-deps --release

# COPY src /tmp/rust-app/src

# RUN cargo build  --release

# CMD [ "sleep","50000" ]
