# --- application/variables.tf ---
output "instance_id1" {
  value = element(aws_instance.web_instance.*.id, 0)
}
output "instance_id2" {
  value = element(aws_instance.web_instance.*.id, 1)
}
output "instance_id3" {
  value = element(aws_instance.web_instance.*.id, 2)
}