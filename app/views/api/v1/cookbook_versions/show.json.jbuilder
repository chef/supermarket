json.license @cookbook_version.license
json.tarball_file_size @cookbook_version.tarball_file_size
json.version @cookbook_version.version
json.average_rating nil
json.cookbook api_v1_cookbook_url(@cookbook)
json.file cookbook_version_download_url(@cookbook_version.cookbook, @cookbook_version)
