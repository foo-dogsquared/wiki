OWNER="foodogsquared"
IMG="go-helloworld"
VERSION="1.0.0"
REMOTE_IMG="${OWNER}/${IMG}:v${VERSION}"

# Build the image with the tag already in place.
podman build --tag "$IMG" .

# Run the packaged app.
podman run -d -p 6111:6111 "$IMG"

# Verify it's running.
podman ps

# Create another image to push it into the Docker registry with the proper naming.
podman tag "$IMG" "$REMOTE_IMG"

# Push the image to the Docker registry.
podman push "$REMOTE_IMG"
