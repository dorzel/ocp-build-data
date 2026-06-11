# This is a base image that most rhel10-based containers should layer on.
FROM registry.redhat.io/rhel10-2-els/rhel-minimal@sha256:a7ea6d51d627e172783cf8f6a0b3edc2f8b817713368823ceb36f97339515b0f

# Start Konflux-specific steps
ENV ART_BUILD_ENGINE=konflux
ENV ART_BUILD_DEPS_METHOD=cachi2
ENV ART_BUILD_NETWORK=hermetic
RUN go clean -cache || true
ENV ART_BUILD_DEPS_MODE=default
USER 0
# End Konflux-specific steps
ENV __doozer=update BUILD_RELEASE=202606111208.p2.g8bafefc.assembly.test.el10 BUILD_VERSION=v5.0.0 OS_GIT_MAJOR=5 OS_GIT_MINOR=0 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=5.0.0-202606111208.p2.g8bafefc.assembly.test.el10 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-5.0 __doozer_key=openshift-base-rhel10 __doozer_uuid_tag=base-rhel10-v5.0.0-20260611.120841 __doozer_version=v5.0.0 
ENV __doozer=merge OS_GIT_COMMIT=8bafefc OS_GIT_VERSION=5.0.0-202606111208.p2.g8bafefc.assembly.test.el10-8bafefc SOURCE_DATE_EPOCH=1781095924 SOURCE_GIT_COMMIT=8bafefc66744b0fc5786dc3aaf1d7e19d085771d SOURCE_GIT_TAG=8bafefc66 SOURCE_GIT_URL=https://github.com/openshift-eng/ocp-build-data 
# we pin to a RHEL EUS (rhel-els) stream for stability.
# rhel10-els from rhel-els-container

# If we are build atop UBI or ELS minimal image, setup a link so that invocations of
# dnf and yum call microdnf instead.
COPY microdnf-wrapper.sh /usr/bin/microdnf-wrapper.sh
RUN chmod +x /usr/bin/microdnf-wrapper.sh
RUN if [ -x /usr/bin/microdnf ]; then \
      echo "microdnf detected: creating symlinks for dnf and yum"; \
      ln -sf /usr/bin/microdnf-wrapper.sh /usr/bin/dnf || true; \
      ln -sf /usr/bin/microdnf-wrapper.sh /usr/bin/yum || true; \
    else \
      echo "microdnf not found: skipping dnf/yum symlink creation"; \
    fi

RUN echo 'skip_missing_names_on_install=0' >> /etc/yum.conf \
 && yum update -y  \
 && yum clean all

# EUS / ELS images do not have repositories configured, and anyway they would
# not be publicly accessible without an enabled subscription. Insert public
# ubi10 repos in the base image so the end user can update all images easily.
COPY ubi.repo /etc/yum.repos.d/ubi.repo

LABEL \
        name="openshift/base-rhel10" \
        vendor="Red Hat, Inc." \
        cpe="cpe:/a:redhat:openshift:5.0::el10" \
        com.redhat.component="openshift-base-rhel10-container" \
        io.openshift.maintainer.project="OCPBUGS" \
        io.openshift.maintainer.component="Unknown" \
        version="v5.0.0" \
        release="202606111208.p2.g8bafefc.assembly.test.el10" \
        io.openshift.build.commit.id="8bafefc66744b0fc5786dc3aaf1d7e19d085771d" \
        io.openshift.build.source-location="https://github.com/openshift-eng/ocp-build-data" \
        io.openshift.build.commit.url="https://github.com/openshift-eng/ocp-build-data/commit/8bafefc66744b0fc5786dc3aaf1d7e19d085771d" \
        io.k8s.description="Empty" \
        io.k8s.display-name="Empty" \
        io.openshift.tags="Empty" \
        description="Empty" \
        summary="Empty"

