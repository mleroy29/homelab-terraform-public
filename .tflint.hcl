plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

config {
  ignore_module = {
    ".terraform" = true
  }
}