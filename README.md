# vscale-infra

Inspired by [terraform](https://www.terraform.io/).

## Usage

```
$> bundle
$> VSCALE_TOKEN=xyz bundle exec bin/info
$> VSCALE_TOKEN=xyz bundle exec bin/plan state.yml
$> VSCALE_TOKEN=xyz bundle exec bin/apply state.yml

```

#### state.yml

```yaml
---
servers:
  - name: 'example.com'
    rplan: small
    location: msk0
    make_from: centos_7_64_001_master
    tags:
      - name: example
    keys:
      # 
      # NOTE: keys are created from web interface only
      # 
      - name: my_key@machine

# NOTE: domains are WIP at the moments
# domains:
  #- name: 'example.com'
    #tags:
      #- name: example
    #records:
      #- { type: A, ttl: 300, content: "<%= servers['example.com'].public_address %>" }
```
