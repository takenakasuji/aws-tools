#==========Create VPC base part==========
# Declare Environment Variable 
export CIDR=10.0.0.0/16
export VPCNAME=TEST1

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

#==========Set Name Tag to DHCP Option part==========
# Declare Environment Variable 
export DHCPOPSNAME=MyDHCP
export DHCPOPSID=$(aws ec2 describe-vpcs --vpc-ids $VPCID --query Vpcs[].DhcpOptionsId[] --output text)

# Set Name Tag
aws ec2 create-tags --resources $DHCPOPSID --tags Key=Name,Value=$DHCPOPSNAME

# Confirm
aws ec2 describe-dhcp-options --dhcp-options-ids $DHCPOPSID

read -p "Press [Enter] key to resume."

#==========Create Subnet part==========
# Declare Environment Variable
export SUBNET1CIDR=10.0.0.0/24
export SUBNET1AZ=ap-northeast-1a
export SUBNET1NAME=MySUBNET1A
export SUBNET2CIDR=10.0.1.0/24
export SUBNET2AZ=ap-northeast-1c
export SUBNET2NAME=MySUBNET1C

# Create Subnet
export SUBNET1ID=$(aws ec2 create-subnet --vpc-id $VPCID --cidr-block $SUBNET1CIDR --availability-zone $SUBNET1AZ | awk '/SubnetId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')
export SUBNET2ID=$(aws ec2 create-subnet --vpc-id $VPCID --cidr-block $SUBNET2CIDR --availability-zone $SUBNET2AZ | awk '/SubnetId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')

# Set Name tag
aws ec2 create-tags --resources $SUBNET1ID --tags Key=Name,Value=$SUBNET1NAME
aws ec2 create-tags --resources $SUBNET2ID --tags Key=Name,Value=$SUBNET2NAME

# Auto Assign Public IP Address
aws ec2 modify-subnet-attribute --subnet-id $SUBNET1ID --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $SUBNET2ID --map-public-ip-on-launch

# Confirm
aws ec2 describe-subnets --subnet-ids $SUBNET1ID
aws ec2 describe-subnets --subnet-ids $SUBNET2ID

read -p "Press [Enter] key to resume."

#==========Create Route Table part==========
# Declare Environment Variable
export RTNAME=MyROUTER
export SUBNETLIST=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPCID" "Name=tag-key,Values=Name" "Name=tag-value,Values=*SUBNET*" --query 'Subnets[].SubnetId[]' --output text)

# Create Route Table
export RTID=$(aws ec2 create-route-table --vpc-id $VPCID | awk '/RouteTableId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')

# Set Name Tag
aws ec2 create-tags --resources $RTID --tags Key=Name,Value=$RTNAME

# Add Route
aws ec2 create-route --route-table-id $RTID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGWID
for SUBNET in $SUBNETLIST
do
	aws ec2 associate-route-table --route-table-id $RTID --subnet-id $SUBNET
done

# Confirm
aws ec2 describe-route-tables --route-table-ids $RT1ID

read -p "Press [Enter] key to resume."