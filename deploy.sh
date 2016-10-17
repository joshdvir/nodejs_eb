# deploy.sh
#! /bin/bash

# Create new Elastic Beanstalk version
export NODE_ENV=production
ZIP_FILE=$CIRCLE_BUILD_NUM-$SERVICE_NAME.zip

sed -e "s/<ENV>/$NODE_ENV/" \
    -e "s/<SERVICE_NAME>/$SERVICE_NAME/" \
    < .ebextensions/04-define-hostname.config.template \
    > .ebextensions/04-define-hostname.config

sed -e "s/<TAG>/$CIRCLE_BUILD_NUM/" < Dockerrun.aws.json.template > Dockerrun.aws.json

zip -r -9 $ZIP_FILE Dockerrun.aws.json .ebextensions/

aws s3 cp $ZIP_FILE s3://$EB_BUCKET/$BUCKET_FOLDER/$ZIP_FILE

echo "Creating new ElasticBeanstalk application version"
aws elasticbeanstalk \
    create-application-version --application-name $APPLICATION_NAME \
    --version-label $CIRCLE_BUILD_NUM-$CIRCLE_BRANCH \
    --source-bundle S3Bucket=$EB_BUCKET,S3Key=$BUCKET_FOLDER/$ZIP_FILE \
    --region=$REGION

# Update Elastic Beanstalk environment to new version
echo "Updating ElasticBeanstalk"
aws elasticbeanstalk update-environment \
    --environment-name $ENVIRONMENT_NAME \
    --version-label $CIRCLE_BUILD_NUM-$CIRCLE_BRANCH \
    --region=$REGION
