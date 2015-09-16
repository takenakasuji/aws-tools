#==========Create Security Group==========
export VPCID=<input vpc-id>
export GROUPNAME=<input group name>
export DESCRIPTION=<input description>
export SSH=<input ssh port number>
export HTTP=<input HTTP port number>

# Create Security Group
export GROUPID=$(aws ec2 create-security-group --group-name $GROUPNAME --description $DESCRIPTION --vpc-id $VPCID | awk '/GroupId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')

# Add Ingress Rule
aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port $SSH --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port $HTTP --cidr 0.0.0.0/0