# Stage 1: Build stage (This dockerfile for the Ubuntu OS)
FROM rust:1.79.0-slim AS builder

# Create a new Rust binary project to leverage dependency caching
#RUN cd /tmp && USER=root cargo new --bin rust-app
WORKDIR /app

# Copy the Cargo.toml and Cargo.lock files to the container
COPY Cargo.toml Cargo.lock ./

# Install necessary build tools and dependencies
RUN apt-get update && \
    apt-get install -y build-essential pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*


# Copy the source code to the container
COPY src /app/src

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
#RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the built binary from the builder stage and change ownership
COPY --from=builder /app/target/release/rocket-app app/

# Set permissions and ownership
#RUN chown appuser:appgroup /app/rocket-app && \
    #chmod +x /app/rocket-app

# Switch to the non-root user
#USER appuser

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["sleep","50000"]

