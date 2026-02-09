{
  systemd.tpm2.enable = false;
  boot = {
    initrd.systemd.tpm2.enable = false;
    blacklistedKernelModules = [
      # If TPM is blacklisted, make sure that you disable TPM either in
      # (1) BIOS settings
      # (2) Both systemd.tpm2.enable and initrd.systemd.tpm2.enable options
      #
      # Otherwise your systemd-boot will get stuck initializing /dev/tpm0.
      # If you disable TPM at BIOS, then blacklisting these mods cause 0 problems.
      "tpm"
      "tpm_crb"
      "tpm_tis"
    ];
  };
}
