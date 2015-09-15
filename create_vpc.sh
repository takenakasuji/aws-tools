#==========Create VPC base part==========
# Declare Environment Variable 
export CIDR=10.0.0.0/16
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

read -p "Press [Enter] key to resume."

#==========Create IGW part==========
# Declare Environment Variable 
export IGWNAME=MyIGW

# Create Internet Gateway
export IGWID=$(aws ec2 create-internet-gateway | awk '/InternetGatewayId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')

# Configure IGW Name Tag
aws ec2 create-tags --resources $IGWID --tags Key=Name,Value=$IGWNAME

# Allocate to VPC
aws ec2 attach-internet-gateway --internet-gateway-id $IGWID --vpc-id $VPCID

# Confirm
aws ec2 describe-internet-gateways --filters "Name=internet-gateway-id,Values=$IGWID"

read -p "Press [Enter] key to resume."