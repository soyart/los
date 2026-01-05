# los

los provides Nix flake, modules, and library for NixOS systems.

The L in los was picked randomly, and could stand for last, light, or even loser.

## Structure

### Modules

Modules are organized under [`./modules`](./modules/):

- [`modules/system/`](./modules/system/) — System-wide NixOS modules
- [`modules/user/`](./modules/user/) — Per-user modules (with `username:` closure)

There's only 1 rule for modules: **a system module must never touch user modules**.

> We allow user modules to read or even set values of system modules,
> or even `nixosConfigurations` itself, *if* that's the natural way to implement the module.

- [System modules in `modules/system/`](./modules/system/)

  The root of this module is the top-level `los`

  The modules here provide los system options like networking, mountpoints,
  users, and doas.

- [User modules in `modules/user/`](./modules/user/)

  The modules here provide `los.home` user options like program configurations,
  user-specific packages, etc.

  #### Directory structure

  - `dm/` — Display manager related configs (sway, pipewire, fonts)
  - `devel/` — Development environment tools
  - `firefox/` — Firefox browser configuration
  - `git/` — Git version control configuration
  - `helix/` — Helix editor configuration
  - `lf/` — lf file manager configuration
  - `vscodium/` — VSCodium editor configuration

  And it goes on.

  #### User-specific options

  Options under `los.home` are user-specific. The per-user configuration
  is implemented by simple, stupid functional module factories that takes
  in a username and returns a user-specific los modules under `los.home.${username}`.

  The options `los.home.${username}` will then be mapped to `home-manager.users.${username}`.

  Note that `home-manager.sharedModules` is not used because some modules here might need to set
  system configurations too, usually low-level or security-related NixOS options.

  #### DM abstraction

  The `dm/` module provides shared display manager settings:
  - `los.home.${username}.dm.pipewire.enable` — Audio/screen sharing support
  - `los.home.${username}.dm.fonts` — Font configuration
  - `los.home.${username}.dm.sway` — Sway window manager

  Other modules (like Firefox) can reference `dm.pipewire.enable` to determine
  whether to enable Pipewire support, avoiding configuration races.

- [Standalone Home Manager entry](./home/default.nix)

  The `home/default.nix` file is the flake entry point for standalone `homeConfigurations`,
  used for non-NixOS systems (e.g., macOS).

### Host configurations

Per-host configurations should be consolidated into a single module
under [`./hosts`](./hosts/).

Preferrably, these *hosts* modules should not declare any options (i.e.
they are `imports`-only modules), and they should not touch user modules directly.

This is because *hosts* are bare-minimum builds that can boot and connect
to the internet.

The way I like it is to use host configuration as the base, and build up from
there with modules and [presets](./presets/).

### Misc.

- [Library](./liblos/) (very opinionated)

  Simple (sometimes useless) non-module Nix code, usually functions.

- [Package lists](./packages/)

  List of package names to be imported by [syspkgs module](./modules/system/syspkgs.nix).

  Each text line is treated as pname of a Nix package.

- [Default settings](./defaults/)

  Ready-to-go, import-only modules with no options defined.

- [Presets and profiles](./presets/)

  Like defaults, but more complex. An example is [`sway-dev`](./presets/sway-dev/),
  which provides my working environment using Sway and Helix.

  Presets usually cover everything but the boot process or hardware settings.

  Lower-level, machine-specific configuration like the boot process, mountpoints,
  and kernel settings should be defined in `hosts/<host>/default.nix`.

  Like with defaults, they provide no options.
