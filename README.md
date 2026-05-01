[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/TGoMac6g)
# CS 4373/6373 — CUDA Hello World Lab

See [docs/student-instructions.md](docs/student-instructions.md)
for complete step-by-step instructions.

theory crafting a workflow that doesn't require me to put my GH token in a pod every time i wanna work on this

Run the job:

```sh
kubectl apply -f k8s/pvc.yaml k8s/job.yaml
```

Once the job is done, mount the pvc to a temp pod to view results:

```sh
kubectl apply -f k8s/inspector.yaml
kubectl exec -it <pod_name> -- /bin/sh

# cat /var/data/outputs/hello_cuda.out
```

Cleanup

```sh
bash ./cleanup.sh
```
