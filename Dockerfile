# CUDA 13.0.3
# assumes arch=sm_89
FROM nvidia/cuda:13.0.3-devel-ubuntu24.04 AS build

WORKDIR /app
COPY cuda_hello.cu cuda_hello.cu

RUN make cuda_hello ARCH=sm_89

FROM nvidia/cuda:13.0.3-runtime-ubuntu24.04 AS runtime
WORKDIR /app
COPY --from=build /app/cuda_hello /app/bin/cuda_hello
CMD ["/app/bin/cuda_hello"]
