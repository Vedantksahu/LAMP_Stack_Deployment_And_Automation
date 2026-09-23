# Task 3 (Bonus) — Terraform + Ansible

This one provisions **real AWS resources**, so it can't be fully run from
WSL against "localhost" — you need actual AWS credentials and it will
incur (small) cost. What you *can* do on WSL:

- `terraform validate` / `terraform plan` — confirms the HCL is correct
  without touching AWS.
- `ansible-playbook --syntax-check` and `ansible-lint` — confirms the
  playbook is well-formed.
- If you want a fully local run: use **LocalStack** to emulate EC2/VPC,
  or just spin up a local Ubuntu VM/container and point the Ansible
  inventory at it manually to test the playbook logic end-to-end.

## Real AWS run
```bash
cd terraform
terraform init
terraform plan -var="key_name=<your-ec2-keypair-name>"
terraform apply -var="key_name=<your-ec2-keypair-name>"
```
This also writes `../ansible/inventory.ini` automatically with the new
instance's public IP.

Wait ~30s for the instance to finish booting and for SSH to come up, then:
```bash
cd ../ansible
ansible-galaxy collection install community.mysql
ansible-playbook -i inventory.ini playbook.yml
```

Visit `http://<public_ip>` — you should see the "Hello, World!" message.

## Teardown (don't leave this running / don't get billed)
```bash
cd ../terraform
terraform destroy -var="key_name=<your-ec2-keypair-name>"
```

## Testing the playbook fully locally (no AWS cost)
```bash
# spin up a plain Ubuntu 22.04 container/VM reachable over SSH, e.g. with
# vagrant, multipass, or a docker container running sshd — then:
ansible-playbook -i "localhost," -c local playbook.yml   # local connection, no SSH needed
```
