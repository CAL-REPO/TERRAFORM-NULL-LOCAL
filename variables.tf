variable "PROFILE" {
    type = string
    default = null
}

variable "SCRIPTs" {
    type = list(object({
        ALWAYS = optional(bool)
        DESTROY = optional(bool)
        PRE_COMMAND = optional(string)
        NAME = optional(string)
        VARIANTs = optional(list(string))
        POST_COMMAND = optional(string)
    }))
    default = []
}