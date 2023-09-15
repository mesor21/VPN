import sys

def remove_peer_by_allowed_ips(config_file, allowed_ips):
    with open(config_file, 'r') as f:
        lines = f.readlines()

    with open(config_file, 'w') as f:
        found_peer = False
        i = 0
        while i < len(lines):
            line = lines[i]
            if line.strip().startswith('[Peer]'):
                peer_lines = []
                j = i + 1
                while j < len(lines) and not lines[j].strip().startswith('['):
                    peer_lines.append(lines[j])
                    j += 1
                peer_allowed_ips = [line for line in peer_lines if line.strip().startswith('AllowedIPs')]
                if peer_allowed_ips and allowed_ips in peer_allowed_ips[0]:
                    found_peer = True
                else:
                    f.write('[Peer]\n')
                    f.writelines(peer_lines)
            else:
                f.write(line)
            i = j if 'j' in locals() else i + 1

    return found_peer

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python remove_peer.py <config_file> <allowed_ips>")
        sys.exit(1)

    config_file = sys.argv[1]
    allowed_ips = sys.argv[2]

    removed = remove_peer_by_allowed_ips(config_file, allowed_ips)
    if removed:
        print(f"Peer with AllowedIPs {allowed_ips} removed from {config_file}")
    else:
        print(f"No matching peer found with AllowedIPs {allowed_ips} in {config_file}")
