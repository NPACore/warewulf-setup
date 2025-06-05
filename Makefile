.PHONY: all cerebro2 nodes
all: cerebro2 nodes
cerebro2: /usr/local/etc/warewulf/warewulf.conf /etc/slurm/slurm.conf /etc/slurm/cgroup.conf /etc/slurm/slurmdbd.conf /etc/mysql/mariadb.conf.d/50-server.cnf /var/local/warewulf/overlays/wwclient/rootfs/etc/systemd/system/wwclient.service exports.cerebro2
nodes: .make/overlay.date

OVDIR := /var/local/warewulf/overlays

/usr/local/etc/warewulf/warewulf.conf:  warewulf.conf
	cp $< $@

# see 02_slurm_overlay.bash
/var/local/warewulf/overlays/slurm/rootfs/etc/slurm/%: %  | /var/local/warewulf/overlays/slurm/
	cp $< $@
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
.make/overlay.date:  nodes.conf $(OVDIR)/slurm/rootfs/etc/slurm/cgroup.conf $(OVDIR)/slurm/rootfs/etc/slurm/slurm.conf.ww \
	$(OVDIR)/chrony/rootfs/etc/chrony/chrony.conf \
	$(OVDIR)/chrony/rootfs/etc/chrony/chrony.key \
	| .make/
	wwctl overlay build
	date >$@


## for posterity. also in 02_slurm_overlay.bash
/var/local/warewulf/overlays/slurm/:
	wwctl overlay mkdir slurm /etc
	wwctl overlay import slurm slurm.conf.ww /etc/slurm.conf.ww
	wwctl overlay import slurm /etc/munge/munge.key
/var/local/warewulf/overlays/chrony/rootfs/etc/chrony/:
	wwctl overlay create chrony -dv
	wwctl overlay mkdir chrony /etc/chrony
	wwctl overlay import chrony chrony.conf /etc/chrony/chrony.conf
	wwctl image exec debian-12.0 -- apt install chrony

%/:
	mkdir -p $@
