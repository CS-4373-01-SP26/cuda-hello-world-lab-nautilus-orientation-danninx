# Makefile — CS 4373/6373  CUDA Hello World Lab
#
# Usage:
#   make         build cuda_hello
#   make clean   remove binary
#
# GPU arch is auto-detected via nvidia-smi; override with:
#   make ARCH=sm_80

NVCC      := nvcc
ARCH      ?= $(shell nvidia-smi --query-gpu=compute_cap \
               --format=csv,noheader 2>/dev/null \
               | head -1 | tr -d '.' | sed 's/^/sm_/' || echo sm_70)
NVCCFLAGS := -arch=$(ARCH) -O2

# default nvcc architectures in cuda toolkit docker image
NVCC_DEFAULT_ARCH := sm_75 sm_80 sm_86 sm_87 sm_88 sm_89 sm_90 sm_100 sm_110 sm_103 sm_120 sm_121
DOCKER_BUILD_TARGETS := $(addprefix docker-build-, $(NVCC_DEFAULT_ARCH))
DOCKER_PUSH_TARGETS  := $(addprefix docker-push-, $(NVCC_DEFAULT_ARCH))

.PHONY: all clean check_arch build-docker push-docker $(DOCKER_BUILD_TARGETS) $(DOCKER_PUSH_TARGETS)

all: check_arch cuda_hello

check_arch:
	@echo "==> Building with GPU arch: $(ARCH)"

cuda_hello: cuda_hello.cu
	$(NVCC) $(NVCCFLAGS) -o cuda_hello cuda_hello.cu

clean:
	rm -f cuda_hello

build-docker: $(DOCKER_BUILD_TARGETS)
push-docker: $(DOCKER_PUSH_TARGETS)

$(DOCKER_BUILD_TARGETS): docker-build-%:
	docker build --build-arg ARCH=$* . -t danninx/cs-4373:hello-cuda-$*

$(DOCKER_PUSH_TARGETS): docker-push-%:
	docker push danninx/cs-4373:hello-cuda-$*
