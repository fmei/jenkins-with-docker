FROM docker:1.10.3
# Source: https://github.com/docker-library/docker/blob/2e8569cf5c665ef955855e95be475f52a55c0720/1.8/dind/Dockerfile

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apk add --update \
		btrfs-progs \
		e2fsprogs \
		iptables \
		xz \
		xfsprogs \
	&& rm -rf /var/cache/apk/*

# TODO aufs-tools

ENV DIND_COMMIT 4e899d64e020a67ca05f913d354aa8d99a341a7b

RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
	&& chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
