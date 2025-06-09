sudo systemctl restart slurmctld.service slurmd
sudo kash -n '10.141.0.[3-4]' systemctl restart slurmd
sudo -u slurm scontrol update nodename=node0[3-4] State=IDLE

