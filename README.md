# CS 4373/6373 — CUDA Hello World Lab

I designed a workflow that doesn't require me to make a Github PAT every time I want to work on the code.

Pros:
- I can submit the job and forget about the problem until later
- Results are persisted after the pod exits, and are easily aggregated with `kubectl cp`

Cons:
- I can only compile for my laptop/desktop's GPU for testing purposes (this wasn't a huge deal here, but might if compute capabilities differ by a large amount)

I build the docker containers locally to multiple architectures. Since docker's VFS will cache the base image this doesn't add too much time to the workflow per architecture, since only the compilation layer differs. I hosted the images on a [docker hub registry](https://hub.docker.com/repository/docker/danninx/cs-4373/tags), and tagged the images with both the problem and architecture. This allows me to choose my GPU ahead of time by targetting its architecture in the k8s manifests, which should produce more deterministic results.

(These are two separate targets because it made debugging more convenient)

```sh
make build-docker
make push-docker
```

Run the job:

```sh
kubectl apply -f k8s/pvc.yaml k8s/job.yaml
```

Once the job is done (it will be marked complete; check with `kubectl get job -n tandy-hpc`), mount the pvc to a temp pod to copy results:

```sh
kubectl apply -f k8s/inspector.yaml
kubectl cp output-viewer:/var/data/outputs ./outputs
```
(Just a heads up, if your results include very large datasets this is probably a bad idea as it will throttle the kube-api server on whatever node the pod/pvc are on; should probably instead mount the pvc to a container with s3 tools and push it to a separate bucket with better throughput; it's ok here because the outputs are very small)

Cleanup all resources, since this isn't our hardware:

```sh
bash ./cleanup.sh
```
