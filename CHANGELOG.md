# Turbot CLI

# Release History

## 1.0.0-beta.2 [2017-07-12]

#### general

- update CLI to use use node 10

#### turbot publish

- support `prepublish` script defined in mod
- when publishing, first call `createVersion` mutation and then `getVersion` query
- ensure index.zip is deleted after publish
- improve CLI output when trying to republish an existing mod version

#### turbot up

- if no package json is present, deduce mod details from tarball filename, close #1818

#### turbot pack

- add build number to filename

#### turbot login

- fix bug requiring 2 logins before acquiring token

#### turbot install

- fix bug where incorrect header path used when writing headers

## 1.0.0-beta.1 [2019-07-11]

- Initial 1.0.0 beta release
