namespace: Integrations.demo.aos.sub_flows
flow:
  name: initialize_artifact
  inputs:
    - host: 10.0.46.33
    - username: root
    - password: admin@123
    - artifact_url:
        required: false
    - script_url: 'http://vmdocker.hcm.demo.local:36980/job/AOS-repo/ws/deploy_war.sh'
    - parameters:
        required: false
  workflow:
    - is_artifact_given:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${artifact_url}'
        navigate:
          - SUCCESS: copy_script
          - FAILURE: copy_artifact
    - copy_artifact:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - url: '${artifact_url}'
        publish:
          - artifact_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: copy_script
    - copy_script:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - url: '${script_url}'
        publish:
          - script_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: execute_script
    - execute_script:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && chmod 755 '+script_name+' && sh '+script_name+' '+get('artifact_name', '')+' '+get('parameters', '')+' > '+script_name+'.log'}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - command_return_code
        navigate:
          - SUCCESS: delete_file
          - FAILURE: delete_file
    - delete_file:
        do:
          Integrations.demo.aos.tools.delete_file:
            - filename: '${script_name}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: has_failed
    - has_failed:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: "${str(command_return_code == '0')}"
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_artifact_given:
        x: 389
        y: 57
      copy_artifact:
        x: 116
        y: 240
      copy_script:
        x: 484
        y: 235
      execute_script:
        x: 117
        y: 393
      delete_file:
        x: 331
        y: 394
      has_failed:
        x: 541
        y: 395
        navigate:
          1d94ae47-877b-793e-61bf-688720a65131:
            targetId: 91a63ceb-7c3c-0ffc-5da0-0e1fa9ec69e6
            port: 'FALSE'
          48252aaf-3e0b-3047-282d-4d25bb8a2b29:
            targetId: e798645f-d99a-d447-4462-483725f866a6
            port: 'TRUE'
    results:
      FAILURE:
        91a63ceb-7c3c-0ffc-5da0-0e1fa9ec69e6:
          x: 663
          y: 485
      SUCCESS:
        e798645f-d99a-d447-4462-483725f866a6:
          x: 666
          y: 327
