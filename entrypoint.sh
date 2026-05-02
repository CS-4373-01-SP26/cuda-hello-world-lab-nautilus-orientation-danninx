#!/usr/bin/env bash
OUTPUT_DIR=/var/data/outputs

mkdir -p $OUTPUT_DIR

# nvidia info
nvidia-smi | tee $OUTPUT_DIR/gpu_info.txt
echo "-------------------------------------------------"

# initial runs
echo "running cuda_hello with 1 thread:"
/app/bin/cuda_hello 1 | tee $OUTPUT_DIR/run_1.txt
echo ""
echo "running cuda_hello with 5 thread:"
/app/bin/cuda_hello 5 | tee $OUTPUT_DIR/run_5.txt
echo ""
echo "running cuda_hello with 5 thread:"
/app/bin/cuda_hello 10 | tee $OUTPUT_DIR/run_10.txt
echo ""
echo "running cuda_hello with 5 thread:"
/app/bin/cuda_hello 32 | tee $OUTPUT_DIR/run_32.txt
echo ""

# repeated runs
echo "running cuda_hello with 10 threads many times:" > $OUTPUT_DIR/run_many.txt
for i in 1 2 3 4 5; do
    echo "--- run $i ---" >> $OUTPUT_DIR/run_many.txt
    /app/bin/cuda_hello 10 >> $OUTPUT_DIR/run_many.txt
done
