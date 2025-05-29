FROM debian:bookworm-slim AS base
CMD ["/usr/local/bin/bash"]

FROM base AS foo
CMD echo "foo"

FROM base AS bar
CMD echo "bar"
