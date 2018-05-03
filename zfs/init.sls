{% from "zfs/map.jinja" import zfs_settings with context %}

zfs_kmod:
{% if zfs_settings.lookup.module_method == 'kmod' %}
  pkg.installed:
    - name: kmod-zfs
{% else %} {# dkms #}
  pkg.installed:
    - pkgs:
      - zfs-dkms
      - kernel-devel
{% endif %}

zfs_packages:
  pkg.installed:
    - pkgs: {{ zfs_settings.lookup.packages }}
    - require:
      - pkg: zfs_kmod

modprobe-zfs:
  file.managed:
    - name: {{ zfs_settings.lookup.files.modprobe }}
    - source: salt://zfs/files/modprobe_zfs.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - context:
      kmod_options: {{ zfs_settings.kmod_options|default('') }}
    - requires:
      - pkg: zfs_packages

cfg-zfs-zed-rc:
  file.managed:
    - name: {{ zfs_settings.lookup.files.zed_rc }}
    - source: salt://zfs/files/zed.rc
    - template: jinja
    - context:
      zed_rc: {{ zfs_settings.zed_rc|default({}) }}
    - user: root
    - group: root
    - mode: 0600
    - require:
      - pkg: zfs_packages

{% if zfs_settings.services.zed == True %}
svc-zed:
  service.running:
    - name: {{ zfs_settings.lookup.services.zed }}
    - enable: True
    - require:
      - pkg: zfs_packages
      - file: cfg-zfs-zed-rc
{% endif %}

{% if zfs_settings.services.import_scan == True %}
svc-zfs-import-scan:
  service.running:
    - name: {{ zfs_settings.lookup.services.import_scan }}
    - enable: True
    - require:
      - pkg: zfs_packages
{% endif %}

{% if zfs_settings.services.import_cache == True %}
svc-zfs-import-cache:
  service.running:
    - name: {{ zfs_settings.lookup.services.import_cache }}
    - enable: True
    - require:
      - pkg: zfs_packages
{% endif %}

{% if zfs_settings.services.share == True %}
svc-zfs-share:
  service.running:
    - name: {{ zfs_settings.lookup.services.share }}
    - enable: True
    - require:
      - pkg: zfs_packages
{% endif %}

{% if zfs_settings.services.mount == True %}
svc-zfs-mount:
  service.running:
    - name: {{ zfs_settings.lookup.services.mount }}
    - enable: True
    - require:
      - pkg: zfs_packages
{% endif %}

{# EOF #}
