# terraform-aws-instance
This repo helps you to get started with deploying apache server in aws instance. AWS knowledge like vpc(route, subnet, cidr etc), ec2 instance, is required.

## Following are the details we are executing with terraform:
1. `Create VPC`
2. `Create Internet Gateway`
3. `Create Custom Route Table`
4. `Create a Subnet`
5. `Associate Subnet with Route Table`
6. `Create Security Group to allow ports 22, 80, 443,`
7. `Create a network interface with an IP in the subnet created in step 4`
8. `Assign an elastic IP to the network interface created in step 7`
9. `Create Ubuntu Server and install/enable apache2`

## Prerequiste
1. Create AWS Free tier Account
2. Create Access and Secret key from the AWS Account. 
3. Create ssh key-pair from ec2 service and save it as you like. In any case, if we want to login to the server, this key is needed.

## Terraform Command Guidelines
- `terraform init` ⇒ This will initialize the terraform and download the necessary configurations of the providers.
- `terraform fmt` ⇒ This will format all the terraform codes. If any error: it will also print the errors in the code.
- `terraform validate` ⇒ This will validate the configuration files. If any error in configuration files: it will also print the errors.
- `terraform plan` ⇒ This is a sort of dry run and lets you know what is happening before executing the code. It will print all the changes that are going to happen once you execute the `terraform apply`.
- `terraform apply` ⇒ This will apply the actual changes. It will print all the changes going to happen and will ask for the ‘yes’ confirmation. You can pass arguments -auto-approve which will directly execute the changes instead of prompting for the confirmation.


## Each Step Details  
Before moving to each detail step, lets talk about the aws provider. We need to first create the aws provider and need to provide the access key and secret key. This key has to be generated from the aws web console. Also, we need to mention which region we are working.
Wherever you see `var.somevariablesname`, please refer to the file `variables.tf`. All the variables are stored in that file. Feel free to modify those variables as per your need and desire.
Now let's begin:  

1. `Create VPC`  
 First, we need to create the VPC. VPC requires a cidr_block which essentially has to be defined by you. Feel free to use your own cidr_block. Follow the terraform documentation [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) with tags.
2. `Create Internet Gateway`  
Second, we need to create the gateway to the internet. Follow the terraform documentation [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).
3. `Create Custom Route Table`
Third, we need to create the custom route with aws route table. This will route the internal network to the internet via internet gateway created in steps 2. Follow the terraform documentation [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table).
4. `Create a Subnet`  
After creating custom route table, let's create a subnet. It is important to have this subnet has to be within the vpc cidr blocks. Also provide the availability zone and it will create subnet for that availability zone. Feel free to create your own subnet. For more info, follow the terraform documentation [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).
5. `Associate Subnet with Route Table`  
Then, we need to associate the above created subnet with the route table which we have created in step 3. This association causes traffic from the subnet or gateway to be routed according to the routes in the route table. For more info, follow the terraform documentation [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association).
6. `Create Security Group to allow ports 22, 80, 443,`  
This security group allows:
    - ingress: incoming traffic for the ports 22, 80, 443 (cidr_blocks is important: from where you want to provide the access to).
    - egress: outgoing traffic to the internet for all the prod-vpc cidr_blocks.  
     For more info, follow the terraform documentation [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group).  
7. `Create a network interface with an IP in the subnet created in step 4`  
Then create a network interface for the instance with the private IP. This private ip needs to be from the subnet cidr_block. Also provide the security group, so that allowed ports in the security group will be applied in this newly created network interface. For more info, follow the terraform documentation [aws_network_interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface).  
8. `Assign an elastic IP to the network interface created in step 7`  
Now before creating aws ec2 instance, we need to create the elastic IP which is a  reserved public IP address that you can assign to any EC2 instance in a particular region, until you choose to release it. To create elastic IP, we also need to provide the network interface and the private IP, so that the security policy we have applied will be mapped from Public IP to private IP. For more info, follow the terraform documentation [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip).  
9. `Create Ubuntu Server (ec2 instance) and install/enable apache2`  
Now finally, lets create the Ubuntu 20.04 ec2 instance. To create the ubuntu instance, you need `ami`(amazon machine image, please copy the ami id from your own region, because ami id differs from region to region), `availability_zone`, `instance_type`(t2.micro in this case which is free) and the `key_name`(please check the key name from `variables.tf`. This key name has to be the same while you saved it when you have generated the ssh key-pair from ec2 service aws console.) Other few notable things are:  
    - `volume_size`: AWS free tier provides upto 30Gib volume to use. By default, t2.micro instance is 8Gib.  
    - `network_interface`: We need to provide the device index and the network interface id. This will set the IP and the network interface with the index number. For example eth0, eth1..  
    - `user_data`: This user data will execute the set of commands in the ubuntu server. Here, we told it to update, install, start and enable apache2 server.  
    - `tags`: Name of the instance.  
For more info, follow the terraform documentation [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).  
## Output
Output will helps to show the output saved as a `output <variables>`. You can output anything you like. This is like a function returning the value. Whichever value we want, we can output it. Here the outputs are: private ip, public ip and public DNS. 


## YAY!!! :sunglasses: Terraformic :wink:
