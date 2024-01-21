"""An AWS Python Pulumi program"""

import pulumi
from pulumi_aws import s3

# Create an AWS resource (S3 Bucket)
bucket = s3.Bucket('my-bucket',
  website=s3.BucketWebsiteArgs(index_document="index.html")
)

# Export the name of the bucket
pulumi.export('bucket_endpoint', pulumi.Output.concat('http://', bucket.website_endpoint))

public_access_block = s3.BucketPublicAccessBlock(
  'public-access-block', 
  bucket=bucket.id, 
  block_public_acls=False
)
def public_read_policy_for_bucket(bucket_name):
  return pulumi.Output.json_dumps({
      "Version": "2012-10-17",
      "Statement": [{
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": [
              pulumi.Output.format("arn:aws:s3:::{0}/*", bucket_name),
          ]
      }]
  })
s3.BucketPolicy('bucket-policy',
  bucket=bucket.id,
  policy=public_read_policy_for_bucket(bucket.id), 
  opts=pulumi.ResourceOptions(depends_on=[public_access_block])
)

bucketObject = s3.BucketObject(
  'index.html',
  content_type='text/html',
  bucket=bucket.id,
  source=pulumi.FileAsset('index.html'),
)
