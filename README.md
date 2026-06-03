Implementing a CI/CD Pipeline for GlobalMart ECommerce Platform

Overview of Project

Scenario:

GlobalMart, a leading e-commerce retailer with 300+ employees across 3
regions, has implemented a CI/CD pipeline for their product catalog service,
but is experiencing deployment failures and site outages. With an estimated
$25,000 in lost revenue per hour of downtime, they urgently need help
troubleshooting their pipeline issues. As their Cloud Support Engineer, you'll
identify and resolve the misconfiguration problems causing these failures.


Solution:

A fully automated CI/CD pipeline using AWS CodePipeline and CodeDeploy
with comprehensive monitoring capabilities. This project demonstrates how
AWS DevOps services work together and teaches essential troubleshooting
skills for common CI/CD misconfigurations.


About Project:

I recreated GlobalMart's CI/CD pipeline with the same issues their team faced,
then troubleshot using CloudWatch, CodePipeline logs, and the AWS Console. I
gained hands-on experience diagnosing and fixing real-world deployment
issues — just as a cloud support engineer would in a production environment.


Steps Performed:
1. Setting Up Environment: Prepared EC2 and GitHub repository
2. Configuring AWS Services: Set up IAM roles and deployment tools
3. Building CI/CD Pipeline: Configured CodeDeploy and CodePipeline
4. Troubleshooting Pipeline Issues: Fixed common deployment problems


Services Used:

• AWS CodePipeline: Fully managed continuous delivery service
• AWS CodeDeploy: Deployment service for EC2 instances
• Amazon EC2: Compute instances for hosting the e-commerce application
• AWS IAM: Identity and access management for AWS resources
• GitHub: Source code repository with webhook integration
• Amazon S3: Storage for deployment artifacts
• AWS Security Groups: Virtual firewalls controlling network traffic

This is the architectural diagram for the project:

<img width="1038" height="405" alt="image" src="https://github.com/user-attachments/assets/dcefec76-d7d6-476e-8304-22c0819a972c" />


Final Result:

A fully functional CI/CD pipeline for GlobalMart that demonstrates:

- Automated deployment of the React application
- Secure configuration of AWS deployment services
- Effective troubleshooting of common pipeline issues

https://lwfiles.mycourse.app/67ed1067042dc73b07d76036-public/f80e68cb98b645c376a9f418196ef290.gif  



Implementation:


Step 1 — EC2 Instance Setup
I launched an EC2 instance on Amazon Linux 2 with instance type t2.micro. I configured the instance with appropriate name tags, set up a key pair for SSH access, and enabled auto-assign public IP. I created a Security Group with SSH access restricted to my IP and HTTP and HTTPS open to the internet.
I added a User Data bootstrap script that automatically ran on instance launch and installed Node.js v16 and the CodeDeploy agent without any manual intervention. After the instance launched, I connected via SSH, manually installed and enabled Nginx as the web server, and verified the CodeDeploy agent was running and Node.js was correctly installed.

Step 2 — GitHub Repository Configuration
I cloned the GlobalMart catalog repository to my local machine, built the React application locally to verify it worked before deployment, and modified the .gitignore file to include the build folder so CodeDeploy could access the pre-built files. I force added the build folder to the repository and created the required deployment configuration files including appspec.yml, scripts/before_install.sh, and scripts/after_install.sh. I made the scripts executable and pushed all changes to the main branch.

Step 3 — IAM Role Configuration
I created two IAM roles. The first was GlobalMart-EC2-Role assigned to the EC2 instance with AmazonS3ReadOnlyAccess, AmazonSSMManagedInstanceCore, and AmazonEC2RoleforAWSCodeDeploy policies attached. This allowed the EC2 instance to access deployment artifacts from S3, be managed via Systems Manager, and receive deployments from CodeDeploy. The second was GlobalMart-CodeDeploy-Role assigned to the CodeDeploy service with the AWSCodeDeployRole policy, allowing CodeDeploy to manage deployments and interact with EC2.

Step 4 — CodeDeploy Setup

I created a CodeDeploy application named GlobalMart-Catalog with EC2/On-premises as the compute platform. I then created a deployment group named GlobalMart-Production, attached the GlobalMart-CodeDeploy-Role, targeted the EC2 instance using the Name tag GlobalMart-WebServer, and configured in-place deployment with CodeDeployDefault.AllAtOnce as the deployment configuration.

