variable "PROFILE" {
    type = string
    default = null
}

variable "SSH_HOST_DATA" {
    type = object({
        SSH_PRI_KEYs = list(string)
        SSH_HOST_USERs = list(string)
        SSH_HOST_IPs = list(string)
    })

    default = {
        SSH_PRI_KEYs = []
        SSH_HOST_USERs = []
        SSH_HOST_IPs = []
    }
}

variable "SSH_PRI_KEY_FROM_S3_TO_RUNNER_DATA" {
    type = object({
        RUNNER_DIR = string
        RUNNER_FILE = string
        S3_FILE = string
    })

    default = {
        RUNNER_DIR = ""
        RUNNER_FILE = ""
        S3_FILE = ""
    }
}