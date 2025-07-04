.PHONY: all cerebro2 nodes
all: cerebro2 nodes
cerebro2: /usr/local/etc/warewulf/warewulf.conf /etc/slurm/slurm.conf /etc/slurm/cgroup.conf /etc/slurm/slurmdbd.conf /etc/mysql/mariadb.conf.d/50-server.cnf /var/local/warewulf/overlays/wwclient/rootfs/etc/systemd/system/wwclient.service exports.cerebro2
nodes: .make/overlay.date

OVDIR := /var/local/warewulf/overlays

/usr/local/etc/warewulf/warewulf.conf:  warewulf.conf
	cp $< $@

# see 02_slurm_overlay.bash
$(OVDIR)/slurm/rootfs/etc/slurm/%: %  | $(OVDIR)/slurm/
	cp $< $@
$(OVDIR)/slurm/rootfs/etc/systemd/system/slurmd.service: slurmd.service  | $(OVDIR)/slurm/
	wwctl overlay import -o slurm slurmd.service  etc/systemd/system/slurmd.service

# bug? client looking in /var/local/etc instead of /etc
/var/local/warewulf/overlays/wwclient/rootfs/etc/systemd/system/wwclient.service: wwclient.service
	cp $< $@

# time keeping (also 02_slurm_overlay.bash)
$(OVDIR)/chrony/rootfs/etc/chrony/chrony.conf: chrony.conf | /var/local/warewulf/overlays/chrony/rootfs/etc/chrony/
	cp $< $@
chrony.keys:
	chronyc keygen 1 SHA256 256 >> chrony.keys
	chronyc keygen $(shell id -u _chrony) SHA256 256 >> chrony.keys
$(OVDIR)/chrony/rootfs/etc/chrony/chrony.keys: chrony.keys
	cp $< /etc/chrony/chrony.keys
	chown _chrony: /etc/chrony/chrony.keys
	wwctl overlay import -o chrony /etc/chrony/chrony.keys

# also for main host
/etc/slurm/%: %.ww
	cp $< $@
/etc/slurm/%: %
	cp $< $@

/etc/mysql/mariadb.conf.d/50-server.cnf: 50-server.cnf
	cp $< $@

# reverse from above b/c always edit with
#  wwctl node edit
#  wwctl profile edit
nodes.conf: /usr/local/etc/warewulf/nodes.conf
	cp $< $@
exports.cerebro2: /etc/exports
	cp $< $@
###
.make/overlay.date:  nodes.conf \
	$(OVDIR)/slurm/rootfs/etc/slurm/cgroup.conf $(OVDIR)/slurm/rootfs/etc/slurm/slurm.conf.ww $(OVDIR)/slurm/rootfs/etc/systemd/system/slurmd.service \
	$(OVDIR)/chrony/rootfs/etc/chrony/chrony.conf $(OVDIR)/chrony/rootfs/etc/chrony/chrony.keys \
	| .make/
	wwctl overlay build
	date >$@


## for posterity. also in 02_slurm_overlay.bash
/var/local/warewulf/overlays/slurm/:
	wwctl overlay mkdir slurm /etc
	wwctl overlay import slurm slurm.conf.ww /etc/slurm.conf.ww
	wwctl overlay import slurm /etc/munge/munge.key
	# for modified service overlay
	wwctl overlay mkdir slurm /lib/systemd/system/

/var/local/warewulf/overlays/chrony/rootfs/etc/chrony/:
	wwctl overlay create chrony -dv
	wwctl overlay mkdir chrony /etc/chrony
	wwctl overlay import chrony chrony.conf /etc/chrony/chrony.conf
	wwctl image exec debian-12.0 -- apt install chrony

cerebro2.iptables:
	# only need to run once after command from 05_nat.bash
	iptables-save > $@
/etc/iptables/rules.v4: cerebro2.iptables
	# this copy done by 'apt install iptables-persistent'
	cp $< $@

/etc/sysctl.d/99-hpc-forwarding.conf: 99-hpc-forwarding.conf
	cp $< $@
%/:
	mkdir -p $@
