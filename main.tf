# Standard AWS Provider Block
terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
    }
}

resource "null_resource" "WAIT_HOST_FOR_SSH_CONNECTION" {
    count = (length(var.SSH_PRI_KEYs) > 0 ?
            length(var.SSH_PRI_KEYs) : 0)
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF

        if [[ -n "${var.SSH_PRI_KEY[count.index]}" ]] && [[ -n "${var.SSH_HOST_USER[count.index]}" ]] && [[ -n "${var.SSH_HOST_IP[count.index]}" ]]; then
            SSH_PRI_KEY="${var.SSH_PRI_KEY[count.index]}"
            SSH_HOST_USER="${var.SSH_HOST_USER[count.index]}"
            SSH_HOST_IP="${var.SSH_HOST_IP[count.index]}"
            echo "Waiting for the remote PC to reboot and SSH to become available..."
            while true; do
                if ssh -q -o "StrictHostKeyChecking=no" -i "$SSH_PRI_KEY" "$SSH_HOST_USER@$SSH_HOST_IP" exit; then
                    echo "SSH connection is now available. Remote PC has rebooted successfully."
                    break
                else
                    echo "SSH connection not available yet. Waiting for 10 seconds..."
                    sleep 10
                fi
            done
        fi
        EOF
    }
}