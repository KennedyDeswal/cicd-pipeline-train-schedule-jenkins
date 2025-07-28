#!/bin/bash

# EC2 Provisioning Setup Script
# This script sets up the environment for running the Ansible playbooks

set -e

echo "🚀 Setting up EC2 Provisioning Environment..."

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install Ansible first."
    echo "   Ubuntu/Debian: sudo apt update && sudo apt install ansible"
    echo "   RHEL/CentOS: sudo yum install ansible"
    echo "   macOS: brew install ansible"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install AWS CLI first."
    echo "   Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Install required Ansible collections
echo "📦 Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml --force

# Create SSH directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Check for SSH key
echo "🔑 Checking SSH key configuration..."
if [ -f "group_vars/all.yml" ]; then
    KEY_NAME=$(grep "key_name:" group_vars/all.yml | awk '{print $2}' | tr -d '"')
    if [ ! -f ~/.ssh/${KEY_NAME}.pem ]; then
        echo "⚠️  SSH key file ~/.ssh/${KEY_NAME}.pem not found"
        echo "   Please ensure your EC2 key pair file is in ~/.ssh/ directory"
        echo "   and has the correct permissions (chmod 400 ~/.ssh/${KEY_NAME}.pem)"
    else
        chmod 400 ~/.ssh/${KEY_NAME}.pem
        echo "✅ SSH key found and permissions set"
    fi
fi

# Validate configuration
echo "🔍 Validating configuration..."
if [ -f "group_vars/all.yml" ]; then
    echo "✅ Configuration file found"
    
    # Check if default values need to be updated
    if grep -q "my-key-pair" group_vars/all.yml; then
        echo "⚠️  Please update the key_name in group_vars/all.yml with your actual key pair name"
    fi
    
    if grep -q "your-repo" group_vars/all.yml; then
        echo "⚠️  Please update the app_repo_url in group_vars/all.yml with your actual repository URL"
    fi
else
    echo "❌ Configuration file group_vars/all.yml not found"
    exit 1
fi

# Test AWS connectivity
echo "🌐 Testing AWS connectivity..."
AWS_REGION=$(grep "aws_region:" group_vars/all.yml | awk '{print $2}' | tr -d '"')
if aws ec2 describe-regions --region-names ${AWS_REGION} &> /dev/null; then
    echo "✅ AWS connectivity test passed"
else
    echo "❌ AWS connectivity test failed. Please check your credentials and region."
    exit 1
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review and update configuration in group_vars/all.yml"
echo "2. Ensure your SSH key pair exists in AWS EC2"
echo "3. Run the playbook: ansible-playbook ec2-provision.yml"
echo ""
echo "For help, see the README.md file"