variable "farewell_message" {
  description = "The final output of our journey."
  default     = "Every ending is a new beginning."
}

resource "smoothstack_teammate" "thanks" {
  count = 4
  name  = element(["Kinza", "Maria", "Janet", "Daniel"], count.index)
  role  = "support"
}

resource "journey" "smoothstack_experience" {
  provisioner "learning" {
    script = <<EOT
      echo "Growth through challenges, knowledge through collaboration."
    EOT
  }

  trigger_when_complete = ["pursue_new_opportunities"]
}

resource "goodbye_smoothstack" "final_stage" {
  depends_on = [journey.smoothstack_experience]

  lifecycle {
    create_before_destroy = true
  }

  farewell_note = "${var.farewell_message} Let's code onward!"

  }
output "best_wishes" {
    value = "Thanks for the memories, teammates!"
  }

  output "next_adventure" {
    value = "Destination: New Horizons 🚀"
  }


resource "legacy" "memories" {
  type = "unforgettable"
  teammates = ["support", "creativity", "laughter"]

  }
output "legacy_value" {
    value = "Always cherished, never forgotten."
  }

