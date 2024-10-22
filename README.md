# terraform-api-workflow
This is an example workflow on how to do an API driven workflow in HCP Terraform to deploy in Azure

# Terraform API-Driven Azure Deployment

This repository contains Terraform configurations and scripts for deploying Azure infrastructure using HCP Terraform's API-driven workflow. It demonstrates how to set up and manage Azure resources programmatically through the Terraform Cloud API.

## Repository Structure

```
terraform-api-workflow/
├── main.tf                 # Main Terraform configuration file
├── variables.tf            # Variable definitions
├── terraform-api-workflow-push.sh    # API workflow script
├── .gitignore             # Git ignore file
└── README.md              # This file
```

## Prerequisites

- HCP Terraform account
- Azure subscription
- Azure service principal with required permissions
- Bash-compatible shell
- `curl` and `jq` installed
- Terraform CLI (optional, for local testing)

## Configuration Files

### main.tf
Contains the main Terraform configuration for Azure resources:
- Resource group
- Virtual network
- Subnet
- Network interface
- Linux virtual machine

### variables.tf
Defines required variables:
- Azure credentials (subscription_id, client_id, client_secret, tenant_id)
- VM configuration options
- Required tags

### terraform-api-workflow-push.sh
Bash script that:
- Creates a tarball of your Terraform configuration
- Interacts with HCP Terraform's API
- Uploads configuration to your workspace
- Triggers new runs

## Setup Instructions

1. **HCP Terraform Configuration**
   ```bash
   # Set up workspace variables in HCP Terraform
   TF_VAR_client_id         (Environment variable)
   TF_VAR_client_secret     (Environment variable, marked as sensitive)
   TF_VAR_subscription_id   (Environment variable)
   TF_VAR_tenant_id        (Environment variable)
   ```

2. **Local Setup**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd terraform-api-workflow

   # Make the script executable
   chmod +x terraform-api-workflow-push.sh

   # Set your API token
   export TOKEN=your_terraform_cloud_api_token
   ```

3. **Using the Script**
   ```bash
   # Push configuration to HCP Terraform
   ./terraform-api-workflow-push.sh . your-organization/your-workspace-name
   ```

## Script Usage

```bash
./terraform-api-workflow-push.sh <path_to_content_directory> <organization>/<workspace>
```

Example:
```bash
./terraform-api-workflow-push.sh . myorg/azure-deployment
```

## API Workflow Process

1. Script creates a tarball of your Terraform configuration
2. Retrieves workspace ID from HCP Terraform
3. Creates a new configuration version
4. Uploads the configuration
5. HCP Terraform automatically starts a new run

## Monitoring Deployments

1. Log into HCP Terraform web interface
2. Navigate to your workspace
3. Monitor runs in the "Runs" tab
4. Review plans and apply changes as needed

## Azure Resources Created

This configuration creates:
- A resource group in East US
- A virtual network (10.0.0.0/16)
- A subnet (10.0.2.0/24)
- A network interface
- A Linux VM (Ubuntu 18.04 LTS)

## Important Notes

- Keep your API token secure and never commit it to version control
- The script creates a directory for API responses for debugging
- First-time setup requires proper Azure credentials
- Review the plan in HCP Terraform before applying changes

## Troubleshooting

Common issues and solutions:

1. **Authentication Failures**
   - Verify TOKEN environment variable is set
   - Ensure API token has proper permissions
   - Check Azure credential variables in HCP Terraform

2. **Upload Errors**
   - Verify organization and workspace names
   - Check network connectivity
   - Ensure content directory exists

3. **Script Permissions**
   - Run `chmod +x terraform-api-workflow-push.sh`
   - Verify bash is available

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Security Considerations

- Never commit sensitive credentials
- Use sensitive variables in HCP Terraform for secrets
- Regularly rotate API tokens and credentials
- Review access logs in HCP Terraform

## License

This project is licensed under the Apache 2.0 LICENSE - see the LICENSE file for details.

## Support

For issues and questions:
1. Create an issue in the repository
2. Check HCP Terraform documentation
3. Review Azure documentation for resource-specific questions

## Additional Resources

- [HCP Terraform Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [API-Driven Workflow Guide](https://developer.hashicorp.com/terraform/cloud-docs/run/api)
