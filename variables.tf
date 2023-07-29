variable "PROFILE" {
    type = string
    default = null
}

variable "PRI_KEY_FILE_FROM_S3_TO_RUNNER" {
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

variable "WAIT_REMOTE_HOST_FOR_CONNECTION" {
    type = object({
        LOCAL_HOST_PRI_KEY_FILE = string
        REMOTE_HOST_USER = string
        REMOTE_HOST_IP = string
    })

    default = {
        LOCAL_HOST_PRI_KEY_FILE = ""
        REMOTE_HOST_USER = ""
        REMOTE_HOST_IP = ""
    }
}