# BUILD
ARG ARCH="sm_89"
FROM nvidia/cuda:13.0.3-devel-ubuntu24.04 AS build

ARG ARCH

WORKDIR /app
COPY Makefile Makefile
COPY cuda_hello.cu cuda_hello.cu

RUN make cuda_hello ARCH=${ARCH}

# RUNTIME
FROM nvidia/cuda:13.0.3-runtime-ubuntu24.04 AS runtime

WORKDIR /app/bin
COPY entrypoint.sh entrypoint.sh
COPY --from=build /app/cuda_hello cuda_hello

ENTRYPOINT ["/bin/bash", "/app/bin/entrypoint.sh"]
