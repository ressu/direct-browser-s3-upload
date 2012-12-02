Direct Browser to S3 Upload
===========================

This is a small web service derived from the example created by [Carson McDonald](https://github.com/carsonmcdonald).

The original example has been altered to use jQuery, CoffeeScript and JSON in addition to the normal HTML5 FileAPI, XHR2, CORS and signed S3 PUT requests to upload files directly from a browser to S3.

Unlike the original example, this version allows you to directly deploy the service using [Capistrano](http://capistranorb.com) with as little modifications as possible. Credentials have been separated in to a standalone configuration file, which is excluded from git commits by default.

## Setting up Amazon S3 CORS

Before using any of the examples you will need to set up your S3 CORS data. It is easy enough to do that using the AWS console. The following is an example CORS configuration that should work wherever you install the example:

``` XML
<CORSConfiguration>
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>PUT</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>Content-Type</AllowedHeader>
        <AllowedHeader>x-amz-acl</AllowedHeader>
        <AllowedHeader>origin</AllowedHeader>
        <AllowedHeader>allowed</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

## Creating a separate account for uploads

It's a good idea to dedicate a single user just for the uploads. One way of doing this is to create an IAM user and applying the following policy to the newly created user:

``` JSON
{
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::<S3-Bucket-Name>/*"]
    }
  ]
}
```

Note down the key and secret of the newly created user.

## Configuring the service

There is a [sample file](config/aws-credentials.sample.rb) with the available configuration options. Copy this file to config/aws-credentials.rb and adjust settings to match your configuration.

Take care never to commit this file to the repository unless you are 100% certain that the repository will never be available in public.

## Deploying to a website

Even though you can run the service manually by either starting unicorn or sinatra manually, it's easy to deploy to a remote site.

Deployment is done with [Capistrano](http://capistranorb.com) and it sets up the remote environment with [RVM](http://rvm.io). You need to adjust the server name and installation path in the config/deploy.rb file. Other than that the service is ready to be deployed out of the box.

run `cap deploy:setup deploy` to deploy to a new server.

Note that it is not required to store the credentials in the repository if deploying with Capistrano. Credentials are copied over through the management connection.
