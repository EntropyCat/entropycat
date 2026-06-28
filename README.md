# EntropyCat

Real-time data quality agent for Kafka streams.

EntropyCat watches your stream as it flows — catching schema drift, null spikes, and
statistical anomalies at ingestion time — and surfaces them for review with a live dashboard
and optional Slack alerts.

---

## Quick start

**macOS**
```sh
brew install entropycat/tap/entropycat
entropycat init     # one-time setup wizard
entropycat start    # start the agent
```

**Linux**
```sh
curl -fsSL https://raw.githubusercontent.com/EntropyCat/entropycat/main/install.sh | sh
entropycat init
entropycat start
```

Once running, open the dashboard at **http://localhost:7070**.

---

## Requirements

- A **Kafka broker** to monitor — you'll enter its address during `entropycat init`.
- **macOS** or **Linux** (x86_64 or arm64). On **Windows**, use Docker or WSL.

---

## Installation

Pick whichever fits your platform:

| Platform | Recommended | Alternatives |
|----------|-------------|--------------|
| macOS    | Homebrew    | Install script, Docker |
| Linux    | Install script | Docker |
| Windows / any | Docker | — |

Each method below lists its full lifecycle: **install · upgrade · uninstall**.

### Homebrew (macOS)

```sh
# Install
brew install entropycat/tap/entropycat

# Upgrade
brew update && brew upgrade entropycat

# Uninstall (add the rm to also delete your config, logs, and snapshot)
brew uninstall entropycat
rm -rf ~/.entropycat
```

### Install script (macOS & Linux)

```sh
# Install (also used to upgrade — stop the agent first when upgrading)
curl -fsSL https://raw.githubusercontent.com/EntropyCat/entropycat/main/install.sh | sh

# Upgrade
entropycat stop
curl -fsSL https://raw.githubusercontent.com/EntropyCat/entropycat/main/install.sh | sh

# Uninstall
entropycat stop
sudo rm -rf /usr/local/bin/entropycat /usr/local/lib/entropycat
rm -rf ~/.entropycat
```

The script auto-detects your OS and architecture and installs the matching build to
`/usr/local/bin` (using `sudo` if that location isn't writable). 

### Docker (any platform)

Config is stored on a mounted volume (`~/.entropycat`) so it survives container restarts and
recreation.

```sh
# Install
docker pull entropycat/entropycat

# One-time setup (interactive wizard; writes config to the mounted volume)
docker run -it --rm -v ~/.entropycat:/root/.entropycat entropycat/entropycat init

# Run (detached; dashboard on http://localhost:7070)
docker run -d --name entropycat \
  -v ~/.entropycat:/root/.entropycat \
  -p 7070:7070 \
  entropycat/entropycat

# Upgrade (pull, then recreate the container — config persists on the volume)
docker pull entropycat/entropycat
docker stop entropycat && docker rm entropycat
docker run -d --name entropycat \
  -v ~/.entropycat:/root/.entropycat \
  -p 7070:7070 \
  entropycat/entropycat

# Uninstall
docker stop entropycat && docker rm entropycat
docker rmi entropycat/entropycat
rm -rf ~/.entropycat
```

> **Connecting to Kafka in another container:** put both on the same Docker network
> (`docker network create ec-net`, then `--network ec-net` on each) and use the Kafka
> container's name as the broker address during `init` (e.g. `kafka:9092`).

---

## Usage

### CLI (Homebrew / script installs)

```sh
entropycat init      # one-time setup wizard: pick a connector, enter Kafka brokers,
                     #   optionally connect Slack for alerts
entropycat start     # start the agent in the background
entropycat start -f  # start in the foreground (Ctrl+C to stop)
entropycat status    # show whether it's running, plus dashboard URLs
entropycat logs      # tail the log (live when running; last lines when stopped)
entropycat stop      # graceful shutdown
entropycat config    # open the config file in $EDITOR
entropycat reset     # remove all EntropyCat data (config, logs, snapshot)
entropycat --version
```

After `entropycat start`, the dashboard is available locally at **http://localhost:7070**, and
a shareable proxy URL is printed in the startup banner.

### Docker

The same commands work inside the container via `docker exec`:

```sh
docker exec -it entropycat entropycat status
docker exec -it entropycat entropycat logs

# Container lifecycle maps to start/stop
docker stop entropycat
docker start entropycat
docker logs -f entropycat     # follow the startup banner / server output
```
