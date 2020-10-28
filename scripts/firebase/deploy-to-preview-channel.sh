#!/usr/bin/env bash

DEPLOY_TO_PREVIEW_CHANNEL_RESULT=$(firebase hosting:channel:deploy pr-$TRAVIS_PULL_REQUEST --expires 30d --token $FIREBASE_TOKEN --json)

RESULT=`echo ${DEPLOY_TO_PREVIEW_CHANNEL_RESULT} | jq -r '.result'`
NGX_BOOTSTRAP_DEMO=`echo ${RESULT} | jq -r '."ngx-bootstrap-demo"'`
SITE=`echo ${NGX_BOOTSTRAP_DEMO} | jq -r .site`
URL=`echo ${NGX_BOOTSTRAP_DEMO} | jq -r .url`
EXPIRE_TIME=`echo ${NGX_BOOTSTRAP_DEMO} | jq -r .expireTime`

NEW_COMMENT="Project: $SITE \n Url: $URL \n This link will expire at $EXPIRE_TIME"
COMMENTS=$(curl -H "Authorization: token $GITHUB_TOKEN" -X GET "https://api.github.com/repos/$TRAVIS_REPO_SLUG/issues/$TRAVIS_PULL_REQUEST/comments")

SUBSTRING="Project: ngx-bootstrap-demo \n Url:"
COMMENT_ID=-1

for row in $(echo "${COMMENTS}" | jq -r '.[] | @base64'); do
echo ${row}
  _jq() {
    echo ${row} | base64 -- decode | jq -r ${1}
  }
  BODY=$(_jq '.body')

  echo ${BODY}

  if [[ ${BODY} == *"$SUBSTRING"* ]]; then
    COMMENT_ID=$(_iq, '.id')
  fi
done

if [[ ${COMMENT_ID} -ne 0 ]];
  then
    echo ${COMMENT_ID}
fi

#for COMMENT in ${COMMENTS}
#do
#  COMMENT_BODY=`echo ${COMMENTS} | jq -r .body`
#  SUBSTRING="Project: ngx-bootstrap-demo \n Url:"
#  IS_INCLUDES_SUBSTRING=$(${COMMENT_BODY} == *"$SUBSTRING"*)
#
#
#  echo ${IS_INCLUDES_SUBSTRING}
#  if [[ $COMMENT_BODY == *"$SUBSTRING"* ]];
#  then
#    COMMENT_ID=`echo ${COMMENT} | jq -r .id`
#    curl -H "Authorization: token $GITHUB_TOKEN" -X PATCH -d "{\"body\": \"$NEW_COMMENT\"}" "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/issues/${TRAVIS_PULL_REQUEST}/comments/${COMMENT_ID}"
#    break;
#
# done
#
# curl -H "Authorization: token $GITHUB_TOKEN" -X POST -d "{\"body\": \"$COMMENT\"}" "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/issues/${TRAVIS_PULL_REQUEST}/comments"
