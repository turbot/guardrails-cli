# Turbot CLI

The Turbot CLI provides development tool for Turbot mods. mIt provides the following commands: 

- inspect
- test
- init
- pack
- up
- login
- publish
- install


## turbot inspect

Display summary information about the mod.


## turbot test

Run tests for the mod.

### Inline control test syntax

#### Control state

```
expect:
  control:
    state: skipped|error|alarm|tbd
```

or

```
expect:
  control: skipped|error|alarm|tbd
```

#### Process state

```
expect:
  processState: update|terminate
```

#### Resource commands

A partial match is performed on each resource command expectation.
(all properties specified in expectation are checked, but any properties which exist in in actual command bu not expectation are ignored)

There are several ways resources can be matched.

##### Ordered

The expectation items must all match the actual resource commands, in the same order.

```
expect:
  resource:
    - create|upsert|put|update|delete|notify: <resourceTypeAka>
      data: {}
    - create|upsert|put|update|delete|notify: <resourceTypeAka>
      data: {}
    - etc.
```

or

```expect:
  resource:
    matchOrdered
        - create|upsert|put|update|delete|notify: <resourceTypeAka>
          data: {}
        - create|upsert|put|update|delete|notify: <resourceTypeAka>
          data: {}
        - etc.
```

##### Unordered

The expecation items must all match the actual resource commands, ignoring order.

```expect:
  resource:
    matchUnordered
        - create|upsert|put|update|delete|notify: <resourceTypeAka>
          data: {}
        - create|upsert|put|update|delete|notify: <resourceTypeAka>
          data: {}
        - etc.
```

##### Include

The actual resource commands must _include_ the expecation items, ignoring order.

```expect:
  resource:
    include
        - create|upsert|put|update|delete|notify: <resourceTypeAka>
          data: {}
        - create|upsert|put|update|delete|notify: <resourceTypeAka>
          data: {}
        - etc.
```

#### Actions

The only difference (for test purposes) between an **action** and a **control** is that the action may take an argument - this appears as `args` in the inline input.

Action tests are exactly the same as control tests, with the difference that the test _input_ may include an _args_ field

#### Policies

For examples of policy tests, see packages/cli/test/mods/aws-kms/src/key/policy/types

Policy tests can (optionally) define either _data_ or _template_ and _templateInput_. (For calculated policies, neither of these wouyld be defined)

If the test expectation is a boolean, the test verified the validity of the policy value.

```
description: Valid
data: Enforce
expect: true
```

```
description: Invalid
data: invalid
expect: false
```

```
description: Invalid
template: {{ value }}
templateInput:
  value: invalid
expect: false
```

The expected output policy value is specified using:

```
expect:
  policy: expectedValue
```

for example

```
  - description: use template settingValue
      template: "- {{value[0]}}\n- {{value[1]}}"
      templateInput:
        value:
          - A
          - B
      expect:
        policy:
          - A
          - B
```

An expected policy state can be specified as follows:

```
expect:
  policy:
    state: error
```

If the policy has an inline and/or lambda, the rendered policy value is provided in the input as _settingValue_.

The inline/lambda can be tested in a similar way as for controls. The test defines _data_ or _template_ and _templateInput_,
and _input_ which is the inline input data

**NOTE: There is no need to define _settingValue_ in your _test input_ - it will be automatically added.**

For example

```
description: use template settingValue from inline
  template: "{{value}}"
  templateInput:
    value: A
  input:
    item:
      title: inlineSettingValue
  expect:
    policy: A(inline)
```

#### Reports

The only difference between a **report** and a **policy** is that the report may take an argument - this appears as `args` in the inline input.

Report tests are exactly the same as policy tests, with the difference that the test _input_ would include an _args_ field


## turbot pack

Package the mod, creating a deployable file for use with Turbot APIs.

## turbot up

Upload and install the mod

## turbot init

Create a new mod, add resources to an existing mode or add controls to existing mod resources.

### init templates

When running `turbot init`, controls, actions, policies and reports (aka _runnables_) are added to the mod by rendering nunjucks templates.

The location for the templates is specified in the `~/.turbot/config.yml` file with the property `init.templatePath`.

The templates should be in the following folder structure

```
templates
  action
    <action-name>
      action
        types
          <action-name>.yml
  control
    <control-name>
      control
        types
          <control-name>.yml
      policy
        types
          <control-name>.yml
   functions
     <function-name>
       index.js
       package.json
   mod
     src
       turbot.yml
     package.json
  policy
    <policy-name>
      policy
        types
          <policy-name>.yml
```
### render context

The templates for the selected runnables are rendered using a render context which is formed as follows:

1 ) A baseRenderContext is created containing the following

```
{
     mod
     resource
     provider
     service
}
```

2 ) Additional render context may be provided on the command line with the command arg `--control-render-context`

3 ) A config file may be used to pass in the additional render context, using the command arg `--config` (see below)

4 ) The runnable yaml for the target runnable is loaded (if it exists) and any render context specified in the yaml front-matter is merged in

### config file
Command parameters may be passed to `turbot init` via a config file specified using the command arg `--config`

The config file should be yaml with the command arguments in the yaml front-matter, as follows:

```
`
---
resource: key
control: approved
renderContext:
  serviceConn: ACM
  describeOperation: getCertificate
  listTagsOperation: listTagsForCertificate
  resourceIdentifierKey: CertificateArn
  resultObjectItemKeys:
    - Certificate
    - CertificateChain
  fatalErrorCodes:
    - AccessDeniedException
  resourceNotFoundErrorCodes:
    - InvalidArnException
    - ResourceNotFoundException
  targetResourceType: region
---
```

### saving the config
The config variables used to create a runnable are saved in the yaml front-matter of any runnables which are created.

This means to regenerate the runnable, all that is needed it to run **turbot init --config <path-to-tunnable-yaml>**


## Turbot Configuration file

The CLI will look for a configuration file at the path **~/.turbot/config.yml**

The following values are expected:

```
init:
    templatePath
testDefaults:
    aws:
      region: ...
      account: ...
    gcp:
      region: ...
      account: ...
    azure:
      region: ...
      account: ...
```

#### templatePath
This is the location used by `turbot init` to search for templates

#### testDefaults
These values aere used by  used by `turbot init` to populate the provider `account` and `region` properties in the template render context.
(These values are typically required to render `region` and `account` properties within control tests.)

# Mod composition

## Overview

Mod definitions may be split into multiple files. 'Directives' may be used define how to 'compose' a mod.

For example, turbot.yml could look as follows:

```
$id: "tmod:@turbot/testpackage"

title: KMS

definitions:
  +object: "definitions.yml"

policy:
  +object: "policy/**"

resource:
  +object: "resource/**"

control:
  +object: "control/**"
```

The `+object` fields will be replaced by an object constructed from the file or files matching the property value, which is a [glob](<https://en.wikipedia.org/wiki/Glob_(programming)>). (Full syntax details are given below.)

