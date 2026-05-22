output "glue_sg_id" {  
    value = aws_security_group.glue_sg.id
}


output "glue_job_name" {
    value = aws_glue_job.extract_job.name
}