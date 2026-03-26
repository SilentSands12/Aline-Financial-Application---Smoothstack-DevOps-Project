/*
Test Summary:
This Go package defines a test function TestBackendResourcesExist that verifies the existence
of AWS resources necessary for backend infrastructure, specifically an S3 bucket and a DynamoDB table.
It uses Terratest, a Go library for testing infrastructure code, and the testify/assert library for assertions.
*/

package test

import (
    "testing"
    "os"
    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/stretchr/testify/assert"
)

// TestBackendResourcesExist verifies the existence of AWS S3 bucket and DynamoDB table.
func TestBackendResourcesExist(t *testing.T) {
    // Enable parallel execution of tests
    t.Parallel()

    // Retrieve AWS region from environment variable AWS_DEFAULT_REGION
    awsRegion := os.Getenv("AWS_DEFAULT_REGION")
    if awsRegion == "" {
        awsRegion = "us-east-1" // Default region if AWS_DEFAULT_REGION is not set
    }

    // Name of the S3 bucket and DynamoDB table to check
    s3BucketName := "terraform-s3-bucket-jc"
    dynamoDbTableName := "terraform-state-lock-jc"

    // Check if S3 bucket exists
    s3BucketExists := aws.GetS3BucketVersioning(t, awsRegion, s3BucketName)
    assert.NotNil(t, s3BucketExists, "S3 bucket does not exist: %s", s3BucketName)

    // Check if DynamoDB table exists
    dynamoDbTable := aws.GetDynamoDBTable(t, awsRegion, dynamoDbTableName)
    assert.NotNil(t, dynamoDbTable, "DynamoDB table does not exist: %s", dynamoDbTableName)
}
