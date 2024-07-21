# Auto CV - Infrastructure

Input is acquired via API calls. To make sure inputs retention is not subject to
specific settings of the computational layer, the relevant API gateway should
deliver inputs to an SQS queue. Order is not important.

The computational layer is powered by a fleet of AWS Lambda instances. The
functions should generate the relevant output (e.g. PDF files) and upload them
to S3.

## TODO

- Should we support the possibility of uploading input JSONs to S3 somehow?
