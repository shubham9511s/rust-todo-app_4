# Stage 1: Build stage
FROM rust:1 AS builder

# Install cargo-build-deps for better dependency caching
RUN cargo install cargo-build-deps

# Create a new Rust binary project to leverage dependency caching
RUN cd /tmp && USER=root cargo new --bin rust-app
WORKDIR /tmp/rust-app

# Copy the Cargo.toml and Cargo.lock files to the container
COPY Cargo.toml Cargo.lock ./

# Build only the dependencies to cache them
RUN cargo build-deps --release

# Copy the source code to the container
COPY . .

# Build the application
RUN cargo build --release

#################################################################################

# Stage 2: Final stage using Alpine
FROM alpine:latest

# Install necessary runtime dependencies (if any)
RUN apk add --no-cache ca-certificates

# Set the working directory inside the final container
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the built binary from the builder stage and change ownership
COPY --from=builder /tmp/rust-app/. /app/rust-app

# Set permissions and ownership
RUN chown appuser:appgroup /app/rust-app && \
    chmod +x /app/rust-app

# Switch to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["/app/rust-app"]
