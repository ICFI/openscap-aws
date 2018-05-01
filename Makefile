#
# Use Docker to build both docs and RPM binary
#

DOCKER := $(shell command -v docker 2> /dev/null)

all: docs rpm

# Build documentation into /docs directory for use with GitHub pages
docs:
ifdef DOCKER
	@docker run \
		-it --rm \
		-v "$$(pwd)/src/docs:/documents" \
		-v "$$(pwd)/docs:/docs-output" \
		asciidoctor/docker-asciidoctor /documents/build-docs.sh
endif
ifndef DOCKER
	@echo "docker binary not found"
endif	

# Build RPM
rpm:
ifdef DOCKER
	@docker run -it --rm -v "$$(pwd)/src/rpm:/src" centos:7 /src/build-rpm.sh
endif
ifndef DOCKER
	@echo "docker binary not found"
endif

# Clean up RPM build directories
clean:
	@rm -rf src/rpm/BUILDROOT/ src/rpm/BUILD/ src/rpm/RPMS/ src/rpm/SRPMS/

.PHONY: all docs clean