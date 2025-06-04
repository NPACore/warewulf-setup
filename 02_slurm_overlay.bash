exit 1
wwctl overlay create slurm -dv
wwctl overlay mkdir slurm /etc
wwctl overlay import slurm slurm.conf /etc/slurm.conf
#wwctl profile set default --wwinit=wwinit,welcome
wwctl profile list default -a

