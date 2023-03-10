Julia Baked
===========

The "julia-baked" folder contains the resources for building a Docker image including:

- Amazon Linux environment
- Julia official binary
- Invenia's private METADATA repository
- The "Julia Deploy" key for passwordless SSH access to select GitLab repos
- The "update-metadata" script which assists in the `Pkg.update()` process
- Sets `JULIA_NUM_THREADS`

The resulting Docker image is meant as the parent for Julia applications and packages.

## Usage

Unless you need to modify the Dockerfile or other resources in this file you can just
download the latest image from the container registry instead of building the image
yourself:

```bash
docker pull 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.7.3
docker tag 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.7.3 julia-baked:1.7.3
docker tag julia-baked:1.7.3 julia-baked:1.7
```

Note that the `--registry-ids` option is required for cross-account access, and this will only
work if your account has been granted permissions on the repository to pull from it.

To run the image locally you can run:

```bash
docker run -it --rm julia-baked:1.7.3       # Run Julia interactively
docker run -it --rm julia-baked:1.7.3 bash  # Run Bash interactively
```

## Building

If you need to make modifications to the image to say update a requirement or just update
the revision of the code within the image you'll need to re-build the image. This image
_requires_ that you manually fetch or build its parent: [julia-bin:1.7.3](../julia-bin).

```bash
time docker build -t julia-baked:1.7.3 ./julia-baked
```

If the newly build image needs to be made generally available you should push the image to
the Amazon container registry. Note if an existing image with the same name and tag exists
the newly pushed image will override the old name:tag.

```bash
docker tag julia-baked:1.7.3 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.7.3
docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.7.3

# Update floating tag(s)
docker tag julia-baked:1.7.3 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.7
docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-baked:1.7
```
