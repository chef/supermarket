+++
title = "{{ .Name | humanize | title }}"
date = {{ .Date }}
draft = false
gh_repo = "supermarket"

[menu]
  [menu.supermarket]
    title = "{{ .Name | humanize | title }}"
    identifier = "supermarket/{{ .Name | humanize | title }}"
    parent = "supermarket"
    weight = 10
+++

