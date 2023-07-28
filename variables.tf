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