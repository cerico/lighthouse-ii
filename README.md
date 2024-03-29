# Lighthouse

[![Deploy Actions](https://github.com/cerico/lighthouse-ii/actions/workflows/deploy.yml/badge.svg)](https://github.com/cerico/lighthouse-ii/actions/workflows/deploy.yml)

![](flagscore.jpg)


### What does it do?

- Builds lighthouse pages for supplied urls
- Builds index page
- Saves times series data on metrics to postgres

# In production

https://lighthouses.io37.ch

## How do I monitor a new url?

Edit `urls.js` to add new urls

# In development

### Pre-requisites

1. Ansible

```
brew install ansible
sudo apt install ansible
```

### Install packages

```
yarn install
```

### How to run

```
make lighthouses
```

### What happened?

```
open /var/www/html/lighthouses/index.html
```

### Run it every day

edit `cron` to change any values, and then

```
make cron
```

