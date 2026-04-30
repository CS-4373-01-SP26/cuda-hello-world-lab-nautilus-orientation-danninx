# CS 4373/6373 — High Performance Computing
## Lab: CUDA Hello World on Nautilus
### Your First GPU Program on a Kubernetes Cluster — Student Instructions

**Points:** 25
**Code submission:** GitHub Classroom (push your repo to trigger the build check)
**Written reflection:** Harvey (one page, PDF)

---

## What This Lab Is About

This is an orientation lab with three goals:

1. Configure `kubectl` and connect to the Nautilus GPU cluster.
2. Launch a GPU pod in the `tandy-hpc` namespace, compile
   `cuda_hello.cu`, and run it on real GPU hardware.
3. Answer five reflection questions grounded in your actual
   observations.

By the end you will have completed the full Nautilus/Kubernetes
workflow that all subsequent GPU assignments use.

---

## The Program

`cuda_hello.cu` is Program 6.1 from Pacheco §6.4.1:

```c
__global__ void Hello(void) {
    printf("Hello from thread %d!\n", threadIdx.x);
}

int main(int argc, char* argv[]) {
    int thread_count = strtol(argv[1], NULL, 10);
    Hello <<<1, thread_count>>>();
    cudaDeviceSynchronize();
    return 0;
}
```

Each GPU thread runs a copy of `Hello` and prints its rank.
`cudaDeviceSynchronize()` forces the CPU to wait for all GPU threads
to finish before the program exits. You will not modify this file.

---

## Part 1: Accept the Assignment and Set Up kubectl

### Step 1.1 — Accept the GitHub Classroom Assignment

Click the invitation link provided by your instructor. A private
repository will be created for you at:
`github.com/YOUR_ORG/hello-cuda-YOUR_USERNAME`

Clone it locally:
```bash
git clone https://github.com/YOUR_ORG/hello-cuda-YOUR_USERNAME.git
cd hello-cuda-YOUR_USERNAME
```

### Step 1.2 — Install kubectl and Configure Nautilus Access

Follow the separate **kubectl Setup Guide** (provided by the
instructor as a PDF) to:

- Install kubectl on your local machine
- Install kubelogin (required for NRP authentication)
- Download the config file: `curl -o ~/.kube/config -fSL "https://nrp.ai/config"`
- Place it at `~/.kube/config` with `chmod 600`

Verify access:
```bash
kubectl get pods -n tandy-hpc
```
Expected: `No resources found in tandy-hpc namespace.`

### Step 1.3 — Find Your NRP Username

You will need your NRP username to fill in the pod YAML. Run:
```bash
kubectl auth whoami
```
or:
```bash
kubectl config view --minify -o jsonpath='{.users[0].name}'
```

### Step 1.4 — Create a GitHub Personal Access Token (PAT)

You will need this to clone your private repo from inside a pod.

1. github.com → Settings → Developer settings → Personal access tokens
   → Tokens (classic) → **Generate new token (classic)**
2. Set expiration: at least 30 days past the due date
3. Check the **repo** scope
4. Click **Generate token** and copy it immediately
5. Store it in a password manager or secure note

Never commit this token to any file. Use it only in shell commands
inside pod sessions.

---

## Part 2: Launch a GPU Pod

### Step 2.1 — Edit the Pod YAML

Open `k8s/gpu-dev-pod.yaml` and replace the placeholder with your
NRP username (found in Step 1.3 above):

```yaml
labels:
  user: CHANGE_TO_YOUR_NRP_USERNAME    # change this
```

Save the file. You do not need to commit this change.

### Step 2.2 — Launch the Pod

```bash
kubectl apply -f k8s/gpu-dev-pod.yaml -n tandy-hpc
```

Watch until the pod is Running:
```bash
kubectl get pods -n tandy-hpc -w
```
Press Ctrl-C once you see `STATUS = Running`.
This usually takes 30–90 seconds.

> **⚠ Critical: 6-Hour Hard Limit**
> The Nautilus cluster automatically deletes interactive pods after
> **6 hours**. There is no warning. If you are mid-session and the
> 6 hours pass, your pod simply vanishes.
>
> Because your code lives in GitHub (not in the pod), **nothing is
> lost as long as you pushed before the limit**. Make it a habit:
> push to GitHub before every break, even a short one.

### Step 2.3 — Open an Interactive Shell

```bash
kubectl exec -it hello-dev-pod -n tandy-hpc -- /bin/bash
```

Your terminal prompt becomes `root@hello-dev-pod:/#`.
You are now running commands on the GPU node.

---

## Part 3: Set Up the Environment Inside the Pod

### Step 3.1 — Install Tools

```bash
apt-get update && apt-get install -y git make
```

### Step 3.2 — Verify the GPU

```bash
nvidia-smi
```

You should see a table showing the GPU model, driver version, and
memory. **Note the GPU model name** — you will need it for reflection
question Q1.

Also verify nvcc is available:
```bash
nvcc --version
```

---

## Part 4: Clone Your Repo and Build

### Step 4.1 — Configure git

```bash
git config --global user.email "you@utulsa.edu"
git config --global user.name  "Your Name"
```

### Step 4.2 — Clone Using Your PAT

Replace the placeholders with your actual values:

```bash
git clone https://YOUR_TOKEN@github.com/YOUR_ORG/hello-cuda-YOUR_USERNAME.git \
    /workspace
cd /workspace
```

### Step 4.3 — Build

```bash
make
```

