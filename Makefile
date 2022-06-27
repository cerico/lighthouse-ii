lighthouses:
	ansible-playbook lighthouses.yml

crontab:
	sudo cp cron /etc/cron.d/lighthouse
