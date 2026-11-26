FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# UID/GID of the user inside the container. It must be able to write to ./app
ARG APP_UID=1000
RUN useradd -m -u ${APP_UID} app

USER app
WORKDIR /opt/brightkb

EXPOSE 8080 27495

# The BrightKB binary is NOT part of the image: it lives in ./app (mounted volume)
ENTRYPOINT ["/opt/brightkb/brightkb"]
