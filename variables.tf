variable "PROFILE" {
    type = string
    default = null
}

variable "SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA" {
    type = object({
        S3_PRI_KEY_FILE = string
        RUNNER_DIR = string
        RUNNER_PRI_KEY_FILE = string
    })

    default = {
        S3_PRI_KEY_FILE = ""
        RUNNER_DIR = ""
        RUNNER_PRI_KEY_FILE = ""
    }
}

variable "SSH_HOST_DATA" {
    type = object({
        SSH_PRI_KEY_FILE = string
        SSH_HOST_USER = string
        SSH_HOST_IP = string
    })

    default = {
        SSH_PRI_KEY_FILE = ""
        SSH_HOST_USER = ""
        SSH_HOST_IP = ""
    }
}