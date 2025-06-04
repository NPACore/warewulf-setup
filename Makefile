/usr/local/etc/warewulf/warewulf.conf:  warewulf.conf
	cp $< $@

# reverse from above b/c always edit with
#  wwctl node edit
#  wwctl profile edit
nodes.conf: /usr/local/etc/warewulf/nodes.conf
	cp $< $@
