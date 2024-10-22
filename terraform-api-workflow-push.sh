#bash script

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 1. Define Variables

if [ -z "$1" ] || [ -z "$2" ]; then
    log "Error: Missing arguments"
    log "Usage: $0 <path_to_content_directory> <organization>/<workspace>"
    exit 1
fi

CONTENT_DIRECTORY="$1"
ORG_NAME="$(cut -d'/' -f1 <<<"$2")"
WORKSPACE_NAME="$(cut -d'/' -f2 <<<"$2")"

log "Starting Terraform Enterprise push script"
log "Content directory: $CONTENT_DIRECTORY"
log "Organization: $ORG_NAME"
log "Workspace: $WORKSPACE_NAME"

# Check if TOKEN is set
if [ -z "$TOKEN" ]; then
    log "Error: TOKEN environment variable is not set"
    exit 1
fi

# 2. Create the File for Upload

UPLOAD_FILE_NAME="./content-$(date +%s).tar.gz"
log "Creating tarball: $UPLOAD_FILE_NAME"
tar --exclude='*.tar.gz' -zcvf "$UPLOAD_FILE_NAME" -C "$CONTENT_DIRECTORY" .
if [ $? -ne 0 ]; then
    log "Error: Failed to create tarball"
    exit 1
fi
log "Tarball created successfully"

# Create a directory to store JSON responses
JSON_DIR="./terraform_api_responses/$(date +'%Y-%m-%d')"
mkdir -p "$JSON_DIR"
log "Created directory for JSON responses: $JSON_DIR"

# 3. Look Up the Workspace ID

log "Looking up Workspace ID"
WORKSPACE_RESPONSE=$(curl \
    --silent \
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/organizations/$ORG_NAME/workspaces/$WORKSPACE_NAME")

echo "$WORKSPACE_RESPONSE" > "$JSON_DIR/workspace_response.json"
log "Saved workspace response to $JSON_DIR/workspace_response.json"

WORKSPACE_ID=$(echo "$WORKSPACE_RESPONSE" | jq -r '.data.id')

if [ -z "$WORKSPACE_ID" ]; then
    log "Error: Failed to retrieve Workspace ID"
    exit 1
fi
log "Workspace ID: $WORKSPACE_ID"

# 4. Create a New Configuration Version

log "Creating new configuration version"
CONFIG_VERSION_PAYLOAD='{"data":{"type":"configuration-versions"}}'
echo "$CONFIG_VERSION_PAYLOAD" > "$JSON_DIR/config_version_request.json"
log "Saved configuration version request payload to $JSON_DIR/config_version_request.json"

CONFIG_VERSION_RESPONSE=$(curl \
    --silent \
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "$CONFIG_VERSION_PAYLOAD" \
    "https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/configuration-versions")

echo "$CONFIG_VERSION_RESPONSE" > "$JSON_DIR/config_version_response.json"
log "Saved configuration version response to $JSON_DIR/config_version_response.json"

UPLOAD_URL=$(echo "$CONFIG_VERSION_RESPONSE" | jq -r '.data.attributes."upload-url"')

if [ -z "$UPLOAD_URL" ]; then
    log "Error: Failed to get upload URL"
    exit 1
fi
log "Upload URL obtained"

# 5. Upload the Configuration Content File

log "Uploading configuration content"
UPLOAD_RESPONSE=$(curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    --header "Content-Type: application/octet-stream" \
    --request PUT \
    --data-binary @"$UPLOAD_FILE_NAME" \
    "$UPLOAD_URL")

if [ "$UPLOAD_RESPONSE" != "200" ]; then
    log "Error: Upload failed with HTTP status $UPLOAD_RESPONSE"
    exit 1
fi
log "Upload completed successfully"

# 6. Delete Temporary Files

log "Cleaning up temporary files"
rm "$UPLOAD_FILE_NAME"
rm ./create_config_version.json
log "Temporary files removed"

log "Script completed successfully"