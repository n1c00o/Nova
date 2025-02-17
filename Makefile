# Creates the bin folder for build artifacts
build/{bin,lib}:
	@mkdir -p build/{lib,bin}

# Builds all rust targets
build/lib/liball_in_one.a build/bin/{cache,gateway,ratelimit,rest,webhook}{,.exe}: build/{bin,lib}
	@echo "Building rust project"
	cargo build --release
	@cp target/release/liball_in_one.a build/lib
	@cp target/release/{cache,gateway,ratelimit,rest,webhook}{,.exe} build/bin

# Generated by a rust build script.
internal/pkg/all-in-one/all-in-one.h: build/lib/liball_in_one.a

# All in one program build
build/bin/nova: build/lib/liball_in_one.a internal/pkg/all-in-one/all-in-one.h
	go build -a -ldflags '-s' -o build/bin/nova cmd/nova/nova.go

all: build/bin/{cache,gateway,ratelimit,rest,webhook}{,.exe} build/bin/nova

docker-images:
	docker-compose build

docker-push:
	docker-compose push

rust-test:
	cargo test

test: rust-test

.PHONY: all docker-images docker-push test rust-test
