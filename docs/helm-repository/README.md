# helm-repo

Provides a helm repository for the helm charts used in the deployments.

## Usage

To update the `index.yaml` file, copy the new (or updated) helm packages (`*.tgz`) on the working folder of this repository and execute the `./build.sh` script. This will update the `index.yaml` file with the information of all the packages contained in this folder.

### Example

```
cp /path/to/helm-package.tgz /this/folder/helm-package.tgz
./build.sh
```

## GitHub Pages

This git repository uses the GitHub Pages feature to expose the helm repository to the world (See `Settings>GitHub Pages` for details). The URL of the helm repository is:

> Your site is published at https://alfpedraza-aws-devops.github.io/helm-repository/
