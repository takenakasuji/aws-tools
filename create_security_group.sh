#==========Create Security Group==========
export VPCID=<input vpc-id>
export GROUPNAME=<input group name>
export DESCRIPTION=<input description>

export GROUPID=$(aws ec2 create-security-group --group-name $GROUPNAME --description $DESCRIPTION --vpc-id $VPCID | awk '/GroupId/ {gsub(/\"/, "");gsub(/,/,""); print $2}')

