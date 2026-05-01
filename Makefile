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

NVCC_DEFAULT_ARCH := sm_75 sm_80 sm_86 sm_87 sm_88 sm_89 sm_90 sm_100 sm_110 sm_103 sm_120 sm_121

.PHONY: all clean check_arch docker $(NVCC_DEFAULT_ARCH)

all: check_arch cuda_hello

check_arch:
	@echo "==> Building with GPU arch: $(ARCH)"

cuda_hello: cuda_hello.cu
	$(NVCC) $(NVCCFLAGS) -o cuda_hello cuda_hello.cu

clean:
	rm -f cuda_hello

docker: $(NVCC_DEFAULT_ARCH)

$(NVCC_DEFAULT_ARCH):
	docker build --build-arg ARCH=$@ . -t danninx/cs-4373:hello-cuda-$@
	docker push danninx/cs-4373:hello-cuda-$@
