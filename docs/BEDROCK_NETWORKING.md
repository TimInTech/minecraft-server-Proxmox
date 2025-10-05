# Bedrock Networking (Proxmox)

- Use **bridged** networking (vmbr0) so the guest gets a LAN IP.
- Open/forward **UDP 19132** to the guest.
- In LXC set features: `keyctl=1,nesting=1`.
- LAN discovery can fail across virtualization; add the server manually via `IP:19132`.
- UFW example inside guest:
  ```bash
  ufw allow 19132/udp
  ```
