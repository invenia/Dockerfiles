Julia GitLab CI
===============

The "julia-gitlab-ci" image extends the "julia-baked" image and adds the support for the following:

- Rendering coverage reports as HTML
- Julia packages depending on BinDeps.jl
- Command line `git` which improves runtime of Coverage.jl
- CI authentication with GitLab via the `gitlab-ci-credential` helper
- Exporting the name of the package being tested in GitLab CI via the `PKG_NAME` variable
- Displaying Julia's `versioninfo()` at the start of a CI job

The resulting Docker image is meant to be used by GitLab CI jobs for testing Julia packages.

## Usage

Unless you need to modify the Dockerfile or other resources in this file you can just
download the latest image from the container registry instead of building the image
yourself:

```bash
docker pull 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-gitlab-ci:1.7.3
docker tag 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-gitlab-ci:1.7.3 julia-gitlab-ci:1.7.3
```

To run the image locally you can run:

```bash
docker run -it --rm julia-gitlab-ci:1.7.3  # Run Julia interactively
```

## Building

If you need to make modifications to the image to say update a requirement or just update
the revision of the code within the image you'll need to re-build the image. This image
_requires_ that you manually fetch or build its parent: [julia-baked](../julia-baked).

```bash
time docker build -t julia-gitlab-ci:1.7.3 ./julia-gitlab-ci
```

If the newly build image needs to be made generally available you should push the image to
the Amazon container registry. Note if an existing image with the same name and tag exists
the newly pushed image will override the old name:tag.

```bash
docker tag julia-gitlab-ci:1.7.3 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-gitlab-ci:1.7.3
docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-gitlab-ci:1.7.3

# Update floating tag(s)
docker tag julia-gitlab-ci:1.7.3 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-gitlab-ci:1.7
docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia-gitlab-ci:1.7
```
