variable "PROFILE" {
    type = string
    default = null
}

variable "APPLY_SCRIPTs" {
    type = list(object({
        ALWAYS = optional(bool)
        PRE_COMMAND = optional(string)
        NAME = optional(string)
        VARIANTs = optional(list(string))
        POST_COMMAND = optional(string)
    }))
    default = []
}

variable "DESTROY_SCRIPTs" {
    type = list(object({
        ALWAYS = optional(bool)
        PRE_COMMAND = optional(string)
        NAME = optional(string)
        VARIANTs = optional(list(string))
        POST_COMMAND = optional(string)
    }))
    default = []
}