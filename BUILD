load("@pip_deps//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_binary")
load("@io_bazel_rules_docker//python3:image.bzl", "py3_image")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//container:image.bzl", "container_image")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_commit")
load("@io_bazel_rules_docker//container:bundle.bzl", "container_bundle")
load("@io_bazel_rules_docker//contrib:push-all.bzl", "container_push")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@k8s_service//:defaults.bzl", "k8s_service")
load("@k8s_ingress//:defaults.bzl", "k8s_ingress")

NAME = "fernet-solver"

DEPS = [
    requirement("Flask"),
    requirement("cryptography"),
    requirement("msgpack-python"),
    requirement("gunicorn"),
    requirement("Jinja2"),
    requirement("MarkupSafe"),
    requirement("Werkzeug"),
    requirement("itsdangerous"),
    requirement("click"),
    requirement("six"),
]

py_binary(
    name = "app",
    srcs = [":app.py"],
    python_version = "PY3",
    deps = DEPS,
)

# Package requirements.txt into a tar so we can load it into the container
# image.
pkg_tar(
    name = "py_requirements",
    srcs = ["//:requirements.txt"],
    mode = "0644",
    package_dir = "/etc",
    visibility = ["//visibility:private"],
)

container_image(
    name = "python3.8.5_base_image",
    base = "@python3.8.5_buster//image",
    creation_time = "{BUILD_TIMESTAMP}",
    stamp = True,
    # slim-buster image places python3 under /usr/local/bin, but the host
    # toolchain used by py3_image might use /usr/bin instead.
    symlinks = {
        "/usr/bin/python": "/usr/local/bin/python",
        "/usr/bin/python3": "/usr/local/bin/python3",
    },
    tars = [":py_requirements"],
    visibility = ["//visibility:private"],
)

container_run_and_commit(
    name = "python3.8.5_base_image_with_deps",
    commands = [
        "pip3 install -r /etc/requirements.txt",
    ],
    image = "python3.8.5_base_image.tar",
    visibility = ["//visibility:private"],
)

py3_image(
    name = "app_image",
    srcs = ["app.py"],
    base = ":python3.8.5_base_image_with_deps",

    # Bazel injected init files can break python import.
    # https://github.com/bazelbuild/rules_python/issues/55
    legacy_create_init = False,
    main = "app.py",

    # Internal dependencies go here.
    # External dependencies are handled by pip install in the container.
    deps = [],
)

container_image(
    name = "image",
    base = ":app_image",
    stamp = False,
    visibility = ["//visibility:public"],
)

container_bundle(
    name = "bundle",
    images = {
        "{STABLE_DOCKER_REPO}/" + NAME + ":{DOCKER_TAG}": ":image",
        "{STABLE_DOCKER_REPO}/" + NAME + ":latest": ":image",
    },
)

container_push(
    name = "push",
    bundle = ":bundle",
    format = "Docker",
)

k8s_deploy(
    name = "deployments",
    images = {
        "docker.io/leoh0" + "/" + NAME + ":latest": ":image",
        #"{STABLE_DOCKER_REPO}/" + NAME + ":latest": ":image",
    },
    template = ":base/deployment.yaml",
)

k8s_service(
    name = "services",

    # A template of a Kubernetes Deployment object yaml.
    template = "base/service.yaml",
)

k8s_ingress(
    name = "ingresses",
    substitutions = {
        "%{ingress}": "$(ingress_domain)",
    },

    # A template of a Kubernetes Deployment object yaml.
    template = "base/ingress.yaml",
)

k8s_objects(
    name = "k8s",
    objects = [
        ":deployments",
        ":services",
        ":ingresses",
    ],
)
