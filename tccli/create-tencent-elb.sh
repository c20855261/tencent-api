#!/bin/bash

# 騰訊雲API的Secret ID和Secret Key
SECRET_ID=""
SECRET_KEY=""

# 騰訊雲地域和可用區域
REGION="ap-hongkong"
ZONE="ap-hongkong-1"

# ELB信息
NUMBER=`cat /dev/urandom | tr -dc '0-9' | fold -w 4 | head -n 1`
LOAD_BALANCER_NAME="api-elb-${NUMBER}"
LOAD_BALANCER_TYPE="OPEN"
LOAD_BALANCER_PROTOCOL="TCP"
LISTENER_PORT=("80" "443")
INSTANCE_ID=("ins-rbvt1123")
VPC_ID="vpc-ez123" #未配置會使用預設

# 創建ELB
echo -e "Creating ELB...\n"

#LOAD_BALANCER_OUTPUT=$(tccli clb CreateLoadBalancer --LoadBalancerName $LOAD_BALANCER_NAME --LoadBalancerType ${LOAD_BALANCER_TYPE} --region $REGION --secretId $SECRET_ID --secretKey $SECRET_KEY)

LOAD_BALANCER_OUTPUT=$(tccli clb CreateLoadBalancer --LoadBalancerName $LOAD_BALANCER_NAME --LoadBalancerType ${LOAD_BALANCER_TYPE} --VpcId $VPC_ID --region $REGION --secretId $SECRET_ID --secretKey $SECRET_KEY)


LOAD_BALANCER_ID=$(echo $LOAD_BALANCER_OUTPUT | jq -r '.LoadBalancerIds[0]')
echo -e "\nLOAD_BALANCER_NAME: ${LOAD_BALANCER_NAME}\n"
echo -e "LOAD_BALANCER_ID: ${LOAD_BALANCER_ID}" && sleep 5

# 創建監聽器
echo -e "\nCreating listener..."
for i in ${LISTENER_PORT[@]};do
LISTENER_OUTPUT=$(tccli clb CreateListener --cli-unfold-argument \
            --HealthCheck.UnHealthNum 4 \
            --HealthCheck.HealthNum 4 \
            --HealthCheck.IntervalTime 7 \
            --HealthCheck.TimeOut 5 \
            --HealthCheck.HealthSwitch 1 \
            --Protocol TCP \
            --Ports ${i} \
            --ListenerNames ${i} \
            --LoadBalancerId ${LOAD_BALANCER_ID} \
            --region $REGION --secretId $SECRET_ID --secretKey $SECRET_KEY)

LISTENER_ID=$(echo $LISTENER_OUTPUT | jq -r '.ListenerIds[0]')

echo -e "\nCreated ListenerId: $LISTENER_ID" && sleep 5

# Add backend servers
  for j in ${INSTANCE_ID[@]};do
    echo -e "\nAdding backend servers..."

    tccli clb RegisterTargets --cli-unfold-argument \
      --LoadBalancerId $LOAD_BALANCER_ID \
      --ListenerId ${LISTENER_ID} \
      --Targets.0.InstanceId ${j} \
      --Targets.0.Port ${i} \
      --Targets.0.Weight 10 \
      --secretId $SECRET_ID --secretKey $SECRET_KEY --region $REGION
   sleep 5
   done
done

LOAD_BALANCER_DOMAIN=$(tccli clb DescribeLoadBalancers \
    --LoadBalancerIds "[\"$LOAD_BALANCER_ID\"]" \
    --region $REGION --secretId $SECRET_ID --secretKey $SECRET_KEY | jq -r '.LoadBalancerSet[0].LoadBalancerDomain[0]')
                                                                                                                        
echo -e "\n\nLoadBalancerdoamin: $LOAD_BALANCER_DOMAIN\n"
