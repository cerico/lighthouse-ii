tldr:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
lighthouses:
	ansible-playbook netlify.yml
	ansible-playbook lighthouses.yml
crontab:
	sudo cp cron /etc/cron.d/lighthouse
netlify:
	ansible-playbook netlify.yml
%:
	@$(MAKE) tldr
