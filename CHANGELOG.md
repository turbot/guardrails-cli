# Turbot CLI

# Release History

## 1.0.0-beta.20 [2019-10-28]

#### General
- add 'graphql' command. This allows graphql queries to be run against turbot environments from the command line. 

#### Bugfixes
- remove error: `type "ResourceWithNavigation" is missing a "__resolveType" resolver.` 
 
## 1.0.0-beta.19 [2019-10-21]

#### Bugfixes
- fix `test`. Call to graphql-tag accidentally removed getUrisFromRunnableInputQuery. 

## 1.0.0-beta.18 [2019-10-18]

#### Bugfixes
- fix `up` and `init` to call `inspect` instead of `doInspect`.

## 1.0.0-beta.17 [2019-10-16]

#### General
 - add ability to view markdown command documentation from command line.

#### Bugfixes
- runnable test data validation failing for array input. 

#### turbot inspect
 - use a nunjucks template to format output. 
 - add inspect template for changelog output.

#### turbot test
 - add support for aws organization.credentials in input queries.
 - update delete testing to use aka if passed in expectation.

#### turbot configure
 - update prompts to use correct names: 'Turbot Access Key' and 'Turbot Secret Key'.

#### turbot up 
 - move defaulting of `parent` into the argument definition

## 1.0.0-beta.16 [2019-10-09]

#### Bugfixes
- Fix bug in buildApiUrl - workspace now requires both `workspace name` and `installation domain` to be provided (e.g. `bananaman-turbot.putney.turbot.io`, rather than just `bananaman-turbot.putney`).

#### turbot up
- credentials environment variables changed:
  - TURBOT_ACCESS_KEY_ID to TURBOT_ACCESS_KEY 
  - TURBOT_SECRET_ACCESS_KEY to TURBOT_SECRET_KEY 

## 1.0.0-beta.15 [2019-10-08]

#### General
- update config file location and registry file format. New format is:
```
~
  .config
    turbot
      config.yml
      registry.yml
      credentials.yml
```
- add one-off migration from old to new config format

#### turbot configure
- add `configure` command to create/update the credentials file

#### turbot up
- add support for credentials profile
- add args: 
  - `profile`
  - `access-key`
  - `secret-key`
  - `workspace`
  - `credentials-file`
- rename `parent-resource` to `parent`

#### turbot init 
 - rename `templatePath` to `templateRoot` and make an argument to `init` command, as opposed to only being set in config 

#### turbot test
- return the number of test failures 

## 1.0.0-beta.14 [2019-10-04]

#### Bug fixes
-  fix `getSecret` nested resource resolver

#### turbot init
 - Added nunjucks filters `camelCase` and `pascalCase` 
 
## 1.0.0-beta.13 [2019-09-26]

#### General

- Add `provider-test` test mod.

#### Bug fixes
- Action state was not being tested by `turbot test`.

#### turbot compose 

- Remove runnable input from head file

#### turbot install 

- Improve error handling if dependency is not in registry. 

## 1.0.0-beta.12 [2019-08-30]x  

#### turbot up

- Fixed: incorrect casing of ControlCommandInput mutation command type used to trigger mod installed control.

## 1.0.0-beta.11 [2019-08-08]

#### turbot test

- Add testing support for `putPaths` resource command.

#### turbot publish 

- Include README.md and CHANGELOG.md files in published mod if present. 

#### turbot install 

- Install README.md and CHANGELOG.md if they exist in registry.
- Add --latest flag to force major version upgrade if there is one available.
- Add logic to determine whether to install a dependency:
    - If the dependency does not exist it is installed.
    - If the dependency exists but does not satisfy the version requirements, it is updated.
    - If the dependency exists but the new version has a higher minor version it is updated.
    - If the dependency exists and the new version has a higher major version it is *NOT* updated unless the `--latest` flag is set.

#### turbot up

- Replace 'mod-file' argument with 'zip-file' and fix implementation. 

## 1.0.0-beta.10 [2019-08-01]

#### General
 
- Update the mod loading code to be platform-independent.
- Support mods with no source, just header and dist file.

## 1.0.0-beta.9 [2019-07-31]

#### General

- Command line args to have higher priority than config file values.
- Do not throw error if config file not present.
- When logging into registry, save refresh token and use to automatically refresh expired tokens.
- Update compile.sh to zip the build results into files with the naming convention: turbot_cli_${version}_${platform}_${arch}.zip
 
#### turbot publish

- Do not remove the index.zip file unless publish is successful.
- Add `--zip-file` argument to publish to bypass the mod packing and use the zip file specified.

## 1.0.0-beta.8 [2019-07-30]

#### General

- All commands now honour arguments set in ~/.turbot/config.yml.
- Only call process.exit in case of error.

#### turbot login, install, publish

- Add `--registry` flag to select the registry to use.

#### turbot init

- Update init to work with new format mods.

## 1.0.0-beta.7 [2019-07-24]

#### turbot up

 - Fixed legacy mod upload.
 
#### turbot publish

 - Fixed bug where publish status was not being returned.
 
## 1.0.0-beta.6 [2019-07-18]

#### General

- Add `include-build-number` flag to pack/up/publish to optionally append build number to packed mod.

#### turbot publish

- Use mod $id instead of name to extract mod identityName and name.

#### turbot install 

- Use updated graphql schema to retrieve download url. 
- Improve error handling and output message when headers cannot be downloaded. 
 
## 1.0.0-beta.5 [2019-07-16]

#### turbot up
- Support both old and new style mods.

#### turbot pack
- No longer add build number to packed mod.


## 1.0.0-beta.4 [2019-07-12]

- Revert to node 8 for Windows compatibility.

## 1.0.0-beta.3 [2019-07-12]

- Workaround: avoid re-entrant calls to CLI. When calling `npm pack` from `turbot pack`, pass `--ignore-scripts` to avoid calling `prepare` (which calls into CLI). Instead explicitly call `prepack`, which webpacks the functions.

## 1.0.0-beta.2 [2019-07-12]

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

