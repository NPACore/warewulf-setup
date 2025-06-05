exit 1
sudo make cerebro2 # update sql config, slurm config
systemctl enable --now munge slurmdbd slurmctld

sudo wwctl overlay import slurm /etc/munge/munge.key

