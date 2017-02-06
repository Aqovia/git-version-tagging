#!/bin/bash

# get highest tag number
EXISTING_VERSION_TAG=`git describe --abbrev=0 --tags`
EXISTING_VERSION=${EXISTING_VERSION_TAG:1}

# replace . with space so can split into an array
EXISTING_VERSION_PARTS=(${EXISTING_VERSION//./ })

# get number parts and increase last one by 1
EXISTING_VERSION_MAJOR=${EXISTING_VERSION_PARTS[0]}
EXISTING_VERSION_MINOR=${EXISTING_VERSION_PARTS[1]}
EXISTING_VERSION_PATCH=${EXISTING_VERSION_PARTS[2]}



# get major and minor version numbers
PACKAGE_VERSION=$(head -n 1 .version)
PACKAGE_VERSION=${PACKAGE_VERSION:1}

PACKAGE_VERSION_PARTS=(${PACKAGE_VERSION//./ })

PACKAGE_VERSION_MAJOR=${PACKAGE_VERSION_PARTS[0]}
PACKAGE_VERSION_MINOR=${PACKAGE_VERSION_PARTS[1]}



# determine new version
NEW_VERSION_MAJOR=$EXISTING_VERSION_MAJOR
NEW_VERSION_MINOR=$EXISTING_VERSION_MINOR
NEW_VERSION_PATCH=0

SKIP_TAGGING=false

if [ -z "$EXISTING_VERSION_TAG" ]; then # use package version numbers if no previous tags exist
    NEW_VERSION_MAJOR=$PACKAGE_VERSION_MAJOR
    NEW_VERSION_MINOR=$PACKAGE_VERSION_MINOR

elif [ "$PACKAGE_VERSION_MAJOR" -lt "$EXISTING_VERSION_MAJOR" ]; then
    SKIP_TAGGING=true # can't decrement version - skip tagging

elif [ "$PACKAGE_VERSION_MAJOR" -gt "$EXISTING_VERSION_MAJOR" ]; then
    NEW_VERSION_MAJOR=$PACKAGE_VERSION_MAJOR
    NEW_VERSION_MINOR=$PACKAGE_VERSION_MINOR

elif [ "$PACKAGE_VERSION_MINOR" -lt "$EXISTING_VERSION_MINOR" ]; then
    SKIP_TAGGING=true # can't decrement version - skip tagging

elif [ "$PACKAGE_VERSION_MINOR" -gt "$EXISTING_VERSION_MINOR" ]; then
    NEW_VERSION_MINOR=$PACKAGE_VERSION_MINOR

else
    NEW_VERSION_PATCH=$((EXISTING_VERSION_PATCH+1))
fi

# skip tagging if a versioning mismatch has occurred
if [ "$SKIP_TAGGING" = true ]; then
    echo "*WARNING* Skipping tagging due to versioning mismatch"
    exit
fi



# create new tag
NEW_VERSION="$NEW_VERSION_MAJOR.$NEW_VERSION_MINOR.$NEW_VERSION_PATCH"
NEW_VERSION_TAG="v$NEW_VERSION"
echo "Updating $EXISTING_VERSION_TAG to $NEW_VERSION_TAG"

# get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT`

# only tag if no tag already (would be better if the git describe command above could have a silent option)
if [ -z "$NEEDS_TAG" ]; then
    echo "Tagged with $NEW_VERSION_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "
    git tag $NEW_VERSION_TAG
    git push --tags
else
    echo "Already a tag on this commit"
fi