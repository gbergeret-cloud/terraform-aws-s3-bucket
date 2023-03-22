package test

import (
   "testing"
   "github.com/gruntwork-io/terratest/modules/aws"
   "github.com/gruntwork-io/terratest/modules/terraform"
   "github.com/stretchr/testify/assert"
)

func TestSimpleBucket(t *testing.T) {
   t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        // The path to where our Terraform code is located
        TerraformDir: "../examples/simple_bucket",
    })

    // At the end of the test, run `terraform destroy`
    defer terraform.Destroy(t, terraformOptions)

    // Run `terraform init` and `terraform apply`.
    terraform.InitAndApply(t, terraformOptions)

    // Get the bucket so we can query AWS
    bucket := terraform.Output(t, terraformOptions, "bucket")

    // Check versioning is Enabled
    versionningStatus := aws.GetS3BucketVersioning(t, "eu-west-1", bucket)
    assert.Equal(t, "Enabled", versionningStatus)
}
