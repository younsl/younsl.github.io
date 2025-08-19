# Makefile for Marp presentations

# Default settings
CONTAINER_PORT ?= 8080
SECONDARY_PORT ?= 37717

# Command aliases - define commands here
DOCKER ?= podman
FIND = find

.PHONY: serve clean build build-dry-run check-container-engine

# Check if container engine is installed
check-container-engine:
	@which $(DOCKER) > /dev/null || (echo "Error: $(DOCKER) is not installed or not in PATH" && exit 1)
	echo "Container engine $(DOCKER) is installed"

# Default target
serve: check-container-engine
	$(DOCKER) run --rm \
		--init \
		-v $(PWD):/home/marp/app \
		-e LANG=$(shell echo $$LANG) \
		-p $(CONTAINER_PORT):$(CONTAINER_PORT) \
		-p $(SECONDARY_PORT):$(SECONDARY_PORT) \
		marpteam/marp-cli -s . --port $(CONTAINER_PORT)
	
	@echo "marp-cli server started at http://localhost:$(CONTAINER_PORT)"

# Build target (generates PDF files from slide-deck.md files)
build:
	./build.sh

# Dry run for build (shows what would be done without generating PDFs)
build-dry-run:
	./build.sh --dry-run

# Clean target (removes PDF files from all directories)
clean:
	$(FIND) . -name "*.pdf" -type f -delete
