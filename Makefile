lighthouses:
	ansible-playbook lighthouses.yml
crontab:
	sudo cp cron /etc/cron.d/lighthouse
netlify:
	ansible-playbook netlify.yml
tldr:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
%:
	@$(MAKE) tldr