The Makefile detects the GPU architecture automatically and passes
the correct `-arch=sm_XX` flag to nvcc. You should see:

```
==> Building with GPU arch: sm_80
nvcc -arch=sm_80 -O2 -o cuda_hello cuda_hello.cu
```

---

## Part 5: Run the Program

Try the following thread counts and **observe the output carefully**.
You will answer questions about what you see.

```bash
./cuda_hello 1
./cuda_hello 5
./cuda_hello 10
./cuda_hello 32
```

Now run the 10-thread version several times in a row:

```bash
for i in 1 2 3 4 5; do
    echo "--- run $i ---"
    ./cuda_hello 10
done
```

**Save your output.** Redirect it to a file you can copy later:
```bash
./cuda_hello 10 | tee run_10.txt
nvidia-smi | tee gpu_info.txt
```

---

## Part 6: Push Your Code

Since `cuda_hello.cu` is unchanged, use `--allow-empty` to trigger
the build check:

```bash
cd /workspace
git commit --allow-empty -m "Ran CUDA hello world on Nautilus"
git push origin main
```

After pushing, go to your GitHub repo → **Actions** tab. A green
check means your code compiles correctly on GitHub's servers.

> **Note:** GitHub's free runners have no GPU, so the workflow only
> compiles the code — it does not run it. The GPU execution you did
> on Nautilus is what counts for this lab.

---

## Part 7: Delete Your Pod

**Always do this when you are done.** GPU resources are shared.

```bash
# Exit the pod shell first
exit

# Then delete from your local terminal
kubectl delete pod hello-dev-pod -n tandy-hpc

# Confirm it is gone
kubectl get pods -n tandy-hpc
```

---

## Part 8: Written Reflection (submit via Harvey, 1 page max)

Answer all five questions. Include specific output from your Nautilus
session as evidence where asked.

**Q1.** What GPU model was allocated to your pod? What is its compute
capability (the sm_XX number)? How many streaming multiprocessors (SMs)
and CUDA cores does it have? (Look up the spec sheet for the model name
shown by `nvidia-smi`.)

**Q2.** When you ran `./cuda_hello 10` multiple times, did the threads
always print their greetings in order (thread 0 first, then 1, 2, ...)?
Paste your loop output as evidence. Based on Pacheco §6.4–6.5, why
might the output order vary — or why might it always be the same?

**Q3.** The kernel is launched with `<<<1, thread_count>>>`. What does
the `1` represent? If you changed the launch to `<<<2, thread_count/2>>>`
for an even `thread_count`, what would change about the output? (Reason
from §6.6 — you do not need to modify and rerun the code.)

**Q4.** Experiment: what is the largest `thread_count` you can pass
before the program fails to produce output or crashes? What CUDA limit
does this correspond to? (See §6.7, Table 6.3 and the compute
capability of your GPU.)

**Q5.** Why is `cudaDeviceSynchronize()` necessary in `main`? What
would happen if it were removed? (Reason from §6.5 — do not modify
the code to test this.)

---

## Grading Rubric

| Component | Points | How Graded |
|-----------|--------|-----------|
| Code compiles (GitHub Actions build check) | 5 | Automated |
| Evidence of running on Nautilus (output in reflection) | 1 | Reflection |
| Q1 — GPU model and specs | 3 | Reflection |
| Q2 — Output ordering observation and explanation | 4 | Reflection |
| Q3 — Block count explanation | 4 | Reflection |
| Q4 — Max thread count and limit identification | 4 | Reflection |
| Q5 — cudaDeviceSynchronize explanation | 4 | Reflection |
| **Total** | **25** | |

---

## Troubleshooting

**Pod denied with admission webhook error:**
The namespace metadata is incomplete. The instructor needs to fill in
the description, institution, publications, and software fields at
https://nrp.ai/namespaces before pods can be created.

**Pod stuck Pending for more than 5 minutes:**
```bash
kubectl describe pod hello-dev-pod -n tandy-hpc
```
Look at the Events section. `Insufficient nvidia.com/gpu` means all
GPU slots are in use. Wait 10–15 minutes or notify the instructor.

**`nvidia-smi: command not found` inside the pod:**
The node may have lost its GPU between scheduling and execution.
Exit, delete the pod, and re-apply to get rescheduled.

**Build fails with `no kernel image available`:**
The auto-detected arch may be wrong. Check manually:
```bash
nvidia-smi --query-gpu=compute_cap --format=csv,noheader
# e.g., 8.0  ->  sm_80
make ARCH=sm_80
```

**`git push` prompts for a password:**
Enter your GitHub PAT (not your GitHub account password).

**The pod was deleted before I pushed my code:**
The 6-hour limit was reached. If you had local edits inside the pod
that were not pushed, they are gone. Always push before leaving a
session. Going forward, edit locally and only use the pod to run code.

---

## Quick kubectl Reference

```bash
# Launch pod
kubectl apply -f k8s/gpu-dev-pod.yaml -n tandy-hpc

# Watch pod status
kubectl get pods -n tandy-hpc -w

# Open shell in pod
kubectl exec -it hello-dev-pod -n tandy-hpc -- /bin/bash

# See events (troubleshoot a stuck pod)
kubectl describe pod hello-dev-pod -n tandy-hpc

# Stream logs
kubectl logs -f hello-dev-pod -n tandy-hpc

# DELETE WHEN DONE
kubectl delete pod hello-dev-pod -n tandy-hpc
```
