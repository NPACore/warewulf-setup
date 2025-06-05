exit 1
# also see Makefile. repeated here with local (head node) apt install commands
sudo apt intsall slurmctld slurmdbd

wwctl overlay create slurm -dv
wwctl overlay mkdir slurm /etc
wwctl overlay import slurm slurm.conf.ww /etc/slurm/slurm.conf.ww # NB. doesn't need to be a template?
wwctl overlay import slurm cgroup.conf /etc/slurm/cgroup.conf
sudo wwctl overlay import slurm /etc/munge/munge.key
#wwctl profile edit # add 'slurm' to list

## also need chrony for syncing clocks
# https://www.admin-magazine.com/HPC/Articles/Warewulf-4-Time-and-Resource-Management
apt install chrond; systemctl enable --now chronyd # head node
wwctl overlay create chrony -dv
wwctl overlay mkdir chrony /etc/chrony
wwctl overlay import chrony chrony.conf /etc/chrony/chrony.conf
wwctl image exec debian-12.0 -- /usr/bin/apt install chrony ntpstat # enables systemctl

