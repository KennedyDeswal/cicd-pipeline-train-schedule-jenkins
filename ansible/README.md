# EC2 Instance Provisioning Playbook

This Ansible playbook automates the provisioning and configuration of EC2 instances for the train schedule application.

## Prerequisites

1. **AWS CLI configured** with appropriate credentials and permissions
2. **Ansible installed** (version 2.9 or higher)
3. **AWS collections installed** for Ansible
4. **SSH key pair** created in AWS EC2

## Installation

1. Install required Ansible collections:
```bash
ansible-galaxy collection install -r requirements.yml
```

2. Configure your AWS credentials:
```bash
aws configure
```

3. Update the variables in `group_vars/all.yml` with your specific configuration.

## Configuration

### Key Variables

Edit `group_vars/all.yml` to customize your deployment:

- `aws_region`: AWS region for deployment (default: us-east-1)
- `key_name`: Name of your EC2 key pair
- `instance_type`: EC2 instance type (default: t3.micro)
- `instance_count`: Number of instances to create
- `environment`: Environment tag (development, staging, production)
- `project_name`: Project name for tagging

### AMI Selection

The playbook uses Amazon Linux 2 AMI by default. Update `ami_id` in `group_vars/all.yml` for different regions:

- us-east-1: ami-0c02fb55956c7d316
- us-west-2: ami-0892d3c7ee96c0bf7
- eu-west-1: ami-0a8e758f5e873d1c1

## Usage

### Provision EC2 Instances

Run the main provisioning playbook:

```bash
cd ansible
ansible-playbook ec2-provision.yml
```

### With Custom Variables

Override default variables:

```bash
ansible-playbook ec2-provision.yml -e "instance_count=3 environment=production"
```

### Terminate Instances

To clean up resources:

```bash
ansible-playbook terminate-instances.yml
```

## Playbook Structure

```
ansible/
├── ec2-provision.yml      # Main provisioning playbook
├── terminate-instances.yml # Cleanup playbook
├── ansible.cfg           # Ansible configuration
├── requirements.yml      # Required collections
├── group_vars/
│   └── all.yml          # Global variables
└── inventory/
    └── hosts.yml        # Inventory template
```

## What the Playbook Does

1. **Creates Security Group**: Sets up firewall rules for SSH, HTTP, HTTPS, and application access
2. **Launches EC2 Instances**: Creates the specified number of instances with proper tagging
3. **Configures Instances**: Installs dependencies and sets up the train schedule application
4. **Verifies Deployment**: Checks if the application is running correctly

## Security Group Rules

The playbook creates a security group with the following rules:
- Port 22 (SSH): 0.0.0.0/0
- Port 80 (HTTP): 0.0.0.0/0
- Port 443 (HTTPS): 0.0.0.0/0
- Port 3000 (Node.js App): 0.0.0.0/0

## Application Setup

The user data script automatically:
1. Updates the system
2. Installs Node.js, npm, Git, and Java
3. Creates an application user
4. Clones the train schedule application
5. Builds the application
6. Creates a systemd service
7. Starts the application

## Accessing the Application

After successful deployment, access your application at:
```
http://<instance-public-ip>:3000
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure your AWS credentials have EC2 full access
2. **Key Pair Not Found**: Verify the key pair exists in the specified region
3. **SSH Connection Failed**: Check security group rules and key file permissions

### Logs

Check the application logs on the instance:
```bash
sudo journalctl -u train-schedule -f
```

### Manual SSH Access

Connect to instances manually:
```bash
ssh -i ~/.ssh/your-key-pair.pem ec2-user@<instance-ip>
```

## Customization

### Different Application

To deploy a different application, modify the user data script in `ec2-provision.yml`:
1. Change the git repository URL
2. Update build commands
3. Modify service configuration

### Network Configuration

For custom VPC deployment, set these variables:
```yaml
vpc_id: vpc-xxxxxxxxx
subnet_id: subnet-xxxxxxxxx
```

## Best Practices

1. **Use specific AMI IDs** for your region
2. **Tag all resources** for better management
3. **Use IAM roles** instead of access keys when possible
4. **Limit security group access** to specific IP ranges
5. **Regularly update** AMI IDs and dependencies

## Cost Optimization

- Use `t3.micro` or `t3.nano` for development
- Terminate instances when not needed
- Consider spot instances for non-production workloads
- Set up CloudWatch billing alarms