exit 1
# also see Makefile. repeated here with local (head node) apt install commands
apt intsall slurmctld slurmdbd

# 20250608 -- slurm causes boot issue? rerunning this commands to create a new overlay
wwctl overlay create slurm -dv
wwctl overlay mkdir slurm /etc/slurm
wwctl overlay import slurm slurm.conf.ww /etc/slurm/slurm.conf.ww # NB. doesn't need to be a template?
wwctl overlay import slurm cgroup.conf /etc/slurm/cgroup.conf
wwctl overlay mkdir slurm /etc/munge
wwctl overlay import slurm /etc/munge/munge.key

## BAD BAD BAD. files (or any overlya folder) in lib/systemd/system causes kerenl crash!
#wwctl overlay mkdir slurm lib/systemd/system/
#wwctl overlay import slurm slurmd.service lib/systemd/system/
#wwctl profile edit # add 'slurm' to list

# go into 'etc' not 'system'!
wwctl overlay mkdir slurm etc/systemd/system/
wwctl overlay import slurm slurmd.service etc/systemd/system/
wwctl profile edit # add 'slurm' to list

# 20250608 -- chrony confirmed to cause no boot issues
## also need chrony for syncing clocks
# https://www.admin-magazine.com/HPC/Articles/Warewulf-4-Time-and-Resource-Management
apt install chrond; systemctl enable --now chronyd # head node
wwctl overlay create chrony -dv
wwctl overlay mkdir chrony /etc/chrony
wwctl overlay import chrony chrony.conf /etc/chrony/chrony.conf
wwctl image exec debian-12.0 -- /usr/bin/apt install chrony ntpstat # enables systemctl

