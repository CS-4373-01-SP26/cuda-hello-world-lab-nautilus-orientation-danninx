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

.PHONY: all clean check_arch docker

all: check_arch cuda_hello

check_arch:
	@echo "==> Building with GPU arch: $(ARCH)"

cuda_hello: cuda_hello.cu
	$(NVCC) $(NVCCFLAGS) -o cuda_hello cuda_hello.cu

clean:
	rm -f cuda_hello

docker:
	docker build -t danninx/cs-4373:hello-cuda
	docker push danninx/cs-4373:hello-cuda
