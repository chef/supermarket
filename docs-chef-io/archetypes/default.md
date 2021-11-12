+++
title = "{{ .Name | humanize | title }}"

date = {{ .Date }}
draft = false

[menu]
  [menu.supermarket]
    title = "{{ .Name | humanize | title }}"
    identifier = "supermarket/{{ .Name | humanize | title }}"
    parent = "supermarket"
    weight = 10
+++

