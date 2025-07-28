# Quick Reference - EC2 Provisioning

## Quick Start

```bash
# 1. Setup environment
cd ansible
./setup.sh

# 2. Edit configuration
vim group_vars/all.yml

# 3. Deploy instances
ansible-playbook ec2-provision.yml

# 4. Clean up (when done)
ansible-playbook terminate-instances.yml
```

## Common Commands

### Provision with Custom Settings
```bash
# Deploy 3 instances in production
ansible-playbook ec2-provision.yml -e "instance_count=3 environment=production"

# Use different instance type
ansible-playbook ec2-provision.yml -e "instance_type=t3.small"

# Deploy to specific region
ansible-playbook ec2-provision.yml -e "aws_region=us-west-2"
```

### Check Instance Status
```bash
# List running instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=train-schedule-app" --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value}"

# Check specific environment
aws ec2 describe-instances --filters "Name=tag:Environment,Values=production" --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress}"
```

### SSH to Instances
```bash
# SSH to instance
ssh -i ~/.ssh/my-key-pair.pem ec2-user@<public-ip>

# Check application status
ssh -i ~/.ssh/my-key-pair.pem ec2-user@<public-ip> "sudo systemctl status train-schedule"

# View application logs
ssh -i ~/.ssh/my-key-pair.pem ec2-user@<public-ip> "sudo journalctl -u train-schedule -f"
```

## Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| `Permission denied (publickey)` | Check key file permissions: `chmod 400 ~/.ssh/key.pem` |
| `Security group not found` | Ensure you have EC2 permissions in the region |
| `AMI not found` | Update AMI ID for your region in `group_vars/all.yml` |
| `Application not responding` | Check security group allows port 3000 |
| `Instance launch failed` | Check AWS service limits and subnet capacity |

### Debug Mode
```bash
# Run with verbose output
ansible-playbook ec2-provision.yml -vvv

# Check syntax
ansible-playbook ec2-provision.yml --syntax-check

# Dry run (check mode)
ansible-playbook ec2-provision.yml --check
```

### Manual Application Restart
```bash
# On the EC2 instance
sudo systemctl restart train-schedule
sudo systemctl status train-schedule
```

## Configuration Examples

### Multiple Environments
```yaml
# group_vars/development.yml
environment: development
instance_count: 1
instance_type: t3.micro

# group_vars/production.yml
environment: production
instance_count: 3
instance_type: t3.small
```

### Custom VPC
```yaml
vpc_id: vpc-12345678
subnet_id: subnet-12345678
security_group_name: custom-sg
```

## Useful AWS CLI Commands

```bash
# List key pairs
aws ec2 describe-key-pairs

# List AMIs
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*" --query "Images[*].[ImageId,Name,CreationDate]" --output table

# List security groups
aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName,Description]" --output table

# Check AWS credentials
aws sts get-caller-identity
```

## Application URLs

After deployment, access your application at:
- **HTTP**: `http://<public-ip>:3000`
- **SSH**: `ssh -i ~/.ssh/key.pem ec2-user@<public-ip>`

## Cost Estimation

| Instance Type | vCPUs | Memory | Storage | Cost/Hour (us-east-1) |
|---------------|-------|---------|---------|----------------------|
| t3.nano       | 2     | 0.5 GB  | EBS     | ~$0.0052            |
| t3.micro      | 2     | 1 GB    | EBS     | ~$0.0104            |
| t3.small      | 2     | 2 GB    | EBS     | ~$0.0208            |
| t3.medium     | 2     | 4 GB    | EBS     | ~$0.0416            |

*Prices may vary by region and are subject to change*