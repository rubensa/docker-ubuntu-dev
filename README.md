# Ubuntu image for local development

This image provides an Ubuntu environment useful for local development purposes.
The internal user (developer) has sudo and the image includes [fixuid](https://github.com/boxboat/fixuid) so you can set internal user (developer) UID and internal group (developers) GUID to your current UID and GUID by providing that info means of "-u" docker running option.

## Running

You can interactively run the container by mapping current user UID:GUID and working directory.

```
docker run --rm -it \
	--name "ubuntu-dev" \
	-v $(pwd):/home/developer/work \
	-w /home/developer/work \
	-u $(id -u $USERNAME):$(id -g $USERNAME) \
	rubensa/ubuntu-dev
```

This way, any file created in the container initial working directory is written and owned by current host user in the launch directory.
