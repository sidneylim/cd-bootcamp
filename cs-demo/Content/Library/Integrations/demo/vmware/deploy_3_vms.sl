namespace: Integrations.demo.vmware
flow:
  name: deploy_3_vms
  workflow:
    - deploy_vm:
        loop:
          for: "prefix in 'sid-tm-','sid-as-','sid-db-'"
          do:
            Integrations.demo.vmware.deploy_vm:
              - prefix: '${prefix}'
          break:
            - FAILURE
          publish:
            - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
            - tomcat_host: '${str(branches_context[0]["ip"])}'
            - account_service_host: '${str(branches_context[1]["ip"])}'
            - db_host: '${str(branches_context[2]["ip"])}'
            - vm_name_list: '${str([str(x["vm_name"]) for x in branches_context])}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      deploy_vm:
        x: 134
        y: 81
        navigate:
          b3ebd7d5-898f-95f4-f077-eb3a53b68e04:
            targetId: d68573cd-9ad3-65e2-239e-e22c7bd95d4a
            port: SUCCESS
    results:
      SUCCESS:
        d68573cd-9ad3-65e2-239e-e22c7bd95d4a:
          x: 337
          y: 89
