namespace: Integrations.demo.aos.tools
flow:
  name: delete_file
  inputs:
    - host: 10.0.46.33
    - username: root
    - password: admin@123
    - filename: deploy_war.sh
  workflow:
    - delete_file:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && rm -f '+filename}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      delete_file:
        x: 169
        y: 255
        navigate:
          850f8a4a-a975-f680-d3f0-76eed8bfb0af:
            targetId: 29fd824b-c87c-2598-5905-f0b995c65bd2
            port: SUCCESS
    results:
      SUCCESS:
        29fd824b-c87c-2598-5905-f0b995c65bd2:
          x: 421
          y: 242
