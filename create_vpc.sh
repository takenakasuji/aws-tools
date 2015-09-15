# Declare Environment Variable 
export CIDR=10.100.0.0/16
export VPCNAME=MyVPC

# Create VPC
export VPCID=$(aws ec2 create-vpc --cidr-block $CIDR | awk '/VpcId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')

# Configure VPC Name Tag 
aws ec2 create-tags --resources $VPCID --tags Key=Name,Value=$VPCNAME

# Configure VPC Attribute
aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-hostnames

# Confirm
aws ec2 describe-vpcs --vpc-ids $VPCID
aws ec2 describe-vpc-attribute --vpc-id $VPCID --attribute enableDnsSupport
aws ec2 describe-vpc-attribute --vpc-id $VPCID --attribute enableDnsHostnames