Guide to ECS
============

[Amazon EC2 Container Service (ECS)](https://aws.amazon.com/ecs/) is a way of running Docker
images within the AWS framework. You should already be familiar with [Docker](docker.md)
before reading this guide as many of the core concepts are from Docker. [Official ECS
documentation](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) will
go into more depth about the service.

## Registry

In order to run a container within ECS we need to register our Docker images with the
[Amazon EC2 Container Registry (ECR)](https://aws.amazon.com/ecr/) which works similarly to
[Docker Hub](https://hub.docker.com/).

Docker images need to be registered with a named repository. New repositories can be created
from the AWS console under [ECS > Repositories](https://console.aws.amazon.com/ecs/home?region=us-east-1#/repositories).
It is recommended that repository names match between your local images and ECR. Examples of
repository names include: julia, julia-baked, and eis.

To register/push your local image follow the "View Push Commands" under the specific
repository you wish to push for. It is recommended that step 4 and 5 use a version number
rather than just "latest". For example to push the "julia:1.0" image to the "julia"
repository with the "1.0" image tag the instructions are:

```bash
docker tag julia:1.0 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia:1.0
docker push 111111111111.dkr.ecr.us-east-1.amazonaws.com/julia:1.0
```
These instructions can be re-used for other repos by just replacing "julia:1.0" with the
repo and tag you wish to push.

## Task Definition

[Task Definitions](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_defintions.html)
allow you to specify container properties such as CPU and memory allocation. Essentially the
task definition is a configuration file containing most of the
[command-line options from `docker run`](https://docs.docker.com/engine/reference/commandline/run/).

Task definitions are versioned in ECS and are grouped by task definition name (also know as
"family" in JSON). Please note that the revision number cannot be specified and will be
unique and never repeated if a task definition is deregistered. For example if you created
task definition "demo" it would be registered as "demo:1". If you then deregistered "demo:1"
and register a new "demo" it would be registered as "demo:2".

When creating a new task definition you should make sure to commit the definition as JSON
in the appropriate directory as a "taskdef.json" file.

Resources on task definition parameters can be found in the documentation:
- [Task Definition Examples](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/example_task_definitions.html)
- [Task Definition Parameters](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
- [Docker Run](https://docs.docker.com/engine/reference/run)
