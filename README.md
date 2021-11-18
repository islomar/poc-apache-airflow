# Apache Airflow

- Playground for learning about Apache Airflow
- https://airflow.apache.org/
- Airflow was started in October 2014 by Maxime Beauchemin at Airbnb. It was open source from the very first commit and officially brought under the Airbnb GitHub and announced in June 2015.
- Airflow is a platform to programmatically author, schedule and monitor **workflows**.
- Use Airflow to author workflows as **Directed Acyclic Graphs (DAGs)** of tasks. The Airflow **scheduler** executes your **tasks** on an array of **workers** while following the specified **dependencies**. Rich command line utilities make performing complex surgeries on DAGs a snap. The rich user interface makes it easy to visualize pipelines running in production, monitor progress, and troubleshoot issues when needed.

## Principles

- **Dynamic**: Airflow pipelines are configuration as code (Python), allowing for dynamic pipeline generation. This allows for writing code that instantiates pipelines dynamically.
- **Extensible**: Easily define your own operators, executors and extend the library so that it fits the level of abstraction that suits your environment.
- **Elegant**: Airflow pipelines are lean and explicit. Parameterizing your scripts is built into the core of Airflow using the powerful Jinja templating engine.
- **Scalable**: Airflow has a modular architecture and uses a message queue to orchestrate an arbitrary number of workers. Airflow is ready to scale to infinity.


## Beyond the Horizon
- Airflow is **not** a data streaming solution. Tasks do not move data from one to the other (though tasks can exchange metadata!). Airflow is not in the Spark Streaming or Storm space, it is more comparable to Oozie or Azkaban.
- **Workflows are expected to be mostly static or slowly changing**. You can think of the structure of the tasks in your workflow as slightly more dynamic than a database structure would be. Airflow workflows are expected to look similar from a run to the next, this allows for clarity around unit of work and continuity.

## Tutorial
- An Airflow pipeline is just a Python script that happens to define an Airflow DAG object.
- **Tasks** are generated when instantiating operator objects. An object instantiated from an operator is called a task

## Run a script
- `./scripts/docker-python-run-script.sh ./dags/tutorial.py`

## Installation

- You need at leas 4GB in Docker Engine (ideally 8GB):
  - Check it running `scripts/check-enough-memory.sh`

## How to build a custom Docker image
- https://airflow.apache.org/docs/docker-stack/build.html

## How to start Airflow with Docker

- Run `docker-compose up`
- The webserver is available at: http://localhost:8080. The default account has the login airflow and the password airflow.

## Run CLI Commands

There are two ways:

1. With Docker
   - E.g. to run `airflow info`, run `docker-compose run airflow-worker airflow info`
2. Without Docker
   - `./official-tutorial/airflow.sh info`

## Resources

- [Apache Breeze](https://www.youtube.com/watch?v=4MCTXq-oF68)
- https://medium.com/ninjavan-tech/setting-up-a-complete-local-development-environment-for-airflow-docker-pycharm-and-tests-3577ddb4ca94
