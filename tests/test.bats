#!/bin/bash bats

load _test_base

@test "turbot login" {
  cd $TURBOT_MODS_DIR
  run turbot login --registry turbot-dev.com --username $USER --password $PASS
  [ "$status" -eq 255 ]
}

@test "turbot install" {
  cd $TURBOT_MODS_DIR
  run turbot install
  [ "$status" -eq 1 ]
}
@test "turbot compose" {
  cd $TURBOT_MODS_DIR
  run turbot compose
  [ "$status" -eq 0 ]
}

@test "turbot inspect" {
  cd $TURBOT_MODS_DIR
  run turbot inspect
  [ "$status" -eq 0 ]
}

@test "turbot test definitions" {
  cd $TURBOT_MODS_DIR
  run turbot test --definitions
  [ "$status" -eq 0 ]
}

@test "turbot configure" {
  cd $TURBOT_MODS_DIR
  run turbot configure --profile default --workspace acceptance --accessKey 29d02647-0a00-4743-bbed-56d8477ba35c --secretKey dee3f0e3-fd4c-487f-b78b-5ae7e71c7158
  echo "$output"
  [ "$status" -eq 0 ]
}
@test "turbot up" {
  cd $TURBOT_MODS_DIR
  run turbot up $TURBOT_WORKSPACE_PROFILE
  echo "$output"
  [ "$status" -eq 1 ]
}

@test "turbot download" {
  cd $TURBOT_MODS_DIR
  run turbot download @turbot/provider-test --registry turbot-dev.com
  [ "$status" -eq 1 ]
}

@test "turbot publish" {
  cd $TURBOT_MODS_DIR
  run turbot publish --registry acceptance.com
  echo "$status"
  [ "$status" -eq 255 ]
}

@test "turbot graphql" {
  cd $TURBOT_MODS_DIR
  run turbot graphql --profile $TURBOT_WORKSPACE_PROFILE --format "json" --query '{
	resource(id:"233843498984"){
	    object
	}
}'
    echo "$status"
  [ "$status" -eq 1 ]
}