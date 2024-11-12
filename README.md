<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Fediverse](https://chaos.social/@medienhaus)

<br>

# rpi-spaces-nextcloud-setup

This repository contains configuration files, some explanations, and some instructions for a *customized* containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [matrix-synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [lldap](https://github.com/lldap/lldap), and additionally [nextcloud](https://github.com/nextcloud/docker).


## infrastructure overview

For [Klasse Klima](https://klasseklima.org/), we strive to self-host a communication and collaboration environment/infrastructure with full control over our data, i.e. we don’t want to store any data in *the cloud*. We do need at least one public IP address for making our services accessible via the internet; this public IP address could be provided by some (virtual private) server or virtual machine in *the cloud*, which creates an encrypted [WireGuard](https://www.wireguard.com/) *tunnel* and serves as reverse proxy, securely forwarding external traffic to our locally self-hosted infrastructure.

In our first proof-of-concept and momentarily to be evaluated prototype, we are using a small travel router running [OpenWrt](https://openwrt.org/), serving as a firewall, and routing our traffic; these tasks could also be taken care of by e.g. [OPNsense](https://opnsense.org/). Running our services, and hosting/storing our data, are two Raspberry Pi 5 single-board computers — in the future being solar-powered — which are connected via the [Docker](https://www.docker.com/) [*overlay network driver*](https://docs.docker.com/engine/network/drivers/overlay/).

**NOTE:** We are using Docker’s [*swarm mode*](https://docs.docker.com/engine/swarm/) to establish a connections between both our Raspberry Pi 5 single-board computers; **however**, we don’t use any swarm features but instead [use an overlay network for standalone containers](https://docs.docker.com/engine/network/tutorials/overlay/#use-an-overlay-network-for-standalone-containers) and manually, via Docker [*compose*](https://docs.docker.com/compose/) files, [attach containers to an overlay network](https://docs.docker.com/engine/network/drivers/overlay/#attach-a-container-to-an-overlay-network).

## instructions

0. Create and join the Docker overlay network; see the documentation linked in the **NOTE** above.
   <details>
   <summary>
   🗯️ I have read the documentation, just show me the necessary commands already!
   </summary>

   <br>

   [Install Docker …](https://docs.docker.com/engine/install/)

   On the **first** Raspberry Pi 5 single-board computer hosting `medienhaus-docker`:

   ```bash
   docker swarm init
   ```

   *This returns the command for the **second** Raspberry Pi to join the Docker swarm.*

   ```bash
   docker network create --driver=overlay --attachable --opt encrypted overlay
   ```

   On the **second** Raspberry Pi 5 single-board computer hosting `nextcloud`:

   ```bash
   docker swarm join --token <TOKEN> <IP_OF_FIRST_RASPBERRY_PI>:2377
   ```
   </details>

> [!IMPORTANT]
> On the **first** Raspberry Pi 5 single-board computer hosting `medienhaus-docker`:

1. Clone this repository
   <br>
   ```bash
   git clone https://github.com/medienhaus/rpi-spaces-nextcloud-setup.git && \
   cd rpi-spaces-nextcloud-setup/
   ```

2. Clone, configure, and start [medienhaus-docker](https://github.com/medienhaus/medienhaus-docker/)

   **IMPORTANT:** The necessary pre-configured [`docker-compose.yml`](/medienhaus-docker/docker-compose.yml) file et cetera are located in the [medienhaus-docker](/medienhaus-docker/) directory; copy the content of [medienhaus-docker](/medienhaus-docker/) to the cloned upstream repository, and if necessary replace the files in there with our files.

   ```bash
   git clone https://github.com/medienhaus/medienhaus-docker.git medienhaus-docker--upstream && \
   rsync -av medienhaus-docker/ medienhaus-docker--upstream
   ```

   💭 If `rsync` is not available/installed, use the following commands <strong>instead</strong>❗️

   <details>
   <summary>
   Show/Hide commands
   </summary>

   ```bash
   git clone https://github.com/medienhaus/medienhaus-docker.git medienhaus-docker--upstream && \
   cp -i medienhaus-docker/.gitmodules medienhaus-docker--upstream/ && \
   cp -i medienhaus-docker/docker-compose.yml medienhaus-docker--upstream/ && \
   cp -i medienhaus-docker/docker-include.medienhaus-spaces.websecure.yml medienhaus-docker--upstream/ && \
   cp -i medienhaus-docker/template/medienhaus-spaces.config.js medienhaus-docker--upstream/template/ && \
   cp -i -R medienhaus-docker/assets medienhaus-docker--upstream/
   ```
   </details>

   **Then follow the instructions in the [medienhaus-docker](https://github.com/medienhaus/medienhaus-docker/) upstream repository.**

3. Configure and start [nextcloud-nginx-reverse-proxy](/nextcloud-nginx-reverse-proxy/)
   <br>
   ```bash
   cd nextcloud-nginx-reverse-proxy/ && \
   cp .env.example .env
   ```

   ```bash
   ${VISUAL:-${EDITOR:-vim}} .env
   ```

   ⚠️ For *production*, please change the following environment variables❗️
      - `BASE_URL` to your *fully qualified domain name*, e.g. `nextcloud.example.org`

   ```bash
   ${VISUAL:-${EDITOR:-vim}} config/nginx.conf
   ```

   ⚠️ For *production*, please change the following lines❗️
      - `server_name nextcloud.example.org` to point to your *fully qualified domain name*

   **Then start the Docker composition.**

   ```bash
   docker compose up -d
   ```

> [!IMPORTANT]
> On the **second** Raspberry Pi 5 single-board computer hosting `nextcloud`:

1. Clone this repository
   <br>
   ```bash
   git clone https://github.com/medienhaus/rpi-spaces-nextcloud-setup.git && \
   cd rpi-spaces-nextcloud-setup/
   ```

2. Configure and start [nextcloud](/nextcloud/)
   <br>
   ```bash
   cd nextcloud/ && \
   cp .env.example .env
   ```

   ```bash
   ${VISUAL:-${EDITOR:-vim}} .env
   ```

   ⚠️ For *production*, please change **at least** the following environment variables❗️
      - `ADMIN_CONTACT_LETSENCRYPT` for issuing SSL certificates via `traefik`
      - `BASE_URL` to your *fully qualified domain name*, e.g. `nextcloud.example.org`
      - `change_me` to generated **long**, **random**, and **secure** passwords/secrets

   💭  Generate **long**, **random**, and **secure** passwords/secrets via `openssl` command:
   ```bash
   openssl rand -hex 32
   ```

   💭 This can also be done programmatically, if the `.env` file does not(!) exist, via `bash`:

   <details>
   <summary>
   Show/Hide commands
   </summary>

   ```bash
   if [[ ! -r .env ]]; then
     while IFS= read -r line; do
       sed "s/change_me/$(openssl rand -hex 32)/" <<< "$line"
     done < .env.example > .env
   fi
   ```
   </details>

   **Then start the Docker composition.**

   ```bash
   docker compose up -d
   ```
