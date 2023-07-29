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

resource "null_resource" "CREATE_PRI_KEY_FILE_DIR_ON_RUNNER" {
    count = (var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.S3_PRI_KEY_FILE != "" ? 1 : 0)
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        on_failure = continue # Add this line to ignore errors
        command = <<-EOF
            mkdir -p "${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.RUNNER_DIR}"
            chmod -R 777 "${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.RUNNER_DIR}"
        EOF
    }
}

resource "null_resource" "PRI_KEY_FILE_FROM_S3_TO_RUNNER" {
    count = (var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.S3_PRI_KEY_FILE != "" ? 1 : 0)
    depends_on = [ null_resource.CREATE_PRI_KEY_FILE_DIR_ON_RUNNER ]
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF
            if [[ ! -f "${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.RUNNER_PRI_KEY_FILE}" ]] then
                aws s3 cp "s3://${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.S3_PRI_KEY_FILE}" "${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.RUNNER_PRI_KEY_FILE}"  --profile ${var.PROFILE}
            fi
            while [ ! -f "${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.RUNNER_PRI_KEY_FILE}" ]; do
                sleep 3
            done
            chmod 400 "${var.PRI_KEY_FILE_FROM_S3_TO_RUNNER.RUNNER_PRI_KEY_FILE}"
        EOF
    }
}

resource "null_resource" "WAIT_REMOTE_HOST_FOR_CONNECTION" {
    count = (var.WAIT_REMOTE_HOST_FOR_CONNECTION.LOCAL_HOST_PRI_KEY_FILE != "" ? 1 : 0)
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<-EOF
        if [[ -n "${var.WAIT_REMOTE_HOST_FOR_CONNECTION.LOCAL_HOST_PRI_KEY_FILE}" ]] && [[ -n "${var.WAIT_REMOTE_HOST_FOR_CONNECTION.REMOTE_HOST_USER}" ]] && [[ -n "${var.WAIT_REMOTE_HOST_FOR_CONNECTION.REMOTE_HOST_IP}" ]]; then
            LOCAL_HOST_PRI_KEY_FILE="${var.WAIT_REMOTE_HOST_FOR_CONNECTION.LOCAL_HOST_PRI_KEY_FILE}"
            REMOTE_HOST_USER="${var.WAIT_REMOTE_HOST_FOR_CONNECTION.REMOTE_HOST_USER}"
            REMOTE_HOST_IP="${var.WAIT_REMOTE_HOST_FOR_CONNECTION.REMOTE_HOST_IP}"
            echo "Waiting for the remote PC to reboot and SSH to become available..."
            echo "$LOCAL_HOST_PRI_KEY_FILE"
            echo "$REMOTE_HOST_USER@$REMOTE_HOST_IP"
            while true; do
                if ssh -q -o "StrictHostKeyChecking=no" -o "PreferredAuthentications=publickey" -i "$LOCAL_HOST_PRI_KEY_FILE" "$REMOTE_HOST_USER@$REMOTE_HOST_IP" exit; then
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