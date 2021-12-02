# Apache Airflow

- Playground for learning about Apache Airflow
- https://airflow.apache.org/
- Airflow was started in October 2014 by Maxime Beauchemin at Airbnb. It was open source from the very first commit and officially brought under the Airbnb GitHub and announced in June 2015.
- Airflow is a platform to programmatically author, schedule and monitor **workflows**.
- Use Airflow to author workflows as **Directed Acyclic Graphs (DAGs)** of **tasks**. The Airflow **scheduler** executes your **tasks** on an array of **workers** while following the specified **dependencies**. Rich command line utilities make performing complex surgeries on DAGs a snap. The rich user interface makes it easy to visualize pipelines running in production, monitor progress, and troubleshoot issues when needed.
- [Airflow 2.0](https://airflow.apache.org/blog/airflow-two-point-oh-is-here/) from December 2020

## Principles

- **Dynamic**: Airflow pipelines are configuration as code (Python), allowing for dynamic pipeline generation. This allows for writing code that instantiates pipelines dynamically.
- **Extensible**: Easily define your own operators, executors and extend the library so that it fits the level of abstraction that suits your environment.
- **Elegant**: Airflow pipelines are lean and explicit. Parameterizing your scripts is built into the core of Airflow using the powerful Jinja templating engine.
- **Scalable**: Airflow has a modular architecture and uses a message queue to orchestrate an arbitrary number of workers. Airflow is ready to scale to infinity.


## Beyond the Horizon
- Airflow is **not** a data streaming solution. Tasks do not move data from one to the other (though tasks can exchange metadata!). Airflow is not in the Spark Streaming or Storm space, it is more comparable to [Oozie](https://oozie.apache.org/) or [Azkaban](https://azkaban.github.io/).
- **Workflows are expected to be mostly static or slowly changing**. You can think of the structure of the tasks in your workflow as slightly more dynamic than a database structure would be. Airflow workflows are expected to look similar from a run to the next, this allows for clarity around unit of work and continuity.

## Tutorial
- **An Airflow pipeline is just a Python script that happens to define an Airflow DAG object**.
- **Tasks** are generated when instantiating operator objects. An object instantiated from an operator is called a task
- **CeleryExecutor** is one of the ways you can scale out the number of workers. For this to work, you need to setup a Celery backend (RabbitMQ, Redis, …) and change your airflow.cfg to point the executor parameter to CeleryExecutor and provide the related Celery settings.

## Architecture overview
- [Architecture Overview](https://airflow.apache.org/docs/apache-airflow/stable/concepts/overview.html)
  - Airflow is a platform that lets you build and run **workflows**. A workflow is represented as a **DAG** (a Directed Acyclic Graph), and contains individual pieces of work called **Tasks**, arranged with dependencies and data flows taken into account.
  - A DAG specifies the dependencies between Tasks, and the order in which to execute them and run retries; the Tasks themselves describe what to do, be it fetching data, running analysis, triggering other systems, or more.
- An Airflow installation generally consists of the following components:
  - An **executor**, which handles running tasks. In the default Airflow installation, this _runs everything inside the scheduler_, but most production-suitable executors actually push task execution out to **workers**.
  - A **scheduler**, which handles both triggering scheduled workflows, and submitting Tasks to the executor to run.
  - A **webserver**, which presents a handy user interface to inspect, trigger and debug the behaviour of DAGs and tasks.
  - A **folder of DAG files**, read by the scheduler and executor (and any workers the executor has)
  - A **metadata database**, used by the scheduler, executor and webserver to store state.
- Most executors will generally also introduce other components to let them talk to their workers - like a **task queue** - but you can still think of the executor and its workers as a single logical component in Airflow overall, handling the actual task execution.
- **Airflow itself is agnostic to what you’re running** - it will happily orchestrate and run anything, either with high-level support from one of our providers, or directly as a command using the shell or Python **Operators**.

### Workloads
- A DAG runs through a series of **Tasks**, and there are **three common types of task** you will see:
    - **Operators**, predefined tasks that you can string together quickly to build most parts of your DAGs.
    - **Sensors**, a special subclass of Operators which are entirely about waiting for an external event to happen.
    - A **TaskFlow-decorated @task**, which is a custom Python function packaged up as a **Task**.
- Internally, these are all actually subclasses of Airflow’s **BaseOperator**, and the concepts of Task and Operator are somewhat interchangeable, but it’s useful to think of them as separate concepts - essentially, **Operators and Sensors are templates, and when you call one in a DAG file, you’re making a Task**.

### Control Flow
- DAGs are designed to be run many times, and multiple runs of them can happen in parallel. DAGs are parameterized, always including an interval they are “running for” (the data interval), but with other optional parameters as well.
- Tasks have **dependencies** declared on each other. 
- By default, **a task will wait for all of its upstream tasks to succeed before it runs**, but this can be customized using features like Branching, LatestOnly, and Trigger Rules.
- To pass data between tasks you have two options:
  - **XComs (“Cross-communications”)**, a system where you can have tasks push and pull small bits of metadata.
  - **Uploading and downloading large files from a storage service** (either one you run, or part of a public cloud)
- Airflow sends out Tasks to run on Workers as space becomes available, so there’s no guarantee all the tasks in your DAG will run on the same worker or the same machine.

## DAGs
- https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html
- A DAG (Directed Acyclic Graph) is the core concept of Airflow, collecting Tasks together, organized with dependencies and relationships to say how they should run.
- It defines four Tasks - A, B, C, and D - and dictates the order in which they have to run, and which tasks depend on what others. It will also say how often to run the DAG
- The DAG itself doesn’t care about what is happening inside the tasks; it is merely concerned with how to execute them - the order to run them in, how many times to retry them, if they have timeouts, and so on.
- You can create one with a context manager, a constructor or a decorator.
- DAGs are nothing without Tasks to run, and those will usually either come in the form of either Operators, Sensors or TaskFlow.
- A Task/Operator does not usually live alone; it has dependencies on other tasks (those upstream of it), and other tasks depend on it (those downstream of it).
- The DAG decorator is new in v2.0

### Loading DAGs
- This means you can define multiple DAGs per Python file, or even spread one very complex DAG across multiple Python files using imports.
- When searching for DAGs inside the DAG_FOLDER, Airflow only considers Python files that contain the strings airflow and dag (case-insensitively) as an optimization.
- You can also provide an **.airflowignore** file inside your DAG_FOLDER, or any of its subfolders, which describes files for the loader to ignore. It covers the directory it’s in plus all subfolders underneath it, and should be one regular expression per line, with # indicating comments.
- Every time you run a DAG, you are creating a new instance of that DAG which Airflow calls a **DAG Run**. DAG Runs can run in parallel for the same DAG, and each has a defined **data interval**, which identifies the **period of data the tasks should operate on**.

### Dynamic DAGs
In general, **we advise you to try and keep the topology (the layout) of your DAG tasks relatively stable**; dynamic DAGs are usually better used for dynamically loading configuration options or changing operator options.

### TaskGroups
- A TaskGroup can be used to organize tasks into hierarchical groups in Graph view. It is useful for creating repeating patterns and cutting down visual clutter.
- Unlike SubDAGs, **TaskGroups are purely a UI grouping concept**. Tasks in TaskGroups live on the same original DAG, and honor all the DAG settings and pool configurations.

### SubDAGs
Sometimes, you will find that you are regularly adding exactly the same set of tasks to every DAG, or you want to group a lot of tasks into a single, logical unit. This is what SubDAGs are for.

### DAG & Task Documentation
It’s possible to add documentation or notes to your DAGs & task objects that are visible in the web interface (“Graph” & “Tree” for DAGs, “Task Instance Details” for tasks).

### DAG Visualization
If you want to see a visual representation of a DAG, you have two options:
  - You can load up the Airflow UI, navigate to your DAG, and select “Graph”
  - You can run `airflow dags show`, which renders it out as an image file

### Packaging DAGs
While simpler DAGs are usually only in a single Python file, it is not uncommon that more complex DAGs might be spread across multiple files and have dependencies that should be shipped with them (“vendored”).

## DAG dependencies
While dependencies between tasks in a DAG are explicitly defined through upstream and downstream relationships, dependencies between DAGs are a bit more complex. In general, there are two ways in which one DAG can depend on another:
  - triggering - TriggerDagRunOperator
  - waiting - ExternalTaskSensor

## Tasks
- Much in the same way that a DAG is instantiated into a **DAG Run** each time it runs, the tasks under a DAG are instantiated into **Task Instances**.
- The possible states for a Task Instance are... lots.
- When a DAG runs, it will create instances for each of these tasks that are upstream/downstream of each other, **but which all have the same data interval**.
- There may also be instances of the same task, but for different data intervals - from other runs of the same DAG. We call these **previous and next** - it is a different relationship to upstream and downstream!

### SLAs
- An SLA, or a Service Level Agreement, is an expectation for the maximum time a Task should take. If a task takes longer than this to run, then it visible in the “SLA Misses” part of the user interface, as well going out in an email of all tasks that missed their SLA.
- Tasks over their SLA are not cancelled, though - they are allowed to run to completion. If you want to cancel a task after a certain runtime is reached, you want Timeouts instead.
- You can also supply an **sla_miss_callback** that will be called when the SLA is missed if you want to run your own logic. The function signature of an sla_miss_callback requires 5 parameters.

### Zombie/Undead Tasks
No system runs perfectly, and task instances are expected to die once in a while. Airflow detects two kinds of task/process mismatch.

## Operators
- An Operator is conceptually a template for a predefined Task, that you can just define declaratively inside your DAG
- Airflow has a very extensive set of operators available, with some built-in to the core or pre-installed providers. 
- https://airflow.apache.org/docs/apache-airflow/stable/operators-and-hooks-ref.html
- https://airflow.apache.org/docs/apache-airflow-providers/operators-and-hooks-ref/index.html
- Inside Airflow’s code, we often mix the concepts of Tasks and Operators, and they are mostly interchangeable. However, when we talk about a Task, we mean the generic “unit of execution” of a DAG; when we talk about an Operator, we mean a reusable, pre-made Task template whose logic is all done for you and that just needs some arguments.
- **Jinja templating**: You can use Jinja templating with every parameter that is marked as “templated” in the documentation. Template substitution occurs just before the pre_execute function of your operator is called.

## Sensors
- Sensors are a special type of Operator that are designed to do exactly one thing - wait for something to occur. It can be time-based, or waiting for a file, or an external event, but all they do is wait until something happens, and then succeed so their downstream tasks can run.
- Because they are primarily idle, Sensors have three different modes of running so you can be a bit more **efficient** about using them
- [Smart Sensors](https://airflow.apache.org/docs/apache-airflow/stable/concepts/smart-sensors.html)

## TaskFlow (new in 2.0)
- If you write most of your DAGs using plain Python code rather than Operators, then the TaskFlow API will make it much easier to author clean DAGs without extra boilerplate, all using the @task decorator.
- TaskFlow takes care of moving inputs and outputs between your Tasks using XComs for you, as well as automatically calculating dependencies - when you call a TaskFlow function in your DAG file, rather than executing it, you will get an object representing the XCom for the result (an XComArg), that you can then use as inputs to downstream tasks or operators. 


## Executor
- Executors are the mechanism by which **task instances get run**. They have a common API and are “pluggable”, meaning you can swap executors based on your installation needs.
- Airflow can only have one executor configured at a time.
- Built-in executors are referred to by name (e.g. _KubernetesExecutor_).
- **Executor types**:
  - There are two types of executor - those that run tasks **locally** (inside the scheduler process), and those that run their tasks **remotely** (usually via a pool of workers).
  - Local Executors 
    - Debug Executor 
    - Local Executor
    - Sequential Executor
  - Remote Executors
    - Celery Executor
    - CeleryKubernetes Executor
    - Dask Executor
    - Kubernetes Executor
  
### DAG Runs
- A DAG Run is an object representing an instantiation of the DAG in time.
- Each DAG may or may not have a schedule, which informs how DAG Runs are created. 
- Data Interval: 
  - Each DAG run in Airflow has an assigned “data interval” that represents the **time range it operates in**. For a DAG scheduled with @daily, for example, each of its data interval would start at midnight of each day and end at midnight of the next day.
  - A DAG run is usually **scheduled after its associated data interval has ended**, to ensure the run is able to collect all the data within the time period. In other words, a run covering the data period of 2020-01-01 generally does not start to run until 2020-01-01 has ended, i.e. after 2020-01-02 00:00:00.
- There can be the case when you may want to run the DAG for a specified historical period e.g., A data filling DAG is created with start_date 2019-11-21, but another user requires the output data from a month ago i.e., 2019-10-21. This process is known as **Backfill**.

## Automatic reloading webserver
To enable automatic reloading of the webserver, when changes in a directory with plugins has been detected, you should set reload_on_plugin_change option in [webserver] section to True.

## Kubernetes
Apache Airflow aims to be a very Kubernetes-friendly project, and many users run Airflow from within a Kubernetes cluster in order to take advantage of the increased stability and autoscaling options that Kubernetes provides.

## Best Practices
- https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html
- You should treat tasks in Airflow equivalent to transactions in a database. This implies that you should never produce incomplete results from your tasks. An example is not to produce incomplete data in HDFS or S3 at the end of a task.
- Airflow can **retry a task if it fails**. Thus, **the tasks should produce the same outcome on every re-run**. Some of the ways you can avoid producing a different result -
  - Do not use INSERT during a task re-run, an INSERT statement might lead to duplicate rows in your database. **Replace it with UPSERT**.

## Use Cases
- https://airflow.apache.org/use-cases/
- Big Fish Games: https://airflow.apache.org/use-cases/big-fish-games/
  - The main challenge is the lack of standardized ETL workflow orchestration tools. 
  - Apache Airflow helps us programmatically control our workflows in Python by setting task dependencies and monitoring tasks within each DAG in a Web UI. 
  - Although we experimented with Apache Oozie for certain workflows, it did not handle failed jobs properly. For late data arrival, these tools are not flexible enough to enforce retry attempts for the job failures.
- Top level Python:
  - You should avoid writing the top level code which is not necessary to create Operators and build DAG relations between them. 
  - Specifically you should not run any database access, heavy computations and networking operations.
  - One of the important factors impacting DAG loading time, that might be overlooked by Python developers is that **top-level imports might take surprisingly a lot of time** and they can generate a lot of overhead and this can be easily avoided by converting them to local imports inside Python callables for example.
- **Airflow variables**
  - As mentioned in the previous chapter, Top level Python code. you should avoid using Airflow Variables at top level Python code of DAGs. You can use the Airflow Variables freely inside the execute() methods of the operators, but you can also pass the Airflow Variables to the existing operators via Jinja template, which will delay reading the value until the task execution.
- Triggering DAGs after changes
  - Avoid triggering DAGs immediately after changing them or any other accompanying files that you change in the DAG folder.
  - You should give the system sufficient time to process the changed files. This takes several steps. 
- Reducing DAG complexity
- Testing a DAG
  - https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html#testing-a-dag
  - DAG Loader Test: 
    - `python your-dag-file.py`
    - `time python airflow/example_dags/example_python_operator.py`
  - Unit tests
  - Self Checks
- Staging environments: **If possible, keep a staging environment to test the complete DAG run before deploying in the production.**
- Mocking variables and connections

## Run a script
- `./official-tutorial/scripts/docker-python-run-script.sh ./official-tutorial/dags/tutorial.py`

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

## Apache Airflow as a Service
- https://airflow.apache.org/ecosystem/#airflow-as-a-service

## Resources

- [Apache Breeze](https://www.youtube.com/watch?v=4MCTXq-oF68)
- https://medium.com/ninjavan-tech/setting-up-a-complete-local-development-environment-for-airflow-docker-pycharm-and-tests-3577ddb4ca94
