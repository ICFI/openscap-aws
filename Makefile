DOCKER := $(shell command -v docker 2> /dev/null)

all:
ifdef DOCKER
	@docker run -it --rm -v "$$(pwd):/src" centos:7 /src/build-rpm.sh
endif
ifndef DOCKER
	@echo "docker binary not found"
endif

clean:
	@rm -rf BUILDROOT/ BUILD/ RPMS/ SRPMS/
