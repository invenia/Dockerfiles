Dockerfile Guide
================

[Docker](https://www.docker.com/products/overview) is essentially a manager for light-weight Linux virtual machines.

To get started see [our Docker documentation in the wiki](https://gitlab.invenia.ca/invenia/wiki/blob/master/setup/docker.md)

The documentation contained here is meant to assist users in common use cases when interacting with this repository.

## Command Overview

- `docker build -t julia-src:1.0 julia-src`: Executes the instructions within "julia-src/Dockerfile" to create a Docker image and tags the image with repo "julia-src" tag "1.0".
- `docker build --no-cache -t julia-src:1.0 julia-src`: Similar to above but does not reuse any previously built steps. Useful there is a package update Docker is ignoring.
- `docker tag <image_id> julia-src:1.0`: Apply a tag to an already built image
- `docker run -it --rm julia-src bash`: Creates a Docker container and starts an interactive bash session. Once the bash session exits the container will be removed (--rm)

## Dockerfile Hints

### Syntax Highlighting

Sublime Text provides syntax highlighting for the Dockerfile using the plugin
"Dockerfile Syntax Highlighting" using Package Control.

### Faster builds
Using multiple processors for the Docker host (on older versions of Docker the VM) can
significantly decrease build times. It is recommended that you at least use 2 processors for
the Docker host. On Docker for Mac you can adjust this by launching Docker.app opening
Preferences then Advanced and modifying the CPUs slider.

### Small Images
An important fact about Docker is that each RUN command is treated as a new layer in the
image. This means if you add a file in one RUN command and then delete it later in a
later RUN command the overall image size will still contain the data of the deleted file
(similar to how version control systems work). In order to work around this problem you
should make sure to cleanup temporary files and data within the same RUN command.

An unfortunate side effect of this approach is that it makes the content of the Dockerfile
less readable but can considerably reduce the image size. For example, the "julia-0.5.0"
Docker image was >5GB but after switching to this technique it dropped to ~1.2GB.

http://developers.redhat.com/blog/2016/03/09/more-about-docker-images-size/

#### Yum

The package manager `yum` does not appear to have a way to "pin" packages. However any
package explicitly installed will not be automatically removed as a dependency. For example
the package "gcc-c++" has the dependency "libstdc++48-devel":

```bash
yum -y install libstdc++48-devel  # Mark package as explicitly installed
yum -y install gcc-c++            # gcc-c++ depends on libstdc++48-devel
yum -y autoremove gcc-c++         # Removes gcc-c++ and dependecies except for libstdc
yum -y install libstdc++48-devel  # States: "nothing to do"
```

If instead we wrote the following we could accidently remove a package we inteaded to keep:

```bash
yum -y install gcc-c++            # gcc-c++ installs dependency libstdc++48-devel
yum -y install libstdc++48-devel  # States that there is "nothing to do"
yum -y autoremove gcc-c++         # Since we didn't actually install libstdc++48-devel above it will be removed
yum -y install libstdc++48-devel  # Installs the package
```

The ideal form of this is:

```bash
yum -y install gcc-c++ libstdc++48-devel  # Explicitly installs both packages
yum -y autoremove gcc-c++                 # Removes gcc-c++ without removing libstdc++48-devel
yum -y install libstdc++48-devel          # States: "nothing to do"
```

Alternatively you could do:

```bash
yum -y install gcc-c++
yum -y install libstdc++48-devel
yumdb set reason user libstdc++48-devel  # yumdb requires yum-utils
yum -y autoremove gcc-c++
```

So far none of these solutions protect us from accidentally removing a package by accident
or from removing a dependency of a package we want to keep. For this we can use a yum
feature called protected packages:

```bash
# Require package permanently
yum -y install libstdc++48-devel
echo "libstdc++48-devel" > /etc/yum/protected.d/demo.conf

# Only requires package temporarily
yum -y install libstdc++48-devel
yum -y autoremove libstdc++48-devel  # Produces an exception `Error: Trying to remove "X", which is protected`
```

In our use case with Docker we want to ignore packages that can be uninstalled because they
are protected:

```bash
# Require package permanently
yum -y install libstdc++48-devel
echo "libstdc++48-devel" > /etc/yum/protected.d/demo.conf

# Only requires package temporarily
yum -y install libstdc++48-devel
for p in "libstdc++48-devel"; do yum -y autoremove $p || true; done
```

### Variables
Remember that Docker isn't Bash. Use of Docker variables created with ENV can contain
whitespace and will be replaced exactly how they were written. For example the following
instructions:

```
ENV PKGS gcc g++ gfortran
RUN apt-get update && apt-get install -y --no-install-recommends $PKGS && ...
```

When interpreted by Docker are equivalent to:

```
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ gfortran && ...
```
