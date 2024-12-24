# Tmux Quick Menu

This plugin offers a quickmenu for Terminal UI commands useful for system
administration which then opens in a popup overlay to the current session.

The purpose of this plugin is to offer quick, temporary views to various
sysadmin tools without sacrificing screen real-estate or interrupting the
current shell.

## Installation

> [!Note]
>
> These instructions do not include any installation instructions for the
> sub commands. Please see the linked pages or install through your
> package manager.

### Manual

Clone this repo to and add the following to your `.tmux.conf` file

```plaintext
source '<path_to_repo>/main.tmux'
```

### Via TPM

Add the following to your tpm plugins:

```plaintext
@plugins 'mproffitt/tmux-quickmenu'
```

## TUIs

For full operation the following TUI applications, broken up into catagories:

### Kubernetes

- k9s <https://github.com/derailed/k9s>
  A super useful Kubernetes cluster manager
- ktop <https://github.com/vladimirvivien/ktop>
  A top like tool for kubernetes clusters
- stern <https://github.com/stern/stern>
  Although not a TUI, this is one of my most used commands when it comes to
  managing kubernetes as it's a super powerful log viewer.

  Choosing this from the menu will first open up a dialog where you can enter
  the namespace, pod pattern and optional log search string. The logs will
  then be piped through `jq` before being fed into `less -r` for display

  Namespace accepts the following:

  `.` Use the current kubeconfig context for the namespace
  `-A` Search all namespaces
  `[ns,[\s]]` a comma separated list of namespaces

  Pod pattern:
  A valid pattern for `stern` pod location - will be wrapped in single quotes
  before being passed to the CLI. Do not use spaces as part of the pattern.

  Search string:
  All text entered after pod pattern is treated as the search string (`-i`)
  flag to stern

  Examples:
  - `kube-system api error` - Look for errors in the api servers in kube system
    namespace
  - `monitoring, grafana .* connection failed` - Look for any pods with
    `connection failed` in the `monitoring` or `grafana` namespaces
- eks-node-viewer <https://github.com/awslabs/eks-node-viewer>
  Quickly visualise dynamic node usage in a cluster

### GIT

- LazyGit <https://github.com/jesseduffield/lazygit>
  A simple TUI for git commands
- tig <https://jonas.github.io/tig/>
  A slightly more involved UI for git that mainly functions as a git repository
  browser.

### System misc

- Lazy docker <https://github.com/jesseduffield/lazydocker>
  A simple terminal UI for both docker and docker-compose
- Lazy Journal <https://github.com/Lifailon/lazyjournal>
  Interact with system journals

### Networking

- Bandwhich or ntap
  Slightly different, this will try and run bandwhich and if not available
  will fall back to ntap. I actually use ntap but went with alphabetical
  ordering for the commands. Both of these offer a quick way to visualise
  which applications are using the most bandwidth on your system

  - Bandwhich can be installed from <https://github.com/imsnif/bandwhich>
  - ntap can be installed from <https://github.com/shellrow/ntap>

- mtr <https://github.com/traviscross/mtr>
  Super useful network diagnostic tool combining ping and traceroute

  Install this through your package manager

### System

- htop <https://github.com/htop-dev/htop>
  Quick overview of CPU, memory and processes

  Install this through your package manager
- kmon <https://github.com/orhun/kmon>
  Linux kernel manager and activity monitor
- ncdu <https://dev.yorhel.nl/ncdu>
  Disk usage visualizer

  Install this through your package manager
- nvtop <https://github.com/Syllo/nvtop>
  Graphics card usage visualisation similar to htop but for graphics cards

  Install this through your package manager

### File manager

- Midnight Commander
  Classic file management UI

  Install this through your package manager

-
