#!/bin/bash

#  http://jmespath.org/examples.html

export http_proxy=http://proxy-dev.aws.wiley.com:8080
export https_proxy=http://proxy-dev.aws.wiley.com:8080
export NO_PROXY="169.254.169.254,wiley.com"
export ANSIBLE_HOST_KEY_CHECKING=False

set +x

#declare -a COMP=(platform-srv business-srv scheduler-srv)

declare -A ALB=(
		[dev]="arn:aws:elasticloadbalancing:us-east-1:868651433674:loadbalancer/app/okta-private-dev-alb/409144ec8b29dc16" 
    		[qa]="arn:aws:elasticloadbalancing:us-east-1:868651433674:loadbalancer/app/okta-private-qa-alb/42d52f315318cfcf"
		)

declare -A OKTA=( [persistence-service]=platform-srv 
                  [logger-service]=platform-srv
                  [model-transformer-service]=platform-srv
                  [config-service]=platform-srv
                  [hr-application-controller-service]=business-srv
                  [hr-scim-controller-service]=business-srv
                  [hr-business-service]=business-srv
                  [ad-business-service]=business-srv
                  [scheduler-service]=scheduler-srv )

ip_output=okta-$CF_ENV-iplist

if [ -e $ip_output ]
then
  rm $ip_output
fi

echo ${OKTA[$SRV_NAME]}
asg_name=$(aws autoscaling describe-tags --filters Name=Value,Values=${OKTA[$SRV_NAME]} --query 'Tags[].ResourceId[]' --output text)
echo asg_name is $asg_name
echo "deploying $APP_VER to $SRV_NAME..."

for i in $asg_name
  do
  final_asg=$(aws autoscaling describe-tags --filters Name=auto-scaling-group,Values=$i Name=Key,Values=ServiceEnvName Name=Value,Values=$CF_ENV --query 'Tags[*].ResourceId[]' --output text)

    if [[ $final_asg ]] ; then
#      echo $CF_ENV, $c, $final_asg, 
#      echo "starting $CF_ENV $c"
#      echo "final_asg is $final_asg"
      ec2_instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $final_asg --query 'AutoScalingGroups[].Instances[].InstanceId' --output text)
      echo [$SRV_NAME] >> $ip_output
      
        for e in $ec2_instances
        do
#          echo "e is $e"
          instance_ip=$(aws ec2 describe-instances --instance-ids $e --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress[]' --output text)
          echo $instance_ip >> $ip_output
        done
      echo "======"
   fi

  done


####
#TGroupARN=$(aws elbv2 describe-target-groups --load-balancer-arn ${ALB[$CF_ENV]} --query "TargetGroups[?TargetGroupName=='$T'].TargetGroupArn" --output text)
#echo T is $T and TGroupARN is $TGroupARN
#aws elbv2 describe-target-groups --target-group-arns $TGroupARN 
#aws elbv2 modify-target-group --target-group-arn $TGroupARN --health-check-protocol TCP --health-check-port 22
#aws elbv2 describe-target-groups --target-group-arns $TGroupARN
####

ansible-playbook -i $ip_output -l $SRV_NAME -e "app_ver=$APP_VER target=$SRV_NAME build=$BUILD_TYPE" playbooks/pb-deploy-target.yml
