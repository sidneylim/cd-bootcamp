namespace: Integrations.demo.aos
flow:
  name: install_aos
  inputs:
    - username: "${get_sp('vm_username')}"
    - password:
        default: "${get_sp('vm_password')}"
        sensitive: true
    - tomcat_host: 10.0.46.33
    - account_service_host:
        required: false
    - db_host:
        required: false
  workflow:
    - install_postgres:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: "${get('db_host', tomcat_host)}"
            - username: '${username}'
            - password: '${password}'
            - script_url: "${get_sp('script_install_postgres')}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: install_java
    - install_java:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${tomcat_host}'
            - username: '${username}'
            - password: '${password}'
            - script_url: "${get_sp('script_install_java')}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: install_tomcat
    - install_tomcat:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${tomcat_host}'
            - username: '${username}'
            - password: '${password}'
            - script_url: "${get_sp('script_install_tomcat')}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_true
    - is_true:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: "${str(get('account_service_host', tomcat_host) != tomcat_host)}"
        navigate:
          - 'TRUE': install_java_as
          - 'FALSE': deploy_wars
    - install_java_as:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${account_service_host}'
            - username: '${username}'
            - password: '${password}'
            - script_url: "${get_sp('script_install_java')}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: install_tomcat_as
    - install_tomcat_as:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${account_service_host}'
            - username: '${username}'
            - password: '${password}'
            - script_url: "${get_sp('script_install_tomcat')}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: deploy_wars
    - deploy_wars:
        do:
          Integrations.demo.aos.sub_flows.deploy_wars:
            - tomcat_host: '${tomcat_host}'
            - account_service_host: "${get('account_service_host', tomcat_host)}"
            - db_host: "${get('db_host', tomcat_host)}"
            - username: '${username}'
            - password: '${password}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      install_postgres:
        x: 117
        y: 100
      install_java:
        x: 312
        y: 102
      install_tomcat:
        x: 502
        y: 100
      is_true:
        x: 352
        y: 252
      install_java_as:
        x: 153
        y: 392
      install_tomcat_as:
        x: 363
        y: 402
      deploy_wars:
        x: 540
        y: 392
        navigate:
          a544daf6-1277-c006-2c81-b6951a985f72:
            targetId: 122a21bd-b039-cfc3-d9d6-9734751d8bbd
            port: SUCCESS
    results:
      SUCCESS:
        122a21bd-b039-cfc3-d9d6-9734751d8bbd:
          x: 701
          y: 383
