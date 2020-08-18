# gcp-pcf-lab-setup

This Repository is setup to enable you to quickly setup a personal PCF Environment within your GCP Project.
This Setup is based off of the Setup Documentation:

* [Installing Pivotal Cloud Foundry on GCP] (http://docs.pivotal.io/pivotalcf/1-9/customizing/gcp.html)
* [Preparing to Deploy PCF on GCP] (http://docs.pivotal.io/pivotalcf/1-9/customizing/gcp-prepare-env.html)

Instead of following this documentation Verbatim, this setup guide skims out the fat with automation using Terraform and with excluding directions out of scope for just a testing environment.

# Setting up your Laptop:
* Install [HomeBrew] (http://brew.sh/) for MacOS
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

* You will then need the [gcloud cli](https://cloud.google.com/sdk/) cli, as well as the [terraform cli](https://www.terraform.io/intro/index.html):

```bash
brew update
brew install Caskroom/cask/google-cloud-sdk
brew install terraform
```

# What is Terraform?
Terraform will allow for us to document an infrastructure as a file. When initiating a terraform apply, Terraform will enable the proper API commands to GCP to create certain resources for us automatically.
* This is a great video on [What Terraform Is](https://www.youtube.com/watch?v=pKIFHtO2Y7I) (36:50)
* This is the [GSS Terraform Tech-Talk](https://drive.google.com/drive/u/0/folders/0B4fTwWz3dsHRVzdJVkN4SWtGaXM) (13:40)

In this Guide, Terraform will create for us the Network, Subnetwork, and Firewall rules.

As of now, You will need to still Manually do a few preparation steps until the full terraform preparation file is at version 1.0.


# Preparing The GCP Environment:
The below has the list of steps already done by Regional Admins, or to be done Manually, or via Terraform.

* [Preparing to Deploy PCF on GCP] (http://docs.pivotal.io/pivotalcf/1-9/customizing/gcp-prepare-env.html):

| Step: | Step Goal: | Scope: | Processed: |
| --- | --- | ---| ---|
| 1 | Create a GCP Network with Subnet | Individual | Terraformed |
| 2 | Create Firewall Rules for the Network | Individual | Terraformed |
| 3 | Set up an IAM Service Account | Project wide | Performed Once by Lab Admin |
| 4 | Create a Project-Wide SSH Keypair for Your Project | Project wide | Performed Once by Lab Admin |
| 5 | Enable Google Cloud APIs | Project wide | Performed Once by Lab Admin |

# Starting your Environment
1) Clone this repo to your local machine

* `git clone https://github.com/JaysonBH/pcf-gcp-terraform-2017.git`

2) Create a GCP Service Account Key & save to the `keys` directory

3) Edit the `0_variables` file with the below values
  * Replace `terraformed` with your username. This will persist throughout your lab and separates yours from others in the same region.
  * Confirm the name of the regional key file variable, `serice_acct_key`, is set to the value of the name of the file you downloaded earlier.
 
4) Run the below commands from the repository's root directory:
  * `terraform plan`
  * `terraform apply`

5) Check the project's GCP console section `Networking` -> `Networks`
  * You should see your username as the network name
  * This confirms that your terraform accessed and ran well!
  
6) Proceed with the documentation of [Deploying Ops Manager](http://docs.pivotal.io/pivotalcf/1-9/customizing/gcp-om-deploy.html)!
