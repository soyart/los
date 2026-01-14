# los

los provides Nix flake, modules, and library for NixOS systems.

The L in los was picked randomly, and could stand for last, light, or even loser.

## Structure

### Modules

Modules are organized under [`./modules`](./modules/):

- [`modules/system/`](./modules/system/) — System-wide NixOS modules
- [`modules/homev2/`](./modules/homev2/) — Per-user modules (merged), V2

There's only 1 rule for modules: **a system module must never touch home modules**.

> We allow user modules to read or even set values of system modules,
> or even `nixosConfigurations` itself, *if* that's the natural way to implement the module.

- [System modules in `modules/system/`](./modules/system/)

  The root of this module is the top-level `los`

  The modules here provide los system options like networking, mountpoints,
  users, and doas.

- [User modules in `modules/homev2/`](./modules/homev2/)

  The modules here provide `los.homev2` user options like program configurations,
  user-specific packages, etc.

  We can define homev2 as a attrset with attr (key) being the target username.
  See [the los.homev2 entrypoint](./modules/homev2/default.nix) for usage.

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

### Defaults and presets

Defaults and presets in los are pre-configured, opinionated NixOS modules.
They provide default configuration for los Nix module options. They are
usually mapped to a los module.

For example, [./defaults/system/net](./defaults/system/net) provides default
values for los networking module [./modules/system/net].

Presets are set of defaults plus a few tweaks if needed. They're supposed to
provide one big opinionated templates for importers.

For example, [./presets/homev2/sway-dev.nix](./presets/homev2/sway-dev.nix)
defines the user configuration that contains sway defaults + development workflow defaults.

For another example, [./presets/homev2/minimal.nix](./presets/homev2/minimal.nix)
defines "minimal" setup that only contains a few required terminal programs,
while [./presets/homev2/devel.nix](./presets/homev2/devel.nix) defines the base developer's setup.
If we combine the two presets, we get a system that have both stuff from sway-dev and minimal setup,
but without Sway or GUI configuration.

- [Default settings](./defaults/)

  Ready-to-go, import-only modules with no options defined.

- [Presets and profiles](./presets/)

  Like defaults, but more complex. An example is [`sway-dev`](./presets/sway-dev/),
  which provides my working environment using Sway and Helix.

  Presets usually cover everything but the boot process or hardware settings.

  Lower-level, machine-specific configuration like the boot process, mountpoints,
  and kernel settings should be defined in `hosts/<host>/default.nix`.

  Like with defaults, they provide no options.

### Misc.

- [Library](./liblos/) (very opinionated)

  Simple (sometimes useless) non-module Nix code, usually functions.

- [Package lists](./packages/)

  List of package names to be imported by [syspkgs module](./modules/system/syspkgs.nix).

  Each text line is treated as pname of a Nix package.

- [Original source code](./src)

  los also has its own programs, packaged into Nix Flake and used within los modules.
