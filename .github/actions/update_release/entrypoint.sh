#!/bin/sh

# create release
GITHUB_SHA_SHORT=$(echo ${GITHUB_SHA} | cut -c -7)
PDF_FILENAME=$(basename ${PDF_FILEPATH})
RES=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/${GITHUB_REPOSITORY}/releases \
-d"{
  \"tag_name\": \"v-${GITHUB_SHA_SHORT}\",
  \"target_commitish\": \"${GITHUB_SHA}\",
  \"name\": \"${PDF_FILENAME} v-${GITHUB_SHA_SHORT}\",
  \"draft\": false,
  \"prerelease\": false
}")

if [ $? -ne 0 ]
then
  echo "Could not create the new release: ${RELEASE_ID}"
  exit 1
fi

# extract release ID
RELEASE_ID=$(echo ${RES} | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")

# upload PDF
curl -s -f \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -X POST https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${PDF_FILENAME} \
  --header "Content-Type: application/pdf" \
  --upload-file ${PDF_FILEPATH}

if [ $? -ne 0 ]
then
  echo -n -e "\n"
  echo "Could not upload the PDF file: ${PDF_FILEPATH}"
  exit 1
fi
echo -n -e "\n"

# get the latest release ID
RES=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/latest)
LATEST_RELEASE_ID=$(echo ${RES} | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")
LATEST_RELEASE_TAG=$(echo ${RES} | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])")
echo "Created the new release: ${LATEST_RELEASE_ID} (${LATEST_RELEASE_TAG})"

# get all IDs of the releases
RES=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/${GITHUB_REPOSITORY}/releases)
RELEASE_IDS=$(echo ${RES} | python3 -c "import sys, json; [print(v['id']) for v in json.load(sys.stdin)]")
# remove the latest ID from the list
OLD_RELEASE_IDS=$(echo ${RELEASE_IDS} | sed -e "s/${LATEST_RELEASE_ID}//")
# delete old releases
for RELEASE_ID in ${OLD_RELEASE_IDS}
do
  echo "Deleted the old release: ${RELEASE_ID}"
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X DELETE https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}
done

# get all release tags
RES=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/${GITHUB_REPOSITORY}/git/matching-refs/tag)
RELEASE_TAGS=$(echo ${RES} | python3 -c "import sys, json; [print(v['ref'].split('/')[2]) for v in json.load(sys.stdin) if v['ref'].split('/')[2].startswith('v-')]")
OLD_RELEASE_TAGS=$(echo ${RELEASE_TAGS} | sed -e "s/${LATEST_RELEASE_TAG}//")
# delete old release tags
for RELEASE_TAG in ${OLD_RELEASE_TAGS}
do
  echo "Deleted the old tag: ${RELEASE_TAG}"
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X DELETE https://api.github.com/repos/${GITHUB_REPOSITORY}/git/refs/tags/${RELEASE_TAG}
done
