# Turbot CLI

# Release History

## 1.0.0-beta.8 [2017-07-30]

#### General

- All commands now honour arguments set in ~/.turbot/config.yml.
- Only call process.exit in case of error.

#### turbot login, install, publish

- Add `--registry` flag to select the registry to use.

#### turbot init

- Update init to work with new format mods.


## 1.0.0-beta.7 [2017-07-24]

#### turbot up

 - Fixed legacy mod upload.
 
#### turbot publish

 - Fixed bug where publish status was not being returned.
 
## 1.0.0-beta.6 [2017-07-18]

#### General

- Add `include-build-number` flag to pack/up/publish to optionally append build number to packed mod.

#### turbot publish

- Use mod $id instead of name to extract mod identityName and name.

#### turbot install 

- Use updated graphql schema to retrieve download url. 
- Improve error handling and output message when headers cannot be downloaded. 
 
## 1.0.0-beta.5 [2017-07-16]

#### turbot up
- Support both old and new style mods.

#### turbot pack
- No longer add build number to packed mod.


## 1.0.0-beta.4 [2017-07-12]

- Revert to node 8 for Windows compatibility

## 1.0.0-beta.3 [2017-07-12]

- Workaround: avoid re-entrant calls to CLI. When calling `npm pack` from `turbot pack`, pass `--ignore-scripts` to avoid calling `prepare` (which calls into CLI). Instead explicitly call `prepack`, which webpacks the functions.

## 1.0.0-beta.2 [2017-07-12]

#### General

- Update CLI to use use node 10.

#### turbot publish

- Support `prepublish` script defined in mod.
- When publishing, first call `createVersion` mutation and then `getVersion` query.
- Ensure index.zip is deleted after publish.
- Improve CLI output when trying to republish an existing mod version.

#### turbot up

- If no package json is present, deduce mod details from tarball filename.

#### turbot pack

- Add build number to filename.

#### turbot login

- Fix bug requiring 2 logins before acquiring token.

#### turbot install

- Fix bug where incorrect header path used when writing headers.

## 1.0.0-beta.1 [2019-07-11]

- Initial 1.0.0 beta release.

