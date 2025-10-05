## Note

### `aws_transfer_tag` for custom hostname

[aws_transfer_tag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_tag) resource only supports aws provider v4.35.0 and higher. If you see more details, please refer to [aws_transfer_server custom hostname via alternate mechanism #18077](https://github.com/hashicorp/terraform-provider-aws/issues/18077#issuecomment-1273904488).

```hcl
# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

This prevents using unsupported versions (below 4.35.0) and ensures `aws_transfer_tag` resource works properly.