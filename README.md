# brightkb-docker

Run BrightKB (https://brightkb.com/) in Docker: a small image, a 'compose.yaml'
and a helper script. Tested on a Synology NAS (x86-64), and it works on any
Linux host with Docker.

> **Unofficial.** This repository is not affiliated with BrightKB. It contains
> **no BrightKB binary and no knowledge modules**: you download them yourself
> from the official site, so you always get the original files under their own terms.

## What you need

- A Linux **x86-64** host (check with `uname -m`) with CLI access
- Docker and Docker Compose

## Quick start

```bash
git clone https://github.com/prablych/brightkb-docker.git
cd brightkb-docker
./get-brightkb.sh            # downloads the official binary into ./app
docker compose up -d --build
```

- Web UI: `http://localhost:8080`
- OpenAI-compatible API: `http://localhost:27495/v1` (any non-empty API key, model `ika-knowledge-base`)

Quick API check:

```bash
curl http://localhost:27495/v1/models
```

### Alternative manual setup (without the script)

1. Download the Linux binary from <https://brightkb.com/#download>.
2. Save it as `app/brightkb` and make it executable: `chmod 755 app/brightkb`.
3. Copy the example settings: `cp config.md.example app/config.md`.
4. `docker compose up -d --build`.

## Terms of use

BrightKB asks you to accept its terms of use (in the web UI: Settings >
Disclaimers). Read them yourself. For headless setups the program offers an
`--accept-terms` option; add it to `command:` in `compose.yaml` only after you
have read and agreed to the terms. This repository does not accept them for you.

## Modules

Modules are `.ikm` files (roughly 130-200 MB each). Two ways to add them:

- From the web UI, using the download buttons.
- Download the file yourself and drop it into `./app`, then `docker restart brightkb`.

## Why `api_host: 0.0.0.0` matters

By default BrightKB listens only on `127.0.0.1` **inside the container**. Docker
publishes the ports, but connections get reset (`Connection reset by peer`)
because nothing listens on the container's external interface. The bind address
is read from `config.md` (there is no command-line option), so the example file
sets:

```
api_host: 0.0.0.0
```

With this, both the web UI and the API listen on all interfaces. After starting,
`docker logs brightkb` should show `0.0.0.0` in the `LISTENING` block.


## Use with AI agents

The skills in OsintObserver/BrightKB-AI
(Claude Code, OpenAI Codex, Hermes Agent, Pi and OpenClaw) let an agent query
BrightKB through its OpenAI-compatible API.
It reads the BRIGHTKB_URL environment variable. By default it calls http://127.0.0.1:27495/v1, which only works when the agent runs on the same
machine as the container.
Where the agent runs
BRIGHTKB_URL
Same machine as the container
http://localhost:27495/v1 (the default)
Another computer on your network
http://<server-ip-or-name>:27495/v1
Another container on the same Docker network
http://brightkb:27495/v1

Set it in the environment of the agent, for example:
export BRIGHTKB_URL=http://192.168.1.50:27495/v1      # Linux / macOS (add it to ~/.bashrc to keep it)
setx BRIGHTKB_URL "http://192.168.1.50:27495/v1"      # Windows (open a new terminal afterwards)
Check that the agent's machine can reach the server:
curl "$BRIGHTKB_URL/models"
Then install the skill for your agent by following the instructions in that repository.
If an agent ignores the helper script and calls the API directly, tell it the URL
above, since the skill text mentions 127.0.0.1.


## Updates from the web UI

The UI can download new versions. The new binary is saved next to the launcher
as `BrightKB-x.y.z` (plus `.sig` files) in `./app`. On every start, `app/brightkb`
detects the newer version in the same folder and hands over to it, so updates
survive container restarts and no rebuild is needed.

- Old versions are not removed automatically. Once the new one works, you can
  delete the intermediate `BrightKB-*` files, but **keep `app/brightkb`** (the container starts it).
- To make the new version the launcher itself: stop the container, copy
  `app/BrightKB-x.y.z` over `app/brightkb`, and start again.
- The `--no-update-check` option in `compose.yaml` disables automatic checks.

## Permissions

The container runs as UID 1000 and needs write access to `./app` (settings,
modules, updates). If your user has another UID or you see write errors:

```bash
sudo chown -R 1000:1000 app
```

or build with another UID: `docker compose build --build-arg APP_UID=$(id -u)`.

## Synology notes

- Older Docker versions on DSM use the legacy builder (no BuildKit), so the
  Dockerfile avoids `COPY --chmod` on purpose.
- Synology ACLs can ignore a plain `chown`. If the container still cannot write
  to `app`, check `synoacltool -get <folder>`, or as a fallback add `user: "0:0"`
  to the service in `compose.yaml`.
- Allow TCP 8080 and 27495 in the DSM firewall if it is enabled.
- If port 8080 is taken by another service, change the left side, e.g. `"8085:8080"`.

## Security

The web UI and the API have **no authentication** (the API accepts any key).
Keep them on your local network. To reach them from outside, use a VPN or a
reverse proxy with authentication, not router port forwarding.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `Connection reset by peer` on 8080 / 27495 | `api_host: 0.0.0.0` missing in `app/config.md` |
| Container exits right away | `app/brightkb` missing or not executable |
| Cannot save settings or download modules | `./app` not writable by UID 1000 |
| Module copied by hand is not loaded | Restart the container; check the `loaded N modules` log line |

## License

The files in this repository (Dockerfile, `compose.yaml`, scripts and docs) are
released under the [MIT License](LICENSE).

BrightKB is a separate work with its own terms (section 7 of its terms of use):

- The program is offered under the
  [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0).
- The knowledge modules and the text BrightKB produces are offered under
  [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0).
- You may not sell it, charge for access to it, or include it in a paid product or service.
- When you publish content based on BrightKB, credit it: "Source: BrightKB.com", with a link where possible.

The MIT license applies only to the wrapper files here and does not change any of those terms.