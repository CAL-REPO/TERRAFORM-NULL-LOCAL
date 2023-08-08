variable "PROFILE" {
    type = string
    default = null
}

variable "SCRIPTs" {
    type = list(object({
        ALWAYS = optional(bool)
        NAME = string
        VARIANTs = optional(list(string))
    }))
    default = []
}