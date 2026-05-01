# defaults to arch=sm_89
ARG ARCH="sm_89"

# CUDA 13.0.3
FROM nvidia/cuda:13.0.3-devel-ubuntu24.04 AS build

ARG ARCH

WORKDIR /app
COPY Makefile Makefile
COPY cuda_hello.cu cuda_hello.cu

RUN make cuda_hello ARCH=${ARCH}

FROM nvidia/cuda:13.0.3-runtime-ubuntu24.04 AS runtime
WORKDIR /app
COPY --from=build /app/cuda_hello /app/bin/cuda_hello
CMD ["/app/bin/cuda_hello"]