Step 5 — CodePipeline Configuration

I created a pipeline named GlobalMart-Pipeline with queued execution mode to ensure only one pipeline execution runs at a time. I connected GitHub as the source provider via OAuth, selected the globalmart-catalog repository and main branch, configured a build stage with npm install and npm run build commands, and set AWS CodeDeploy as the deploy provider pointing to the GlobalMart-Catalog application and GlobalMart-Production deployment group. I attached the AWSCodeDeployFullAccess policy to the pipeline service role and created the pipeline. The first execution ran successfully, deploying the React application to the EC2 instance and confirming the end-to-end pipeline was operational.



Troubleshooting:

This section documents four real-world pipeline failures I intentionally introduced and then diagnosed and resolved. Each issue mirrors common misconfiguration problems found in production CI/CD environments.


Issue 1 — GitHub Webhook Connection

I deleted the webhook that CodePipeline had created in the GitHub repository. This broke the automatic communication link between GitHub and CodePipeline, meaning code pushes no longer triggered the pipeline.

The symptom was that after committing and pushing a change, no new pipeline execution appeared in CodePipeline history. To diagnose, I went to the GitHub repository Settings and confirmed the webhook was missing, which confirmed the root cause.

To resolve it, I edited the pipeline source stage, added a new action with GitHub via OAuth as the provider, reconnected to GitHub, selected the repository and branch, and saved. This automatically recreated the webhook. I verified the fix by pushing a new commit and confirming the pipeline triggered automatically.




Issue 2 — IAM Permissions Problem


I removed the AWSCodeDeployRole policy from the GlobalMart-CodeDeploy-Role and replaced it with the more restrictive AmazonS3ReadOnlyAccess policy. This prevented CodeDeploy from performing its core functions.

The symptom was that the pipeline failed specifically at the Deploy stage while Source and Build completed successfully. CodeDeploy logs showed a clear IAM permission error. To diagnose, I reviewed the deployment in CodeDeploy, identified the permission error message, went to IAM, and confirmed the role was missing the correct policy.

To resolve it, I removed AmazonS3ReadOnlyAccess, attached AWSCodeDeployRole back to GlobalMart-CodeDeploy-Role, triggered a release change, and confirmed the deployment completed successfully.



Issue 3 — Security Group Configuration

I deleted the inbound rule allowing HTTP traffic on port 80 from the Security Group attached to the EC2 instance. This prevented all web traffic from reaching the application.

The symptom was that the EC2 instance was running and SSH still worked, but accessing the application in a browser resulted in a connection timeout. To diagnose, I checked the Security Group inbound rules on the EC2 Security tab and confirmed the HTTP rule was missing.

To resolve it, I edited the inbound rules, added HTTP on port 80 from 0.0.0.0/0, saved the rules, and confirmed the application was accessible in the browser.



Issue 4 — CodeDeploy Agent

I stopped the CodeDeploy agent on the EC2 instance by running sudo service codedeploy-agent stop. Without a running agent, CodeDeploy cannot communicate with the instance to execute deployments.

The symptom was that the deployment timed out and CodeDeploy reported the agent was not responding. To diagnose, I SSH'd into the instance and ran sudo service codedeploy-agent status, which confirmed the agent was stopped.

To resolve it, I started the agent with sudo service codedeploy-agent start, verified it was running, and configured it to auto-restart on reboot using sudo chkconfig codedeploy-agent on. I then triggered a release change and confirmed the deployment completed successfully.




Key Learnings:

Working through this project gave me practical experience in how AWS DevOps services connect and depend on each other. The most valuable insight was understanding that IAM misconfigurations are the most common and least obvious source of deployment failures. A pipeline can pass the Source and Build stages cleanly and still fail at Deploy purely because of a missing policy, which requires knowing where to look in the logs to identify it.

I also learned that troubleshooting CI/CD pipelines requires a methodical approach — identifying the failure point first, reading the exact error message in the logs, verifying the configuration of the relevant service, testing the fix, and documenting the solution. Skipping any of these steps leads to guessing rather than diagnosing.

The experience of intentionally breaking and fixing each component gave me a much deeper understanding of how the pipeline works than simply following a setup guide would have.



Tech Stack:

AWS CodePipeline, AWS CodeDeploy, Amazon EC2, AWS IAM, Amazon S3, Amazon CloudWatch, AWS Security Groups, GitHub, Nginx, Node.js, React, Amazon Linux 2, Bash


