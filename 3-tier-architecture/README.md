This is a standard 3-tier monolithic architecture for AWS deployment. The client will interact with Route53, which routes traffic to an Application Load Balancer (ALB). The ALB sends traffic to two EC2 instances, distributed accross two availability zones. As expected, the database-tier resides in a private subnet. The VPC and private/public subnet set-up, internet and NAT gateway and subsequent route tables, alongside the appropriate security group rules have been set accordingly. 

Now, the terraform deployment configures the EC2 by running the appropriate bashscripts for the user-data argument (fed to the argument through a local value). The architecture is as follows:


![image](https://user-images.githubusercontent.com/98710900/203857458-5ddec2f1-1667-438a-b867-555e565ea006.png)
