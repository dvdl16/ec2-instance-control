# EC2 Instance Control Script

This script uses AWS CLI to provide a basic but interactive way to stop/start EC2 instances you have access to.

## Requirements

- This script requires `jq` to be installed. On Ubuntu, you can install this with `sudo apt install jq`.
- This script also requires a valid AWS CLI Credentials file: `~/.aws/credentials`

## Usage

To run the script, mark it as executable and run it:

```bash
chmod +x ./ec2-instance-control.sh
./ec2-instance-control.sh
```