namespace: Integrations.demo.aos.sub_flows
flow:
  name: deploy_wars
  inputs:
    - tomcat_host: 10.0.46.33
    - account_service_host: 10.0.46.33
    - db_host: 10.0.46.33
    - username: root
    - password: admin@123
    - url: "${get_sp('war_repo_root_url')}"
  workflow:
    - deploy_account_service:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${account_service_host}'
            - username: "${get_sp('vm_username')}"
            - password: "${get_sp('vm_password')}"
            - artifact_url: "${url+'accountservice/target/accountservice.war'}"
            - script_url: "${get_sp('script_deploy_war')}"
            - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: deploy_tm_wars
    - deploy_tm_wars:
        loop:
          for: "war in 'catalog','MasterCredit','order','ROOT','ShipEx','SafePay'"
          do:
            Integrations.demo.aos.sub_flows.initialize_artifact:
              - host: '${tomcat_host}'
              - username: "${get_sp('vm_username')}"
              - password: "${get_sp('vm_password')}"
              - artifact_url: "${url+war.lower()+'/target/'+war+'.war'}"
              - script_url: "${get_sp('script_deploy_war')}"
              - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      deploy_account_service:
        x: 138
        y: 89
      deploy_tm_wars:
        x: 347
        y: 81
        navigate:
          aa510e3c-ae09-cd8e-20b3-e83e1a1b16d5:
            targetId: b42b7981-ac10-1421-42b8-76e0d29079f6
            port: SUCCESS
    results:
      SUCCESS:
        b42b7981-ac10-1421-42b8-76e0d29079f6:
          x: 515
          y: 84
