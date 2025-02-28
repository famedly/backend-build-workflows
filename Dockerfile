FROM docker-nightly.nexus.famedly.de/rust-container:dev-tlater-entrypoint AS test-builder

# TODO: We currently cannot mount the repo because of
# https://github.com/nextest-rs/nextest/issues/2066
#
# In the future, it would however be nice to use `--mount=target/repo`
# instead of copying.
COPY . /repo
WORKDIR /repo
RUN \
	--mount=type=cache,target=/build \
	--mount=type=cache,target=/cargo \
	export CARGO_TARGET_DIR=/build && \
	export CARGO_HOME=/cargo && \
	git archive HEAD --output=/git.tar && \
	cargo nextest archive --profile e2e --archive-file /tests.tar.zst

FROM docker-nightly.nexus.famedly.de/rust-container:dev-tlater-entrypoint AS test

RUN \
	--mount=from=test-builder,source=/git.tar,target=/git.tar \
	mkdir -p /repo && \
	tar xf /git.tar -C /repo
COPY --from=test-builder /tests.tar.zst /tests.tar.zst

CMD cargo nextest run --profile e2e --archive-file /tests.tar.zst --workspace-remap /repo

FROM debian:bookworm-slim
CMD ["/usr/local/bin/bash"]
