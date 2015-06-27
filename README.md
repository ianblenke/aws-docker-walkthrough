= ianblenke/aws-docker-walkthrough

This is a README aggregated from the blog post markdown:

[AWS Docker Walkthrough with ElasticBeanstalk: Part 1](https://github.com/ianblenke/blog/tree/source/source/_posts/2015-06-27-aws-docker-walkthrough-with-elasticbeanstalk-part-1.markdown)

---

While deploying docker containers for immutable infrastructure on AWS ElasticBeanstalk,
I've learned a number of useful tricks that go beyond the official Amazon documentation.

This series of posts are an attempt to summarize some of the useful bits that may benefit
others facing the same challenges.

---

= Part 1 : Preparing a VPC for your ElasticBeanstalk environments

== Step 1 : Prepare your AWS development environment.

On OS/X, I install [homebrew](http://brew.sh), and then:

```bash
brew install awscli
```

On Windows, I install [chocolatey](https://chocolatey.org/) and then:

```bash
choco install awscli
```

As `awscli` is a python tool, we can alternatively use python `easyinstall` or `pip` directly:

```bash
pip install awscli
```

You may (or may not) need to prefix that pip install with `sudo`, depending. ie:

```bash
sudo pip install awscli awsebcli
```

These tools will detect if they are out of date when you run them. You may eventually get a message like:

```
Alert: An update to this CLI is available.
```

When this happens, you will likely want to either upgrade via homebrew:

```bash
brew update & brew upgrade awscli
```

or, more likely, upgrade using pip directly:

```bash
pip install --upgrade awscli
```

Again, you may (or may not) need to prefix that pip install with `sudo`, depending. ie:

```bash
sudo pip install --upgrade awscli
```

# Prepare your AWS environment variables

If you haven't already, [prepare for AWS cli access](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence).

You can now configure your `~/.aws/config` by running:

    aws configure

This will create a default configuration.

I've yet to work with any company with only one AWS account though. You will likely find that you need to support managing multiple AWS configuration profiles.

Here's an example `~/.aws/config` file with multiple profiles:

```
[default]
output = json
region = us-east-1

[profile aws-dev]
AWS_ACCESS_KEY_ID={REDACTED}
AWS_SECRET_ACCESS_KEY={REDACTED}

[profile aws-prod]
AWS_ACCESS_KEY_ID={REDACTED}
AWS_SECRET_ACCESS_KEY={REDACTED}
```

You can create this by running:

```bash
$ aws configure --profile aws-dev
AWS Access Key ID [REDACTED]: YOURACCESSKEY
AWS Secret Access Key [REDACTED]: YOURSECRETKEY
Default region name [None]: us-east-1
Default output format [None]: json
```

Getting in the habit of specifying `--profile aws-dev` is a bit of a reassurance that you're provisioning resources into the correct AWS account, and not sullying AWS cloud resources between VPC environments.

== Step 2: Preparing a VPC

Deploying anything to AWS EC2 Classic instances these days is to continue down the path of legacy maintenance.

For new ElasticBeanstalk deployments, a VPC should be used.

The easiest/best way to deploy a VPC is to use a [CloudFormation template](http://aws.amazon.com/cloudformation/aws-cloudformation-templates/). 

Below is a public gist of a VPC CloudFormation that I use for deployment:

{% gist 0a6a6f26d1ecaa0d81eb }

Here is an example CloudFormation parameters file for this template:

{% gist 9f4b8dd2b39c7d1c31ef }

To script the creation, updating, watching, and deleting of the CloudFormation VPC, I have this Makefile as well:

{% gist 55b740ff19825d621ef4 }

You can get these same files by cloning my github project, and ssuming you have a profile named `aws-dev` as mentioned above, you can even run `make` and have it create the `myapp-dev` VPC via CloudFormation:

    git clone https://github.com/ianblenke/aws-docker-walkthrough
    cd aws-docker-walkthrough
    make

You can run `make watch` to watch the CloudFormation events and wait for a `CREATE_COMPLETE` state.

When this is complete, you can see the CloudFormation outputs by running:

    make output

The output will look something like this:

{% gist 59715079304a6db7182c }

These CloudFormation Outputs list parameters that we will need to pass to the ElasticBeanstalk Environment creation during the next part of this walkthrough. 

Stay tuned...
