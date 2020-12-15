# vim: ft=sh:sw=2:et

ORGANIZATION="Test Organization"
PRODUCT="Test Product"
CONTAINER_REPOSITORY="foremanbusybox"
FILE_REPOSITORY="file repo"
PUPPET_REPOSITORY="Puppet Modules"
YUM_REPOSITORY="Zoo"
YUM_REPOSITORY_2="modules-rpms"
YUM_REPOSITORY_3="rpm-deps"
YUM_REPOSITORY_URL=https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/
LIFECYCLE_ENVIRONMENT="Test"
CONTENT_VIEW="Test CV"
CONTENT_VIEW_2="Component 1"
CONTENT_VIEW_3="Composite"
ACTIVATION_KEY="Test AK"
FILTER1="errata excluder"
FILTER2="rpm excluder"
FILTER3="modulemd includer"

ORGANIZATION_LABEL="${ORGANIZATION/ /_}"
PRODUCT_LABEL="${PRODUCT/ /_}"
CONTAINER_REPOSITORY_LABEL="${CONTAINER_REPOSITORY/ /_}"
FILE_REPOSITORY_LABEL="${FILE_REPOSITORY/ /_}"
PUPPET_REPOSITORY_LABEL="${PUPPET_REPOSITORY/ /_}"
YUM_REPOSITORY_LABEL="${YUM_REPOSITORY/ /_}"
LIFECYCLE_ENVIRONMENT_LABEL="${LIFECYCLE_ENVIRONMENT/ /_}"
CONTENT_VIEW_LABEL="${CONTENT_VIEW/ /_}"
ACTIVATION_KEY_LABEL="${ACTIVATION_KEY/ /_}"

IMPORT_ORGANIZATION="Import Organization"


find_or_create_org() {
  local org_name="$1"
  run hammer --output csv --no-headers organization info --name="$org_name" --fields=id
  if [ $status != 0 ]; then
    run hammer organization create --name="$org_name" | grep -q "Organization created"
    [ $status -eq 0 ]
    run hammer --output csv --no-headers organization info --name="$org_name" --fields=id
  fi
  [ $status -eq 0 ]
  # returns org_id
  echo "$output"
}

find_or_create_product() {
  local product_name="$1"
  local org_id="$2"
  run hammer --output csv --no-headers product info --name="$product_name" --organization-id=$org_id --fields=id
  if [ $status != 0 ]; then
    run hammer product create --name="$product_name" --organization-id=$org_id | grep -q "Product created"
    [ $status -eq 0 ]
    run hammer --output csv --no-headers product info --name="$product_name" --organization-id=$org_id --fields=id
  fi
  [ $status -eq 0 ]
  # returns product_id
  echo "$output"
}

find_or_create_yum_repository() {
  local repository_name="$1"
  local product_id="$2"
  run hammer --output csv --no-headers repository info --name="$repository_name" --product-id=$product_id --fields=id
  if [ $status != 0 ]; then
    run hammer repository create --name="$repository_name" --product-id=$product_id --content-type=yum  | grep -q "created"
    [ $status -eq 0 ]
    run hammer --output csv --no-headers repository info --name="$repository_name" --product-id=$product_id --fields=id
  fi
  [ $status -eq 0 ]
  # returns repository_id
  echo "$output"
}

find_or_create_content_view() {
  local content_view_name="$1"
  local org_id="$2"
  local composite=${3:-false}
  local import_only=${4:-false}
  run hammer --output csv --no-headers content-view info --name="$content_view_name" --organization-id=$org_id --fields=id
  if [ $status != 0 ]; then
    if $composite ; then
      run hammer content-view create --name="$content_view_name" --organization-id=$org_id --composite| grep -q "created"
    elif $import_only ; then
      run hammer content-view create --name="$content_view_name" --organization-id=$org_id --import-only| grep -q "created"
    else
      run hammer content-view create --name="$content_view_name" --organization-id=$org_id| grep -q "created"
    fi
    [ $status -eq 0 ]
    run hammer --output csv --no-headers content-view info --name="$content_view_name" --organization-id=$org_id --fields=id
  fi
  [ $status -eq 0 ]
  # returns content_view_id
  echo "$output"
}

find_metadata_file() {
  local history_id=$1
  run hammer --output csv --no-headers  content-export list --id=$history_id --fields=path
  [ $status -eq 0 ]
  local path=${output}
  local  metadata_filename="metadata-$history_id.json" # metadata-16.json
  if [ -f "${path}/metadata.json" ]; then
    echo "${path}/metadata.json"
  else
    echo "$(pwd)/${metadata_filename}"
  fi
}

# @test "create a product" {
#   hammer product create --organization="${ORGANIZATION}" --name="${PRODUCT}" | grep -q "Product created"
# }
