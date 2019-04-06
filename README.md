# Introduction

This project was part of the Server [Side Swift with Kitura](https://store.raywenderlich.com/products/server-side-swift-with-kitura) book authored by David Okun & Chris Bailey

I read the book and followed along with the code. This particular project is a RESTful API written in Swift with the Kitura Framework. It also has a very basic web application included. It is exaclty what the title says, its an app to track your emotions with emoji's. There is also a field on the compainion iOS app & the web app that draws data for a "Fortune Cookie" from a place on the web called [yerkee](http://yerkee.com/api).

## Project Information

I'm not going to outline what this project consists of as the generated portion of this readme covers this pretty thoroughly.
I built this with Xcode 10.2 using Swift 5. The project is built and run in a docker container as this appears to be standard for Kitura generated projects. I used this project as a way to get more familiar with Server Side Swift as a whole and to get more familiar with Kitura specifically. 

## What I learned

I learned a great deal from this project. I was most impressed with the way Kitura handles some of the more mundane tasks in making API's. I like the OpenAPI module alot and like the way that the book seems to be written from a devops-centric perspective. The book outlines what some best practices are for building real world RESTful API's which I appreciate.

I learned about the OpenAPI standard and swagger and how to use the KituraOpenAPI package to leverage it for making documentation & code generation easy for client side projects, and for making testing API endpoints easy for developers.

Through the SwiftKueryORM & SwiftKueryPostgreSQL packages I learned how to persist the typical CRUD based operations from the API & companion iOS app for a postgreSQL server that was installed locally. It would be just as easy to use a docker container with postgres in it as well for persistence I think, I'm not sure why the authors chose to do it this way. I also learned how to make core complex database queries in the Kitura environment.

I learned about Kitura's various methods for authentication via middleware like Kitura-CredentialsHTTP & thier 3rd part packages for OAuth based authentication from Facebook, Google & Github. In the book and this project only focussed on the HTTP basic authentication.

I learned about how to add multi-user support to the API and the iOS app and how to manage the users to restrict their ability to make changes in the database to entries that were associated with them.

Using KituralStencil, which is Kitura's templating system for web-based frontends, I learned how to inject data from the database to routes for rendering on the web. I also learned more about authentication for a web app.

Moving along I learned how to make asyncronous calls with other API's which, as I mentioned above, for this project was adding "Fortune Cookie" messages to the different emoji cells through yerkee's API. Also i learned how to handle calls that don't return data in a resonable amount of time.

I then learned how to generate self-signed HTTPS certificates and apply them to the Kitura server. It was an exercise in demonstrating that for any real world application you need to make your app conform to the https protocol if you care at all about security. Kitura uses OpenSSl framework on Linux & Secure Transport on macOS for managing TLS. It does this through the BlueSSLService package. The way the project is right now the HTTPS protocol is **NOT** in use as later in the book we were instructed to revert this protocol back to HTTP.

The most interesting portion of the book for me came at the end when it went over taking this project "live" with Kubernetes. I learned how to sucessfully install Kubernetes to the Docker Desktop App I have installed locally & then installed Helm CLI through homebrew.

Using the helm cli to initialize the project creates a Kubernetes cluster component called Tiller. Tiller interacts with Kubernetes to install, upgrade, rollback, query & remove Kubernetes resources based on behalf of a Helm Chart. I then learned ho to deploy a PostgreSQL database with a Helm Chart pulled from the **stable** Helm Chart repository google has. I then deployed this project as a Kubernetes pod by changing the Helm Chart template that is generated with the Kitura projects. I learned that most of the templates that are generated contain configuration files for various components & features of Kubernetes. These don't really need to be touched as the configutrable variables in those files have been centralized into a `chart/<your project name>/values.yaml` file.

Environment variables for the API need to be configured in your `chart/<your app name>/bindings.yaml` as this file describes how to populate a number of environment variables in the environment of the app from **Kubernetes Secrets** which are config variables like usernames & passwords. After this is done and you ensure your app builds and runs correctly you can use `helm install --name <whatever> chart/<your app name>` to deploy your app as a Kubernetes pod. I learned to test whether the app is running successfully or not is as simple as using the KituraOpenAPI UI with the deployed instance once you have mapped the Kubernetes port back to your localhost.

I then learned how to scale a Kubernetes cluster by adding replicas (extremely easy - was really impressed). The book seemed to reccommend having 3 replicas at a minumim for triple redundancy when deploying for resilience & availability. The next thing I learned was how to add NGINX as what Kubernetes would call an **Ingress Controller**. It seems that Kubernetes has a simple built in load balancer that you can use, but in production, you would want to use something like NGINX that provides a high performance load balancer & web proxy. NGINX also was used to carry out TLS termination for the project so I learned how to generate a Kubernetes **secret** from the certificate I had in the directory. 

**The remainder of this README has been generated by the Kitura Application**

## Scaffolded Swift Kitura server application

This scaffolded application provides a starting point for creating Swift applications running on [Kitura](http://www.kitura.io/).

### Table of Contents
* [Requirements](#requirements)
* [Project contents](#project-contents)
* [Run](#run)
* [Configuration](#configuration)
* [Deploy to IBM Cloud](#deploy-to-ibm-cloud)
* [Service descriptions](#service-descriptions)
* [License](#license)
* [Generator](#generator)

#### Project contents
This application has been generated with the following capabilities and services, which are described in full in their respective sections below:

* [CloudEnvironment](#configuration)
* [Embedded metrics dashboard](#embedded-metrics-dashboard)
* [Docker files](#docker-files)
* [Iterative Development](#iterative-development)
* [IBM Cloud deployment](#ibm-cloud-deployment)


### Requirements
* [Swift 4](https://swift.org/download/)

### Run
To build and run the application:
1. `swift build`
1. `.build/debug/EmojiJournalServer`

#### Docker
A description of the files related to Docker can be found in the [Docker files](#docker-files) setion. To build the two docker images, run the following commands from the root directory of the project:
* `docker build -t myapp-run .`
* `docker build -t myapp-build -f Dockerfile-tools .`
You may customize the names of these images by specifying a different value after the `-t` option.

To compile the application using the tools docker image, run:
* `docker run -v $PWD:/swift-project -w /swift-project myapp-build /swift-utils/tools-utils.sh build release`

To run the application:
* `docker run -it -p 8080:8080 -v $PWD:/swift-project -w /swift-project myapp-run sh -c .build-ubuntu/release/EmojiJournalServer`


#### Kubernetes
To deploy your application to your Kubernetes cluster, run `helm install --name myapp .` in the `/chart/EmojiJournalServer` directory. You need to make sure you change the `repository` variable in your `chart/EmojiJournalServer/values.yaml` file points to the docker image containing your runnable application.

### Configuration
Your application configuration information for any services is stored in the `localdev-config.json` file in the `config` directory. This file is in the `.gitignore` to prevent sensitive information from being stored in git. The connection information for any configured services that you would like to access when running locally, such as username, password and hostname, is stored in this file.

The application uses the [CloudEnvironment package](https://github.com/IBM-Swift/CloudEnvironment) to read the connection and configuration information from the environment and this file. It uses `mappings.json`, found in the `config` directory, to communicate where the credentials can be found for each service.

If the application is running locally, it can connect to IBM Cloud services using unbound credentials read from this file. If you need to create unbound credentials you can do so from the IBM Cloud web console ([example](https://cloud.ibm.com/docs/services/Cloudant/tutorials/create_service.html#creating-a-service-instance)), or using the CloudFoundry CLI [`cf create-service-key` command](http://cli.cloudfoundry.org/en-US/cf/create-service-key.html).

When you push your application to IBM Cloud, these values are no longer used, instead the application automatically connects to bound services using environment variables.

#### Iterative Development
The `iterative-dev.sh` script is included in the root of the generated Swift project and allows for fast & easy iterations for the developer. Instead of stopping the running Kitura server to see new code changes, while the script is running, it will automatically detect changes in the project's **.swift** files and recompile the app accordingly.

To use iterative development:
* For native OS, execute the `./iterative-dev.sh` script from the root of the project.
* With docker, shell into the tools container mentioned above, and run the `./swift-project/iterative-dev.sh` script.  File system changes are detected using a low-tech infinitely looping poll mechanism, which works in both local OS/filesystem and across host OS->Docker container volume scenarios.

### Deploy to IBM Cloud
You can deploy your application to IBM Cloud using:
* the [CloudFoundry CLI](#cloudfoundry-cli)
* an [IBM Cloud toolchain](#ibm-cloud-toolchain)

#### CloudFoundry CLI
You can deploy the application using the IBM Cloud command-line:
1. Install the [IBM Cloud CLI](https://cloud.ibm.com/docs/cli/index.html)
1. Ensure all configured services have been provisioned
1. Run `ibmcloud app push` from the project root directory

The Cloud Foundry CLI will not provision the configured services for you, so you will need to do this manually using the IBM Cloud web console ([example](https://cloud.ibm.com/docs/services/Cloudant/tutorials/create_service.html#creating-a-service-instance)) or the CloudFoundry CLI (`cf create-service` command)[http://cli.cloudfoundry.org/en-US/cf/create-service.html]. The service names and types will need to match your [configuration](#configuration).

#### IBM Cloud toolchain
You can also set up a default IBM Cloud Toolchain to handle deploying your application to IBM Cloud. This is achieved by publishing your application to a publicly accessible github repository and using the "Create Toolchain" button below. In this case configured services will be automatically provisioned, once, during toolchain creation.

[![Create Toolchain](https://cloud.ibm.com/devops/graphics/create_toolchain_button.png)](https://cloud.ibm.com/devops/setup/deploy/)

### Service descriptions
#### Embedded metrics dashboard
This application uses the [SwiftMetrics package](https://github.com/RuntimeTools/SwiftMetrics) to gather application and system metrics.

These metrics can be viewed in an embedded dashboard on `/swiftmetrics-dash`. The dashboard displays various system and application metrics, including CPU, memory usage, HTTP response metrics and more.
#### Docker files
The application includes the following files for Docker support:
* `.dockerignore`
* `Dockerfile`
* `Dockerfile-tools`

The `.dockerignore` file contains the files/directories that should not be included in the built docker image. By default this file contains the `Dockerfile` and `Dockerfile-tools`. It can be modified as required.

The `Dockerfile` defines the specification of the default docker image for running the application. This image can be used to run the application.

The `Dockerfile-tools` is a docker specification file similar to the `Dockerfile`, except it includes the tools required for compiling the application. This image can be used to compile the application.

Details on how to build the docker images, compile and run the application within the docker image can be found in the [Run section](#run).
#### IBM Cloud deployment
Your application has a set of cloud deployment configuration files defined to support deploying your application to IBM Cloud:
* `manifest.yml`
* `.bluemix/toolchain.yml`
* `.bluemix/pipeline.yml`

The [`manifest.yml`](https://cloud.ibm.com/docs/cloud-foundry/deploy-apps.html#appmanifest) defines options which are passed to the Cloud Foundry `cf push` command during application deployment.

[IBM Cloud DevOps](https://cloud.ibm.com/docs/services/ContinuousDelivery/index.html#cd_getting_started) service provides toolchains as a set of tool integrations that support development, deployment, and operations tasks inside IBM Cloud, for both Cloud Foundry and Kubernetes applications. The ["Create Toolchain"](#deploy-to-ibm-cloud) button creates a DevOps toolchain and acts as a single-click deploy to IBM Cloud including provisioning all required services.


### License
All generated content is available for use and modification under the permissive MIT License (see `LICENSE` file), with the exception of SwaggerUI which is licensed under an Apache-2.0 license (see `NOTICES.txt` file).

### Generator
This project was generated with [generator-swiftserver](https://github.com/IBM-Swift/generator-swiftserver) v5.12.1.
