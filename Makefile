lighthouses:
	ansible-playbook netlify.yml
	ansible-playbook lighthouses.yml

crontab:
	sudo cp cron /etc/cron.d/lighthouse

netlify:
	ansible-playbook netlify.yml