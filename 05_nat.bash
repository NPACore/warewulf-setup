exit 1
sudo sysctl net.ipv4.ip_forward=1

public=enp6s0f1
private=enp6s0f0
sudo iptables -t nat -A POSTROUTING -o $public -j MASQUERADE
sudo iptables -A FORWARD -i $public -o $private  -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $private -o $public -j ACCEPT

# doesn't work! have ACCEPT where it should be
sudo iptables -t nat -F POSTROUTING # clear routing
sudo iptables -t nat -A POSTROUTING -s 10.141.0.0/16 -o enp6s0f1 -j MASQUERADE
# working!

sudo iptables > cerebro2.iptables

# testing like
#   sudo tcpdump -i enp6s0f0 -n src 10.141.0.1 and not port 22
# AND
#   sudo tcpdump -i enp6s0f1 -n host 1.1.1.1
# THEN on node
#   curl 1.1.1.1

