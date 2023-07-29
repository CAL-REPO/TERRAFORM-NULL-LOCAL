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

resource "null_resource" "SET_SSH_PRI_KEY_FROM_S3_FILE_TO_GIT_ACTION_RUNNER" {
    count = (var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.S3_PRI_KEY_FILE != "" ? 1 : 0)
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF
            mkdir -p "${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.RUNNER_DIR}"
            chmod -R 777 "${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.RUNNER_DIR}"
            if [[ ! -f "${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.RUNNER_PRI_KEY_FILE}" ]] then
                aws s3 cp "s3://${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.S3_PRI_KEY_FILE}" "${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.RUNNER_PRI_KEY_FILE}"  --profile ${var.PROFILE}
            fi
            while [ ! -f "${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.RUNNER_PRI_KEY_FILE}" ]; do
                sleep 3
            done
            chmod 400 "${var.SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA.RUNNER_PRI_KEY_FILE}"
        EOF
    }
}

resource "null_resource" "WAIT_HOST_FOR_SSH_CONNECTION" {
    count = (var.SSH_HOST_DATA.SSH_PRI_KEY_FILE != "" ? 1 : 0)
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF

        if [[ -n "${var.SSH_HOST_DATA.SSH_PRI_KEY_FILE}" ]] && [[ -n "${var.SSH_HOST_DATA.SSH_HOST_USER}" ]] && [[ -n "${var.SSH_HOST_DATA.SSH_HOST_IP}" ]]; then
            SSH_PRI_KEY_FILE="${var.SSH_HOST_DATA.SSH_PRI_KEY_FILE}"
            SSH_HOST_USER="${var.SSH_HOST_DATA.SSH_HOST_USER}"
            SSH_HOST_IP="${var.SSH_HOST_DATA.SSH_HOST_IP}"
            echo "Waiting for the remote PC to reboot and SSH to become available..."
            while true; do
                if ssh -q -o "StrictHostKeyChecking=no" -i "$SSH_PRI_KEY_FILE" "$SSH_HOST_USER@$SSH_HOST_IP" exit; then
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