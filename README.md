<div align="center">
<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://avatars.githubusercontent.com/u/87377917?s=200&v=4" width="200" alt="404NFID Logo"></a></p>

 [![GitHub Stars](https://img.shields.io/github/stars/404NotFoundIndonesia/fixit-hub.svg)](https://github.com/404NotFoundIndonesia/fixit-hub/stargazers)
 [![GitHub license](https://img.shields.io/github/license/404NotFoundIndonesia/fixit-hub)](https://github.com/404NotFoundIndonesia/fixit-hub/blob/main/LICENSE)
 
</div>

# FixIT Hub

__FixIT Hub__ is a web-based application designed to streamline and manage the service and repair operations for HP and laptop devices. It provides a centralized platform for technicians, administrators, and customers to collaborate effectively, track service requests, and ensure timely resolution of device issues.

## Goals

- __Efficient Service Management__: Simplify the process of receiving, assigning, and completing service requests for HP and laptop devices.
- __Enhanced Customer Experience__: Provide customers with a user-friendly interface to submit service requests, track progress, and receive updates on device repairs.
- __Improved Technician Productivity__: Empower technicians with tools for efficient diagnosis, repair, and documentation of device issues.
- __Data Insights__: Generate reports and analytics to gain insights into service trends, technician performance, and customer satisfaction.

## Features

- User Roles
    - Admin: Manages technicians, service requests, and system settings.
    - Technician: Receives, processes, and completes service requests.
    - Customer: Submits service requests, tracks progress, and communicates with technicians.
- Customer-Facing Features
    - Service Request Submission: Customers can submit service requests by providing device details, issue descriptions, and contact information.
    - Service Tracking: Real-time status updates and notifications for customers to track the progress of their service requests.
    - Communication: Integrated messaging system for customers to communicate with assigned technicians regarding their device repairs.
- Technician-Facing Features
    - Service Dashboard: Overview of assigned service requests, priorities, and pending tasks.
    - Device Diagnosis: Tools and resources for diagnosing device issues, troubleshooting, and documenting repair steps.
    - Service Completion: Marking service requests as completed, adding repair notes, and updating customer status.
- Admin Dashboard
    - User Management: Add, edit, and manage technician accounts, customer profiles, and administrative settings.
    - Service Queue: Monitor and assign service requests to available technicians based on workload and expertise.
    - Analytics and Reporting: Generate reports on service performance, customer feedback, and device repair trends.

## Technical Specifications

- __Framework__: Ruby on Rails (Version 7.0.8)
- __Database__: PostgreSQL
- __Frontend__: HTML5, CSS3, JavaScript
- __Authentication__: Devise gem for user authentication

## Get Started

### Get the Source Code
Of course, you need to put this code on your computer first. There are two ways to do this: by __downloading the project zip file__ or __by using Git (recommended)__.

1. **Download the Project Zip**

    You can click on [this link](https://github.com/404NotFoundIndonesia/fixit-hub/archive/refs/heads/main.zip) to download the zip file of this project.

2. **Git Clone**

    Make sure that you have installed git. Open the directory where you want to place the source code in the terminal. Then, run the following command:
    ```shell
    git clone git@github.com:404NotFoundIndonesia/fixit-hub.git
    ```

### Install Dependencies

Run the following command to install all the dependencies (gems) required by the Rails project:

```shell
bundle install
```

### Setup Credentials

Go to the `config` directory and make sure there are files named `credentials.yml.enc` and `master.key`. If they are not present, run the following command:

```shell
rails credentials:edit
```

The command will open the decrypted `credentials.yml.enc` file. Once it's open, please enter the PostgreSQL credentials in the following format:

```yaml
postgre_username: ...
postgre_password: ...
postgre_hostname: ...
postgre_database: ...
```

Please replace the `...` symbols with your actual credentials.

### Setup Database

Run the following command to create the database, run migrations, and seed data:

```shell
rails db:setup
```

### How to Run

To start the Rails server, make sure the terminal is in the root directory of the project and use the following command:

```shell
rails server
```

Open `http://localhost:3000` in your browser to access FixIT Hub.

## License

__FixIT Hub__ is open-sourced software licensed under the [MIT license](https://github.com/404NotFoundIndonesia/fixit-hub?tab=MIT-1-ov-file).
