provider "aws" {
    region = "us-east-1" # replace with your AWS region
}

resource "aws_security_group" "allow_http" {
    name        = "allow_http"
    description = "Allow HTTP inbound traffic"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "react_app" {
    ami           = "ami-0b72821e2f351e396" # replace with your AMI ID
    instance_type = "t2.micro"
    key_name      = "FirstJavaEndpointAppKeyPair" # replace with your key pair name
    vpc_security_group_ids = [aws_security_group.allow_http.id]

    user_data = <<-EOF
                            #!/bin/bash
                            sudo yum update -y
                            curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
                            sudo yum install -y nodejs
                            sudo yum install -y nginx
                            sudo systemctl start nginx
                            sudo systemctl enable nginx
                            git clone https://github.com/yourusername/your-react-app.git
                            cd your-react-app
                            npm install
                            npm run build
                            sudo cp -r build/* /usr/share/nginx/html/
                            EOF

    tags = {
        Name = "ReactAppInstance"
    }
}